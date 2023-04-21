/datum/tree_node/major/fruit/strange_fruit
	created_fruit = /obj/item/fruit/strange_fruit
	pulses_per_fruit = 6


/obj/item/fruit/strange_fruit
	name = "Strange Fruit"
	desc = "A Strange Fruit, seems perfect to use as fertilizer"
	icon_state = "strange"

/obj/item/fruit/strange_fruit/on_hydrotray_add(obj/item/seeds/stored_seed)
	stored_seed.add_random_reagents(4,6)
