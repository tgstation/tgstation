///Ensures mobs that have recently stopped crawling can be hit by projectiles with hit_crawling_targets TRUE for just a little longer.
#define CRAWLING_PENALTY (0.5 SECONDS)

/**
 * Allows a living mobs that's lying on the floor to avoid getting hit by bullets and thrown objects not
 * with hit_crawling_targets TRUE and not directly aimed at them when prone but not crawling and without
 * the CANNOT_AVOID_PROJECTILES trait.
 */
/datum/component/prone_projectiles_avoidance
	/**
	 * Stores the value of the movement delay (be it from AIs or client) of last successful movement plus CRAWLING_PENALTY.
	 * Projectiles should be unavoidable as long as this is higher than world.time.
	 */
	var/successful_move_penalty
	/// The connect_loc_behalf component necessary for getting intercept thrown things moving over the mob.
	var/datum/component/connect_loc_behalf/thrownthing_catcher

/datum/component/prone_projectiles_avoidance/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/prone_projectiles_avoidance/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_AI_MOVED, .proc/on_ai_moved)
	RegisterSignal(parent, COMSIG_MOB_CLIENT_MOVED, .proc/on_client_moved)
	RegisterSignal(parent, COMSIG_LIVING_ON_LYING_DOWN, .proc/on_lying_down)
	RegisterSignal(parent, COMSIG_LIVING_ON_STANDING_UP, .proc/on_standing_up)
	// If the parent is already prone, add the connect_loc_behalf component.
	var/mob/living/living_parent = parent
	if(living_parent.body_position == LYING_DOWN)
		RegisterSignal(parent, COMSIG_ATOM_CAN_BE_HIT_BY_PROJECTILE, .proc/can_be_hit_by_projectile)
		thrownthing_catcher = AddComponent(/datum/component/connect_loc_behalf, parent, list(COMSIG_TURF_FIND_THROWNTHING_TARGET = .proc/thrownthing_find_target))

/datum/component/prone_projectiles_avoidance/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_AI_MOVED, COMSIG_MOB_CLIENT_MOVED, COMSIG_LIVING_ON_LYING_DOWN, COMSIG_LIVING_ON_STANDING_UP, COMSIG_ATOM_CAN_BE_HIT_BY_PROJECTILE))
	QDEL_NULL(thrownthing_catcher)
	successful_move_penalty = null

/datum/component/prone_projectiles_avoidance/proc/on_ai_moved(atom/movable/source, datum/ai_controller/controller, delta_time)
	SIGNAL_HANDLER
	successful_move_penalty = controller.movement_cooldown + CRAWLING_PENALTY

/datum/component/prone_projectiles_avoidance/proc/on_client_moved(mob/source)
	SIGNAL_HANDLER
	successful_move_penalty = source.client.move_delay + CRAWLING_PENALTY

/datum/component/prone_projectiles_avoidance/proc/on_lying_down(datum/source, new_lying_angle)
	SIGNAL_HANDLER
	RegisterSignal(parent, COMSIG_ATOM_CAN_BE_HIT_BY_PROJECTILE, .proc/can_be_hit_by_projectile)
	thrownthing_catcher = AddComponent(/datum/component/connect_loc_behalf, parent, list(COMSIG_TURF_FIND_THROWNTHING_TARGET = .proc/thrownthing_find_target))

/datum/component/prone_projectiles_avoidance/proc/on_standing_up()
	SIGNAL_HANDLER
	UnregisterSignal(parent, COMSIG_ATOM_CAN_BE_HIT_BY_PROJECTILE)
	QDEL_NULL(thrownthing_catcher)

/datum/component/prone_projectiles_avoidance/proc/can_be_hit_by_projectile(mob/living/source, obj/projectile, direct_target, ignore_loc, cross_failed)
	SIGNAL_HANDLER
	if(direct_target || cross_failed)
		return
	if(successful_move_penalty <= world.time && !HAS_TRAIT(source, TRAIT_CANNOT_EVADE_PROJECTILES))
		return COMSIG_DODGE_PROJECTILE

/datum/component/prone_projectiles_avoidance/proc/thrownthing_find_target(turf/source, datum/thrownthing/throwdatum, atom/actual_target)
	SIGNAL_HANDLER
	var/mob/living/living_parent = parent
	// Skip if the thrown thing has either completed its trajectory or isn't hitting crawling mobs or if the parent is incapacitated.
	if(!throwdatum.thrownthing.throwing || !throwdatum.hit_crawling_targets || PROJECTILES_SHOULD_AVOID(living_parent))
		return
	if(successful_move_penalty <= world.time && !HAS_TRAIT(living_parent, TRAIT_CANNOT_EVADE_PROJECTILES))
		throwdatum.finalize(TRUE, living_parent)

#undef CRAWLING_PENALTY
