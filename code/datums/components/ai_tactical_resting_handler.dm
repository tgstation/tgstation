/**
 * Handles whether an AI controlled mob can avoid getting hit by stray bullets and thrown objects
 * when lying on the floor. Cliented and ai controlled living mobs alike should be hit by projectiles when crawling.
 */
/datum/component/ai_tactical_resting_handler
	///Stores the value of the ai movement cooldown if that was successful.
	var/successful_move_cooldown
	///The connect_loc_behalf component necessary for getting hit by thrown things while crawling.
	var/datum/component/connect_loc_behalf/thrownthing_catcher

/datum/component/ai_tactical_resting_handler/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/ai_tactical_resting_handler/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_SET_AI_STATUS, .proc/on_set_ai_status)
	var/mob/living/living_parent = parent
	// Call setup_can_hit_deck() if the mob has already been possessed by the ai controller and that controller is already on.
	if(istype(living_parent.ai_controller) && living_parent.ai_controller.ai_status == AI_STATUS_ON)
		setup_can_hit_deck(living_parent)

/datum/component/ai_tactical_resting_handler/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_SET_AI_STATUS)
	unset_can_hit_deck(parent)

/datum/component/ai_tactical_resting_handler/proc/on_set_ai_status(datum/source, new_ai_status)
	SIGNAL_HANDLER
	var/mob/living/living_parent = parent
	switch(new_ai_status)
		if(AI_STATUS_ON)
			setup_can_hit_deck(living_parent)
		if(AI_STATUS_OFF)
			unset_can_hit_deck(living_parent)

/datum/component/ai_tactical_resting_handler/proc/setup_can_hit_deck(mob/living/target)
	// Prevents the mob from normally dodging projectiles in [/obj/projectile/can_hit_target()] since there's no client.
	ADD_TRAIT(target, TRAIT_CANNOT_EVADE_PROJECTILES, TACTICAL_RESTING_COMPONENT_TRAIT)
	RegisterSignal(parent, COMSIG_MOVABLE_ON_AI_MOVEMENT, .proc/on_ai_movement)
	RegisterSignal(target, COMSIG_LIVING_ON_LYING_DOWN, .proc/on_lying_down)
	RegisterSignal(target, COMSIG_LIVING_ON_STANDING_UP, .proc/on_standing_up)
	RegisterSignal(target, COMSIG_ATOM_CAN_BE_HIT_BY_PROJECTILE, .proc/can_be_hit_by_projectile)
	// If the target is already prone, add the connect_loc_behalf component.
	if(target.body_position == LYING_DOWN)
		thrownthing_catcher = AddComponent(/datum/component/connect_loc_behalf, target, list(COMSIG_TURF_FIND_THROWNTHING_TARGET = .proc/thrownthing_find_target))

/datum/component/ai_tactical_resting_handler/proc/unset_can_hit_deck(mob/living/target)
	UnregisterSignal(target, list(COMSIG_MOVABLE_ON_AI_MOVEMENT, COMSIG_LIVING_ON_LYING_DOWN, COMSIG_LIVING_ON_STANDING_UP,COMSIG_ATOM_CAN_BE_HIT_BY_PROJECTILE))
	REMOVE_TRAIT(target, TRAIT_CANNOT_EVADE_PROJECTILES, TACTICAL_RESTING_COMPONENT_TRAIT)
	QDEL_NULL(thrownthing_catcher)
	successful_move_cooldown = null

/datum/component/ai_tactical_resting_handler/proc/on_ai_movement(atom/movable/source, datum/ai_controller/controller, delta_time, success)
	SIGNAL_HANDLER
	if(success)
		successful_move_cooldown = controller.movement_cooldown

/datum/component/ai_tactical_resting_handler/proc/on_lying_down(datum/source, new_lying_angle)
	SIGNAL_HANDLER
	thrownthing_catcher = AddComponent(/datum/component/connect_loc_behalf, parent, list(COMSIG_TURF_FIND_THROWNTHING_TARGET = .proc/thrownthing_find_target))

/datum/component/ai_tactical_resting_handler/proc/on_standing_up()
	SIGNAL_HANDLER
	UnregisterSignal(parent, COMSIG_ATOM_CAN_BE_HIT_BY_PROJECTILE)
	QDEL_NULL(thrownthing_catcher)

/datum/component/ai_tactical_resting_handler/proc/thrownthing_find_target(turf/source, datum/thrownthing/throwdatum, atom/actual_target)
	SIGNAL_HANDLER
	var/mob/living/living_parent = parent
	// Skip if the thrown thing has either completed its trajectory or isn't hitting crawling mobs or if the parent is incapacitated.
	if(!throwdatum.thrownthing.throwing || !throwdatum.hit_crawling_targets || PROJECTILES_SHOULD_AVOID(living_parent))
		return
	if(!IS_HITTING_DECK(living_parent, successful_move_cooldown, TRUE) || HAS_TRAIT_NOT_FROM(living_parent, TRAIT_CANNOT_EVADE_PROJECTILES, TACTICAL_RESTING_COMPONENT_TRAIT))
		throwdatum.finalize(TRUE, living_parent)

/datum/component/ai_tactical_resting_handler/proc/can_be_hit_by_projectile(mob/living/source, obj/projectile, direct_target, ignore_loc, cross_failed)
	SIGNAL_HANDLER
	if(direct_target || cross_failed)
		return
	if(IS_HITTING_DECK(source, successful_move_cooldown, TRUE) && !HAS_TRAIT_NOT_FROM(source, TRAIT_CANNOT_EVADE_PROJECTILES, TACTICAL_RESTING_COMPONENT_TRAIT))
		return COMSIG_DODGE_PROJECTILE
