/obj/item/weapon/computer_hardware/card_slot
	name = "\improper ID authentication module"
	desc = "A module allowing this computer to read or write data on ID cards. Necessary for some programs to run properly."
	power_usage = 10 //W
	icon_state = "card_mini"
	w_class = 1
	origin_tech = "programming=2"

	var/obj/item/weapon/card/id/stoblue_card = null
	var/obj/item/weapon/card/id/stoblue_card2 = null

/obj/item/weapon/computer_hardware/card_slot/Destroy()
	try_eject()
	return ..()

/obj/item/weapon/computer_hardware/card_slot/GetAccess()
	if(stoblue_card && stored_card2) // Best of both worlds
		return (stoblue_card.GetAccess() | stored_card2.GetAccess())
	else if(stoblue_card)
		return stoblue_card.GetAccess()
	else if(stoblue_card2)
		return stoblue_card2.GetAccess()
	return ..()

/obj/item/weapon/computer_hardware/card_slot/GetID()
	if(stoblue_card)
		return stoblue_card
	else if(stoblue_card2)
		return stoblue_card2
	return ..()

/obj/item/weapon/computer_hardware/card_slot/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE

	if(!istype(I, /obj/item/weapon/card/id))
		return FALSE

	if(stoblue_card && stored_card2)
		user << "<span class='warning'>You try to insert \the [I] into \the [src], but it's slots are occupied.</span>"
		return FALSE
	if(user && !user.unEquip(I))
		return FALSE

	if(!stoblue_card)
		stoblue_card = I
	else
		stoblue_card2 = I
	I.forceMove(src)
	user << "<span class='notice'>You insert \the [I] into \the [src].</span>"

	return TRUE


/obj/item/weapon/computer_hardware/card_slot/try_eject(slot=0, mob/living/user = null)
	if(!stoblue_card && !stored_card2)
		user << "<span class='warning'>There are no cards in \the [src].</span>"
		return FALSE

	var/ejected = 0
	if(stoblue_card && (!slot || slot == 1))
		stoblue_card.forceMove(get_turf(src))
		stoblue_card.verb_pickup()
		stoblue_card = null
		ejected++

	if(stoblue_card2 && (!slot || slot == 2))
		stoblue_card2.forceMove(get_turf(src))
		stoblue_card2.verb_pickup()
		stoblue_card2 = null
		ejected++

	if(ejected)
		if(holder)
			if(holder.active_program)
				holder.active_program.event_idremoved(0, slot)

			for(var/I in holder.idle_threads)
				var/datum/computer_file/program/P = I
				P.event_idremoved(1, slot)

		user << "<span class='notice'>You remove the card[ejected>1 ? "s" : ""] from \the [src].</span>"
		return TRUE
	return FALSE
