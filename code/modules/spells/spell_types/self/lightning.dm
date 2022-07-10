/datum/action/cooldown/spell/tesla
	name = "Tesla Blast"
	desc = "Charge up a tesla arc and release it at random nearby targets! \
		You can move freely while it charges. The arc jumps between targets and can knock them down."
	button_icon_state = "lightning"

	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 6.75 SECONDS

	invocation = "UN'LTD P'WAH!"
	invocation_type = INVOCATION_SHOUT
	school = SCHOOL_EVOCATION

	/// Whether we're currently channelling a tesla blast or not
	var/currently_channeling = FALSE
	/// How long it takes to channel the zap.
	var/channel_time = 10 SECONDS
	/// The radius around (either the caster or people shocked) to which the tesla blast can reach
	var/shock_radius = 7
	/// The halo that appears around the caster while charging the spell
	var/static/mutable_appearance/halo
	/// The sound played while charging the spell
	/// Quote: "the only way i can think of to stop a sound, thank MSO for the idea."
	var/sound/charge_sound

/datum/action/cooldown/spell/tesla/Remove(mob/living/remove_from)
	reset_tesla(remove_from)
	return ..()

/datum/action/cooldown/spell/tesla/set_statpanel_format()
	. = ..()
	if(!islist(.))
		return

	if(currently_channeling)
		.[PANEL_DISPLAY_STATUS] = "CHANNELING"

/datum/action/cooldown/spell/tesla/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(currently_channeling)
		if(feedback)
			to_chat(owner, span_warning("You're already channeling [src]!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/tesla/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	to_chat(cast_on, span_notice("You start gathering power..."))
	charge_sound = new /sound('sound/magic/lightning_chargeup.ogg', channel = 7)
	halo ||= mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	cast_on.add_overlay(halo)
	playsound(get_turf(cast_on), charge_sound, 50, FALSE)

	currently_channeling = TRUE
	if(!do_after(cast_on, channel_time, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM)))
		reset_tesla(cast_on)
		return . | SPELL_CANCEL_CAST

	return TRUE

/datum/action/cooldown/spell/tesla/reset_spell_cooldown()
	reset_tesla(owner)
	return ..()

/// Resets the tesla effect.
/datum/action/cooldown/spell/tesla/proc/reset_tesla(atom/to_reset)
	to_reset.cut_overlay(halo)
	currently_channeling = FALSE

/datum/action/cooldown/spell/tesla/cast(atom/cast_on)
	. = ..()

	// byond, why you suck?
	charge_sound = sound(null, repeat = 0, wait = 1, channel = charge_sound.channel)
	// Sorry MrPerson, but the other ways just didn't do it the way i needed to work, this is the only way.
	playsound(get_turf(cast_on), charge_sound, 50, FALSE)

	var/mob/living/carbon/to_zap_first = get_target(cast_on)
	if(QDELETED(to_zap_first))
		cast_on.balloon_alert(cast_on, "no targets nearby!")
		reset_spell_cooldown()
		return FALSE

	playsound(get_turf(cast_on), 'sound/magic/lightningbolt.ogg', 50, TRUE)
	zap_target(cast_on, to_zap_first)
	reset_tesla(cast_on)
	return TRUE

/// Zaps a target, the bolt originating from origin.
/datum/action/cooldown/spell/tesla/proc/zap_target(atom/origin, mob/living/carbon/to_zap, bolt_energy = 30, bounces = 5)
	origin.Beam(to_zap, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	playsound(get_turf(to_zap), 'sound/magic/lightningshock.ogg', 50, TRUE, -1)

	if(to_zap.can_block_magic(antimagic_flags))
		to_zap.visible_message(
			span_warning("[to_zap] absorbs the spell, remaining unharmed!"),
			span_userdanger("You absorb the spell, remaining unharmed!"),
		)

	else
		to_zap.electrocute_act(bolt_energy, "Lightning Bolt", flags = SHOCK_NOGLOVES)

	if(bounces >= 1)
		var/mob/living/carbon/to_zap_next = get_target(to_zap)
		if(!QDELETED(to_zap_next))
			zap_target(to_zap, to_zap_next, max((bolt_energy - 5), 5), bounces - 1)

/// Get a target in view of us to zap next. Returns a carbon, or null if none were found.
/datum/action/cooldown/spell/tesla/proc/get_target(atom/center)
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
