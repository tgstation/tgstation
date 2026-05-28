/datum/gizmo_effect/explode
	var/range_heavy = 0
	var/range_medium = 1
	var/range_light = 3
	var/range_flame = 0

/datum/gizmo_effect/explode/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	explosion(holder, range_heavy, range_medium, range_light, range_flame)

/datum/gizmo_effect/explode/fire
	range_flame = 5
