/datum/gizmo_effect/lights_on/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	SEND_SIGNAL(holder, COMSIG_GIZMO_ON_STATE)

	holder.set_light(
		l_range = 3,
		l_power = 2,
		l_color = LIGHT_COLOR_INTENSE_RED,
		l_on = TRUE,
	)

/datum/gizmo_effect/lights_off/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	SEND_SIGNAL(holder, COMSIG_GIZMO_OFF_STATE)
	holder.set_light_on(FALSE)
