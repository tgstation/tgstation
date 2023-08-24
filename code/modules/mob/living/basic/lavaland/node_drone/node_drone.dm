/mob/living/basic/node_drone
	name = "NODE drone"
	desc = "Standard in-atmosphere drone, used by Nanotrasen to operate and excavate valuable ore vents."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_node_active"
	icon_living = "mining_node_active"
	icon_dead = "mining_node"

	maxHealth = 1000
	health = 1000
	density = TRUE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ROBOTIC
	faction = list(FACTION_STATION, FACTION_NEUTRAL)

	speak_emote = list("chirps")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "clangs"
	response_harm_simple = "clang against"

	ai_controller = /datum/ai_controller/basic_controller/node_drone

	/// Is the drone currently attached to a vent?
	var/active_node = FALSE
	/// Weakref to the vent the drone is currently attached to.
	var/obj/structure/ore_vent/attached_vent = null
	/// Set when the drone is begining to leave lavaland after the vent is secured.
	var/escaping = FALSE

/mob/living/basic/node_drone/death(gibbed)
	. = ..()
	attached_vent = null
	explosion(origin = src, light_impact_range = 1 ,smoke = 1)

/mob/living/basic/node_drone/examine(mob/user)
	. = ..()
	var/sameside = user.faction_check_mob(src, exact_match = FALSE)
	if(sameside)
		. += span_notice("This drone is currently attached to a mineral vent. You should protect it from harm to secure the mineral vent.")
	else
		. += span_warning("This vile Nanotrasen trash is trying to destroy the environment. Attack it to free the mineral vent from its grasp.")

/mob/living/basic/node_drone/proc/arrive()
	icon_state = "mining_node_flying"
	update_appearance(UPDATE_ICON_STATE)
	pixel_z = 400
	animate(src, pixel_z = 0, time = 2 SECONDS, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

/**
 * Called when wave defense is completed. Visually flicks the escape sprite and then deletes the mob.
 */
/mob/living/basic/node_drone/proc/escape()
	attached_vent?.unbuckle_mob(src)
	if(!escaping)
		escaping = TRUE
		flick("mining_node_escape", src)
		addtimer(CALLBACK(src, PROC_REF(escape)), 1.9 SECONDS)
		return
	icon_state = "mining_node_flying"
	//update_appearance(UPDATE_ICON_STATE)
	visible_message(src, "The drone flies away to safety as the vent is secured.")
	animate(src, pixel_z = 400, time = 2 SECONDS, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, PROC_REF(qdel), src), 1 SECONDS) //node drone died on the way back to his home planet.


/// The node drone AI controller
//	Generally, this is a very simple AI that will try to find a vent and latch onto it, unless attacked by a lavaland mob, who it will try to flee from.
/datum/ai_controller/basic_controller/node_drone
	blackboard = list(
		BB_BASIC_MOB_FLEEING = FALSE, // Will flee when the vent lies undefended.
		BB_CURRENT_HUNTING_TARGET = null, // Hunts for vents.
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(), // Use this to find vents to run away from
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = null
	planning_subtrees = list(
		// Top priority is to look for and execute hunts for vents, even if we're being attacked.
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_vent,
		// Next priority is see if lavaland mobs are looking at us
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		// Fly you feel
		/datum/ai_planning_subtree/flee_target/node_drone,
		//Potentially add more behaviors here for herding boulders to the vent if they get displaced.
	)

// Node subtree to hunt down ore vents.
/datum/ai_planning_subtree/find_and_hunt_target/look_for_vent
	hunting_behavior = /datum/ai_behavior/hunt_target/latch_onto/node_drone
	hunt_targets = list(/obj/structure/ore_vent)
	hunt_range = 7 // Hunt vents to the end of the earth.

// node drone behavior for buckling down on a vent.
/datum/ai_behavior/hunt_target/latch_onto/node_drone
	hunt_cooldown = 5 SECONDS

// Evasion behavior.
/datum/ai_planning_subtree/flee_target/node_drone
	flee_behaviour = /datum/ai_behavior/run_away_from_target/drone

/datum/ai_behavior/run_away_from_target/drone
	action_cooldown = 1 SECONDS
	required_distance = 5
