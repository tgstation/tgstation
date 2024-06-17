/datum/action/cooldown/spell/charged/beam/fire_blast
	name = "Volcano Blast"
	desc = "Charge up a blast of fire that chains between nearby targets, setting them ablaze. \
		Targets already on fire will take priority. If the target fails to catch ablaze, or \
		extinguishes themselves before it bounces, the chain will stop."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "flames"
	sound = 'sound/magic/fireball.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "Eld'fjall!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	channel_time = 5 SECONDS
	target_radius = 5
	max_beam_bounces = 4

	/// How long the beam visual lasts, also used to determine time between jumps
	var/beam_duration = 2 SECONDS

/datum/action/cooldown/spell/charged/beam/fire_blast/cast(atom/cast_on)
	if(isliving(cast_on))
		var/mob/living/caster = cast_on
		// Caster becomes fireblasted, but in a good way - heals damage over time
		caster.apply_status_effect(/datum/status_effect/fire_blasted, beam_duration, -2)
	return ..()

/datum/action/cooldown/spell/charged/beam/fire_blast/send_beam(atom/origin, mob/living/carbon/to_beam, bounces = 4)
	// Send a beam from the origin to the hit mob
	origin.Beam(to_beam, icon_state = "solar_beam", time = beam_duration, beam_type = /obj/effect/ebeam/reacting/fire)

	// If they block the magic, the chain wont necessarily stop,
	// but likely will (due to them not catching on fire)
	if(to_beam.can_block_magic(antimagic_flags))
		to_beam.visible_message(
			span_warning("[to_beam] absorbs the spell, remaining unharmed!"),
			span_userdanger("You absorb the spell, remaining unharmed!"),
		)
		// Apply status effect but with no overlay
		to_beam.apply_status_effect(/datum/status_effect/fire_blasted)

	// Otherwise, if unblocked apply the damage and set them up
	else
		to_beam.apply_damage(20, BURN, wound_bonus = 5)
		to_beam.adjust_fire_stacks(3)
		to_beam.ignite_mob()
		// Apply the fire blast status effect to show they got blasted
		to_beam.apply_status_effect(/datum/status_effect/fire_blasted, beam_duration * 0.5)

	// We can keep bouncing, try to continue the chain
	if(bounces >= 1)
		playsound(to_beam, sound, 50, vary = TRUE, extrarange = -1)
		// Chain continues shortly after. If they extinguish themselves in this time, the chain will stop anyways.
		addtimer(CALLBACK(src, PROC_REF(continue_beam), to_beam, bounces), beam_duration * 0.5)

	else
		playsound(to_beam, sound, 50, vary = TRUE, frequency = 12000)
		// We hit the maximum chain length, apply a bonus for managing it
		new /obj/effect/temp_visual/fire_blast_bonus(to_beam.loc)
		for(var/mob/living/nearby_living in range(1, to_beam))
			if(IS_HERETIC_OR_MONSTER(nearby_living) || nearby_living == owner)
				continue
			nearby_living.Knockdown(0.8 SECONDS)
			nearby_living.apply_damage(15, BURN, wound_bonus = 5)
			nearby_living.adjust_fire_stacks(2)
			nearby_living.ignite_mob()

/// Timer callback to continue the chain, calling send_fire_bream recursively.
/datum/action/cooldown/spell/charged/beam/fire_blast/proc/continue_beam(mob/living/carbon/beamed, bounces)
	// We will only continue the chain if we exist, are still on fire, and still have the status effect
	if(QDELETED(beamed) || !beamed.on_fire || !beamed.has_status_effect(/datum/status_effect/fire_blasted))
		return
	// We fulfilled the conditions, get the next target
	var/mob/living/carbon/to_beam_next = get_target(beamed)
	if(isnull(to_beam_next)) // No target = no chain
		return

	// Chain again! Recursively
	send_beam(beamed, to_beam_next, bounces - 1)

/// Pick a carbon mob in a radius around us that we can reach.
/// Mobs on fire will have priority and be targeted over others.
/// Returns null or a carbon mob.
/datum/action/cooldown/spell/charged/beam/fire_blast/get_target(atom/center)
	var/list/possibles = list()
	var/list/priority_possibles = list()
	for(var/mob/living/carbon/to_check in view(target_radius, center))
		if(to_check == center || to_check == owner)
			continue
		if(to_check.has_status_effect(/datum/status_effect/fire_blasted)) // Already blasted
			continue
		if(IS_HERETIC_OR_MONSTER(to_check))
			continue
		if(!length(get_path_to(center, to_check, max_distance = target_radius, simulated_only = FALSE)))
			continue

		possibles += to_check
		if(to_check.on_fire && to_check.stat != DEAD)
			priority_possibles += to_check

	if(!length(possibles))
		return null

	return length(priority_possibles) ? pick(priority_possibles) : pick(possibles)

/**
 * Status effect applied when someone's hit by the fire blast.
 *
 * Applies an overlay, then causes a damage over time (or heal over time)
 */
/datum/status_effect/fire_blasted
	id = "fire_blasted"
	alert_type = null
	duration = 5 SECONDS
	tick_interval = 0.5 SECONDS
	/// How much fire / stam to do per tick (stamina damage is doubled this)
	var/tick_damage = 1
	/// How long does the animation of the appearance last? If 0 or negative, we make no overlay
	var/animate_duration = 0.75 SECONDS

/datum/status_effect/fire_blasted/on_creation(mob/living/new_owner, animate_duration = -1, tick_damage = 1)
	src.animate_duration = animate_duration
	src.tick_damage = tick_damage
	return ..()

/datum/status_effect/fire_blasted/on_apply()
	if(owner.on_fire && animate_duration > 0 SECONDS)
		var/mutable_appearance/warning_sign = mutable_appearance('icons/effects/effects.dmi', "blessed", BELOW_MOB_LAYER)
		var/atom/movable/flick_visual/warning = owner.flick_overlay_view(warning_sign, initial(duration))
		warning.alpha = 50
		animate(warning, alpha = 255, time = animate_duration)

	return TRUE

/datum/status_effect/fire_blasted/tick(seconds_between_ticks)
	owner.adjustFireLoss(tick_damage * seconds_between_ticks)
	owner.adjustStaminaLoss(2 * tick_damage * seconds_between_ticks)

// The beam fireblast spits out, causes people to walk through it to be on fire
/obj/effect/ebeam/reacting/fire
	name = "fire beam"

/obj/effect/ebeam/reacting/fire/beam_entered(atom/movable/entered)
	. = ..()
	if(!isliving(entered))
		return
	var/mob/living/living_entered = entered
	if(IS_HERETIC_OR_MONSTER(living_entered) || living_entered.has_status_effect(/datum/status_effect/fire_blasted))
		return
	living_entered.apply_damage(10, BURN, wound_bonus = 5)
	living_entered.adjust_fire_stacks(2)
	living_entered.ignite_mob()
	// Apply the fireblasted effect - no overlay
	living_entered.apply_status_effect(/datum/status_effect/fire_blasted)

// Visual effect played when we hit the max bounces
/obj/effect/temp_visual/fire_blast_bonus
	name = "fire blast"
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosion"
	duration = 1 SECONDS
