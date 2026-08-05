#define FLY_IN_STATE 1
#define FLY_OUT_STATE 2
#define NEUTRAL_STATE 3

/**
 * Mining drones that are spawned when starting a ore vent's wave defense minigame.
 * They will latch onto the vent to defend it from lavaland mobs, and will flee if attacked by lavaland mobs.
 * If the drone survives, they will fly away to safety as the vent spawns ores.
 * If the drone dies, the wave defense will fail.
 */

/mob/living/basic/node_drone
	name = "NODE drone"
	desc = "Standard in-atmosphere drone, used by Nanotrasen to operate and excavate valuable ore vents."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_node_active"
	icon_living = "mining_node_active"
	icon_dead = "mining_node_active"

	maxHealth = 300 // We adjust the max health based on the vent size in the arrive() proc.
	health = 300
	density = TRUE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ROBOTIC
	faction = list(FACTION_STATION, FACTION_NEUTRAL)
	light_range = 4
	basic_mob_flags = DEL_ON_DEATH
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
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
	/// What status do we currently track for icon purposes?
	var/flying_state = NEUTRAL_STATE
	/// Weakref to the vent the drone is currently attached to.
	var/obj/structure/ore_vent/attached_vent = null
	/// Set when the drone is begining to leave lavaland after the vent is secured.
	var/escaping = FALSE

/mob/living/basic/node_drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_MINING_AOE_IMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/node_drone/death(gibbed)
	. = ..()
	explosion(origin = src, light_impact_range = 1, smoke = 1)

/mob/living/basic/node_drone/Destroy()
	attached_vent?.node = null //clean our reference to the vent both ways.
	attached_vent = null
	return ..()

/mob/living/basic/node_drone/examine(mob/user)
	. = ..()
	var/sameside = user.faction_check_atom(src, exact_match = FALSE)
	if(sameside)
		. += span_notice("This drone is currently attached to a mineral vent. You should protect it from harm to secure the mineral vent.")
	else
		. += span_warning("This vile Nanotrasen trash is trying to destroy the environment. Attack it to free the mineral vent from its grasp.")

/mob/living/basic/node_drone/update_icon_state()
	. = ..()

	icon_state = "mining_node_active"

	if(flying_state == FLY_IN_STATE || flying_state == FLY_OUT_STATE)
		icon_state = "mining_node_flying"

/mob/living/basic/node_drone/update_overlays()
	. = ..()
	if(attached_vent)
		var/time_remaining = COOLDOWN_TIMELEFT(attached_vent, wave_cooldown)
		var/wave_timers
		switch(attached_vent?.boulder_size)
			if(BOULDER_SIZE_SMALL)
				wave_timers = WAVE_DURATION_SMALL
			if(BOULDER_SIZE_MEDIUM)
				wave_timers = WAVE_DURATION_MEDIUM
			if(BOULDER_SIZE_LARGE)
				wave_timers = WAVE_DURATION_LARGE
		var/remaining_fraction = (time_remaining / wave_timers)
		if(remaining_fraction <= 0.3)
			. += "node_progress_4"
			return
		if(remaining_fraction <= 0.55)
			. += "node_progress_3"
			return
		if(remaining_fraction <= 0.80)
			. += "node_progress_2"
			return
		. += "node_progress_1"
		return

/mob/living/basic/node_drone/proc/arrive(obj/structure/ore_vent/parent_vent)
	attached_vent = parent_vent
	maxHealth = 300 + ((attached_vent.boulder_size/BOULDER_SIZE_SMALL) * 100)
	health = maxHealth
	flying_state = FLY_IN_STATE
	update_appearance(UPDATE_ICON_STATE)
	pixel_z = 400
	animate(src, pixel_z = 0, time = 2 SECONDS, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)


/**
 * Called when wave defense is completed. Visually flicks the escape sprite and then deletes the mob.
 */
/mob/living/basic/node_drone/proc/escape(success)
	var/funny_ending = FALSE
	flying_state = FLY_OUT_STATE
	update_appearance(UPDATE_ICON_STATE)
	if(prob(1))
		say("I have to go now, my planet needs me.")
		funny_ending = TRUE
	if(success)
		visible_message(span_notice("The drone flies away to safety as the vent is secured."))
	else
		visible_message(span_danger("The drone flies away after failing to open the vent!"))
	animate(src, pixel_z = 400, time = 2 SECONDS, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(2 SECONDS)
	if(funny_ending)
		playsound(src, 'sound/effects/explosion/explosion3.ogg', 50, FALSE) //node drone died on the way back to his home planet.
		visible_message(span_notice("...or maybe not."))
	qdel(src)


/mob/living/basic/node_drone/proc/pre_escape(success = TRUE)
	if(buckled)
		buckled.unbuckle_mob(src)
	if(attached_vent)
		attached_vent = null
	if(!escaping)
		escaping = TRUE
		flick("mining_node_escape", src)
		addtimer(CALLBACK(src, PROC_REF(escape), success), 1.9 SECONDS)
		return

/// The node drone AI controller
/datum/ai_controller/basic_controller/node_drone
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/node_drone/node_drone.bt.json"
	blackboard = list(
		BB_CURRENT_HUNTING_TARGET = null,
		BB_CURRENT_TARGET_HIDING_LOCATION = null,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_FLEE_DISTANCE = 3,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance

/// Validates an ore vent as a valid hunt target: must exist and have no drone already latched.
/datum/targeting_strategy/ore_vent_unclaimed

/datum/targeting_strategy/ore_vent_unclaimed/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/structure/ore_vent/vent = target
	return istype(vent) && isnull(vent.node)


#undef FLY_IN_STATE
#undef FLY_OUT_STATE
#undef NEUTRAL_STATE
