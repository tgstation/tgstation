/obj/item/stack/tile/plasteel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon"
	icon_state = "tile"
	w_class = 3.0
	force = 6.0
	m_amt = 937.5
	w_type = RECYK_METAL
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	max_amount = 60

/obj/item/stack/tile/plasteel/New()
	. = ..()
	pixel_x = rand(1, 14)
	pixel_y = rand(1, 14)

/obj/item/stack/tile/plasteel/recycle(var/datum/materials/rec)
	rec.addAmount("iron",amount/4)
	return 1

/*
/obj/item/stack/tile/plasteel/attack_self(mob/user as mob)
	if (usr.stat)
		return
	var/T = user.loc
	if (!( istype(T, /turf) ))
		user << "\red You must be on the ground!"
		return
	if (!( istype(T, /turf/space) ))
		user << "\red You cannot build on or repair this turf!"
		return
	src.build(T)
	src.add_fingerprint(user)
	use(1)
	return
*/

/obj/item/stack/tile/plasteel/proc/build(turf/S as turf)
	if (istype(S,/turf/space))
		S.ChangeTurf(/turf/simulated/floor/plating/airless)
	else
		S.ChangeTurf(/turf/simulated/floor/plating)
//	var/turf/simulated/floor/W = S.ReplaceWithFloor()
//	W.make_plating()
	return