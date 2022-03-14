/datum/action/cooldown/spell/pointed
	click_to_activate = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	action_icon_state = "projectile"
	/// Message showing to the spell owner upon activating pointed spell.
	var/active_msg = "You prepare to use the spell on a target..."
	/// Message showing to the spell owner upon deactivating pointed spell.
	var/deactive_msg = "You dispel the magic..."
	/// Variable dictating if the spell will use turf based aim assist
	var/aim_assist = TRUE

/datum/action/cooldown/spell/pointed/New()
	. = ..()
	active_msg = "You prepare to use [src] on a target..."
	deactive_msg = "You dispel [src]."

/datum/action/cooldown/spell/pointed/set_ranged_ability()
	if(!can_cast_spell())
		return FALSE

	on_activation()
	return ..()

/datum/action/cooldown/spell/pointed/unset_ranged_ability()
	on_deactivation()
	return ..()

/datum/action/cooldown/spell/pointed/proc/on_activation()
	to_chat(owner, span_notice("[active_msg] <B>Left-click to activate the spell on a target!</B>"))

/datum/action/cooldown/spell/pointed/proc/on_deactivation()
	to_chat(owner, span_notice("[deactive_msg]"))

/datum/action/cooldown/spell/pointed/InterceptClickOn(mob/living/caller, params, atom/target)

	var/atom/aim_assist_target
	if(aim_assist && isturf(target))
		// Find any human in the list. We aren't picky, it's aim assist after all
		aim_assist_target = locate(/mob/living/carbon/human) in target
		if(!aim_assist_target)
			// If we didn't find a human, we settle for any living at all
			aim_assist_target = locate(/mob/living) in target

	return ..(caller, params, aim_assist_target || target)

/datum/action/cooldown/spell/pointed/is_valid_target(atom/cast_on)
	if(cast_on == owner)
		to_chat(user, span_warning("You cannot cast [src] on yourself!"))
		return FALSE

	if(get_dist(owner, cast_on) > range)
		to_chat(user, span_warning("[target.p_theyre(TRUE)] too far away!"))
		return FALSE

	return TRUE
