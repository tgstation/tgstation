///max amount of pills allowed on our tile before we start storing them instead
#define MAX_FLOOR_PRODUCTS 10

/datum/component/plumbing/pill_press
	demand_connects = SOUTH
	distinct_reagent_cap = 3

/datum/component/plumbing/pill_press/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/pill_press))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/pill_press/send_request(dir)
	var/obj/machinery/plumbing/pill_press/target = parent

	//required volume of reagents to package the product has been sent
	if(reagents.total_volume >= target.current_volume)
		return

	//dont dump too much products on the ground
	var/container_amount = 0
	for(var/obj/item/reagent_containers/thing in target.loc)
		container_amount++
		if(container_amount >= MAX_FLOOR_PRODUCTS) //too much so just stop
			return

	//request reagents
	return ..()

#undef MAX_FLOOR_PRODUCTS
