/obj/item/quantum_keycard
	name = "quantum keycard"
	desc = "A keycard able to link to a quantum pad's particle signature, allowing other quantum pads to travel there instead of their linked pad."
	icon = 'icons/obj/device.dmi'
	icon_state = "quantum_keycard"
	item_state = "quantum_keycard"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/quantumpad/qpad

/obj/item/quantum_keycard/examine(mob/user)
	..()
	if(qpad)
		to_chat(user, "It's currently linked to a quantum pad.")
		to_chat(user, "<span class='notice'>Alt-click to unlink the keycard.</span>")
	else
		to_chat(user, "<span class='notice'>Insert [src] into an active quantum pad to link it.</span>")