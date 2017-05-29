/obj/effect/decal
	name = "decal"
	anchored = 1
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/decal/ex_act(severity, target)
	qdel(src)

/obj/effect/decal/fire_act(exposed_temperature, exposed_volume)
	if(!(resistance_flags & FIRE_PROOF)) //non fire proof decal or being burned by lava
		qdel(src)

/obj/effect/decal/HandleTurfChange(turf/T)
	..()
	if(T == loc && (isspaceturf(T) || isclosedturf(T) || islava(T) || istype(T, /turf/open/water) || istype(T, /turf/open/chasm)))
		qdel(src)

/obj/effect/turf_decal
	var/group = TURF_DECAL_PAINT
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	anchored = 1

//in case we need some special decals
/obj/effect/turf_decal/proc/get_decal()
	return image(icon='icons/turf/decals.dmi',icon_state=icon_state,dir=dir,layer=TURF_LAYER)

/obj/effect/turf_decal/Initialize(mapload)
	var/turf/T = loc
	if(!istype(T)) //you know this will happen somehow
		CRASH("Turf decal initialized in an object/nullspace")
	T.add_decal(get_decal(),group)
	qdel(src)


/obj/effect/turf_decal/stripes/line
	icon_state = "warningline"

/obj/effect/turf_decal/stripes/end
	icon_state = "warn_end"

/obj/effect/turf_decal/stripes/corner
	icon_state = "warninglinecorner"

/obj/effect/turf_decal/stripes/asteroid/line
	icon_state = "ast_warn"

/obj/effect/turf_decal/stripes/asteroid/end
	icon_state = "ast_warn_end"

/obj/effect/turf_decal/stripes/asteroid/corner
	icon_state = "ast_warn_corner"

/obj/effect/turf_decal/delivery
	icon_state = "delivery"

/obj/effect/turf_decal/bot
	icon_state = "bot"

/obj/effect/turf_decal/loading_area
	icon_state = "loading_area"

/obj/effect/turf_decal/sand
	icon_state = "sandyfloor"

/obj/effect/turf_decal/sand/plating
	icon_state = "sandyplating"

/obj/effect/turf_decal/plaque
	icon_state = "plaque"