/datum/gizmodes/viro_smoke
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/pie_thrower/ordinary,
	)

/datum/gizpulse/pie_thrower/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	throw_pie(holder)

	var/obj/item/food/pie/cream/mysterious_pie = new /obj/item/food/pie/cream
	mysterious_pie.stun_and_blur(holder)

/datum/gizpulse/pie_thrower/proc/throw_pie(atom/movable/holder)
	var/obj/item/food/pie/cream/mysterious_pie = new /obj/item/food/pie/cream
	for(var/mob/living/carbon/human/human in urange(range, holder))
		mysterious_pie.stun_and_blur(human)
