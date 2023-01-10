//Korta Nut
/obj/item/seeds/korta_nut
	name = "pack of korta nut seeds"
	desc = "These seeds grow into korta nut bushes, native to Tizira."
	icon_state = "seed-korta"
	species = "kortanut"
	plantname = "Korta Nut Bush"
	product = /obj/item/food/grown/korta_nut
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "kortanut-grow"
	icon_dead = "kortanut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/one_bite)
	mutatelist = list(/obj/item/seeds/korta_nut/sweet)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/korta_nut
	seed = /obj/item/seeds/korta_nut
	name = "korta nut"
	desc = "A little nut of great importance. Has a peppery shell which can be ground into flour and a soft, pulpy interior that produces a milky fluid when juiced. Or you can eat them whole, as a quick snack."
	icon_state = "korta_nut"
	foodtypes = NUTS
	grind_results = list(/datum/reagent/consumable/korta_flour = 0)
	juice_results = list(/datum/reagent/consumable/korta_milk = 0)
	tastes = list("peppery heat" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/kortara

//Sweet Korta Nut
/obj/item/seeds/korta_nut/sweet
	name = "pack of sweet korta nut seeds"
	desc = "These seeds grow into sweet korta nuts, a mutation of the original species that produces a thick syrup that Tizirans use for desserts."
	icon_state = "seed-sweetkorta"
	species = "kortanut"
	plantname = "Sweet Korta Nut Bush"
	product = /obj/item/food/grown/korta_nut/sweet
	maturation = 10
	production = 10
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/korta_nectar = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20

/obj/item/food/grown/korta_nut/sweet
	seed = /obj/item/seeds/korta_nut/sweet
	name = "sweet korta nut"
	desc = "A sweet treat lizards love to eat."
	icon_state = "korta_nut"
	grind_results = list(/datum/reagent/consumable/korta_flour = 0)
	juice_results = list(/datum/reagent/consumable/korta_milk = 0, /datum/reagent/consumable/korta_nectar = 0)
	tastes = list("peppery sweet" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/kortara
