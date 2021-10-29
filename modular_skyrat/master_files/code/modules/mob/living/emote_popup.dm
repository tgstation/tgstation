/obj/effect/overlay/emote_popup
	icon = 'modular_skyrat/master_files/icons/mob/popup_flicks.dmi'
	icon_state = "combat"
	layer = FLY_LAYER
	plane = GAME_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	mouse_opacity = 0

/mob/living/proc/flick_emote_popup_on_mob(state, time)
	var/obj/effect/overlay/emote_popup/I = new
	I.icon_state = state
	vis_contents += I
	animate(I, alpha = 255, time = 5, easing = BOUNCE_EASING, pixel_y = 10)
	addtimer(CALLBACK(src, .proc/remove_emote_popup_on_mob, I), time)

/mob/living/proc/remove_emote_popup_on_mob(obj/effect/overlay/emote_popup/I)
	vis_contents -= I
	qdel(I)
	return
