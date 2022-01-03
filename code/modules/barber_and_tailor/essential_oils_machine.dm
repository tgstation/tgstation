/obj/machinery/essential_oils_machine
	name = "essential oil machine"
	desc = "Insert edible objects to mulch them into essential oils for massage work."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "oil_machine"
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/essential_oils_machine
	density = TRUE
	var/rating = 1

/obj/machinery/essential_oils_machine/RefreshParts()
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating = M.rating

/obj/machinery/essential_oils_machine/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon, /obj/item/food/grown))
		var/obj/item/food/grown/plant = weapon
		var/obj/item/essential_oil/oil = new(get_turf(src))
		oil.potency = plant.seed.potency * rating
		for(var/datum/plant_gene/reagent/reagent_gene in plant.seed.genes)
			oil.reagents_to_apply += reagent_gene.reagent_id
		oil.name = "[plant.name]-brand essential oil"
		oil.desc = "A plastic container of essential oils made from [plant.name]. Use for back massages."
		oil.color = plant.filling_color
		to_chat(user, "You extract the plant into an essential oil.")
		qdel(plant)
