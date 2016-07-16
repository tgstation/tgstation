//Dextrous
/mob/living/simple_animal/hostile/guardian/dextrous
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, CLONE = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = "<span class='holoparasite'>As a <b>dextrous</b> type you can hold items, store an item within yourself, and have medium damage resistance, but do low damage on attacks. Recalling and leashing will force you to drop unstored items!</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Drone, a dextrous master of construction and repair.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Dextrous combat modules loaded. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! You caught one! It can hold stuff in its fins, sort of.</span>"
	dextrous = 1
	environment_target_typecache = list(
	/obj/machinery/door/window,
	/obj/structure/window,
	/obj/structure/closet,
	/obj/structure/table,
	/obj/structure/grille,
	/obj/structure/rack,
	/obj/structure/barricade,
	/obj/machinery/camera) //so we can also attack cameras
	var/obj/item/internal_storage //what we're storing within ourself

/mob/living/simple_animal/hostile/guardian/dextrous/death(gibbed)
	..()
	if(internal_storage)
		unEquip(internal_storage)

/mob/living/simple_animal/hostile/guardian/dextrous/examine(mob/user)
	if(dextrous)
		var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <b>[src]</b>!\n"
		msg += "[desc]\n"
		if(l_hand && !(l_hand.flags&ABSTRACT))
			if(l_hand.blood_DNA)
				msg += "<span class='warning'>It is holding \icon[l_hand] [l_hand.gender==PLURAL?"some":"a"] blood-stained [l_hand.name] in its left hand!</span>\n"
			else
				msg += "It is holding \icon[l_hand] \a [l_hand] in its left hand.\n"

		if(r_hand && !(r_hand.flags&ABSTRACT))
			if(r_hand.blood_DNA)
				msg += "<span class='warning'>It is holding \icon[r_hand] [r_hand.gender==PLURAL?"some":"a"] blood-stained [r_hand.name] in its right hand!</span>\n"
			else
				msg += "It is holding \icon[r_hand] \a [r_hand] in its right hand.\n"

		if(internal_storage && !(internal_storage.flags&ABSTRACT))
			if(internal_storage.blood_DNA)
				msg += "<span class='warning'>It is holding \icon[internal_storage] [internal_storage.gender==PLURAL?"some":"a"] blood-stained [internal_storage.name] in its internal storage!</span>\n"
			else
				msg += "It is holding \icon[internal_storage] \a [internal_storage] in its internal storage.\n"
		msg += "*---------*</span>"
		user << msg
	else
		..()

/mob/living/simple_animal/hostile/guardian/dextrous/Recall()
	if(loc == summoner || cooldown > world.time)
		return 0
	drop_l_hand()
	drop_r_hand()
	return ..() //lose items, then return

/mob/living/simple_animal/hostile/guardian/dextrous/snapback()
	if(summoner && !(get_dist(get_turf(summoner),get_turf(src)) <= range))
		drop_l_hand()
		drop_r_hand()
		..() //lose items, then return

//SLOT HANDLING BULLSHIT FOR INTERNAL STORAGE
/mob/living/simple_animal/hostile/guardian/dextrous/unEquip(obj/item/I, force)
	if(..(I,force))
		update_inv_hands()
		if(I == internal_storage)
			internal_storage = null
			update_inv_internal_storage()
		return 1
	return 0

/mob/living/simple_animal/hostile/guardian/dextrous/can_equip(obj/item/I, slot)
	switch(slot)
		if(slot_generic_dextrous_storage)
			if(internal_storage)
				return 0
			return 1
	..()

/mob/living/simple_animal/hostile/guardian/dextrous/equip_to_slot(obj/item/I, slot)
	if(!..())
		return

	switch(slot)
		if(slot_generic_dextrous_storage)
			internal_storage = I
			update_inv_internal_storage()
		else
			src << "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>"

/mob/living/simple_animal/hostile/guardian/dextrous/getBackSlot()
	return slot_generic_dextrous_storage

/mob/living/simple_animal/hostile/guardian/dextrous/getBeltSlot()
	return slot_generic_dextrous_storage

/mob/living/simple_animal/hostile/guardian/dextrous/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used && hud_used.hud_shown)
		internal_storage.screen_loc = ui_id
		client.screen += internal_storage

/mob/living/simple_animal/hostile/guardian/dextrous/regenerate_icons()
	..()
	update_inv_internal_storage()