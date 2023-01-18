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
	var/max_amount = 210
	var/current_amount = 0
	var/active = FALSE
	var/mob/listeningTo
	var/obj/item/stack/cable_coil/cable
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

/obj/item/rwd/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, wield_callback = CALLBACK(src, PROC_REF(on_wield)), unwield_callback = CALLBACK(src, PROC_REF(on_unwield)))
	update_appearance()

/obj/item/rwd/examine(mob/user)
	. = ..()
	. += "It has [current_amount] pieces remaining"
	. += "Right click on it to dispense a custom amount of cable"

/obj/item/rwd/update_icon_state()
	switch(current_amount)
		if(61 to INFINITY)
			icon_state = "rwd-30"
			inhand_icon_state = "rwd"
		if(31 to 60)
			icon_state = "rwd-20"
			inhand_icon_state = "rwd"
		if(1 to 30)
			icon_state = "rwd-10"
			inhand_icon_state = "rwd"
		else
			icon_state = "rcl-0"
			inhand_icon_state = "rcl-0"
	return ..()

/obj/item/rwd/attack_self_secondary(mob/user, modifiers)
	if(current_amount == 0)
		balloon_alert(user, "nothing to dispense")
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
		the_cable.use(consumed)
		amount_to_consume -= consumed
	current_amount -= amount

	//spawn the cable. if it merged with the stak below then you pick that up else put it in the user's hand
	var/obj/item/stack/cable_coil/new_cable = new(user.drop_location(), amount)
	if(QDELETED(new_cable))
		balloon_alert(user,"merged with stack below!")
	else
		user.put_in_active_hand(new_cable)
	//update
	update_appearance()

/// triggered on wield of two handed item
/obj/item/rwd/proc/on_wield(obj/item/source, mob/user)
	active = TRUE

/// triggered on unwield of two handed item
/obj/item/rwd/proc/on_unwield(obj/item/source, mob/user)
	active = FALSE

/obj/item/rwd/pickup(mob/to_hook)
	..()
	if(listeningTo == to_hook)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(to_hook, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	listeningTo = to_hook

/obj/item/rwd/dropped(mob/wearer)
	..()
	UnregisterSignal(wearer, COMSIG_MOVABLE_MOVED)
	listeningTo = null

/// for inserting cable into the rwd
/obj/item/rwd/attackby(obj/item/attacking_item, mob/living/user)
	if(!istype(attacking_item, /obj/item/stack/cable_coil))
		return
	var/obj/item/stack/cable_coil/cable = attacking_item
	add_cable(user, cable)

/// insert cable into the rwd
/obj/item/rwd/proc/add_cable(mob/user, obj/item/stack/cable_coil/cable)
	if(current_amount == max_amount)
		balloon_alert(user, "device is full")
		return

	var/insert_amount = min(cable.amount, max_amount - current_amount)
	if(cable.use(insert_amount))
		balloon_alert(user, "inserted [insert_amount] cable")
		current_amount += insert_amount
		update_appearance()

/// get cached reference of cable which gets used over time
/obj/item/rwd/proc/get_cable()
	if(!cable || QDELETED(cable))
		var/create_amount = min(30, current_amount)
		if(!create_amount)
			return null
		cable = new/obj/item/stack/cable_coil(src, create_amount)
	return cable

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
	 * - there is no already cable on the turf
	 */
	if(active && the_turf.can_have_cabling() && the_turf.can_lay_cable() && !locate(/obj/structure/cable, the_turf))
		var/obj/item/stack/cable_coil/coil = get_cable()
		if(!coil)
			return
		var/obj/structure/cable/cable = coil.place_turf(the_turf, user)
		if(cable && !QDELETED(cable)) // if user does not have insulated gloves the cable can deconstruct from shock i.e. get deleted
			current_amount -= 1
			update_appearance()

	// pick up any stray cable pieces lying on the floor
	for(var/obj/item/stack/cable_coil/cable_piece in the_turf)
		add_cable(user, cable_piece)

/obj/item/rwd/loaded
	icon_state = "rwd-30"
	current_amount = 210

/obj/item/rwd/admin
	name = "admin RWD"
	max_amount = INFINITY
	current_amount = INFINITY


