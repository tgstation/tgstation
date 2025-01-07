/datum/action/cooldown/spell/pointed/void_prison
	name = "Void Prison"
	desc = "Sends a heathen into the void for 10 seconds. \
		They will be unable to perform any actions for the duration. \
		Afterwards, they will be chilled and returned to the mortal plane."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidball"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	sound = 'sound/effects/magic/voidblink.ogg'

	cooldown_time = 1 MINUTES
	cast_range = 3

	sound = null
	school = SCHOOL_FORBIDDEN
	invocation = "V''D PR'S'N!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/void_prison/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	if(!ismob(cast_on))
		return SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/void_prison/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		cast_on.visible_message(
			span_danger("A swirling, cold void wraps around [cast_on], but they burst free in a wave of heat!"),
			span_danger("A yawning void begins to open before you, but a great wave of heat bursts it apart! You are protected!!")
		)
		return
	cast_on.apply_status_effect(/datum/status_effect/void_prison, "void_stasis")

/datum/status_effect/void_prison
	id = "void_prison"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/void_prison
	///The overlay that gets applied to whoever has this status active
	var/obj/effect/abstract/voidball/stasis_overlay

/datum/status_effect/void_prison/on_creation(mob/living/new_owner, set_duration)
	. = ..()
	stasis_overlay = new /obj/effect/abstract/voidball(new_owner)
	RegisterSignal(stasis_overlay, COMSIG_QDELETING, PROC_REF(clear_overlay))
	new_owner.vis_contents += stasis_overlay
	stasis_overlay.animate_opening()
	addtimer(CALLBACK(src, PROC_REF(enter_prison), new_owner), 1 SECONDS)

/datum/status_effect/void_prison/on_remove()
	if(!IS_HERETIC(owner))
		owner.apply_status_effect(/datum/status_effect/void_chill, 3)
	if(stasis_overlay)
		//Free our prisoner
		owner.remove_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM, TRAIT_SOFTSPOKEN), REF(src))
		owner.forceMove(get_turf(stasis_overlay))
		stasis_overlay.forceMove(owner)
		owner.vis_contents += stasis_overlay
		//Animate closing the ball
		stasis_overlay.animate_closing()
		stasis_overlay.icon_state = "voidball_closed"
		QDEL_IN(stasis_overlay, 1.1 SECONDS)
		stasis_overlay = null
	return ..()

///Freezes our prisoner in place
/datum/status_effect/void_prison/proc/enter_prison(mob/living/prisoner)
	stasis_overlay.forceMove(prisoner.loc)
	prisoner.forceMove(stasis_overlay)
	prisoner.add_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM, TRAIT_SOFTSPOKEN), REF(src))

///Makes sure to clear the ref in case the voidball ever suddenly disappears
/datum/status_effect/void_prison/proc/clear_overlay()
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

//---- Screen alert
/atom/movable/screen/alert/status_effect/void_prison
	name = "Void Prison"
	desc = "A Yawning void encases your mortal coil." //Go straight to jail, do not pass GO, do not collect 200$
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "voidball_effect"
