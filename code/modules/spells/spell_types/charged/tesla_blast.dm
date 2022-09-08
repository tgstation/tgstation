/datum/action/cooldown/spell/charged/tesla
	name = "Tesla Blast"
	desc = "Charge up a tesla arc and release it at random nearby targets! \
		You can move freely while it charges. The arc jumps between targets and can knock them down."
	button_icon_state = "lightning"
	sound = 'sound/magic/lightningbolt.ogg'

	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 6.75 SECONDS

	invocation = "UN'LTD P'WAH!"
	invocation_type = INVOCATION_SHOUT
	school = SCHOOL_EVOCATION

	channel_message = span_notice("You start gathering power...")
	charge_overlay_icon = 'icons/effects/effects.dmi'
	charge_overlay_state = "electricity"
	charge_sound = 'sound/magic/lightning_chargeup.ogg'

	/// The radius around (either the caster or people shocked) to which the tesla blast can reach
	var/shock_radius = 7
	/// What's the max number of bounces before we stop zapping
	var/max_bounces = 5
	/// How much energy / damage does the initial bounce
	var/initial_energy = 30
	/// How much energy / damage is lost per bounce
	var/energy_lost_per_bounce = 5

/datum/action/cooldown/spell/charged/tesla/cast(atom/cast_on)
	var/mob/living/carbon/to_zap_first = get_target(cast_on)
	if(isnull(to_zap_first))
		cast_on.balloon_alert(cast_on, "no targets nearby!")
		reset_spell_cooldown()
		stop_channel_effect(cast_on)
		return

	zap_target(cast_on, to_zap_first, initial_energy, max_bounces)
	return ..()

/// Zaps a target, the bolt originating from origin.
/datum/action/cooldown/spell/charged/tesla/proc/zap_target(atom/origin, mob/living/carbon/to_zap, bolt_energy = 30, bounces = 5)
	origin.Beam(to_zap, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	playsound(get_turf(to_zap), 'sound/magic/lightningshock.ogg', 50, TRUE, -1)

	if(to_zap.can_block_magic(antimagic_flags))
		to_zap.visible_message(
			span_warning("[to_zap] absorbs the spell, remaining unharmed!"),
			span_userdanger("You absorb the spell, remaining unharmed!"),
		)

	else
		to_zap.electrocute_act(bolt_energy, "Lightning Bolt", flags = SHOCK_NOGLOVES)

	// Bounce again! Call our proc recursively to keep the chain going (even if our mob blocked it with antimagic)
	if(bounces < 1)
		return
	var/mob/living/carbon/to_zap_next = get_target(to_zap)
	if(isnull(to_zap_next))
		return
	zap_target(to_zap, to_zap_next, max(bolt_energy - energy_lost_per_bounce, energy_lost_per_bounce), bounces - 1)

/// Get a target in view of us to zap next. Returns a carbon, or null if none were found.
/datum/action/cooldown/spell/charged/tesla/proc/get_target(atom/center)
	var/list/possibles = list()
	for(var/mob/living/carbon/to_check in view(shock_radius, center))
		if(to_check == center || to_check == owner)
			continue
		if(!length(get_path_to(center, to_check, max_distance = shock_radius, simulated_only = FALSE)))
			continue

		possibles += to_check

	if(!length(possibles))
		return null

	return pick(possibles)
