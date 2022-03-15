/datum/action/cooldown/spell/tesla
	name = "Tesla Blast"
	desc = "Charge up a tesla arc and release it at random nearby targets! \
		You can move freely while it charges. The arc jumps between targets and can knock them down."
	action_icon_state = "lightning"

	sound = 'sound/magic/lightningbolt.ogg'
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 6.75 SECONDS

	invocation = "UN'LTD P'WAH!"
	invocation_type = INVOCATION_SHOUT
	school = SCHOOL_EVOCATION
	range = 7

	var/static/mutable_appearance/halo
	var/sound/charge_sound // so far only way i can think of to stop a sound, thank MSO for the idea.


/datum/action/cooldown/spell/tesla/before_cast(atom/cast_on)
	to_chat(user, span_notice("You start gathering power..."))
	charge_sound = new /sound('sound/magic/lightning_chargeup.ogg', channel = 7)
	halo = halo || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	user.add_overlay(halo)
	playsound(get_turf(cast_on), charge_sound, 50, FALSE)

	if(!do_after(user, 10 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM)))
		revert_cast()
		return FALSE

	return TRUE

/datum/action/cooldown/spell/tesla/revert_cast()
	reset_tesla(owner)
	return ..()

/datum/action/cooldown/spell/tesla/proc/reset_tesla()
	user.cut_overlay(halo)

/datum/action/cooldown/spell/tesla/cast(atom/cast_on)
	ready = FALSE

	// byond, why you suck?
	charge_sound = sound(null, repeat = 0, wait = 1, channel = charge_sound.channel)
	// Sorry MrPerson, but the other ways just didn't do it the way i needed to work, this is the only way.
	playsound(get_turf(cast_on), charge_sound, 50, FALSE)

	var/mob/living/carbon/to_zap_first = get_target(cast_on)
	if(QDELETED(to_zap_first))
		to_chat(cast_on, span_warning("No targets found!"))
		revert_cast()
		return

	zap_target(cast_on, to_zap_first)
	reset_tesla()

/datum/action/cooldown/spell/tesla/proc/zap_target(atom/origin, mob/living/carbon/to_zap, bolt_energy = 30, bounces = 5)
	origin.Beam(to_zap, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	playsound(get_turf(to_zap), 'sound/magic/lightningshock.ogg', 50, TRUE, -1)

	if(to_zap.anti_magic_check())
		to_zap.visible_message(
			span_warning("[to_zap] absorbs the spell, remaining unharmed!"),
			span_userdanger("You absorb the spell, remaining unharmed!"),
		)

	else
		to_zap.electrocute_act(bolt_energy, "Lightning Bolt", flags = SHOCK_NOGLOVES)

	if(bounces >= 1)
		var/mob/living/carbon/to_zap_next = get_target(to_zap)
		if(to_zap_next)
			zap_target(to_zap, to_zap_next, max((bolt_energy - 5), 5), bounces - 1)

/datum/action/cooldown/spell/tesla/proc/get_target(atom/center)
	var/list/possibles = list()
	for(var/mob/living/carbon/to_check in view(range, center))
		if(to_check == center || to_check == owner)
			continue
		if(!los_check(center, to_check))
			continue
		possibles += to_check

	return pick(possibles)
