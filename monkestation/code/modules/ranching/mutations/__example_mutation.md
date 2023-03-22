
EXAMPLE MUTATION

Everything in the mutation needs to be true in order for it to have a chance at being born, so be careful when overloading these things.
/datum/mutation/ranching/chicken/debug_chicken
	chicken_type = /mob/living/simple_animal/chicken/debug

	happiness = 25
	needed_temperature = 4
	temperature_variance = 40
	needed_pressure = 0
	pressure_variance = 2

	food_requirements = list(/obj/item/food/burger/human, /obj/item/food/donut/jelly)
	reagent_requirements = list(/datum/reagent/drug/methamphetamine)
	needed_turfs = list(/turf/open/floor/iron)
	nearby_items = list(/obj/item/screwdriver)

