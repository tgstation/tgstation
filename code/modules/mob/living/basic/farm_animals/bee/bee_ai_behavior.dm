/// if we have a hive, this will be our aggro distance
#define AGGRO_DISTANCE_FROM_HIVE 2
/datum/ai_behavior/hunt_target/pollinate
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/pollinate/target_caught(mob/living/hunter, obj/machinery/hydroponics/hydro_target)
	var/datum/callback/callback = CALLBACK(hunter, TYPE_PROC_REF(/mob/living/basic/bee, pollinate), hydro_target)
	callback.Invoke()

/datum/ai_behavior/find_hunt_target/pollinate
	action_cooldown = 10 SECONDS

/datum/ai_behavior/find_hunt_target/pollinate/valid_dinner(mob/living/source, obj/machinery/hydroponics/dinner, radius)
	if(!dinner.can_bee_pollinate())
		return FALSE
	return can_see(source, dinner, radius)

/datum/ai_behavior/enter_exit_hive
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 10 SECONDS

/datum/ai_behavior/enter_exit_hive/setup(datum/ai_controller/controller, target_key, attack_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/enter_exit_hive/perform(seconds_per_tick, datum/ai_controller/controller, target_key, attack_key)
	var/obj/structure/beebox/current_home = controller.blackboard[target_key]
	var/atom/attack_target = controller.blackboard[attack_key]

	if(attack_target) // forget about who we attacking when we go home
		controller.clear_blackboard_key(attack_key)

	controller.ai_interact(target = current_home, combat_mode = FALSE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/inhabit_hive
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/inhabit_hive/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/inhabit_hive/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/obj/structure/beebox/potential_home = controller.blackboard[target_key]
	var/mob/living/bee_pawn = controller.pawn

	if(!potential_home.habitable(bee_pawn)) //the house become full before we get to it
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.ai_interact(target = potential_home, combat_mode = FALSE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/inhabit_hive/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key) //failed to make it our home so find another

/datum/ai_behavior/find_and_set/bee_hive
	action_cooldown = 10 SECONDS

/datum/ai_behavior/find_and_set/bee_hive/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/valid_hives = list()
	var/mob/living/bee_pawn = controller.pawn

	if(istype(bee_pawn.loc, /obj/structure/beebox))
		return bee_pawn.loc //for premade homes

	for(var/obj/structure/beebox/potential_home in oview(search_range, bee_pawn))
		if(!potential_home.habitable(bee_pawn))
			continue
		valid_hives += potential_home

	if(valid_hives.len)
		return pick(valid_hives)

/datum/targeting_strategy/basic/bee

/datum/targeting_strategy/basic/bee/can_attack(mob/living/owner, atom/target, vision_range)
	if(!isliving(target))
		return FALSE
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/mob_target = target

	if(mob_target.mob_biotypes & MOB_PLANT)
		return FALSE

	var/datum/ai_controller/basic_controller/bee_ai = owner.ai_controller
	if(isnull(bee_ai))
		return FALSE

	var/atom/bee_hive = bee_ai.blackboard[BB_CURRENT_HOME]
	if(bee_hive && get_dist(target, bee_hive) > AGGRO_DISTANCE_FROM_HIVE && can_see(owner, bee_hive, 9))
		return FALSE

	return !(mob_target.bee_friendly())


///pet commands
/datum/pet_command/follow/bee
	///the behavior we use to follow
	follow_behavior = /datum/ai_behavior/pet_follow_friend/bee

/datum/ai_behavior/pet_follow_friend/bee
	required_distance = 0

///swirl around the owner in menacing fashion
/datum/pet_command/point_targeting/attack/swirl
	command_name = "Swirl"
	command_desc = "Your pets will swirl around you and attack whoever you point at!"
	speech_commands = list("swirl", "spiral", "swarm")
	pointed_reaction = null
	refuse_reaction = null
	command_feedback = null
	///the owner we will swarm around
	var/key_to_swarm = BB_SWARM_TARGET

/datum/pet_command/point_targeting/attack/swirl/try_activate_command(mob/living/commander)
	var/mob/living/living_pawn = weak_parent.resolve()
	if(isnull(living_pawn))
		return
	var/datum/ai_controller/basic_controller/controller = living_pawn.ai_controller
	if(isnull(controller))
		return
	controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
	controller.set_blackboard_key(key_to_swarm, commander)
	return ..()

/datum/pet_command/point_targeting/attack/swirl/execute_action(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		return ..()
	controller.queue_behavior(/datum/ai_behavior/swirl_around_target, BB_SWARM_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/swirl_around_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 0
	///chance to swirl
	var/swirl_chance = 60

/datum/ai_behavior/swirl_around_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/swirl_around_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn

	if(QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	if(get_dist(target, living_pawn) > 1)
		set_movement_target(controller, target)
		return AI_BEHAVIOR_DELAY

	if(!SPT_PROB(swirl_chance, seconds_per_tick))
		return AI_BEHAVIOR_DELAY

	var/list/possible_turfs = list()

	for(var/turf/possible_turf in oview(2, target))
		if(possible_turf.is_blocked_turf(source_atom = living_pawn))
			continue
		possible_turfs += possible_turf

	if(!length(possible_turfs))
		return AI_BEHAVIOR_DELAY

	if(isnull(controller.movement_target_source) || controller.movement_target_source == type)
		set_movement_target(controller, pick(possible_turfs))
	return AI_BEHAVIOR_DELAY


/datum/pet_command/beehive
	radial_icon = 'icons/obj/service/hydroponics/equipment.dmi'
	radial_icon_state = "beebox"

/datum/pet_command/beehive/try_activate_command(mob/living/commander)
	var/mob/living/living_pawn = weak_parent.resolve()
	if(isnull(living_pawn))
		return
	var/datum/ai_controller/basic_controller/controller = living_pawn.ai_controller
	if(isnull(controller))
		return
	var/obj/hive = controller.blackboard[BB_CURRENT_HOME]
	if(isnull(hive))
		return
	if(!check_beehive_conditions(living_pawn, hive))
		return
	return ..()

/datum/pet_command/beehive/proc/check_beehive_conditions(obj/structure/hive)
	return

/datum/pet_command/beehive/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(/datum/ai_behavior/enter_exit_hive, BB_CURRENT_HOME)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/beehive/enter
	command_name = "Enter beehive"
	command_desc = "Your bees will enter their beehive."
	speech_commands = list("enter", "home", "in")

/datum/pet_command/beehive/enter/check_beehive_conditions(mob/living/living_pawn, obj/structure/hive)
	if(living_pawn in hive) //already in hive
		return FALSE
	return can_see(living_pawn, hive, 9)

/datum/pet_command/beehive/exit
	command_name = "Exit beehive"
	command_desc = "Your bees will exit their beehive."
	speech_commands = list("exit", "leave", "out")

/datum/pet_command/beehive/exit/check_beehive_conditions(mob/living/living_pawn, obj/structure/hive)
	return (living_pawn in hive)

/datum/pet_command/scatter
	command_name = "Scatter"
	command_desc = "Command your pets to scatter all around you!"
	speech_commands = list("disperse", "spread", "scatter")

/datum/pet_command/scatter/set_command_active(mob/living/parent, mob/living/commander)
	. = ..()
	set_command_target(parent, commander)

/datum/pet_command/scatter/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(/datum/ai_behavior/run_away_from_target/scatter, BB_CURRENT_PET_TARGET)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/run_away_from_target/scatter
	run_distance = 4

#undef AGGRO_DISTANCE_FROM_HIVE
