/obj/effect/decal
	name = "decal"
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/decal/ex_act(severity, target)
	qdel(src)

/obj/effect/decal/fire_act(exposed_temperature, exposed_volume)
	if(!(resistance_flags & FIRE_PROOF)) //non fire proof decal or being burned by lava
		qdel(src)

/obj/effect/decal/HandleTurfChange(turf/T)
	..()
	if(T == loc && (isspaceturf(T) || isclosedturf(T) || islava(T) || istype(T, /turf/open/water) || ischasm(T)))
		qdel(src)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/turf_decal
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	var/turf_decal_type = /datum/component/turf_decal

/obj/effect/turf_decal/Initialize()
	..()
	var/turf/T = loc
	if(!istype(T)) //you know this will happen somehow
		CRASH("Turf decal initialized in an object/nullspace")
	T.AddComponent(turf_decal_type, dir)
	return INITIALIZE_HINT_QDEL

/obj/effect/turf_decal/stripes/line
	icon_state = "warningline"
	turf_decal_type = /datum/component/turf_decal/stripes/line

/obj/effect/turf_decal/stripes/end
	icon_state = "warn_end"
	turf_decal_type = /datum/component/turf_decal/stripes/end

/obj/effect/turf_decal/stripes/corner
	icon_state = "warninglinecorner"
	turf_decal_type = /datum/component/turf_decal/stripes/corner

/obj/effect/turf_decal/stripes/asteroid/line
	icon_state = "ast_warn"
	turf_decal_type = /datum/component/turf_decal/stripes/asteroid/line

/obj/effect/turf_decal/stripes/asteroid/end
	icon_state = "ast_warn_end"
	turf_decal_type = /datum/component/turf_decal/stripes/asteroid/end

/obj/effect/turf_decal/stripes/asteroid/corner
	icon_state = "ast_warn_corner"
	turf_decal_type = /datum/component/turf_decal/stripes/asteroid/corner

/obj/effect/turf_decal/delivery
	icon_state = "delivery"
	turf_decal_type = /datum/component/turf_decal/delivery

/obj/effect/turf_decal/bot
	icon_state = "bot"
	turf_decal_type = /datum/component/turf_decal/bot

/obj/effect/turf_decal/loading_area
	icon_state = "loading_area"
	turf_decal_type = /datum/component/turf_decal/loading_area

/obj/effect/turf_decal/sand
	icon_state = "sandyfloor"
	turf_decal_type = /datum/component/turf_decal/sand

/obj/effect/turf_decal/sand/warning
	icon_state = "sandy_warn"
	turf_decal_type = /datum/component/turf_decal/sand/warning

/obj/effect/turf_decal/sand/warning/corner
	icon_state = "sandy_warn_corner"
	turf_decal_type = /datum/component/turf_decal/sand/warning/corner

/obj/effect/turf_decal/sand/plating
	icon_state = "sandyplating"
	turf_decal_type = /datum/component/turf_decal/sand/plating

/obj/effect/turf_decal/sand/plating/warning
	icon_state = "sandy_plating_warn"
	turf_decal_type = /datum/component/turf_decal/sand/plating/warning

/obj/effect/turf_decal/sand/plating/warning/corner
	icon_state = "sandy_plating_warn_corner"
	turf_decal_type = /datum/component/turf_decal/sand/plating/warning/corner

/obj/effect/turf_decal/plaque
	icon_state = "plaque"
	turf_decal_type = /datum/component/turf_decal/plaque
