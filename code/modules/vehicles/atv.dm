
/obj/vehicle/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-earth technologies that are still relevant on most planet-bound outposts."
	icon_state = "atv"
	var/static/mutable_appearance/atvcover

/obj/vehicle/atv/buckle_mob(mob/living/buckled_mob, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/atv

/obj/vehicle/atv/Initialize()
	. = ..()
	atvcover = atvcover || mutable_appearance(icon, "atvcover", ABOVE_MOB_LAYER)


/obj/vehicle/atv/post_buckle_mob(mob/living/M)
	if(has_buckled_mobs())
		add_overlay(atvcover)
	else
		cut_overlay(atvcover)



//TURRETS!
/obj/vehicle/atv/turret
	var/obj/machinery/porta_turret/syndicate/vehicle_turret/turret = null


/obj/machinery/porta_turret/syndicate/vehicle_turret
	name = "mounted turret"
	scan_range = 7
	emp_vunerable = 1
	density = 0


/obj/vehicle/atv/turret/Initialize()
	. = ..()
	turret = new(loc)
	turret.base = src

/obj/vehicle/atv/turret/buckle_mob(mob/living/buckled_mob, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/atv/turret

