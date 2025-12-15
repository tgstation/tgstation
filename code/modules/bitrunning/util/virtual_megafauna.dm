/// Removes all the loot and achievements from megafauna for bitrunning related
/mob/living/simple_animal/hostile/megafauna/proc/make_virtual_megafauna()
	var/new_max = clamp(maxHealth * 0.5, 600, 1300)
	maxHealth = new_max
	health = new_max

	true_spawn = FALSE

	// rebuild the achievement element's arguments to remove it appropriately
	if (achievement_type || score_achievement_type)
		var/list/achievements = list(/datum/award/achievement/boss/boss_killer, /datum/award/score/boss_score)
		if (achievement_type)
			achievements += achievement_type
		if (score_achievement_type)
			achievements += score_achievement_type
		RemoveElement(/datum/element/kill_achievement, string_list(achievements), crusher_achievement_type, /datum/memory/megafauna_slayer)

	// remove the crusher loot element's arguments also to remove it appropriately
	RemoveElement(\
		/datum/element/crusher_loot,\
		trophy_type = crusher_loot,\
		guaranteed_drop = 0.6,\
		replace_all = replace_crusher_drop,\
		drop_immediately = del_on_death,\
	)

	loot.Cut()
	loot += /obj/structure/closet/crate/secure/bitrunning/encrypted
