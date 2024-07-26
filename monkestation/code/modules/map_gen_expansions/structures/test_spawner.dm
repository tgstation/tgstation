/datum/component/spawner/targeting/after_mob_spawn(mob/living/basic/created)
	if(!istype(created))
		return

	created.ai_controller?.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, parent)
	created.ai_controller?.set_blackboard_key(BB_TEMPORARY_TARGET, TRUE)
	created.AddElement(/datum/element/clear_target_key_and_retaliate)

/obj/structure/test_spawn_targeter
	var/list/defending_mobs = list(
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/legion/spawner_made,
		/mob/living/basic/mining/watcher,
		/mob/living/basic/mining/lobstrosity/lava,
		/mob/living/basic/mining/brimdemon,
		/mob/living/basic/mining/bileworm,
	)

/obj/structure/test_spawn_targeter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_MOB_DESTROYABLE, INNATE_TRAIT)
	AddComponent(\
		/datum/component/spawner/targeting, \
		spawn_types = defending_mobs, \
		spawn_time = (10 SECONDS), \
		max_spawned = 10, \
		max_spawn_per_attempt = (2), \
		spawn_text = "emerges to assault", \
		spawn_distance = 4, \
		spawn_distance_exclude = 3, \
	)
