/obj/effect/proc_holder/spell/pointed
	name = "pointed spell"
	ranged_mousepointer = 'icons/effects/throw_target.dmi'
	/// Message showing to the spell owner upon deactivating pointed spell.
	var/deactive_msg = "You dispel the magic..."
	/// Message showing to the spell owner upon activating pointed spell.
	var/active_msg = "You prepare to use the spell on a target..."
	/// Default icon for the pointed spell, used for active/inactive states switching.
	var/base_icon_state = "projectile"

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
		on_deactivation(user)
	else
		msg = "<span class='notice'>[active_msg] <B>Left-click to activate spell on a target!</B></span>"
		add_ranged_ability(user, msg, TRUE)
		on_activation(user)
 /**
  *
  * What happens upon pointed spell activation.
  *
  * user mob The mob interacting owning the spell.
  *
 **/
/obj/effect/proc_holder/spell/pointed/proc/on_activation(mob/user)
	return

 /**
  *
  * What happens upon pointed spell deactivation.
  *
  * user mob The mob interacting owning the spell.
  *
 **/
/obj/effect/proc_holder/spell/pointed/proc/on_deactivation(mob/user)
	return

/obj/effect/proc_holder/spell/pointed/update_icon()
	if(!action)
		return
	action.button_icon_state = "[base_icon_state][active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/pointed/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return FALSE
	if(!cast_check(TRUE, ranged_ability_user))
		remove_ranged_ability()
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/cast(list/targets, mob/living/user)
	remove_ranged_ability()
	charge_counter = 0
	start_recharge()
	on_deactivation(user)
