GLOBAL_LIST_EMPTY(dynamic_human_icons)

/proc/get_dynamic_human_icon(outfit_path, species_path = /datum/species/human, mob_spawn_path, l_hand, r_hand, bloody_slots = NONE, generated_dirs = GLOB.cardinals)
	if(!species_path)
		return FALSE
	var/arg_string = "[outfit_path]_[species_path]_[mob_spawn_path]_[l_hand]_[r_hand]_[bloody_slots]_[english_list(generated_dirs, nothing_text = "", and_text = ",", comma_text = ",")]"
	if(GLOB.dynamic_human_icons[arg_string])
		return GLOB.dynamic_human_icons[arg_string]
	var/mob/living/carbon/human/dummy/consistent/dummy = new()
	dummy.set_species(species_path)
	dummy.stat = DEAD //this is to avoid side effects of mob spawners
	dummy.underwear = "Nude"
	dummy.undershirt = "Nude"
	dummy.socks = "Nude"
	if(outfit_path)
		var/datum/outfit/outfit = new outfit_path()
		if(l_hand != FALSE) //we can still override to be null, false means just use outfit's
			outfit.l_hand = l_hand
		if(r_hand != FALSE)
			outfit.r_hand = r_hand
		dummy.equipOutfit(outfit)
	else if(mob_spawn_path)
		var/obj/effect/mob_spawn/spawner = new mob_spawn_path(null, TRUE)
		spawner.outfit_override = list()
		if(r_hand != FALSE)
			spawner.outfit_override["r_hand"] = r_hand
		if(l_hand != FALSE)
			spawner.outfit_override["l_hand"] = l_hand
		spawner.special(dummy, dummy)
		spawner.equip(dummy)
	for(var/obj/item/carried_item in dummy)
		if(dummy.is_holding(carried_item))
			if(carried_item.GetComponent(/datum/component/two_handed))
				dummy.swap_hand(dummy.get_held_index_of_item(carried_item))
				carried_item.attack_self(dummy)
			if(carried_item.GetComponent(/datum/component/transforming))
				carried_item.attack_self(dummy)
		if(bloody_slots & carried_item.slot_flags)
			carried_item.add_mob_blood(dummy)
	dummy.update_held_items()
	var/icon/output = icon('icons/blanks/32x32.dmi', "nothing")
	for(var/direction in generated_dirs)
		var/icon/partial = getFlatIcon(dummy, defdir = direction)
		output.Insert(partial, dir = direction)
	GLOB.dynamic_human_icons[arg_string] = output
	qdel(dummy)
	return output

/proc/apply_dynamic_human_icon(atom/target, outfit_path, species_path = /datum/species/human, mob_spawn_path, l_hand, r_hand, bloody_slots = NONE, generated_dirs = GLOB.cardinals)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(set_dynamic_human_icon), args)

/proc/set_dynamic_human_icon(list/arguments)
	var/atom/target = arguments[1]
	var/icon/dynamic_icon = get_dynamic_human_icon(arglist(arguments.Copy(2)))
	target.icon = dynamic_icon
