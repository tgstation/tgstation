// Gizmode mode, which throws pie, when activating
// 2 possible - mode with real creampie, which is stunning
// or fake pie, which only do your face cream pied
// Low chances for stun cream pie?
// throwing the pie at the nearest target
/datum/gizmodes/pie_thrower
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/pie_thrower/ordinary,
		/datum/gizpulse/pie_thrower/floar,
		/datum/gizpulse/pie_thrower/no_stun_pie,
	)

/datum/gizpulse/pie_thrower

	var/range = 3

/datum/gizpulse/pie_thrower/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	throw_pie(holder)

	var/obj/item/food/pie/cream/mysterious_pie = new /obj/item/food/pie/cream
	mysterious_pie.stun_and_blur(holder)

/datum/gizpulse/pie_thrower/proc/throw_pie(atom/movable/holder)
	var/obj/item/food/pie/cream/mysterious_pie = new /obj/item/food/pie/cream
	for(var/mob/living/carbon/human/human in urange(range, holder))
		mysterious_pie.stun_and_blur(human)

/datum/gizpulse/pie_thrower/ordinary
