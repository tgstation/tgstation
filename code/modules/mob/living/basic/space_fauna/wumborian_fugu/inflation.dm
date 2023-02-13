/**
 * Action which inflates you, making you larger and stronger for the duration. Also invulnerable.
 * This is pretty much all just handled by a status effect.
 * Unfortunately the requirements here are specific enough that it kind of only works for the mob it is designed for.
 */
/datum/action/cooldown/fugu_expand
	name = "Inflate"
	desc = "Temporarily increases your size, making you significantly more dangerous and durable!"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "expand"
	background_icon_state = "bg_fugu"
	overlay_icon_state = "bg_fugu_border"
	cooldown_time = 16 SECONDS
	melee_cooldown_time = 0 SECONDS

/datum/action/cooldown/fugu_expand/IsAvailable(feedback)
	. = ..()
	if (!.)
		return FALSE
	if(!istype(owner, /mob/living/basic/wumborian_fugu)) // A shame but there's not any good way to make this work on other mobs
		if (feedback)
			owner.balloon_alert(owner, "not stretchy enough!")
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_FUGU_GLANDED))
		if (feedback)
			owner.balloon_alert(owner, "already large!")
		return FALSE
	return TRUE

/datum/action/cooldown/fugu_expand/Activate(atom/target)
	. = ..()
	var/mob/living/living_owner = owner
	living_owner.apply_status_effect(/datum/status_effect/inflated)

/**
 * Status effect from the Expand action, makes you big and round and strong.
 */
/datum/status_effect/inflated
	id = "wumbo_inflated"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/inflated

/atom/movable/screen/alert/status_effect/inflated
	name = "WUMBO"
	desc = "You feel big and strong!"
	icon_state = "gross"

/datum/status_effect/inflated/on_creation(mob/living/new_owner, ...)
	if (!istype(new_owner, /mob/living/basic/wumborian_fugu))
		return FALSE
	return ..()

/datum/status_effect/inflated/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(check_death))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/inflated)
	ADD_TRAIT(owner, TRAIT_FUGU_GLANDED, TRAIT_STATUS_EFFECT(id))
	owner.AddElement(/datum/element/wall_smasher)
	owner.mob_size = MOB_SIZE_LARGE
	owner.icon_state = "Fugu1"
	owner.melee_damage_lower = 15
	owner.melee_damage_upper = 20
	owner.status_flags |= GODMODE
	var/mob/living/basic/basic_owner = owner
	basic_owner.obj_damage = 60
	basic_owner.ai_controller.blackboard[BB_BASIC_MOB_FLEEING] = FALSE
	basic_owner.ai_controller.CancelActions()

/datum/status_effect/inflated/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_STATCHANGE)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/inflated)
	REMOVE_TRAIT(owner, TRAIT_FUGU_GLANDED, TRAIT_STATUS_EFFECT(id))
	if (!istype(owner, /mob/living/basic/wumborian_fugu))
		return
	owner.RemoveElement(/datum/element/wall_smasher)
	owner.mob_size = MOB_SIZE_SMALL
	owner.melee_damage_lower = 0
	owner.melee_damage_upper = 0
	owner.status_flags &= ~GODMODE
	if (owner.stat != DEAD)
		owner.icon_state = "Fugu0"
	var/mob/living/basic/basic_owner = owner
	basic_owner.obj_damage = 0
	basic_owner.ai_controller.blackboard[BB_BASIC_MOB_FLEEING] = TRUE
	basic_owner.ai_controller.CancelActions()

/// Remove status effect if we die
/datum/status_effect/inflated/proc/check_death(mob/living/source, new_stat)
	SIGNAL_HANDLER
	if (new_stat == DEAD)
		qdel(src)
