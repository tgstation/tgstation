// Primarly a debug utility to spawn most random kitchen stuff.
/obj/effect/spawner/porta_kitchen/Initialize(mapload)
	. = ..()

	var/turf/center_turf = get_step(get_turf(src), EAST)

	var/turf/current_turf = get_step(center_turf, NORTHWEST)
	new /obj/structure/table(current_turf)
	new /obj/machinery/reagentgrinder(current_turf)

	current_turf = get_step(center_turf, NORTH)
	new /obj/structure/table(current_turf)

	current_turf = get_step(center_turf, NORTHEAST)
	var/obj/machinery/vending/dinnerware/vendor = new(current_turf)
	vendor.all_products_free = TRUE

	current_turf = get_step(center_turf, EAST)
	new /obj/structure/table(current_turf)

	current_turf = get_step(center_turf, SOUTHEAST)
	new /obj/machinery/oven/range(current_turf)

	current_turf = get_step(center_turf, SOUTH)
	new /obj/machinery/griddle(current_turf)



	center_turf = get_step(get_step(center_turf, WEST), WEST)

	current_turf = get_step(center_turf, NORTH)
	new /obj/structure/table(current_turf)

	current_turf = get_step(center_turf, NORTHWEST)
	new /obj/machinery/deepfryer(current_turf)

	current_turf = get_step(center_turf, WEST)
	new /obj/structure/table(current_turf)

	current_turf = get_step(center_turf, SOUTHWEST)
	new /obj/machinery/processor(current_turf)

	current_turf = get_step(center_turf, SOUTH)
	new /obj/structure/table(current_turf)
	new /obj/machinery/microwave(current_turf)

