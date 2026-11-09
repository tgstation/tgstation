/// Attach to revenant spells to make them cost essence to cast
/datum/component/revenant_ability
	/// If it's locked, and needs to be unlocked before use
	VAR_FINAL/locked = TRUE
	/// How much essence it costs to unlock
	var/unlock_amount = 100
	/// How much essence it costs to use
	var/cast_amount = 50

	/// How long it reveals the revenant
	var/reveal_duration = 8 SECONDS
	// How long it stuns the revenant
	var/stun_duration = 2 SECONDS

	VAR_FINAL/image/locked_overlay

/datum/component/revenant_ability/Initialize(
	unlock_amount = 100,
	cast_amount = 50,
	reveal_duration = 8 SECONDS,
	stun_duration = 2 SECONDS,
)

	if(!istype(parent, /datum/action/cooldown/spell))
		return COMPONENT_INCOMPATIBLE

	set_unlock_amount(unlock_amount)
	set_cast_amount(cast_amount)
	set_durations(reveal_duration, stun_duration)

	RegisterSignal(parent, COMSIG_SPELL_CAN_CAST_CHECK, PROC_REF(can_cast))
	RegisterSignal(parent, COMSIG_SPELL_BEFORE_CAST, PROC_REF(before_cast))
	RegisterSignal(parent, COMSIG_SPELL_AFTER_CAST, PROC_REF(after_cast))
	RegisterSignal(parent, COMSIG_ACTION_OVERLAY_APPLY, PROC_REF(add_locked_overlay))

	locked_overlay = image('icons/mob/actions/actions_revenant.dmi', "locked")

/datum/component/revenant_ability/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if(NAMEOF(src, unlock_amount))
			set_unlock_amount(var_value)
		if(NAMEOF(src, cast_amount))
			set_cast_amount(var_value)
		if(NAMEOF(src, reveal_duration), NAMEOF(src, stun_duration))
			set_durations(reveal_duration, stun_duration)
		if(NAMEOF(src, locked))
			update_spell_name()

/datum/component/revenant_ability/proc/update_spell_name()
	var/datum/action/cooldown/spell/spell = parent
	if(locked)
		spell.name = "[initial(spell.name)] ([unlock_amount]SE)"
	else
		spell.name = "[initial(spell.name)] ([cast_amount]E)"
	spell.build_all_button_icons()

/datum/component/revenant_ability/proc/set_unlock_amount(new_value)
	unlock_amount = new_value
	update_spell_name()

/datum/component/revenant_ability/proc/set_cast_amount(new_value)
	cast_amount = new_value
	update_spell_name()

/datum/component/revenant_ability/proc/set_durations(new_reveal_duration, new_stun_duration)
	reveal_duration = new_reveal_duration
	stun_duration = new_stun_duration

/datum/component/revenant_ability/proc/can_cast(datum/action/cooldown/spell/source, feedback)
	SIGNAL_HANDLER

	var/mob/living/basic/revenant/ghost = source.owner
	if(!istype(ghost))
		return NONE // just allow it anyways

	if(locked)
		if(ghost.essence_excess >= unlock_amount)
			return NONE
		if(feedback)
			to_chat(ghost, span_revenwarning("You don't have enough essence to unlock [initial(source.name)]!"))
		return SPELL_CANCEL_CAST

	if(!ghost.cast_check(cast_amount, deduct_essence = FALSE, silent = !feedback))
		return SPELL_CANCEL_CAST

	return NONE

/datum/component/revenant_ability/proc/before_cast(datum/action/cooldown/spell/source, atom/cast_on)
	SIGNAL_HANDLER

	var/mob/living/basic/revenant/ghost = source.owner
	if(!istype(ghost))
		return NONE // just allow it anyways

	if(locked)
		if(ghost.unlock(unlock_amount))
			to_chat(ghost, span_revennotice("You have unlocked [initial(source.name)]!"))
			locked = FALSE
			update_spell_name()
		else
			to_chat(ghost, span_revenwarning("You don't have enough essence to unlock [initial(source.name)]!"))
		return SPELL_CANCEL_CAST

	if(!ghost.cast_check(cast_amount, deduct_essence = TRUE, silent = FALSE))
		return SPELL_CANCEL_CAST

	return NONE

/datum/component/revenant_ability/proc/after_cast(datum/action/cooldown/spell/source, atom/cast_on)
	SIGNAL_HANDLER

	var/mob/living/caster = source.owner
	if(reveal_duration > 0 SECONDS)
		caster.apply_status_effect(/datum/status_effect/revenant/revealed, reveal_duration)
	if(stun_duration > 0 SECONDS)
		caster.apply_status_effect(/datum/status_effect/incapacitating/paralyzed/revenant, stun_duration)

/datum/component/revenant_ability/proc/add_locked_overlay(datum/action/cooldown/spell/source, atom/movable/screen/movable/action_button/current_button, ...)
	SIGNAL_HANDLER

	current_button.cut_overlay(locked_overlay)
	if(locked)
		current_button.add_overlay(locked_overlay)
