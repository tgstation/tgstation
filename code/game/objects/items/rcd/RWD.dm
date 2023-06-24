/obj/item/rwd
	name = "rapid wiring device"
	desc = "A device used to rapidly lay cable & pick up stray cable pieces laying around."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"
	inhand_icon_state = "rcl-0"
	opacity = FALSE
	force = 5 //Plastic is soft
	throwforce = 5
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

	/// maximum amount of cable this device can hold
	var/max_amount = 210
	/// current amount of cable in the machine
	var/current_amount = 0
	/// are we dual wielding this machine
	var/active = FALSE
	/// the player currently holding this device.
	var/mob/listeningTo
	/// what layer of cable are we working with
	var/cable_layer = CABLE_LAYER_2
	/// cached reference of the cable used in the device
	var/obj/item/stack/cable_coil/cable
	/// radial menu to select cable layer
	var/list/radial_menu = null

/obj/item/rwd/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, wield_callback = CALLBACK(src, PROC_REF(on_wield)), unwield_callback = CALLBACK(src, PROC_REF(on_unwield)))
	update_appearance(UPDATE_ICON_STATE)

/obj/item/rwd/Destroy(force)
	. = ..()
	if(!QDELETED(cable))
		QDEL_NULL(cable)

/obj/item/rwd/examine(mob/user)
	. = ..()
	. += "Dual wield & walk over floors to lay cable."
	. += "It has [current_amount] pieces remaining."
	. += "Right click on it to dispense a custom amount of cable."
	. += "Alt click to change cable layer."

/obj/item/rwd/update_icon_state()
	switch(current_amount)
		if(61 to INFINITY)
			icon_state = "rwd-30-layer[cable_layer]"
			inhand_icon_state = "rwd-layer[cable_layer]"
		if(31 to 60)
			icon_state = "rwd-20-layer[cable_layer]"
			inhand_icon_state = "rwd-layer[cable_layer]"
		if(1 to 30)
			icon_state = "rwd-10-layer[cable_layer]"
			inhand_icon_state = "rwd-layer[cable_layer]"
		else
			icon_state = "rcl-0"
			inhand_icon_state = "rcl-0"
	return ..()

/obj/item/rwd/attack_self_secondary(mob/user, modifiers)
	if(current_amount <= 0)
		balloon_alert(user, "nothing to dispense!")
		return

	var/amount = tgui_input_number(user = user, message = "Enter amount to dispense", title = "Custom cable", default = 0, max_value = min(30, current_amount), min_value = min(1, current_amount), timeout = 0, round_value = TRUE)
	if(isnull(amount) || amount > current_amount)
		return

	/**
	 * if the user say requested 22 pieces but the cached cable reference has only 5 pieces then it wont be an exact multiple
	 * So the while loop runs twice i.e 1st iteration it uses 5 pieces and it has 22-5= 17 pieces left to consume from this device
	 * Finally 2nd iteration it creates a new cached cable & consumes the remaining 17 pieces and now the device will use the cached cable containing 30-17 = 30 pieces.
	 */
	var/amount_to_consume = amount
	while(amount_to_consume)
		var/obj/item/stack/cable_coil/the_cable = get_cable()
		if(!the_cable)
			return
		var/consumed = min(amount_to_consume, the_cable.amount)
		if(!the_cable.use(consumed))
			return
		delta_cable(consumed, decrement = TRUE)
		amount_to_consume -= consumed

	//spawn the cable. if it merged with the stak below then you pick that up else put it in the user's hand
	var/obj/item/stack/cable_coil/new_cable = new(user.drop_location(), amount)
	if(QDELETED(new_cable))
		balloon_alert(user, "merged with stack below!")
	else
		user.put_in_active_hand(modify_cable(new_cable))

	update_appearance(UPDATE_ICON_STATE)

/// triggered on wield of two handed item
/obj/item/rwd/proc/on_wield(obj/item/source, mob/user)
	active = TRUE

/// triggered on unwield of two handed item
/obj/item/rwd/proc/on_unwield(obj/item/source, mob/user)
	active = FALSE

