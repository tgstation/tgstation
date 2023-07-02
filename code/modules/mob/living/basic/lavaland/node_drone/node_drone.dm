/mob/living/basic/node_drone
	name = "NODE drone"
	desc = "Standard in-atmosphere drone, used by Nanotrasen to operate and excavate valuable ore vents."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_node"
	icon_living = "mining_node_active"
	icon_dead = "mining_node"

	maxHealth = 100
	health = 100
	density = TRUE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ROBOTIC
	faction = list(FACTION_STATION)

	speak_emote = list("chirps")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "clangs"
	response_harm_simple = "clang"

	ai_controller = /datum/ai_controller/basic_controller/mouse

	/// Is the drone currently attached to a vent?
	var/active_node = FALSE
	/// Weakref to the vent the drone is currently attached to.
	var/obj/structure/ore_vent/attached_vent = null

/mob/living/basic/node_drone/Initialize(mapload)
	. = ..()


/mob/living/basic/node_drone/examine(mob/user)
	. = ..()
	var/sameside = user.faction_check_mob(src, exact_match = FALSE)
	if(sameside)
		. += span_notice("This drone is currently attached to a mineral vent. You should protect it from harm to secure the mineral vent.")
	else
		. += span_warning("This vile Nanotrasen trash is trying to destroy the environment. Attack it to free the mineral vent from its grasp.")


// On death, remove the mouse from the ratcap, and turn it into an item if applicable
/mob/living/basic/node_drone/death(gibbed)
	. = ..(TRUE)
	say("I'm dead now!")
	qdel(src)



// I'll probably need some VERY BASIC AI but we'll see

// /// The mouse AI controller
// /datum/ai_controller/basic_controller/mouse
// 	blackboard = list(
// 		BB_BASIC_MOB_FLEEING = TRUE, // Always cowardly
// 		BB_CURRENT_HUNTING_TARGET = null, // cheese
// 		BB_LOW_PRIORITY_HUNTING_TARGET = null, // cable
// 		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(), // Use this to find people to run away from
// 	)

// 	ai_traits = STOP_MOVING_WHEN_PULLED
// 	ai_movement = /datum/ai_movement/basic_avoidance
// 	idle_behavior = /datum/idle_behavior/idle_random_walk
// 	planning_subtrees = list(
// 		// Top priority is to look for and execute hunts for cheese even if someone is looking at us
// 		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
// 		// Next priority is see if anyone is looking at us
// 		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
// 		// Skedaddle
// 		/datum/ai_planning_subtree/flee_target/mouse,
// 		// Try to speak, because it's cute
// 		/datum/ai_planning_subtree/random_speech/mouse,
// 		// Otherwise, look for and execute hunts for cabling
// 		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
// 	)

// /// Don't look for anything to run away from if you are distracted by being adjacent to cheese
// /datum/ai_planning_subtree/flee_target/mouse
// 	flee_behaviour = /datum/ai_behavior/run_away_from_target/mouse

// /datum/ai_planning_subtree/flee_target/mouse

// /datum/ai_planning_subtree/flee_target/mouse/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
// 	var/atom/hunted_cheese = controller.blackboard[BB_CURRENT_HUNTING_TARGET]
// 	if (!isnull(hunted_cheese))
// 		return // We see some cheese, which is more important than our life
// 	return ..()

// /datum/ai_planning_subtree/flee_target/mouse/select

// /datum/ai_behavior/run_away_from_target/mouse
// 	run_distance = 3 // Mostly exists in small tunnels, don't get ahead of yourself

// /// AI controller for rats, slightly more complex than mice becuase they attack people
// /datum/ai_controller/basic_controller/mouse/rat
// 	blackboard = list(
// 		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
// 		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/not_friends(),
// 		BB_BASIC_MOB_CURRENT_TARGET = null, // heathen
// 		BB_CURRENT_HUNTING_TARGET = null, // cheese
// 		BB_LOW_PRIORITY_HUNTING_TARGET = null, // cable
// 	)

// 	ai_traits = STOP_MOVING_WHEN_PULLED
// 	ai_movement = /datum/ai_movement/basic_avoidance
// 	idle_behavior = /datum/idle_behavior/idle_random_walk
// 	planning_subtrees = list(
// 		/datum/ai_planning_subtree/pet_planning,
// 		/datum/ai_planning_subtree/simple_find_target,
// 		/datum/ai_planning_subtree/attack_obstacle_in_path,
// 		/datum/ai_planning_subtree/basic_melee_attack_subtree,
// 		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
// 		/datum/ai_planning_subtree/random_speech/mouse,
// 		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
// 	)
