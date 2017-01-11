
/obj/vehicle/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-earth technologies that are still relevant on most planet-bound outposts."
	icon_state = "atv"
	var/static/image/atvcover = null

/obj/vehicle/atv/buckle_mob()
	. = ..()
	riding_datum = new/datum/riding/atv

/obj/vehicle/atv/New()
	..()
	if(!atvcover)
		atvcover = image("icons/obj/vehicles.dmi", "atvcover")
		atvcover.layer = ABOVE_MOB_LAYER


/obj/vehicle/atv/post_buckle_mob(mob/living/M)
	if(has_buckled_mobs())
		add_overlay(atvcover)
	else
		overlays -= atvcover



//TURRETS!
/obj/vehicle/atv/turret
	var/obj/machinery/porta_turret/syndicate/vehicle_turret/turret = null


/obj/machinery/porta_turret/syndicate/vehicle_turret
	name = "mounted turret"
	scan_range = 7
	emp_vunerable = 1
	density = 0


/obj/vehicle/atv/turret/New()
	. = ..()
	turret = new(loc)
	turret.base = src

/obj/vehicle/atv/turret/buckle_mob()
	..()
	riding_datum = new/datum/riding/atv/turret


