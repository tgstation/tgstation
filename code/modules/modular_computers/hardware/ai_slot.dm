/obj/item/computer_hardware/ai_slot
	name = "intelliCard interface slot"
	desc = "A module allowing this computer to interface with most common intelliCard modules. Necessary for some programs to run properly."
	power_usage = 100 //W
	icon_state = "card_mini"
	atom_size = ITEM_SIZE_SMALL
	device_type = MC_AI
	expansion_hw = TRUE

	var/obj/item/aicard/stored_card
	var/locked = FALSE

///What happens when the intellicard is removed (or deleted) from the module, through try_eject() or not.
/obj/item/computer_hardware/ai_slot/Exited(atom/movable/gone, direction)
	if(stored_card == gone)
		stored_card = null
	return ..()

/obj/item/computer_hardware/ai_slot/examine(mob/user)
	. = ..()
	if(stored_card)
		. += "There appears to be an intelliCard loaded. There appears to be a pinhole protecting a manual eject button. A screwdriver could probably press it."

/obj/item/computer_hardware/ai_slot/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE

	if(!istype(I, /obj/item/aicard))
		return FALSE

	if(stored_card)
		to_chat(user, span_warning("You try to insert \the [I] into \the [src], but the slot is occupied."))
		return FALSE
	if(user && !user.transferItemToLoc(I, src))
		return FALSE

	stored_card = I
	to_chat(user, span_notice("You insert \the [I] into \the [src]."))

	return TRUE


/obj/item/computer_hardware/ai_slot/try_eject(mob/living/user = null, forced = FALSE)
	if(!stored_card)
		to_chat(user, span_warning("There is no card in \the [src]."))
		return FALSE

	if(locked && !forced)
		to_chat(user, span_warning("Safeties prevent you from removing the card until reconstruction is complete..."))
		return FALSE

	if(stored_card)
		to_chat(user, span_notice("You remove [stored_card] from [src]."))
		locked = FALSE
		if(Adjacent(user))
			user.put_in_hands(stored_card)
		else
			stored_card.forceMove(drop_location())

		return TRUE
	return FALSE

/obj/item/computer_hardware/ai_slot/attackby(obj/item/I, mob/living/user)
	if(..())
		return
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, span_notice("You press down on the manual eject button with \the [I]."))
		try_eject(user, TRUE)
		return