/obj/item/rwd/pickup(mob/to_hook)
	. = ..()
	if(listeningTo == to_hook)
		return .
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(to_hook, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	listeningTo = to_hook

/obj/item/rwd/dropped(mob/wearer)
	. = ..()
	UnregisterSignal(wearer, COMSIG_MOVABLE_MOVED)
	listeningTo = null

/// for inserting cable into the rwd
/obj/item/rwd/attackby(obj/item/attacking_item, mob/living/user)
	if(!istype(attacking_item, /obj/item/stack/cable_coil))
		return
	var/obj/item/stack/cable_coil/cable = attacking_item
	add_cable(user, cable)
	return TRUE

/obj/item/rwd/AltClick(mob/user)
	. = ..()
	if(!radial_menu)
		radial_menu = list(
			"Layer 1" = image(icon = 'icons/hud/radial.dmi', icon_state = "coil-red"),
			"Layer 2" = image(icon = 'icons/hud/radial.dmi', icon_state = "coil-yellow"),
			"Layer 3" = image(icon = 'icons/hud/radial.dmi', icon_state = "coil-blue"),
		)

	var/layer_result = show_radial_menu(user, src, radial_menu, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(layer_result)
		if("Layer 1")
			cable_layer = CABLE_LAYER_1
		if("Layer 2")
			cable_layer = CABLE_LAYER_2
		if("Layer 3")
			cable_layer = CABLE_LAYER_3
	update_appearance(UPDATE_ICON_STATE)

/obj/item/rwd/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/// insert cable into the rwd
/obj/item/rwd/proc/add_cable(mob/user, obj/item/stack/cable_coil/cable)
	if(current_amount == max_amount)
		balloon_alert(user, "device is full!")
		return

	var/insert_amount = min(cable.amount, max_amount - current_amount)
	if(!cable.use(insert_amount))
		return

	delta_cable(insert_amount, decrement = FALSE)
	update_appearance(UPDATE_ICON_STATE)
	balloon_alert(user, "inserted [insert_amount] cable")

/// modify cable properties according to its layer
/obj/item/rwd/proc/modify_cable(obj/item/stack/cable_coil/target_cable)
	switch(cable_layer)
		if(CABLE_LAYER_1)
			target_cable.set_cable_color(CABLE_COLOR_RED)
			target_cable.target_type = /obj/structure/cable/layer1
			target_cable.target_layer = CABLE_LAYER_1
		if(CABLE_LAYER_2)
			target_cable.set_cable_color(CABLE_COLOR_YELLOW)
			target_cable.target_type = /obj/structure/cable
			target_cable.target_layer = CABLE_LAYER_2
		else
			target_cable.set_cable_color(CABLE_COLOR_BLUE)
			target_cable.target_type = /obj/structure/cable/layer3
			target_cable.target_layer = CABLE_LAYER_3
	return target_cable

/// get cached reference of cable which gets used over time
/obj/item/rwd/proc/get_cable()
	if(QDELETED(cable))
		var/create_amount = min(30, current_amount)
		if(create_amount <= 0)
			return null
		cable = new/obj/item/stack/cable_coil(src, create_amount)
	return modify_cable(cable)

/// check if the turf has the same cable layer as this design. If it does don't put cable here
/obj/item/rwd/proc/cable_allowed_here(turf/the_turf)
	// infer our intended cable design from the layer
	var/obj/structure/cable/design_type
	switch(cable_layer)
		if(CABLE_LAYER_1)
			design_type = /obj/structure/cable/layer1
		if(CABLE_LAYER_2)
			design_type = /obj/structure/cable
		else
			design_type = /obj/structure/cable/layer3

	for(var/obj/structure/cable/cable as anything in the_turf)
		// cable layer on the turf is the same as our intended design layer so nope
		if(cable.type == design_type)
			return FALSE

	return TRUE

/// extra safe modify just to be sure
/obj/item/rwd/proc/delta_cable(amount, decrement)
	if(decrement)
		current_amount -= amount
	else
		current_amount += amount
	current_amount = clamp(current_amount, 0, max_amount)

/// stuff to do when moving
/obj/item/rwd/proc/on_move(mob/user)
	SIGNAL_HANDLER

	if(!isturf(user.loc))
		return
	var/turf/the_turf = user.loc
	/**
	 * Lay cable only if
	 * - device is active
	 * - the turf can hold cable
	 * - there is no cable on the turf or there is cable on the turf but its not the same layer we are gonna put on the turf
	 */
	if(active && the_turf.can_have_cabling() && the_turf.can_lay_cable() && cable_allowed_here(the_turf))
		var/obj/item/stack/cable_coil/coil = get_cable()
		if(!coil)
			return

		coil.place_turf(the_turf, user)
		delta_cable(1, decrement = TRUE)
		update_appearance(UPDATE_ICON_STATE)

	// pick up any stray cable pieces lying on the floor
	for(var/obj/item/stack/cable_coil/cable_piece in the_turf)
		add_cable(user, cable_piece)

/obj/item/rwd/loaded
	icon_state = "rwd-30-layer2"
	current_amount = 210

/obj/item/rwd/admin
	name = "admin RWD"
	max_amount = INFINITY
	current_amount = INFINITY


