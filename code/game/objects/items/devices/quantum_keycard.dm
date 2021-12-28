/obj/item/quantum_keycard
	name = "quantum keycard"
	desc = "A keycard able to link to a quantum pad's particle signature, allowing other quantum pads to travel there instead of their linked pad."
	icon = 'icons/obj/device.dmi'
	icon_state = "quantum_keycard"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	atom_size = WEIGHT_CLASS_TINY
	var/obj/machinery/quantumpad/qpad

/obj/item/quantum_keycard/examine(mob/user)
	. = ..()
	if(qpad)
		. += "It's currently linked to a quantum pad."
		. += span_notice("Alt-click to unlink the keycard.")
	else
		. += span_notice("Insert [src] into an active quantum pad to link it.")

/obj/item/quantum_keycard/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return
	to_chat(user, span_notice("You start pressing [src]'s unlink button..."))
	if(do_after(user, 40, target = src))
		to_chat(user, span_notice("The keycard beeps twice and disconnects the quantum link."))
		qpad = null

/obj/item/quantum_keycard/update_icon_state()
	icon_state = qpad ? "quantum_keycard_on" : initial(icon_state)
	return ..()
