//////////////////////////
/////Driveshaft Event/////
//////////////////////////

/obj/effect/immovablerod/driveshaft
	name = "hyperspaced driveshaft"
	desc = "What the fuck is that?"
	icon = 'modular_meta/features/cheburek_car/icons/anomaly.dmi'
	icon_state = "driveshaft"
	notify = FALSE
	loopy_rod = TRUE
	dnd_style_level_up = FALSE
	/// The distance the rod will go.
	var/max_distance = 13
	/// The turf the rod started from, to calcuate distance.
	var/turf/start_turf

/obj/effect/immovablerod/driveshaft/Initialize(mapload, atom/target_atom, atom/specific_target, force_looping = FALSE, max_distance = 13)
	. = ..()
	start_turf = get_turf(src)
	src.max_distance = max_distance

/obj/effect/immovablerod/driveshaft/Destroy(force)
	start_turf = null
	return ..()

/obj/effect/immovablerod/driveshaft/Move()
	if(get_dist(start_turf, get_turf(src)) >= max_distance)
		qdel(src)
		return
	return ..()

/obj/effect/immovablerod/driveshaft/penetrate(mob/living/penetrated)
	penetrated.visible_message(
		span_danger("[penetrated] is penetrated by a hyperspaced driveshaft!"),
		span_userdanger("The [src] penetrates you!"),
		span_danger("You hear a CRANG!"),
		)
	penetrated.adjustBruteLoss(50)
