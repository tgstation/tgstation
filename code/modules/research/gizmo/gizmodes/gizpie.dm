/datum/gizmodes/pie_thrower
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/throw_pie,
	)



/datum/gizpulse/pie_thrower/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)

	var/obj/item/food/pie/cream/mysterious_pie = new /obj/item/food/pie/cream
	mysterious_pie.stun_and_blur(holder)
