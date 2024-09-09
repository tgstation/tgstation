// Peanuts!
/obj/item/seeds/peanut
	name = "peanut seed pack"
	desc = "These seeds grow into peanut plants."
	icon_state = "seed-peanut"
	species = "peanut"
	plantname = "Peanut Plant"
	product = /obj/item/food/grown/peanut
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/service/hydroponics/growing.dmi'
	icon_grow = "peanut-grow"
	icon_dead = "peanut-dead"
	genes = list(/datum/plant_gene/trait/one_bite)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/peanut
	seed = /obj/item/seeds/peanut
	name = "peanut"
	desc = "A tasty pair of groundnuts concealed in a tough shell."
	icon_state = "peanut"
	foodtypes = NUTS
	grind_results = list(/datum/reagent/consumable/peanut_butter = 0)
	tastes = list("peanuts" = 1)
