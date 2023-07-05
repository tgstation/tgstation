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

	ai_controller = /datum/ai_controller/basic_controller/node_drone

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


/mob/living/basic/node_drone/death(gibbed)
	. = ..(TRUE)
	say("I'm dead, NOW!")
	qdel(src)


/// The node drone AI controller
/datum/ai_controller/basic_controller/node_drone
	blackboard = list(
		BB_BASIC_MOB_FLEEING = FALSE, // Will flee when the vent lies undefended.
		BB_CURRENT_HUNTING_TARGET = null, // Hunts for vents.
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(), // Use this to find vents to run away from
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		// Top priority is to look for and execute hunts for cheese even if someone is looking at us
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
		// Next priority is see if anyone is looking at us
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		// Skedaddle
		/datum/ai_planning_subtree/flee_target/mouse,
		// Otherwise, look for and execute hunts for cabling
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
	)

/datum/ai_behavior/hunt_target/unarmed_attack_target/target_caught(mob/living/hunter, obj/structure/cable/hunted)
	hunter.UnarmedAttack(hunted, TRUE)
