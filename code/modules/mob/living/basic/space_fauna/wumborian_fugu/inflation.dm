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
	show_duration = TRUE

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
	var/mob/living/basic/wumborian_fugu/fugu = owner
	if (!istype(fugu))
		return FALSE
	RegisterSignal(fugu, COMSIG_MOB_STATCHANGE, PROC_REF(check_death))
	fugu.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/inflated)
	ADD_TRAIT(fugu, TRAIT_FUGU_GLANDED, TRAIT_STATUS_EFFECT(id))
	fugu.AddElement(/datum/element/wall_tearer, allow_reinforced = FALSE)
	fugu.mob_size = MOB_SIZE_LARGE
	fugu.icon_state = "Fugu1"
	fugu.melee_damage_lower = 15
	fugu.melee_damage_upper = 20
	fugu.status_flags |= GODMODE
	fugu.obj_damage = 60
	fugu.ai_controller.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, TRUE)
	fugu.ai_controller.CancelActions()

/datum/status_effect/inflated/on_remove()
	. = ..()
	var/mob/living/basic/wumborian_fugu/fugu = owner
	if (!istype(fugu))
		return // Check again in case you changed mob after application but somehow kept the status effect
	UnregisterSignal(fugu, COMSIG_MOB_STATCHANGE)
	fugu.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/inflated)
	REMOVE_TRAIT(fugu, TRAIT_FUGU_GLANDED, TRAIT_STATUS_EFFECT(id))
	fugu.RemoveElement(/datum/element/wall_tearer, allow_reinforced = FALSE)
	fugu.mob_size = MOB_SIZE_SMALL
	fugu.melee_damage_lower = 0
	fugu.melee_damage_upper = 0
	fugu.status_flags &= ~GODMODE
	if (fugu.stat != DEAD)
		fugu.icon_state = "Fugu0"
	fugu.obj_damage = 0
	fugu.ai_controller.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, FALSE)
	fugu.ai_controller.CancelActions()

/// Remove status effect if we die
/datum/status_effect/inflated/proc/check_death(mob/living/source, new_stat)
	SIGNAL_HANDLER
	if (new_stat == DEAD)
		qdel(src)
