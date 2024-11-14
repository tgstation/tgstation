/datum/action/cooldown/spell/charged/beam/tesla
	name = "Tesla Blast"
	desc = "Charge up a tesla arc and release it at random nearby targets! \
		You can move freely while it charges. The arc jumps between targets and can knock them down."
	button_icon_state = "lightning"
	sound = 'sound/effects/magic/lightningbolt.ogg'

	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 6.75 SECONDS

	invocation = "UN'LTD P'WAH!"
	invocation_type = INVOCATION_SHOUT
	school = SCHOOL_EVOCATION

	channel_message = span_notice("You start gathering power...")
	charge_overlay_icon = 'icons/effects/effects.dmi'
	charge_overlay_state = "electricity"
	charge_sound = 'sound/effects/magic/lightning_chargeup.ogg'
	target_radius = 7
	max_beam_bounces = 5

	/// How much energy / damage does the initial bounce
	var/initial_energy = 30
	/// How much energy / damage is lost per bounce
	var/energy_lost_per_bounce = 5

/// Zaps a target, the bolt originating from origin.
/datum/action/cooldown/spell/charged/beam/tesla/send_beam(atom/origin, mob/living/carbon/to_beam, bolt_energy = 30, bounces = 5)
	origin.Beam(to_beam, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	playsound(get_turf(to_beam), 'sound/effects/magic/lightningshock.ogg', 50, TRUE, -1)

	if(to_beam.can_block_magic(antimagic_flags))
		to_beam.visible_message(
			span_warning("[to_beam] absorbs the spell, remaining unharmed!"),
			span_userdanger("You absorb the spell, remaining unharmed!"),
		)

	else
		to_beam.electrocute_act(bolt_energy, "Lightning Bolt", flags = SHOCK_NOGLOVES)

	// Bounce again! Call our proc recursively to keep the chain going (even if our mob blocked it with antimagic)
	if(bounces < 1)
		return
	var/mob/living/carbon/to_beam_next = get_target(to_beam)
	if(isnull(to_beam_next))
		return
	send_beam(to_beam, to_beam_next, max(bolt_energy - energy_lost_per_bounce, energy_lost_per_bounce), bounces - 1)

/datum/action/cooldown/spell/charged/beam/tesla/get_target(atom/center)
	var/list/possibles = list()
	for(var/mob/living/carbon/to_check in view(target_radius, center))
		if(to_check == center || to_check == owner)
			continue
		if(!length(get_path_to(center, to_check, max_distance = target_radius, simulated_only = FALSE)))
			continue

		possibles += to_check

	if(!length(possibles))
		return null

	return pick(possibles)
