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
	var/obj/effect/abstract/voidball/stasis_overlay

/datum/status_effect/grouped/stasis/void_stasis/on_creation(mob/living/new_owner, set_duration)
	stasis_overlay = new /obj/effect/abstract/voidball(new_owner)
	RegisterSignal(stasis_overlay, COMSIG_QDELETING, PROC_REF(clear_overlay))
	new_owner.vis_contents += stasis_overlay
	stasis_overlay.animate_opening()
	return ..()

/datum/status_effect/grouped/stasis/void_stasis/on_remove()
	if(!IS_HERETIC(owner))
		owner.apply_status_effect(/datum/status_effect/void_chill, 1)
	if(stasis_overlay)
		stasis_overlay.animate_closing()
		stasis_overlay.icon_state = "voidball_closed"
		QDEL_IN(stasis_overlay, 11)
		stasis_overlay = null
	return ..()

///Makes sure to clear the ref in case the voidball ever suddenly disappears
/datum/status_effect/grouped/stasis/void_stasis/proc/clear_overlay()
	SIGNAL_HANDLER
	stasis_overlay = null

//----Voidball effect
/obj/effect/abstract/voidball
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "voidball_effect"
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_ID

///Plays a opening animation
/obj/effect/abstract/voidball/proc/animate_opening()
	flick("voidball_opening", src)

///Plays a closing animation
/obj/effect/abstract/voidball/proc/animate_closing()
	flick("voidball_closing", src)
