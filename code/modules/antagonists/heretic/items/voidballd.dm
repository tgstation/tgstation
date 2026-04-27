/obj/item/void_prison
	name = "void prison"
	desc = "A small glass orb of swirling darkness. It feels cold to the touch, and consumes all light around it."
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "voidball"
	pickup_sound = 'sound/items/handling/materials/glass_pick_up.ogg'
	drop_sound = 'sound/items/handling/materials/glass_drop.ogg'

/obj/item/void_prison/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.5)

/obj/item/void_prison/attack_self(mob/living/user, modifiers)
	. = ..()
	if(.)
		return

	playsound(src, SFX_SHATTER, 50, TRUE)
	playsound(src, 'sound/effects/magic/voidblink.ogg', 50, FALSE)
	if(IS_HERETIC(user))
		to_chat(user, span_mansus("You smash [src], releasing its power around you!"))
		for(var/mob/living/nearby_mob in view(3, user))
			if(IS_HERETIC_OR_MONSTER(nearby_mob))
				continue
			if(nearby_mob.has_status_effect(/datum/status_effect/eldritch))
				continue
			if(nearby_mob.can_block_magic(MAGIC_RESISTANCE))
				nearby_mob.visible_message(
					span_danger("A swirling, cold void wraps around [nearby_mob], but they burst free in a wave of heat!"),
					span_userdanger("A yawning void begins to open before you, but a great wave of heat bursts it apart! You are protected!!")
				)
				continue
			nearby_mob.visible_message(
				span_danger("A swirling, cold void wraps around [nearby_mob]!"),
				span_userdanger("A yawning void opens before you! You are swallowed by the darkness, and find yourself in complete nothingness..."),
			)
			nearby_mob.apply_status_effect(/datum/status_effect/void_prison)

	else if(user.can_block_magic(MAGIC_RESISTANCE))
		to_chat(user, span_hypnophrase("You smash [src], but its power begins to encompass you!"))
		user.visible_message(
			span_danger("A swirling, cold void wraps around [user], but they burst free in a wave of heat!"),
			span_userdanger("A yawning void begins to open before you, but a great wave of heat bursts it apart! You are protected!!")
		)

	else
		to_chat(user, span_hypnophrase("You smash [src], but its power begins to encompass you!"))
		user.visible_message(
			span_danger("A swirling, cold void wraps around [user]!"),
			span_userdanger("A yawning void opens before you! You are swallowed by the darkness, and find yourself in complete nothingness..."),
		)
		user.apply_status_effect(/datum/status_effect/void_prison)

	qdel(src)
	return TRUE

/datum/status_effect/void_prison
	id = "void_prison"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/void_prison
	///The overlay that gets applied to whoever has this status active
	var/obj/effect/abstract/voidball/stasis_overlay

/datum/status_effect/void_prison/on_creation(mob/living/new_owner)
	. = ..()
	stasis_overlay = new /obj/effect/abstract/voidball(new_owner)
	RegisterSignal(stasis_overlay, COMSIG_QDELETING, PROC_REF(clear_overlay))
	new_owner.vis_contents += stasis_overlay
	stasis_overlay.animate_opening()
	addtimer(CALLBACK(src, PROC_REF(enter_prison), new_owner), 1 SECONDS)

/datum/status_effect/void_prison/on_remove()
	if(!IS_HERETIC(owner))
		owner.apply_status_effect(/datum/status_effect/void_chill, 1)
	if(stasis_overlay)
		//Free our prisoner
		owner.remove_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM, TRAIT_SOFTSPOKEN), TRAIT_STATUS_EFFECT(id))
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
	prisoner.add_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM, TRAIT_SOFTSPOKEN), TRAIT_STATUS_EFFECT(id))

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
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	icon_state = "heretic_template"
	overlay_icon = 'icons/mob/actions/actions_ecult.dmi'
	overlay_state = "voidball_effect"
