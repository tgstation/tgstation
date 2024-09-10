/obj/effect/overlay/emote_popup
	icon = 'modular_doppler/indicators/icons/popup_flicks.dmi'
	icon_state = "combat"
	layer = FLY_LAYER
	plane = GAME_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/**
 * A proc type that, when called, causes a image/sprite to appear above whatever entity it is called on.
 *
 * There are two types: on_mob and on_obj, they can only be called on their respective typepaths.
 *
 * Arguments:
 * * state -- The icon_state of whatever .dmi file you're attempting to use for the sprite, in "" format. Ex. "combat", not combat.dmi.
 * * time -- The amount of time the sprite remains before remove_emote_popup_on_mob is called. Is used in the addtimer.
 */
/mob/living/proc/flick_emote_popup_on_mob(state, time)
	var/obj/effect/overlay/emote_popup/emote_overlay = new
	emote_overlay.icon_state = state
	vis_contents += emote_overlay
	animate(emote_overlay, alpha = 255, time = 5, easing = BOUNCE_EASING, pixel_y = 10)
	addtimer(CALLBACK(src, PROC_REF(remove_emote_popup_on_mob), emote_overlay), time)

/**
 * A proc type that, when called, causes a image/sprite to appear above whatever entity it is called on.
 *
 * There are two types: on_mob and on_obj, they can only be called on their respective typepaths.
 *
 * Arguments:
 * * state -- The icon_state of whatever .dmi file you're attempting to use for the sprite, in "" format. Ex. "combat", not combat.dmi.
 * * time -- The amount of time the sprite remains before remove_emote_popup_on_obj is called. Is used in the addtimer.
 */

/obj/proc/flick_emote_popup_on_obj(state, time)
	var/obj/effect/overlay/emote_popup/emote_overlay = new
	emote_overlay.icon_state = state
	vis_contents += emote_overlay
	animate(emote_overlay, alpha = 255, time = 5, easing = BOUNCE_EASING, pixel_y = 10)
	addtimer(CALLBACK(src, PROC_REF(remove_emote_popup_on_obj), emote_overlay), time)

/**
 * A proc that is automatically called whenever flick_emote_popup_on_mob's addtimer expires, and removes the popup.
 *
 * Arguments:
 * * emote_overlay -- Inherits state from the preceding proc.
 */

/mob/living/proc/remove_emote_popup_on_mob(obj/effect/overlay/emote_popup/emote_overlay)
	vis_contents -= emote_overlay
	qdel(emote_overlay)
	return

/**
 * A proc that is automatically called whenever flick_emote_popup_on_obj's addtimer expires, and removes the popup.
 *
 * Arguments:
 * * emote_overlay -- Inherits state from the preceding proc.
 */

/obj/proc/remove_emote_popup_on_obj(obj/effect/overlay/emote_popup/emote_overlay)
	vis_contents -= emote_overlay
	qdel(emote_overlay)
	return
