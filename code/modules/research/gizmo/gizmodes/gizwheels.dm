/datum/gizmodes/gizmo_wheels
	guaranteed_active_gizmodes = list(/datum/gizpulse/gizmo_wheels/wheels, /datum/gizpulse/gizmo_wheels/hot_wheels)
	// possible_active_modes = list(
	// 	/datum/gizpulse/radiation_pulse = 1,
	// )

/datum/gizpulse/gizmo_wheels

/datum/gizpulse/gizmo_wheels/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	// this proc will transform gizmo into venichle
	// holder.transform...

/datum/gizpulse/gizmo_wheels/wheels
	//its ordinary venichle


/datum/gizpulse/gizmo_wheels/hot_wheels
	// this venichle type gizmode will be not affected by gravity
