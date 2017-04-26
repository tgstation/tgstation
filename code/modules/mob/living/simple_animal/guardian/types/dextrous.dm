//metal pinky
/datum/guardian_abilities/dextrous
	id = "dextrous"
	name = "Dexterity"
	value = 4

/datum/guardian_abilities/dextrous/handle_stats()
	. = ..()
	guardian.dextrous = TRUE
	guardian.environment_target_typecache = list(
	/obj/machinery/door/window,
	/obj/structure/window,
	/obj/structure/closet,
	/obj/structure/table,
	/obj/structure/grille,
	/obj/structure/rack,
	/obj/structure/barricade,
	/obj/machinery/camera)
	guardian.melee_damage_lower += 5
	guardian.melee_damage_upper += 5
	for(var/i in guardian.damage_coeff)
		guardian.damage_coeff[i] -= 0.15

/datum/guardian_abilities/dextrous/recall_act(forced)
	if(!user || guardian.loc == user || (cooldown > world.time && !forced) && guardian.dextrous)
		return FALSE
	guardian.drop_all_held_items()
	return TRUE //lose items, then return

/datum/guardian_abilities/dextrous/snapback_act()
	if(user && !(get_dist(get_turf(user),get_turf(guardian)) <= guardian.range) && guardian.dextrous)
		guardian.drop_all_held_items()
		return TRUE //lose items, then return
