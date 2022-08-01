
/datum/action/cooldown/spell/pointed/swap
	name = "Swap"
	desc = "This spell allows you to swap locations with any living being."
	button_icon_state = "swap"
	ranged_mousepointer = 'icons/effects/mouse_pointers/swap_target.dmi'

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

/datum/action/cooldown/spell/pointed/swap/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(cast_on))
		to_chat(owner, span_warning("You can only swap locations with living beings!"))
		return FALSE
	return TRUE

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
	var/target_location = cast_on.loc
	do_teleport(cast_on, owner.loc, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	do_teleport(owner, target_location, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	cast_on.playsound_local(get_turf(cast_on), 'sound/magic/swap.ogg', 50, 1)
	owner.playsound_local(get_turf(owner), 'sound/magic/swap.ogg', 50, 1)
