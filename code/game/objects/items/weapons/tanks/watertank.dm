/obj/item/weapon/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	w_class = 4.0
	slot_flags = SLOT_BACK
	slowdown = 3
	action_button_name = "Toggle Mister"

	var/obj/item/weapon/reagent_containers/glass/mister/noz
	var/on = 0
	var/volume = 500

/obj/item/weapon/watertank/New()
	..()
	create_reagents(volume)
	return

/obj/item/weapon/watertank/ui_action_click()
	if (usr.get_item_by_slot(slot_back) == src)
		toggle_mister()
	else
		usr << "<span class='notice'>The watertank needs to be on your back to use!</span>"
	return

/obj/item/weapon/watertank/verb/toggle_mister()
	set name = "Toggle Mister"
	set category = "Object"
	on = !on

	var/mob/living/carbon/human/user = usr
	if(on)
		//Detach the nozzle into the user's hands
		noz = new(src)
		var/list/L = list("left hand" = slot_l_hand,"right hand" = slot_r_hand)
		if(!user.equip_in_one_of_slots(noz, L))
			on = 0
			user << "<span class='notice'>You need a free hand to hold the mister!</span>"
	else
		//Remove from their hands and put back "into" the tank
		remove_noz(user)
	return

/obj/item/weapon/watertank/equipped(mob/user, slot)
	if (slot != slot_back)
		remove_noz(user)

/obj/item/weapon/watertank/proc/remove_noz(mob/user)
	if (noz != null)
		var/mob/living/carbon/human/M = user
		M.u_equip(noz)
	return

/obj/item/weapon/watertank/Del()
	if (noz)
		var/M = get(noz, /mob)
		remove_noz(M)
	..()
	return

// This mister item is intended as an extension of the watertank and always attached to it.
// Therefore, it's designed to be "locked" to the player's hands or extended back onto
// the watertank backpack. Allowing it to be placed elsewhere or created without a parent
// watertank object will likely lead to weird behaviour or runtimes.
/obj/item/weapon/reagent_containers/glass/mister
	name = "water mister"
	desc = "A mister nozzle attached to a water tank."
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "mister"
	item_state = "mister"
	w_class = 4.0
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(25,50,100)
	volume = 500
	can_be_placed_into = list(/obj/structure/sink)

	var/obj/item/weapon/watertank/tank

/obj/item/weapon/reagent_containers/glass/mister/New(parent_tank)
	..()
	if (!parent_tank || !istype(parent_tank, /obj/item/weapon/watertank))	//To avoid weird issues from admin spawns
		var/mob/living/carbon/human/M = usr
		M.u_equip(src)
		Del()
	else
		tank = parent_tank
		reagents = tank.reagents	//This mister is really just a proxy for the tank's reagents
		return

/obj/item/weapon/reagent_containers/glass/mister/dropped(mob/user as mob)
	user << "<span class='notice'>The mister snaps back onto the watertank!</span>"
	tank.on = 0
	Del()
