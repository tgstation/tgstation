/datum/status_effect/firewalled
	id = "firewalled"
	duration = 30 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/firewall
	show_duration = TRUE
	processing_speed = STATUS_EFFECT_PRIORITY
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/firewalled/on_creation(mob/living/new_owner, set_duration = 30 SECONDS)
	src.duration = set_duration
	return ..()

/datum/status_effect/firewalled/refresh(effect, set_duration = 30 SECONDS)
	src.duration = max(src.duration, set_duration)

/atom/movable/screen/alert/status_effect/firewall
	name = "Firewalled"
	desc = "Recent changes to your core lawset have restricted your actions."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "hazard_area"
