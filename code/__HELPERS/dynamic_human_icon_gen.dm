///Global list of all dynamically generated icons, for caching, so we don't have to generate multiple times.
GLOBAL_LIST_EMPTY(dynamic_human_icons)

///This proc takes an amount of arguments and creates a human dummy using the paths, for visuals you want!
/proc/get_dynamic_human_icon(outfit_path, species_path = /datum/species/human, mob_spawn_path, r_hand, l_hand, bloody_slots = NONE, list/generated_dirs = GLOB.cardinals, animated = TRUE)
	if(!species_path)
		return FALSE
	var/arg_string = "[outfit_path]_[species_path]_[mob_spawn_path]_[l_hand]_[r_hand]_[bloody_slots]_[generated_dirs.Join(",")]"
	if(GLOB.dynamic_human_icons[arg_string]) //if already exists in our cache, just return that
		return GLOB.dynamic_human_icons[arg_string]
	var/mob/living/carbon/human/dummy/consistent/dummy = new()
	dummy.set_species(species_path)
	dummy.stat = DEAD //this is to avoid side effects of mob spawners
	dummy.underwear = "Nude"
	dummy.undershirt = "Nude"
	dummy.socks = "Nude"
	if(outfit_path)
		var/datum/outfit/outfit = new outfit_path()
		if(r_hand != NO_REPLACE) //we can still override to be null, no replace means just use outfit's
			outfit.r_hand = r_hand
		if(l_hand != NO_REPLACE)
			outfit.l_hand = l_hand
		dummy.equipOutfit(outfit, visualsOnly = TRUE)
	else if(mob_spawn_path)
		var/obj/effect/mob_spawn/spawner = new mob_spawn_path(null, TRUE)
		spawner.outfit_override = list()
		if(r_hand != NO_REPLACE)
			spawner.outfit_override["r_hand"] = r_hand
		if(l_hand != NO_REPLACE)
			spawner.outfit_override["l_hand"] = l_hand
		spawner.special(dummy, dummy)
		spawner.equip(dummy)
	for(var/obj/item/carried_item in dummy)
		if(dummy.is_holding(carried_item))
			var/datum/component/two_handed/twohanded = carried_item.GetComponent(/datum/component/two_handed)
			if(twohanded)
				twohanded.wield(dummy)
			var/datum/component/transforming/transforming = carried_item.GetComponent(/datum/component/transforming)
			if(transforming)
				transforming.set_active(carried_item)
		if(bloody_slots & carried_item.slot_flags)
			carried_item.add_mob_blood(dummy)
	dummy.update_held_items()
	var/icon/output = icon('icons/blanks/32x32.dmi', "nothing")
	for(var/direction in generated_dirs)
		var/icon/partial = getFlatIcon(dummy, defdir = direction, no_anim = !animated)
		output.Insert(partial, dir = direction)
	GLOB.dynamic_human_icons[arg_string] = output
	qdel(dummy)
	return output

///This exists to apply the icons async, as that cannot be done in Initialize because of possible sleeps.
/proc/apply_dynamic_human_icon(atom/target, outfit_path, species_path = /datum/species/human, mob_spawn_path, r_hand, l_hand, bloody_slots = NONE, generated_dirs = GLOB.cardinals)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(set_dynamic_human_icon), args)

///This proc gets an argument of a target and runs
/proc/set_dynamic_human_icon(list/arguments)
	var/atom/target = arguments[1] //1st argument is the target
	var/icon/dynamic_icon = get_dynamic_human_icon(arglist(arguments.Copy(2))) //the rest of the arguments starting from 2 matter to the proc
	target.icon = dynamic_icon
