/obj/item/quantum_keycard
	name = "quantum keycard"
	desc = "A keycard able to link to a quantum pad's particle signature, allowing other quantum pads to travel there instead of their linked pad."
	icon = 'icons/obj/device.dmi'
	icon_state = "quantum_keycard_gags"
	greyscale_config = /datum/greyscale_config/quantum_keycard
	greyscale_colors = "#FFFFFF"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	obj_flags = UNIQUE_RENAME
	var/obj/machinery/quantumpad/qpad

	/// where the pad is located and what color the card will become
	var/static/list/gags_coloring = list(
		/area/station/maintenance = COLOR_ASSISTANT_GRAY,
		/area/station/security = COLOR_SECURITY_RED,
		/area/station/service = COLOR_SERVICE_LIME,
		/area/centcom = COLOR_CENTCOM_BLUE,  // how?
		/area/station/command = COLOR_COMMAND_BLUE,
		/area/station/ai_monitored = COLOR_COMMAND_BLUE,
		/area/station/medical = COLOR_MEDICAL_BLUE,
		/area/station/science = COLOR_SCIENCE_PINK,
		/area/station/engineering = COLOR_ENGINEERING_ORANGE,
		/area/station/cargo = COLOR_CARGO_BROWN,
		/area/mine = COLOR_CARGO_BROWN
	)

/obj/item/quantum_keycard/examine(mob/user)
	. = ..()
	if(qpad)
		. += "It's currently linked to a quantum pad."

		var/area_name = get_area_name(qpad)
		if(area_name)
			. += span_notice("The pad is located in \the [area_name]")

		. += span_notice("Alt-click to unlink the keycard.")
	else
		. += span_notice("Insert [src] into an active quantum pad to link it.")

/obj/item/quantum_keycard/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = FALSE, need_hands = !iscyborg(user)))
		return
	to_chat(user, span_notice("You start pressing [src]'s unlink button..."))
	if(do_after(user, 40, target = src))
		to_chat(user, span_notice("The keycard beeps twice and disconnects the quantum link."))
		set_pad()

/obj/item/quantum_keycard/proc/set_pad(obj/machinery/quantumpad/new_pad)
	qpad = new_pad

	if(!istype(new_pad))
		set_greyscale(initial(greyscale_colors))
		name = initial(name)
		return

	var/new_color = is_type_in_list(get_area(new_pad), gags_coloring, zebra = TRUE) || COLOR_WEBSAFE_DARK_GRAY
	set_greyscale(new_color)
