//metal pinky
/datum/sutando_abilities/dextrous
	id = "dextrous"
	name = "Dexterity"
	value = 4

/datum/sutando_abilities/dextrous/handle_stats()
	. = ..()
	stand.dextrous = TRUE
	stand.environment_target_typecache = list(
	/obj/machinery/door/window,
	/obj/structure/window,
	/obj/structure/closet,
	/obj/structure/table,
	/obj/structure/grille,
	/obj/structure/rack,
	/obj/structure/barricade,
	/obj/machinery/camera)
	stand.melee_damage_lower += 5
	stand.melee_damage_upper += 5
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.15

/datum/sutando_abilities/dextrous/recall_act(forced)
	if(!user || stand.loc == user || (cooldown > world.time && !forced) && stand.dextrous)
		return FALSE
	stand.drop_all_held_items()
	return TRUE //lose items, then return

/datum/sutando_abilities/dextrous/snapback_act()
	if(user && !(get_dist(get_turf(user),get_turf(stand)) <= stand.range) && stand.dextrous)
		stand.drop_all_held_items()
		return TRUE //lose items, then return
