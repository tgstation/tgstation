//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/world/New()
	..()

	diary = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
	diary << {"

Starting up. [time2text(world.timeofday, "hh:mm.ss")]
---------------------
"}

	diaryofmeanpeople = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")] Attack.log")

	diaryofmeanpeople << {"

Starting up. [time2text(world.timeofday, "hh:mm.ss")]
---------------------
"}

	jobban_loadbanfile()
	jobban_updatelegacybans()
	LoadBans()
	process_teleport_locs() //Sets up the wizard teleport locations
	process_ghost_teleport_locs() //Sets up ghost teleport locations.
	sleep_offline = 1

	if (config.kick_inactive)
		spawn(30)
			KickInactiveClients()

#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	for(var/client/C)
		if( !C.holder && (C.inactivity >= INACTIVITY_KICK) )
			if(C.mob)
				if(!istype(C.mob, /mob/dead/))
					log_access("AFK: [key_name(C)]")
					C << "\red You have been inactive for more than 10 minutes and have been disconnected."
			del(C)
	spawn(3000) KickInactiveClients()//more or less five minutes

/// EXPERIMENTAL STUFF

// This function counts a passed job.
proc/countJob(rank)
	var/jobCount = 0
	for(var/mob/H in world)
		if(H.mind && H.mind.assigned_role == rank)
			jobCount++
	return jobCount

/mob/living/carbon/human/var/const/slot_back = 1
/mob/living/carbon/human/var/const/slot_wear_mask = 2
/mob/living/carbon/human/var/const/slot_handcuffed = 3
/mob/living/carbon/human/var/const/slot_l_hand = 4
/mob/living/carbon/human/var/const/slot_r_hand = 5
/mob/living/carbon/human/var/const/slot_belt = 6
/mob/living/carbon/human/var/const/slot_wear_id = 7
/mob/living/carbon/human/var/const/slot_ears = 8
/mob/living/carbon/human/var/const/slot_glasses = 9
/mob/living/carbon/human/var/const/slot_gloves = 10
/mob/living/carbon/human/var/const/slot_head = 11
/mob/living/carbon/human/var/const/slot_shoes = 12
/mob/living/carbon/human/var/const/slot_wear_suit = 13
/mob/living/carbon/human/var/const/slot_w_uniform = 14
/mob/living/carbon/human/var/const/slot_l_store = 15
/mob/living/carbon/human/var/const/slot_r_store = 16
/mob/living/carbon/human/var/const/slot_s_store = 17
/mob/living/carbon/human/var/const/slot_in_backpack = 18

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		del(W)
	return null

/mob/living/carbon/human/proc/equip_to_appropriate_slot(obj/item/W)
	if(!W)
		return
	if(!ishuman(src))
		return

	if(W.slot_flags & SLOT_BACK)
		if(!src.back)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.back = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_ID)
		if(!src.wear_id)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.wear_id = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_ICLOTHING)
		if(!src.w_uniform)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.w_uniform = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_OCLOTHING)
		if(!src.wear_suit)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.wear_suit = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_MASK)
		if(!src.wear_mask)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.wear_mask = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_HEAD)
		if(!src.head)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.head = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_FEET)
		if(!src.shoes)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.shoes = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_GLOVES)
		if(!src.gloves)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.gloves = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_EARS)
		if(!src.ears)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.ears = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_EYES)
		if(!src.glasses)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.glasses = W
			update_clothing()
			return

	if(W.slot_flags & SLOT_BELT)
		if(!src.belt)
			if( src.get_active_hand() == W )
				src.u_equip(W)
			src.belt = W
			update_clothing()
			return

	//Suit storage
	var/confirm
	if (wear_suit)
		if(wear_suit.allowed)
			if (istype(W, /obj/item/device/pda) || istype(W, /obj/item/weapon/pen))
				confirm = 1
			if (is_type_in_list(W, wear_suit.allowed))
				confirm = 1
		if(confirm)
			src.u_equip(W)
			src.s_store = W
			update_clothing()
			return

	//Pockets
	if ( !( W.slot_flags & SLOT_DENYPOCKET ) )
		if(!src.l_store)
			if ( W.w_class <= 2 || ( W.slot_flags & SLOT_POCKET ) )
				u_equip(W)
				l_store = W
				update_clothing()
				return
		if(!src.r_store)
			if ( W.w_class <= 2 || ( W.slot_flags & SLOT_POCKET ) )
				u_equip(W)
				r_store = W
				update_clothing()
				return


/mob/living/carbon/human/proc/equip_if_possible(obj/item/W, slot, del_on_fail = 1) // since byond doesn't seem to have pointers, this seems like the best way to do this :/
	//warning: icky code
	var/equipped = 0
	if((slot == l_store || slot == r_store || slot == belt || slot == wear_id) && !src.w_uniform)
		del(W)
		return
	if(slot == s_store && !src.wear_suit)
		del(W)
		return
	switch(slot)
		if(slot_back)
			if(!src.back)
				src.back = W
				equipped = 1
		if(slot_wear_mask)
			if(!src.wear_mask)
				src.wear_mask = W
				equipped = 1
		if(slot_handcuffed)
			if(!src.handcuffed)
				src.handcuffed = W
				equipped = 1
		if(slot_l_hand)
			if(!src.l_hand)
				src.l_hand = W
				equipped = 1
		if(slot_r_hand)
			if(!src.r_hand)
				src.r_hand = W
				equipped = 1
		if(slot_belt)
			if(!src.belt)
				src.belt = W
				equipped = 1
		if(slot_wear_id)
			if(!src.wear_id)
				src.wear_id = W
				equipped = 1
		if(slot_ears)
			if(!src.ears)
				src.ears = W
				equipped = 1
		if(slot_glasses)
			if(!src.glasses)
				src.glasses = W
				equipped = 1
		if(slot_gloves)
			if(!src.gloves)
				src.gloves = W
				equipped = 1
		if(slot_head)
			if(!src.head)
				src.head = W
				equipped = 1
		if(slot_shoes)
			if(!src.shoes)
				src.shoes = W
				equipped = 1
		if(slot_wear_suit)
			if(!src.wear_suit)
				src.wear_suit = W
				equipped = 1
		if(slot_w_uniform)
			if(!src.w_uniform)
				src.w_uniform = W
				equipped = 1
		if(slot_l_store)
			if(!src.l_store)
				src.l_store = W
				equipped = 1
		if(slot_r_store)
			if(!src.r_store)
				src.r_store = W
				equipped = 1
		if(slot_s_store)
			if(!src.s_store)
				src.s_store = W
				equipped = 1
		if(slot_in_backpack)
			if (src.back && istype(src.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = src.back
				if(B.contents.len < B.storage_slots && W.w_class <= B.max_w_class)
					W.loc = B
					equipped = 1

	if(equipped)
		W.layer = 20
	else
		if (del_on_fail)
			del(W)
	return equipped

/proc/AutoUpdateAI(obj/subject)
	if (subject!=null)
		for(var/mob/living/silicon/ai/M in world)
			if ((M.client && M.machine == subject))
				subject.attack_ai(M)

/proc/AutoUpdateTK(obj/subject)
	if (subject!=null)
		for(var/obj/item/tk_grab/T in world)
			if (T.host)
				var/mob/M = T.host
				if(M.client && M.machine == subject)
					subject.attack_hand(M)
