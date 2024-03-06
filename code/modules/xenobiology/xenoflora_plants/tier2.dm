/// Broombush

/datum/xenoflora_plant/broombush
	name = "Broombush"
	desc = "A bright green plant that somewhat resembles normal cabbage, broombush requires high amounts of N2 to grow and produces N2O as byproduct. It's leaves are ribbed and very bitter and are usually left for animals."

	icon_state = "broombush"
	ground_icon_state = "grass_alien"
	seeds_icon_state = "xenoseeds-broombush"

	required_gases = list(/datum/gas/nitrogen = 0.1)
	produced_gases = list()
	min_safe_temp = T0C
	max_safe_temp = T0C + 60

	min_produce = 2
	max_produce = 3
	produce_type = /obj/item/food/xenoflora/broombush

/obj/item/food/xenoflora/broombush
	name = "broombush leaf"
	desc = "A bright green ribbed leaf from a broombush plant. These are extremely bitter and are usually only fed to slimes and wobble chicken."
	icon_state = "broombush"
	tastes = list("extreme bitterness" = 3, "rotting socks" = 1)
	bite_consumption = 3
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/cellulose = 3)
	foodtypes = GROSS | VEGETABLES
	grind_results = list(/datum/reagent/cellulose = 10, /datum/reagent/consumable/nutriment = 5)
	seed_type = /obj/item/xeno_seeds/broombush

/// Cubomelon

/datum/xenoflora_plant/cubomelon
	name = "Cubomelon"
	desc = "As the name implies, cubomelons are basically cube-shaped watermelons colored blue. Human consumption of these is not recommended due to high concentration of frost oil."

	icon_state = "cubomelon"
	ground_icon_state = "dirt"
	seeds_icon_state = "xenoseeds-cubomelon"

	required_chems = list(/datum/reagent/bromine = 0.2)
	produced_chems = list(/datum/reagent/medicine/c2/hercuri = 0.05) //Slooow
	min_safe_temp = 213.15
	max_safe_temp = T0C

	min_produce = 1
	max_produce = 1
	max_progress = 100 //Grows three times as fast because it drops only one melon
	produce_type = /obj/item/food/xenoflora/cubomelon

/datum/xenoflora_plant/cubomelon/harvested(mob/harvester)
	. = ..()
	parent_pod.plant = null
	parent_pod.update_icon()
	qdel(src)

/obj/item/food/xenoflora/cubomelon
	name = "cubomelon"
	desc = "A huge blue cubomelon with a greenish tint, indicating that it was grown artificially."
	icon_state = "cubomelon"
	tastes = list("cubomelon" = 3, "cold" = 1)
	bite_consumption = 6
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/frostoil = 12)
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/frostoil = 18, /datum/reagent/consumable/nutriment = 5)
	seed_type = /obj/item/xeno_seeds/cubomelon
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/food/xenoflora/cubomelon/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/xenoflora/cubomelon_slice, 5, 20)

/obj/item/food/xenoflora/cubomelon_slice
	name = "cubomelon slice"
	desc = "A slice of blue juicy cubomelon. It's cold to touch."
	icon_state = "cubomelonslice"
	food_reagents = list(/datum/reagent/consumable/frostoil = 1, /datum/reagent/consumable/nutriment/vitamin = 0.2, /datum/reagent/consumable/nutriment = 1)
	tastes = list("cubomelon" = 1, "cold" = 1)
	juice_typepath = list(/datum/reagent/consumable/frostoil = 5, /datum/reagent/consumable/nutriment = 1)
	foodtypes = FRUIT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	seed_type = /obj/item/xeno_seeds/cubomelon
