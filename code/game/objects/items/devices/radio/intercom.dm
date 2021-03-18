/obj/item/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	dog_fashion = null
	unscrewed = FALSE

/obj/item/radio/intercom/unscrewed
	unscrewed = TRUE

/obj/item/radio/intercom/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)
	var/area/current_area = get_area(src)
	if(!current_area)
		return
	RegisterSignal(current_area, COMSIG_AREA_POWER_CHANGE, .proc/AreaPowerCheck)

/obj/item/radio/intercom/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use [MODE_TOKEN_INTERCOM] when nearby to speak into it.</span>"
	if(!unscrewed)
		. += "<span class='notice'>It's <b>screwed</b> and secured to the wall.</span>"
	else
		. += "<span class='notice'>It's <i>unscrewed</i> from the wall, and can be <b>detached</b>.</span>"

/obj/item/radio/intercom/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(unscrewed)
			user.visible_message("<span class='notice'>[user] starts tightening [src]'s screws...</span>", "<span class='notice'>You start screwing in [src]...</span>")
			if(I.use_tool(src, user, 30, volume=50))
				user.visible_message("<span class='notice'>[user] tightens [src]'s screws!</span>", "<span class='notice'>You tighten [src]'s screws.</span>")
				unscrewed = FALSE
		else
			user.visible_message("<span class='notice'>[user] starts loosening [src]'s screws...</span>", "<span class='notice'>You start unscrewing [src]...</span>")
			if(I.use_tool(src, user, 40, volume=50))
				user.visible_message("<span class='notice'>[user] loosens [src]'s screws!</span>", "<span class='notice'>You unscrew [src], loosening it from the wall.</span>")
				unscrewed = TRUE
		return
	else if(I.tool_behaviour == TOOL_WRENCH)
		if(!unscrewed)
			to_chat(user, "<span class='warning'>You need to unscrew [src] from the wall first!</span>")
			return
		user.visible_message("<span class='notice'>[user] starts unsecuring [src]...</span>", "<span class='notice'>You start unsecuring [src]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 80))
			user.visible_message("<span class='notice'>[user] unsecures [src]!</span>", "<span class='notice'>You detach [src] from the wall.</span>")
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			new/obj/item/wallframe/intercom(get_turf(src))
			qdel(src)
		return
	return ..()

/**
 * Override attack_tk_grab instead of attack_tk because we actually want attack_tk's
 * functionality. What we DON'T want is attack_tk_grab attempting to pick up the
 * intercom as if it was an ordinary item.
 */
/obj/item/radio/intercom/attack_tk_grab(mob/user)
	interact(user)
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/item/radio/intercom/attack_ai(mob/user)
	interact(user)

/obj/item/radio/intercom/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	interact(user)

/obj/item/radio/intercom/ui_state(mob/user)
	return GLOB.default_state

/obj/item/radio/intercom/can_receive(freq, level)
	if(!on)
		return FALSE
	if(wires.is_cut(WIRE_RX))
		return FALSE
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return FALSE
	if(!listening)
		return FALSE
	if(freq == FREQ_SYNDICATE)
		if(!(syndie))
			return FALSE//Prevents broadcast of messages over devices lacking the encryption

	return TRUE


/obj/item/radio/intercom/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, list/message_mods = list())
	if(message_mods[RADIO_EXTENSION] == MODE_INTERCOM)
		return  // Avoid hearing the same thing twice
	return ..()

/obj/item/radio/intercom/emp_act(severity)
	. = ..() // Parent call here will set `on` to FALSE.
	update_appearance()

/obj/item/radio/intercom/end_emp_effect(curremp)
	. = ..()
	AreaPowerCheck() // Make sure the area/local APC is powered first before we actually turn back on.

/obj/item/radio/intercom/update_icon_state()
	icon_state = on ? initial(icon_state) : "intercom-p"
	return ..()

/**
 * Proc called whenever the intercom's area loses or gains power. Responsible for setting the `on` variable and calling `update_icon()`.
 *
 * Normally called after the intercom's area recieves the `COMSIG_AREA_POWER_CHANGE` signal, but it can also be called directly.
 * Arguments:
 * * source - the area that just had a power change.
 */
/obj/item/radio/intercom/proc/AreaPowerCheck(datum/source)
	var/area/current_area = get_area(src)
	if(!current_area)
		on = FALSE
	else
		on = current_area.powered(AREA_USAGE_EQUIP) // set "on" to the equipment power status of our area.
	update_appearance()

/obj/item/radio/intercom/add_blood_DNA(list/blood_dna)
	return FALSE

//Created through the autolathe or through deconstructing intercoms. Can be applied to wall to make a new intercom on it!
/obj/item/wallframe/intercom
	name = "intercom frame"
	desc = "A ready-to-go intercom. Just slap it on a wall and screw it in!"
	icon_state = "intercom"
	result_path = /obj/item/radio/intercom/unscrewed
	pixel_shift = 29
	inverse = TRUE
	custom_materials = list(/datum/material/iron = 75, /datum/material/glass = 25)

/obj/item/radio/intercom/chapel
	name = "Confessional intercom"
	anonymize = TRUE
	frequency = 1481
	broadcasting = TRUE

/obj/item/radio/intercom/directional/north
	pixel_y = 22

/obj/item/radio/intercom/directional/south
	pixel_y = -28

/obj/item/radio/intercom/directional/east
	pixel_x = 28

/obj/item/radio/intercom/directional/west
	pixel_x = -28
