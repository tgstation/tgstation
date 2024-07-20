/datum/action/cooldown/spell/pointed/void_stasis
	name = "Void Stasis"
	desc = "DEBUG DESC VOID STASIS AHHHHHHHHHHHHHHH" //XANTODO
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidball"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	//cooldown_time = 1 MINUTES //DEBUG REMOVING COOLDOWN

	sound = null
	school = SCHOOL_FORBIDDEN
	invocation = "Stasis!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/void_stasis/is_valid_target(atom/cast_on)
	return ishuman(cast_on) //Dont call parent to enable cast on self

/datum/action/cooldown/spell/pointed/void_stasis/cast(mob/living/carbon/human/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/grouped/stasis/void_stasis, "void_stasis")

/datum/status_effect/grouped/stasis/void_stasis
	duration = 10 SECONDS
	///The overlay that gets applied to whoever has this status active
	var/mutable_appearance/stasis_overlay

/datum/status_effect/grouped/stasis/void_stasis/on_creation(mob/living/new_owner, set_duration)
	stasis_overlay = mutable_appearance('icons/mob/actions/actions_ecult.dmi', "voidball_effect", ABOVE_ALL_MOB_LAYER)
	return ..()

/datum/status_effect/grouped/stasis/void_stasis/Destroy()
	QDEL_NULL(stasis_overlay)
	return ..()

/datum/status_effect/grouped/stasis/void_stasis/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	owner.update_icon(UPDATE_OVERLAYS)

/**
 * Signal proc for [COMSIG_ATOM_UPDATE_OVERLAYS].
 *
 * Adds the generated effect overlay to the afflicted.
 */
/datum/status_effect/grouped/stasis/void_stasis/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER
	overlays += stasis_overlay

/datum/status_effect/grouped/stasis/void_stasis/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	if(!IS_HERETIC(owner))
		owner.apply_status_effect(/datum/status_effect/void_chill, 1)
	owner.update_icon(UPDATE_OVERLAYS)
	return ..()
