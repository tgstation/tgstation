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

/// Attempt to grant control of a mob to ghosts before spawning it in. if spawn_anyway_if_no_player = TRUE, we spawn the mob even if there's no ghosts
/datum/shuttle_event/simple_spawner/player_controlled/proc/try_grant_ghost_control(spawn_type)
	var/list/candidates = poll_ghost_candidates(ghost_alert_string + " (Warning: you will not be able to return to your body!)", role_type, FALSE, 10 SECONDS)

	if(!candidates.len && !spawn_anyway_if_no_player)
		return

	var/mob/living/new_mob = new spawn_type (get_turf(get_spawn_turf()))

	if(candidates.len)
		var/mob/dead/observer/candidate = pick(candidates)
		new_mob.ckey = candidate.ckey
		post_spawn(new_mob)

///BACK FOR REVENGE!!!
/datum/shuttle_event/simple_spawner/player_controlled/alien_queen
	name = "ALIEN QUEEN! (Kinda dangerous!)"
	spawning_list = list(/mob/living/carbon/alien/adult/royal/queen = 1, /obj/vehicle/sealed/mecha/ripley = 1)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE

	event_probability = 0.2
	spawn_probability_per_process = 10
	activation_fraction = 0.5

	spawn_anyway_if_no_player = FALSE
	ghost_alert_string = "Would you like to be an alien queen shot at the shuttle?"
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

	role_type = ROLE_ALIEN

///Spawns three player controlled carp!! Deadchats final chance to wreak havoc, probably really not that dangerous if even one person has a laser gun
/datum/shuttle_event/simple_spawner/player_controlled/carp
	name = "Three player controlled carp! (Little dangerous!)"
	spawning_list = list(/mob/living/basic/carp = 10, /mob/living/basic/carp/mega = 2, /mob/living/basic/carp/magic = 2, /mob/living/basic/carp/magic/chaos = 1)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE

	event_probability = 1
	spawn_probability_per_process = 10
	activation_fraction = 0.4

	spawn_anyway_if_no_player = TRUE
	ghost_alert_string = "Would you like to be a space carp to pester the emergency shuttle?"
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

	role_type = ROLE_SENTIENCE

	///how many carp can we spawn max?
	var/max_carp_spawns = 3

/datum/shuttle_event/simple_spawner/player_controlled/carp/New(obj/docking_port/mobile/port)
	. = ..()

	var/list/spawning_list_copy = spawning_list.Copy()
	spawning_list.Cut()
	for(var/i in 1 to max_carp_spawns)
		spawning_list[pick_weight(spawning_list_copy)] += 1
