/client
	var/ghost_critter_cooldown = 0


/client/proc/get_critter_spawn(obj/structure/ghost_critter_spawn/spawner)
	var/list/basic_list = list(
		/mob/living/basic/mouse,
		/mob/living/basic/axolotl,
		/mob/living/basic/butterfly,
		/mob/living/basic/crab,
		/mob/living/basic/mothroach
	)

	var/list/mobs_to_pick = list()

	mobs_to_pick += return_donator_mobs()

	if(!patreon.has_access(ACCESS_ASSISTANT_RANK) && !is_admin(src) && !length(mobs_to_pick))
		return pick(basic_list)

	mobs_to_pick += basic_list

	var/list/spawned_mobs = list()
	var/list/deletors = list()
	for(var/mob/living/basic/basic as anything in mobs_to_pick)
		var/mob/living/basic/created = new basic()
		spawned_mobs += list(created.name = created)
		deletors += created

	var/choice = show_radial_menu(mob, spawner, spawned_mobs, tooltips = TRUE)
	if(!choice)
		spawned_mobs = null
		QDEL_LIST(deletors)
		return pick(basic_list)
	var/mob/living/basic/picked = spawned_mobs[choice]
	var/mob_type = picked.type
	spawned_mobs = null
	QDEL_LIST(deletors)
	return mob_type

/client/proc/try_critter_spawn(obj/structure/ghost_critter_spawn/spawner)
	var/turf/open/turf = get_turf(spawner)

	var/mob/living/basic/spawned_mob = get_critter_spawn(spawner)
	var/mob/living/basic/created_mob = new spawned_mob(turf)

	var/cooldown_time = get_critter_cooldown()
	ghost_critter_cooldown = cooldown_time

	if(patreon.has_access(ACCESS_NUKIE_RANK) || is_admin(src))
		created_mob.AddComponent(/datum/component/basic_inhands, y_offset = -6)
		created_mob.AddComponent(/datum/component/max_held_weight, WEIGHT_CLASS_SMALL)
		created_mob.AddElement(/datum/element/dextrous)
	ADD_TRAIT(created_mob, TRAIT_MUTE, INNATE_TRAIT)

	if(!mob.mind)
		mob.mind = new /datum/mind(key)

	var/mob/dead/observer/observe = mob
	created_mob.key = observe.key

	init_verbs()

/client/proc/get_critter_cooldown()
	var/base_time = 25 MINUTES

	switch(patreon.access_rank)
		if(0, 1)
			return base_time
		if(2)
			return base_time - 5 MINUTES
		if(3)
			return base_time - 10 MINUTES
		if(4)
			return base_time - 15 MINUTES
		if(5)
			return base_time - 20 MINUTES
		else
			return 1 MINUTES
