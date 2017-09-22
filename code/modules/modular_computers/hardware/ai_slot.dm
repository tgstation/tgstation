/obj/item/computer_hardware/ai_slot
	name = "intelliCard interface slot"
	desc = "A module allowing this computer to interface with most common intelliCard modules. Necessary for some programs to run properly."
	power_usage = 100 //W
	icon_state = "card_mini"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "programming=2"
	device_type = MC_AI

	var/obj/item/device/aicard/stored_card = null
	var/locked = FALSE


/obj/item/computer_hardware/ai_slot/examine(mob/user)
	..()
	if(stored_card)
		to_chat(user, "There appears to be an intelliCard loaded. There appears to be a pinhole protecting a manual eject button. A screwdriver could probably press it")

/obj/item/computer_hardware/ai_slot/on_install(obj/item/device/modular_computer/M, mob/living/user = null)
	M.add_verb(device_type)

/obj/item/computer_hardware/ai_slot/on_remove(obj/item/device/modular_computer/M, mob/living/user = null)
	M.remove_verb(device_type)

/obj/item/computer_hardware/ai_slot/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE

	if(!istype(I, /obj/item/device/aicard))
		return FALSE

	if(stored_card)
		to_chat(user, "<span class='warning'>You try to insert \the [I] into \the [src], but the slot is occupied.</span>")
		return FALSE
	if(user && !user.transferItemToLoc(I, src))
		return FALSE

	stored_card = I
	to_chat(user, "<span class='notice'>You insert \the [I] into \the [src].</span>")

	return TRUE


/obj/item/computer_hardware/ai_slot/try_eject(slot=0,mob/living/user = null,forced = 0)
	if(!stored_card)
		to_chat(user, "<span class='warning'>There is no card in \the [src].</span>")
		return FALSE

	if(locked && !forced)
		to_chat(user, "<span class='warning'>Safeties prevent you from removing the card until reconstruction is complete...</span>")
		return FALSE

	if(stored_card)
		stored_card.forceMove(get_turf(src))
		locked = FALSE
		stored_card.verb_pickup()
		stored_card = null

		to_chat(user, "<span class='notice'>You remove the card from \the [src].</span>")
		return TRUE
	return FALSE

/obj/item/computer_hardware/ai_slot/attackby(obj/item/I, mob/living/user)
	if(..())
		return
	if(istype(I, /obj/item/screwdriver))
		to_chat(user, "<span class='notice'>You press down on the manual eject button with \the [I].</span>")
		try_eject(,user,1)
		return