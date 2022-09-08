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
	cooldown_time = 40 SECONDS

	invocation = "V'LC'N!"
	invocation_type = INVOCATION_SHOUT
	channel_time = 5 SECONDS

	/// The max number of chains between mobs
	var/max_bounces = 4
	/// How much each blast does in burn damage
	var/blast_burn_damage = 20
	/// How much firestacks each blast applies
	var/blast_firestacks = 2
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

/datum/action/cooldown/spell/charged/fire_blast/proc/send_fire_beam(atom/origin, mob/living/carbon/to_blast, bounces = 4)
	// Send a beam from the origin to the hit mob
	origin.Beam(to_blast, icon_state = "solar_beam", time = beam_duration)

	// If they block the magic, the chain wont necessarily stop, but likely will
	// (due to them not catching on fire)
	if(to_blast.can_block_magic(antimagic_flags))
		to_blast.visible_message(
			span_warning("[to_blast] absorbs the spell, remaining unharmed!"),
			span_userdanger("You absorb the spell, remaining unharmed!"),
		)

	// Otherwise, if unblocked apply the damage and set them up
	else
		to_blast.apply_damage(blast_burn_damage, BURN)
		to_blast.adjust_fire_stacks(blast_firestacks)
		to_blast.ignite_mob()

	// Next beam will happen in about half the duration of the beam
	var/next_beam_happens_in = beam_duration / 2
	// Apply the fire blast status effect to show they got blasted
	to_blast.apply_status_effect(/datum/status_effect/fire_blasted, next_beam_happens_in * 0.75)

	playsound(to_blast, sound, 50, TRUE, -1)
	// No more bounces left. Stop here
	if(bounces < 1)
		return

	// Chain continues shotly after. If they extinguish themselves in this time, the chain will stop anyways.
	addtimer(CALLBACK(src, .proc/continue_beam, to_blast, bounces), next_beam_happens_in)

/datum/action/cooldown/spell/charged/fire_blast/proc/continue_beam(mob/living/carbon/to_blast, bounces)
	if(QDELETED(to_blast) || !to_blast.on_fire || !to_blast.has_status_effect(/datum/status_effect/fire_blasted))
		return
	var/mob/living/carbon/to_blast_next = get_target_with_priority(to_blast)
	if(isnull(to_blast_next))
		return

	send_fire_beam(to_blast, to_blast_next, bounces - 1)

/datum/action/cooldown/spell/charged/fire_blast/proc/get_target_with_priority(atom/center)
	var/list/possibles = list()
	var/list/priority_possibles = list()
	for(var/mob/living/carbon/to_check in view(5, center))
		if(to_check == center || to_check == owner)
			continue
		if(to_check.has_status_effect(/datum/status_effect/fire_blasted)) // Already blasted
			continue
		if(!length(get_path_to(center, to_check, max_distance = 5, simulated_only = FALSE)))
			continue

		possibles += to_check
		if(to_check.on_fire)
			priority_possibles += to_check

	if(!length(possibles))
		return null

	return length(priority_possibles) ? pick(priority_possibles) : pick(possibles)


/// Status effect that handles adding and removing an overlay to a mob who's been fireblasted.
/datum/status_effect/fire_blasted
	id = "fire_blasted"
	alert_type = null
	duration = 5 SECONDS
	/// An appearance we apply below the mob to show they've been blasted
	var/image/warning_sign
	/// How long does the animation of the appearance last?
	var/animate_duration = 0.75 SECONDS

/datum/status_effect/fire_blasted/on_creation(mob/living/new_owner, animate_duration = 0.75 SECONDS)
	src.animate_duration = animate_duration
	return ..()

/datum/status_effect/fire_blasted/on_apply()
	if(owner.on_fire) // Melbert todo: This kinda sucks I think
		warning_sign = image(icon = 'icons/effects/effects.dmi', icon_state = "blessed", layer = BELOW_MOB_LAYER)
		if(warning_sign)
			warning_sign.alpha = 0
			owner.add_overlay(warning_sign)
			animate(warning_sign, alpha = 255, time = animate_duration)
		else
			stack_trace("[type] didn't make an image. Huh?")
		RegisterSignal(owner, COMSIG_LIVING_EXTINGUISHED, .proc/on_extinguished)

	return TRUE

/datum/status_effect/fire_blasted/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_EXTINGUISHED)
	clean_overlay()

/// Signal proc for [COMSIG_LIVING_EXTINGUISHED], remove the overlay when we're extinguished.
/datum/status_effect/fire_blasted/proc/on_extinguished(datum/source)
	SIGNAL_HANDLER

	clean_overlay()

/// Helper to remove the overlay from the owner and null it out.
/datum/status_effect/fire_blasted/proc/clean_overlay()
	if(!warning_sign)
		return

	owner.cut_overlay(warning_sign)
	warning_sign = null
