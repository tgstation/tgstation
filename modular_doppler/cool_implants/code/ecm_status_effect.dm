/atom/movable/screen/alert/status_effect/ecm_jammed
	name = "ECM Jammed"
	desc = "Either because you are robotic, or standing in a dense cloud of glittering confetti, it's awfully hard to see right now."
	icon = 'icons/hud/implants.dmi'
	icon_state = "lighting_bolt"

/datum/status_effect/ecm_jammed
	id = "ecm_jammed"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/ecm_jammed
	remove_on_fullheal = TRUE

/datum/status_effect/ecm_jammed/on_apply()
	to_chat(owner, span_userdanger("The cloud of metal confetti obscures your vision!"))
	owner.overlay_fullscreen("jamming", /atom/movable/screen/fullscreen/ecm_static)
	owner.overlay_fullscreen("jamming_vignette", /atom/movable/screen/fullscreen/crit/vision, 9)
	return ..()

/datum/status_effect/ecm_jammed/on_remove()
	owner.clear_fullscreen("jamming", 5 SECONDS)
	owner.clear_fullscreen("jamming_vignette", 5 SECONDS)
	return ..()

/atom/movable/screen/fullscreen/ecm_static
	icon = 'icons/hud/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"
	alpha = 120
