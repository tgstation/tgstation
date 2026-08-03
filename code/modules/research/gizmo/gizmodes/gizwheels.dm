/datum/gizmodes/wheels_eject
	guaranteed_active_gizmodes = list(/datum/gizpulse/wheels_eject/wheels, /datum/gizpulse/wheels_eject/hot_wheels)
	possible_active_modes = list(
		/datum/gizpulse/radiation_pulse = 1,
	)

/datum/gizpulse/wheels_eject

/datum/gizpulse/wheels_eject/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	mood_pulse(holder)
