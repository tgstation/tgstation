/obj/structure/spacepoddoor
	name = "Podlock"
	desc = "An air-tight holodoor that only lets spacepods through."
	icon = 'icons/effects/beam.dmi'
	icon_state = "n_beam"
	density = 0
	anchored = TRUE
	var/id = 1.0

/obj/structure/spacepoddoor/Initialize()
	. = ..()
	air_update_turf(TRUE)

/obj/structure/spacepoddoor/CanAtmosPass(turf/T)
	return FALSE

/obj/structure/spacepoddoor/Destroy()
	air_update_turf(TRUE)
	return ..()

/obj/structure/spacepoddoor/CanPass(atom/movable/A, turf/T)
	if(istype(A, /obj/spacepod))
		return ..()
	else
		return FALSE