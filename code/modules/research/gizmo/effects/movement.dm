/datum/gizmo_effect/start_moving/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	holder.AddElement(/datum/element/moving_randomly)
	SEND_SIGNAL(holder, COMSIG_GIZMO_START_MOVING, src)

/datum/gizmo_effect/stop_moving/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	holder.RemoveElement(/datum/element/moving_randomly)
	SEND_SIGNAL(holder, COMSIG_GIZMO_STOP_MOVING, src)
