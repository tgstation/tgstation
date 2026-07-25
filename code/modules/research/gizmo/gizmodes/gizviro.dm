/datum/gizmodes/viro_smoke
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/viro_smoke/good,
	)

/datum/gizpulse/viro_smoke/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	release_viro_smoke()

/datum/gizpulse/viro_smoke/proc/release_viro_smoke(atom/movable/holder)
