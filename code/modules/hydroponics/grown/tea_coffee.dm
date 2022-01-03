// Tea
/obj/item/seeds/tea
	name = "pack of tea aspera seeds"
	desc = "These seeds grow into tea plants."
	icon_state = "seed-teaaspera"
	species = "teaaspera"
	plantname = "Tea Aspera Plant"
	product = /obj/item/food/grown/tea
	lifespan = 20
	maturation = 5
	production = 5
	yield = 5
	growthstages = 5
	icon_dead = "tea-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/tea/astra)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/toxin/teapowder = 0.1)

/obj/item/food/grown/tea
	seed = /obj/item/seeds/tea
	name = "Tea Aspera tips"
	desc = "These aromatic tips of the tea plant can be dried to make tea."
	icon_state = "tea_aspera_leaves"
	grind_results = list(/datum/reagent/toxin/teapowder = 0)
	dry_grind = TRUE
	can_distill = FALSE
	filling_color = "#008000"

// Tea Astra
/obj/item/seeds/tea/astra
	name = "pack of tea astra seeds"
	icon_state = "seed-teaastra"
	species = "teaastra"
	plantname = "Tea Astra Plant"
	product = /obj/item/food/grown/tea/astra
	mutatelist = null
	reagents_add = list(/datum/reagent/medicine/synaptizine = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/toxin/teapowder = 0.1)
	rarity = 20

/obj/item/food/grown/tea/astra
	seed = /obj/item/seeds/tea/astra
	name = "Tea Astra tips"
	icon_state = "tea_astra_leaves"
	bite_consumption_mod = 2
	grind_results = list(/datum/reagent/toxin/teapowder = 0, /datum/reagent/medicine/salglu_solution = 0)
	filling_color = "#4582B4"


// Coffee
/obj/item/seeds/coffee
	name = "pack of coffee arabica seeds"
	desc = "These seeds grow into coffee arabica bushes."
	icon_state = "seed-coffeea"
	species = "coffeea"
	plantname = "Coffee Arabica Bush"
	product = /obj/item/food/grown/coffee
	lifespan = 30
	endurance = 20
	maturation = 5
	production = 5
	yield = 5
	instability = 20
	growthstages = 5
	icon_dead = "coffee-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/coffee/robusta)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/toxin/coffeepowder = 0.1, /datum/reagent/nitrogen = 0.05)

/obj/item/food/grown/coffee
	seed = /obj/item/seeds/coffee
	name = "coffee arabica beans"
	desc = "Dry them out to make coffee."
	icon_state = "coffee_arabica"
	dry_grind = TRUE
	grind_results = list(/datum/reagent/toxin/coffeepowder = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/kahlua
	filling_color = "#DC143C"

// Coffee Robusta
/obj/item/seeds/coffee/robusta
	name = "pack of coffee robusta seeds"
	desc = "These seeds grow into coffee robusta bushes."
	icon_state = "seed-coffeer"
	species = "coffeer"
	plantname = "Coffee Robusta Bush"
	product = /obj/item/food/grown/coffee/robusta
	mutatelist = null
	reagents_add = list(/datum/reagent/medicine/ephedrine = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/toxin/coffeepowder = 0.1)
	rarity = 20

/obj/item/food/grown/coffee/robusta
	seed = /obj/item/seeds/coffee/robusta
	name = "coffee robusta beans"
	desc = "Increases robustness by 37 percent!"
	icon_state = "coffee_robusta"
	grind_results = list(/datum/reagent/toxin/coffeepowder = 0, /datum/reagent/medicine/morphine = 0)
