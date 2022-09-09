/datum/action/cooldown/spell/charged/fire_blast
	name = "Volcano Blast"
	desc = "Charge up a blast of fire that chains between nearby targets, setting them ablaze. \
		Targets already on fire will take priority. If the target fails to catch ablaze, or \
		extinguishes themselves before it bounces, the chain will stop."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "flames"
	sound = 'sound/magic/fireball.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "V'LC'N!"
	invocation_type = INVOCATION_SHOUT
	channel_time = 5 SECONDS

	/// The max number of chains between mobs
	var/max_bounces = 4
	/// How long the beam visual lasts, also used to determine time between jumps
	var/beam_duration = 2 SECONDS

/datum/action/cooldown/spell/charged/fire_blast/cast(atom/cast_on)
	var/mob/living/carbon/to_blast_first = get_target_with_priority(cast_on)
	if(isnull(to_blast_first))
		cast_on.balloon_alert(cast_on, "no targets nearby!")
		reset_spell_cooldown()
		stop_channel_effect(cast_on)
		return

	send_fire_beam(cast_on, to_blast_first, max_bounces)
	return ..()

/**
 * Sends a fire beam from [origin] to [to_blast].
 * Dealing damage and igniting the target mob if they have no antimagic.
 * Recursive, the number of recursions dictated by the bounces parameter.
 */
/datum/action/cooldown/spell/charged/fire_blast/proc/send_fire_beam(atom/origin, mob/living/carbon/to_blast, bounces = 4)
	// Send a beam from the origin to the hit mob
	origin.Beam(to_blast, icon_state = "solar_beam", time = beam_duration, beam_type = /obj/effect/ebeam/fire)

	// If they block the magic, the chain wont necessarily stop, but likely will
	// (due to them not catching on fire)
	if(to_blast.can_block_magic(antimagic_flags))
		to_blast.visible_message(
			span_warning("[to_blast] absorbs the spell, remaining unharmed!"),
			span_userdanger("You absorb the spell, remaining unharmed!"),
		)
		// Apply status effect but with no overlay
		to_blast.apply_status_effect(/datum/status_effect/fire_blasted)

	// Otherwise, if unblocked apply the damage and set them up
	else
		to_blast.apply_damage(20, BURN, wound_bonus = 5)
		to_blast.adjust_fire_stacks(3)
		to_blast.ignite_mob()
		// Apply the fire blast status effect to show they got blasted
		to_blast.apply_status_effect(/datum/status_effect/fire_blasted, next_beam_happens_in * 0.1.5)

	// We can keep bouncing, try to continue the chain
	if(bounces >= 1)
		playsound(to_blast, sound, 50, vary = TRUE, extrarange = -1)
		// Chain continues shortly after. If they extinguish themselves in this time, the chain will stop anyways.
		addtimer(CALLBACK(src, .proc/continue_beam, to_blast, bounces), beam_duration * 0.5)

	else
		playsound(to_blast, sound, 50, vary = TRUE, frequency = 12000)
		// We hit the maximum chain length, apply a bonus for managing it
		new /obj/effect/temp_visual/fire_blast_bonus(to_blast.loc)
		for(var/mob/living/nearby_living in range(1, to_blast))
			if(IS_HERETIC_OR_MONSTER(nearby_living) || nearby_living == owner)
				continue
			nearby_living.Knockdown(0.8 SECONDS)
			nearby_living.apply_damage(15, BURN, wound_bonus = 5)
			nearby_living.adjust_fire_stacks(2)
			nearby_living.ignite_mob()

/// Timer callback to continue the chain, calling send_fire_bream recursively.
/datum/action/cooldown/spell/charged/fire_blast/proc/continue_beam(mob/living/carbon/to_blast, bounces)
	// We will only continue the chain if we exist, are still on fire, and still have the status effect
	if(QDELETED(to_blast) || !to_blast.on_fire || !to_blast.has_status_effect(/datum/status_effect/fire_blasted))
		return
	// We fulfilled the conditions, get the next target
	var/mob/living/carbon/to_blast_next = get_target_with_priority(to_blast)
	if(isnull(to_blast_next)) // No target = no chain
		return

	// Chain again! Recursively
	send_fire_beam(to_blast, to_blast_next, bounces - 1)

/// Pick a carbon mob in a radius around us that we can reach.
/// Mobs on fire will have priority and be targeted over others.
/// Returns null or a carbon mob.
/datum/action/cooldown/spell/charged/fire_blast/proc/get_target_with_priority(atom/center, radius = 5)
	var/list/possibles = list()
	var/list/priority_possibles = list()
	for(var/mob/living/carbon/to_check in view(radius, center))
		if(to_check == center || to_check == owner)
			continue
		if(to_check.has_status_effect(/datum/status_effect/fire_blasted)) // Already blasted
			continue
		if(IS_HERETIC_OR_MONSTER(to_check))
			continue
		if(!length(get_path_to(center, to_check, max_distance = radius, simulated_only = FALSE)))
			continue

		possibles += to_check
		if(to_check.on_fire && to_check.stat != DEAD)
			priority_possibles += to_check

	if(!length(possibles))
		return null

	return length(priority_possibles) ? pick(priority_possibles) : pick(possibles)

// Status effect applied when someone's hit by the fire blast. Applies and overlay and causes some damage over time.
/datum/status_effect/fire_blasted
	id = "fire_blasted"
	alert_type = null
	duration = 5 SECONDS
	tick_interval = 0.5 SECONDS
	/// How long does the animation of the appearance last? If 0 or negative, we make no overlay
	var/animate_duration = 0.75 SECONDS

/datum/status_effect/fire_blasted/on_creation(mob/living/new_owner, animate_duration = -1)
	src.animate_duration = animate_duration
	return ..()

/datum/status_effect/fire_blasted/on_apply()
	if(owner.on_fire && animate_duration > 0 SECONDS)
		var/image/warning_sign = image(icon = 'icons/effects/effects.dmi', icon_state = "blessed", layer = BELOW_MOB_LAYER, loc = owner)
		flick_overlay_view(warning_sign, owner, initial(duration))
		warning_sign.alpha = 50
		animate(warning_sign, alpha = 255, time = animate_duration)

	return TRUE

/datum/status_effect/fire_blasted/tick(delta_time, times_fired)
	owner.take_overall_damage(burn = 1, stamina = 2)

// The beam fireblast spits out, causes people to walk through it to be on fire
/obj/effect/ebeam/fire
	name = "fire beam"

/obj/effect/ebeam/fire/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	if(!isturf(loc) || mapload) // idk if this would ever be maploaded but you never know
		return

	for(var/mob/living/living_mob in loc)
		on_entered(entered = living_mob)

/obj/effect/ebeam/fire/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(!isliving(entered))
		return
	var/mob/living/living_entered = entered
	if(IS_HERETIC_OR_MONSTER(living_entered) || living_entered.has_status_effect(/datum/status_effect/fire_blasted))
		return
	living_entered.apply_damage(10, BURN, wound_bonus = 5)
	living_entered.adjust_fire_stacks(2)
	living_entered.ignite_mob()
	living_entered.apply_status_effect(/datum/status_effect/fire_blasted) // No overlay, just the status

// Visual effect played when we hit the max bounces
/obj/effect/temp_visual/fire_blast_bonus
	name = "fire blast"
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosion"
	duration = 1 SECONDS
