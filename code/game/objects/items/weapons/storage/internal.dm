/obj/item/weapon/storage/internal
	var/obj/item/master_item

/obj/item/weapon/storage/internal/New(obj/item/MI)
	master_item = MI
	loc = master_item
	name = master_item.name
	verbs -= /obj/item/verb/verb_pickup
	..()

/obj/item/weapon/storage/internal/Destroy()
	master_item = null
	return ..()

/obj/item/weapon/storage/internal/attack_hand()
	return

/obj/item/weapon/storage/internal/mob_can_equip()
	return 0

/obj/item/weapon/storage/internal/proc/handle_mousedrop(mob/user as mob, obj/over_object as obj)
	if (ishuman(user))
		if (istype(user.loc,/obj/mecha))
			return 0

		if(over_object == user && Adjacent(user))
			orient2hud(user)
			show_to(user)
			return 0

		if (!( istype(over_object, /obj/screen) ))
			return 1

		if (!(master_item.loc == user) || (master_item.loc && master_item.loc.loc == user))
			return 0

		if (!( user.restrained() ) && !( user.stat ))
			var/obj/screen/inventory/hand/H = over_object
			switch(H.slot_id)
				if(slot_r_hand)
					user.unEquip(master_item)
					user.put_in_r_hand(master_item)
				if(slot_l_hand)
					user.unEquip(master_item)
					user.put_in_l_hand(master_item)
			master_item.add_fingerprint(user)
			return 0
	return 0

/obj/item/weapon/storage/internal/proc/handle_attack_hand(mob/user as mob)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == master_item && !H.get_active_hand())
			H.put_in_hands(master_item)
			H.l_store = null
			return 0
		if(H.r_store == master_item && !H.get_active_hand())
			H.put_in_hands(master_item)
			H.r_store = null
			return 0

	src.add_fingerprint(user)
	orient2hud(user)
	if (master_item.loc == user)
		show_to(user)
		return 0

	for(var/mob/M in range(1, master_item.loc))
		if (M.s_active == src)
			src.close(M)
	return 1

/obj/item/weapon/storage/internal/Adjacent(var/atom/neighbor)
	return master_item.Adjacent(neighbor)

/obj/item/weapon/storage/internal/pockets/New(var/newloc, var/slots, var/slot_size)
	storage_slots = slots
	max_w_class = slot_size
	..()