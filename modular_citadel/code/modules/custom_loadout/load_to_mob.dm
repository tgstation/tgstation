
//Proc that does the actual loading of items to mob
/*Itemlists are formatted as
"[typepath]" = number_of_it_to_spawn
*/

#define DROP_TO_FLOOR 0
#define LOADING_TO_HUMAN 1

/proc/handle_roundstart_items(mob/living/M, ckey_override, job_override, special_override)
	if(!istype(M) || (!M.ckey && !ckey_override) || (!M.mind && (!job_override || !special_override)))
		return FALSE
	return load_itemlist_to_mob(M, parse_custom_roundstart_items(ckey_override? ckey_override : M.ckey, M.name, job_override? job_override : M.mind.assigned_role, special_override? special_override : M.mind.special_role), TRUE, TRUE, FALSE)

//Just incase there's extra mob selections in the future.....
/proc/load_itemlist_to_mob(mob/living/L, list/itemlist, drop_on_floor_if_full = TRUE, load_to_all_slots = TRUE, replace_slots = FALSE)
	if(!istype(L) || !islist(itemlist))
		return FALSE
	var/loading_mode = DROP_TO_FLOOR
	var/turf/current_turf = get_turf(L)
	if(ishuman(L))
		loading_mode = LOADING_TO_HUMAN
	switch(loading_mode)
		if(DROP_TO_FLOOR)
			for(var/I in itemlist)
				var/typepath = text2path(I)
				if(!typepath)
					continue
				for(var/i = 0, i < itemlist[I], i++)
					new typepath(current_turf)
			return TRUE
		if(LOADING_TO_HUMAN)
			return load_itemlist_to_human(L, itemlist, drop_on_floor_if_full, load_to_all_slots, replace_slots)

/proc/load_itemlist_to_human(mob/living/carbon/human/H, list/itemlist, drop_on_floor_if_full = TRUE, load_to_all_slots = TRUE, replace_slots = FALSE)
	if(!istype(H) || !islist(itemlist))
		return FALSE
	var/turf/T = get_turf(H)
	for(var/item in itemlist)
		var/path = item
		if(!ispath(path))
			path = text2path(path)
		if(!path)
			continue
		var/amount = itemlist[item]
		for(var/i in 1 to amount)
			var/atom/movable/loaded_atom = new path
			if(!istype(loaded_atom))
				QDEL_NULL(loaded_atom)
				continue
			if(!istype(loaded_atom, /obj/item))
				loaded_atom.forceMove(T)
				continue
			var/obj/item/loaded = loaded_atom
			var/obj/item/storage/S = H.get_item_by_slot(SLOT_BACK)
			if(istype(S))
				SEND_SIGNAL(S, COMSIG_TRY_STORAGE_INSERT,loaded, TRUE, H)	//Force it into their backpack
				continue
			if(!H.put_in_hands(loaded))						//They don't have one/somehow that failed, put it in their hands
				loaded.forceMove(T)				//Guess we're just dumping it on the floor!
	return TRUE
