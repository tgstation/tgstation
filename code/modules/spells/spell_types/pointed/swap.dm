/datum/action/cooldown/spell/pointed/swap
	name = "Swap"
	desc = "This spell allows you to swap locations with any living being. \
		RMB: Mark a secondary swap target. This secondary swap target will be discarded once you swap, \
		or else you can click yourself with the RMB to discard your secondary target."
	button_icon_state = "swap"
	ranged_mousepointer = 'icons/effects/mouse_pointers/swap_target.dmi'
	active_overlay_icon_state = "bg_spell_border_active_blue"

	school = SCHOOL_TRANSLOCATION
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 6 SECONDS
	cast_range = 9
	invocation = "FRO' BRT'TRO, DA!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_OFF_CENTCOM
	active_msg = "You prepare to swap locations with a target..."

	smoke_type = /datum/effect_system/fluid_spread/smoke
	smoke_amt = 0

	/// A variable for holding the second selected target with right click.
	var/mob/living/second_target

/datum/action/cooldown/spell/pointed/swap/Destroy()
	second_target = null
	return ..()

/datum/action/cooldown/spell/pointed/swap/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(cast_on))
		to_chat(owner, span_warning("You can only swap locations with living beings!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/swap/InterceptClickOn(mob/living/caller, params, atom/click_target)
	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		if(!IsAvailable(feedback = TRUE))
			return FALSE
		if(!target)
			return FALSE
		if(!isliving(click_target) || isturf(click_target))
			// Find any living being in the list. We aren't picky, it's aim assist after all
			click_target = locate(/mob/living) in click_target
			if(!click_target)
				to_chat(owner, span_warning("You can only select living beings as secondary target!"))
				return FALSE
		if(click_target == owner)
			if(!isnull(second_target))
				to_chat(owner, span_notice("You cancel your secondary swap target!"))
				second_target = null
			else
				to_chat(owner, span_warning("You have no secondary swap target!"))
			return FALSE
		second_target = click_target
		to_chat(owner, span_notice("You select [click_target.name] as a secondary swap target!"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/swap/cast(mob/living/carbon/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(owner, span_warning("The spell had no effect!"))
		to_chat(cast_on, span_warning("You feel space bending, but it rapidly dissipates."))
		return FALSE

	to_chat(cast_on, span_userdanger("You feel space bending."))
	if(ispath(smoke_type, /datum/effect_system/fluid_spread/smoke))
		var/datum/effect_system/fluid_spread/smoke/smoke = new smoke_type()
		smoke.set_up(smoke_amt, holder = owner, location = get_turf(owner))
		smoke.start()
	var/turf/target_location = get_turf(cast_on)
	if(!isnull(second_target) && get_dist(owner, second_target) <= cast_range && !(cast_on == second_target))
		to_chat(second_target, span_userdanger("You feel space bending."))
		if(ispath(smoke_type, /datum/effect_system/fluid_spread/smoke))
			var/datum/effect_system/fluid_spread/smoke/smoke = new smoke_type()
			smoke.set_up(smoke_amt, holder = owner, location = get_turf(second_target))
			smoke.start()
		var/turf/second_location = get_turf(second_target)
		do_teleport(second_target, owner.loc, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
		do_teleport(cast_on, second_location, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
		do_teleport(owner, target_location, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
		second_target.playsound_local(get_turf(second_target), 'sound/magic/swap.ogg', 50, 1)
		cast_on.playsound_local(get_turf(cast_on), 'sound/magic/swap.ogg', 50, 1)
		owner.playsound_local(get_turf(owner), 'sound/magic/swap.ogg', 50, 1)
	else
		do_teleport(cast_on, owner.loc, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
		do_teleport(owner, target_location, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
		cast_on.playsound_local(get_turf(cast_on), 'sound/magic/swap.ogg', 50, 1)
		owner.playsound_local(get_turf(owner), 'sound/magic/swap.ogg', 50, 1)
	second_target = null
