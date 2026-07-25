/datum/gizmodes/pie_thrower
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/throw_pie,
	)

	var/datum/weakref/pie_target

/datum/gizpulse/pie_thrower/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	mysterious_pie = /obj/item/food/pie/cream
	pie_target = holder
	mysterious_pie.stun_and_blur(pie_target)
