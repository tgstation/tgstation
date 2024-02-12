/**
 * Draws a line between you and another atom, hurt anyone stood in the line
 */
/datum/component/damage_chain
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// How often do we attempt to deal damage?
	var/tick_interval
	/// Tracks when we can next deal damage
	COOLDOWN_DECLARE(tick_cooldown)
	/// Damage inflicted per tick
	var/damage_per_tick
	/// Type of damage to inflict
	var/damage_type
	/// Optional callback which checks if we can damage the target
	var/datum/callback/validate_target
	/// Optional callback for additional visuals or text display when dealing damage
	var/datum/callback/chain_damage_feedback
	/// We will fire the damage feedback callback on every x successful attacks
	var/feedback_interval
	/// How many successful attacks have we made?
	var/successful_attacks = 0
	/// Time between making any attacks at which we just reset the successful attack counter
	var/reset_feedback_timer = 0
	/// Our chain
	var/datum/beam/chain

/datum/component/damage_chain/Initialize(
	atom/linked_to,
	max_distance = 7,
	beam_icon = 'icons/effects/beam.dmi',
	beam_state = "medbeam",
	beam_type = /obj/effect/ebeam,
	tick_interval = 0.3 SECONDS,
	damage_per_tick = 1.2,
	damage_type = BURN,
	datum/callback/validate_target = null,
	datum/callback/chain_damage_feedback = null,
	feedback_interval = 5,
)
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if (!isatom(linked_to))
		CRASH("Attempted to create [type] linking [parent.type] with non-atom [linked_to]!")

	src.tick_interval = tick_interval
	src.damage_per_tick = damage_per_tick
	src.damage_type = damage_type
	src.validate_target = validate_target
	src.chain_damage_feedback = chain_damage_feedback
	src.feedback_interval = feedback_interval

	var/atom/atom_parent = parent
	chain = atom_parent.Beam(linked_to, icon = beam_icon, icon_state = beam_state, beam_type = beam_type, maxdistance = max_distance)
	RegisterSignal(chain, COMSIG_QDELETING, PROC_REF(end_beam))
	START_PROCESSING(SSfastprocess, src)

/datum/component/damage_chain/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(end_beam)) // We actually don't really use many signals it's all processing

/datum/component/damage_chain/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)

/datum/component/damage_chain/Destroy(force)
	if (!QDELETED(chain))
		UnregisterSignal(chain, COMSIG_QDELETING)
		QDEL_NULL(chain)
	chain = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/// Destroy ourself
/datum/component/damage_chain/proc/end_beam()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/damage_chain/process(seconds_per_tick)
	var/successful_hit = FALSE
	var/list/target_turfs = list()
	for(var/obj/effect/ebeam/chainpart in chain.elements)
		if (isnull(chainpart) || !chainpart.x || !chainpart.y || !chainpart.z)
			continue
		var/turf/overlaps = get_turf_pixel(chainpart)
		target_turfs |= overlaps
		if(overlaps == get_turf(chain.origin) || overlaps == get_turf(chain.target))
			continue
		for(var/turf/nearby_turf in circle_range(overlaps, 1))
			target_turfs |= nearby_turf

	for(var/turf/hit_turf as anything in target_turfs)
		for(var/mob/living/victim in hit_turf)
			if (victim == parent || victim.stat == DEAD)
				continue
			if (!isnull(validate_target) && !validate_target.Invoke(victim))
				continue
			if (successful_attacks == 0)
				chain_damage_feedback?.Invoke(victim)
			victim.apply_damage(damage_per_tick, damage_type, wound_bonus = CANT_WOUND)
			successful_hit = TRUE

	if (isnull(chain_damage_feedback))
		return
	if (successful_hit)
		successful_attacks++
		reset_feedback_timer = addtimer(CALLBACK(src, PROC_REF(reset_feedback)), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_DELETE_ME)
	if (successful_attacks > feedback_interval)
		reset_feedback()

/// Make it so that the next time we hit something we'll invoke the feedback callback
/datum/component/damage_chain/proc/reset_feedback()
	successful_attacks = 0
	deltimer(reset_feedback_timer)
