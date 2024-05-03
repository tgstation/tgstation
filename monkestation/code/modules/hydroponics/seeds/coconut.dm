/obj/item/seeds/coconut
	name = "pack of Coconut seeds"
	desc = "These seeds grow into coconut trees."
	plant_icon_offset = 0
	icon = 'monkestation/icons/obj/hydroponics/fruit.dmi'
	icon_state = "coconut_seed"

	growing_icon = 'goon/icons/obj/hydroponics/plants_fruit.dmi'
	growthstages = 3
	icon_grow = "coconut-grow"
	icon_dead = "coconut-dead"
	icon_harvest = "coconut-harvest"
	plantname = "Coconut Tree"

	yield = 5
	potency = 75
	lifespan = 125
	harvest_age = 250

	product = /obj/item/food/grown/coconut
	genes = list(/datum/plant_gene/trait/repeated_harvest)

	reagents_add = list(/datum/reagent/consumable/milk = 0.05, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.02)
	infusion_mutations = list(/datum/hydroponics/plant_mutation/infusion/coconut_gun)

/obj/item/seeds/coconut/gun
	name = "coconut gun tree"

	icon_state = "coconut_gun_seed"

	possible_mutations = list()

	product = /obj/item/food/grown/shell/coconut_gun
