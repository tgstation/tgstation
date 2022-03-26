/datum/action/cooldown/spell/pointed/mind_transfer
	name = "Mind Transfer"
	desc = "This spell allows the user to switch bodies with a target next to him."
	button_icon_state = "mindswap"
	ranged_mousepointer = 'icons/effects/mouse_pointers/mindswap_target.dmi'

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank =  10 SECONDS
	spell_requirements = SPELL_REQUIRES_MIND

	invocation = "GIN'YU CAPAN"
	invocation_type = INVOCATION_WHISPER

	active_msg = "You prepare to swap minds with a target..."
	deactive_msg = "You dispel mind swap."
	cast_range = 1

	/// For how long is the caster stunned for after the spell
	var/unconscious_amount_caster = 40 SECONDS
	/// For how long is the victim stunned for after the spell
	var/unconscious_amount_victim = 40 SECONDS

	var/static/list/mob/living/blacklisted_mobs = typecacheof(list(
		/mob/living/simple_animal/hostile/imp/slaughter,
		/mob/living/simple_animal/hostile/megafauna,
	))

/datum/action/cooldown/spell/pointed/mind_transfer/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(owner))
		return FALSE
	if(owner.suiciding)
		if(feedback)
			to_chat(owner, span_warning("You're killing yourself! You can't concentrate enough to do this!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/mind_transfer/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	if(!isliving(cast_on))
		to_chat(owner, span_warning("You can only swap minds with living beings!"))
		return FALSE
	if(is_type_in_typecache(cast_on, blacklisted_mobs))
		to_chat(owner, span_warning("This creature is too powerful to control!"))
		return FALSE
	if(isguardian(cast_on))
		var/mob/living/simple_animal/hostile/guardian/stand = cast_on
		if(stand.summoner && stand.summoner == owner)
			to_chat(owner, span_warning("Swapping minds with your own guardian would just put you back into your own head!"))
			return FALSE

	var/mob/living/living_target = cast_on
	if(living_target.stat == DEAD)
		to_chat(owner, span_warning("You don't particularly want to be dead!"))
		return FALSE
	if(!living_target.key || !living_target.mind)
		to_chat(owner, span_warning("[living_target.p_theyve(TRUE)] appear[living_target.p_s()] to be catatonic! \
			Not even magic can affect [living_target.p_their()] vacant mind."))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/mind_transfer/cast(mob/living/cast_on)
	. = ..()
	swap_minds(owner, cast_on)

/datum/action/cooldown/spell/pointed/mind_transfer/proc/swap_minds(mob/living/caster, mob/living/cast_on)

	var/mob/living/to_swap = cast_on
	if(isguardian(cast_on))
		var/mob/living/simple_animal/hostile/guardian/stand = cast_on
		if(stand.summoner)
			to_swap = stand.summoner

	var/datum/mind/mind_to_swap = to_swap.mind
	if(to_swap.anti_magic_check(TRUE, FALSE) \
		|| mind_to_swap.has_antag_datum(/datum/antagonist/wizard) \
		|| mind_to_swap.has_antag_datum(/datum/antagonist/cult) \
		|| mind_to_swap.has_antag_datum(/datum/antagonist/changeling) \
		|| mind_to_swap.has_antag_datum(/datum/antagonist/rev) \
		|| mind_to_swap.key[1] == "@" \
	)
		to_chat(caster, span_warning("[to_swap.p_their(TRUE)] mind is resisting your spell!"))
		return FALSE

	// MIND TRANSFER BEGIN
	var/mob/dead/observer/to_swap_ghost = to_swap.ghostize()
	caster.mind.transfer_to(to_swap)
	to_swap_ghost.mind.transfer_to(caster)

	if(to_swap_ghost.key)
		// Have to transfer the key, since the mind was "not active"
		caster.key = to_swap_ghost.key
	qdel(to_swap_ghost)
	// MIND TRANSFER END

	// Here we knock both mobs out for a time.
	caster.Unconscious(unconscious_amount_caster)
	to_swap.Unconscious(unconscious_amount_victim)
	// Only the caster and victim hear the sounds,
	// that way no one knows for sure if the swap happened
	SEND_SOUND(caster, sound('sound/magic/mandswap.ogg'))
	SEND_SOUND(to_swap, sound('sound/magic/mandswap.ogg'))

	return TRUE
