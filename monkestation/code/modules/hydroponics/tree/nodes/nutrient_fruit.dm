/datum/tree_node/major/fruit/nutribooster
	created_fruit = /obj/item/fruit/nutribooster
	pulses_per_fruit = 6


/obj/item/fruit/nutribooster
	name = "Stat Boosting Fruit"
	desc = "A Strange Fruit, seems perfect to use as fertilizer"
	icon_state = "strange"

/obj/item/fruit/strange_fruit/on_hydrotray_add(obj/item/seeds/stored_seed)
	stored_seed.adjust_endurance(rand(10, 30))
	stored_seed.adjust_lifespan(rand(10, 30))
	stored_seed.adjust_maturation(rand(5, 15))
	stored_seed.adjust_production(rand(5, 15))
	stored_seed.adjust_potency(rand(10, 30))
	stored_seed.adjust_yield(rand(1, 10))
