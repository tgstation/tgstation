/obj/effect/decal
	name = "decal"
	anchored = 1
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/decal/ex_act(severity, target)
	qdel(src)

/obj/effect/decal/fire_act(exposed_temperature, exposed_volume)
	if(!(resistance_flags & FIRE_PROOF)) //non fire proof decal or being burned by lava
		qdel(src)


/obj/effect/turf_decal
	var/group = TURF_DECAL_PAINT
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"

//in case we need some special decals
/obj/effect/turf_decal/proc/get_decal()
	return image(icon='icons/turf/decals.dmi',icon_state=icon_state,dir=dir,layer=TURF_LAYER)

/obj/effect/turf_decal/initialize()
	var/turf/T = loc
	if(!istype(T)) //you know this will happen somehow
		return
	T.add_decal(get_decal(),group)
	qdel(src)


/obj/effect/turf_decal/stripes/line
	icon_state = "warningline"

/obj/effect/turf_decal/stripes/side
	icon_state = "warn_side"

/obj/effect/turf_decal/stripes/corner
	icon_state = "warninglinecorner"