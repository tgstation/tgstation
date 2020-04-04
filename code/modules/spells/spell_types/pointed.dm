/obj/effect/proc_holder/spell/pointed
	name = "pointed spell"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	action_icon_state = "projectile"
	/// Message showing to the spell owner upon deactivating pointed spell.
	var/deactive_msg = "You dispel the magic..."
	/// Message showing to the spell owner upon activating pointed spell.
	var/active_msg = "You prepare to use the spell on a target..."
	/// Variable dictating if the user is allowed to cast a spell on himself.
	var/self_castable = FALSE

/obj/effect/proc_holder/spell/pointed/Click()
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/msg
	if(!can_cast(user))
		msg = "<span class='warning'>You can no longer cast [name]!</span>"
		remove_ranged_ability(msg)
		return
	if(active)
		msg = "<span class='notice'>[deactive_msg]</span>"
		remove_ranged_ability(msg)
	else
		msg = "<span class='notice'>[active_msg] <B>Left-click to activate spell on a target!</B></span>"
		add_ranged_ability(user, msg, TRUE)

/obj/effect/proc_holder/spell/pointed/on_lose(mob/living/user)
	remove_ranged_ability()

/obj/effect/proc_holder/spell/pointed/remove_ranged_ability(msg)
	. = ..()
	on_deactivation(ranged_ability_user)

/obj/effect/proc_holder/spell/pointed/add_ranged_ability(mob/living/user, msg, forced)
	. = ..()
	on_activation(user)

/**
  * on_activation: What happens upon pointed spell activation.
  *
  * Arguments:
  * * user The mob interacting owning the spell.
  */
/obj/effect/proc_holder/spell/pointed/proc/on_activation(mob/user)
	return

/**
  * on_activation: What happens upon pointed spell deactivation.
  *
  * Arguments:
  * * user The mob interacting owning the spell.
  */
/obj/effect/proc_holder/spell/pointed/proc/on_deactivation(mob/user)
	return

/obj/effect/proc_holder/spell/pointed/update_icon()
	if(!action)
		return
	if(active)
		action.button_icon_state = "[action_icon_state]1"
	else
		action.button_icon_state = "[action_icon_state]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/pointed/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return TRUE
	if(!intercept_check(caller, target))
		return TRUE
	perform(list(target), user = caller)
	remove_ranged_ability()
	return TRUE // Do not do any underlying actions after the spell cast

/**
  * intercept_check: Specific spell checks for InterceptClickOn() targets.
  *
  * Arguments:
  * * user The mob using the ranged spell via intercept.
  * * target The atom that is being targeted by the spell via intercept.
  */
/obj/effect/proc_holder/spell/pointed/proc/intercept_check(mob/user, atom/target)
	if(!self_castable && target == user)
		to_chat(user, "<span class='warning'>You cannot cast the spell on yourself!</span>")
		return FALSE
	if(!(target in view_or_range(range, user, selection_type)))
		to_chat(user, "<span class='warning'>[target.p_theyre(TRUE)] too far away!</span>")
		return FALSE
	if(!can_target(target, user))
		return FALSE
	if(!cast_check(FALSE, user))
		return FALSE
	return TRUE
