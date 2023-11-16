/// Reduce a cyborg's speed when you throw things at it
/datum/status_effect/borg_throw_slow
	id = "borg_throw_slowdown"
	alert_type = /atom/movable/screen/alert/status_effect/borg_throw_slow
	duration = 3 SECONDS
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/borg_throw_slow/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/borg_throw, update = TRUE)

/datum/status_effect/borg_throw_slow/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/borg_throw, update = TRUE)

/atom/movable/screen/alert/status_effect/borg_throw_slow
	name = "Percussive Maintenance"
	desc = "A sudden impact has triggered your collision avoidance routines, reducing movement speed."
	icon_state = "weaken"

/datum/movespeed_modifier/borg_throw
	multiplicative_slowdown = 0.9
