///Mobs spawned with this one are automatically player controlled, if possible
/datum/shuttle_event/simple_spawner/player_controlled
	spawning_list = list(/mob/living/basic/carp)

	///If we cant find a ghost, do we spawn them anyway? Otherwise they go in the garbage bin
	var/spawn_anyway_if_no_player = FALSE

	var/ghost_alert_string = "Would you like to be shot at the shuttle?"

	var/role_type = ROLE_SENTIENCE

/datum/shuttle_event/simple_spawner/player_controlled/spawn_movable(spawn_type)
	if(ispath(spawn_type, /mob/living))
		INVOKE_ASYNC(src, PROC_REF(try_grant_ghost_control), spawn_type)
	else
		..()

/datum/shuttle_event/simple_spawner/player_controlled/proc/try_grant_ghost_control(spawn_type)
	var/list/candidates = poll_ghost_candidates(ghost_alert_string + " (Warning: you will not be able to return to your body!)", role_type, FALSE, 10 SECONDS)
	var/mob/dead/observer/candidate = pick(candidates)
	if(candidate || spawn_anyway_if_no_player)
		var/mob/living/new_mob = new spawn_type (get_turf(get_spawn_turf()))
		if(candidate)
			new_mob.ckey = candidate.ckey
		post_spawn(new_mob)

///BACK FOR REVENGE!!!
/datum/shuttle_event/simple_spawner/player_controlled/alien_queen
	spawning_list = list(/mob/living/carbon/alien/adult/royal/queen = 1, /obj/vehicle/sealed/mecha/working/ripley = 1)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE

	probability = 0.1
	spawn_probability_per_process = 10
	activation_fraction = 0.5

	spawn_anyway_if_no_player = FALSE
	ghost_alert_string = "Would you like to be an alien queen shot at the shuttle?"
	remove_from_list_when_spawned = TRUE

	role_type = ROLE_ALIEN
