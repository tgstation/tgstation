// Tea
/obj/item/seeds/tea
	name = "pack of tea aspera seeds"
	desc = "These seeds grow into tea plants."
	icon_state = "seed-teaaspera"
	species = "teaaspera"
	plantname = "Tea Aspera Plant"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tea
	lifespan = 20
	maturation = 5
	production = 5
	yield = 5
	growthstages = 5
	mutatelist = list(/obj/item/seeds/tea/astra)

/obj/item/weapon/reagent_containers/food/snacks/grown/tea
	seed = /obj/item/seeds/tea
	name = "Tea Aspera tips"
	desc = "These aromatic tips of the tea plant can be dried to make tea."
	icon_state = "tea_aspera_leaves"
	filling_color = "#008000"
	reagents_add = list("vitamin" = 0.04, "teapowder" = 0.1)

// Tea Astra
/obj/item/seeds/tea/astra
	name = "pack of tea astra seeds"
	icon_state = "seed-teaastra"
	species = "teaastra"
	plantname = "Tea Astra Plant"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra
	mutatelist = list()
	rarity = 20

/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra
	seed = /obj/item/seeds/tea/astra
	name = "Tea Astra tips"
	icon_state = "tea_astra_leaves"
	filling_color = "#4582B4"
	reagents_add = list("salglu_solution" = 0.05, "vitamin" = 0.04, "teapowder" = 0.1)


// Coffee
/obj/item/seeds/coffee
	name = "pack of coffee arabica seeds"
	desc = "These seeds grow into coffee arabica bushes."
	icon_state = "seed-coffeea"
	species = "coffeea"
	plantname = "Coffee Arabica Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/coffee
	lifespan = 30
	endurance = 20
	maturation = 5
	production = 5
	yield = 5
	growthstages = 5
	mutatelist = list(/obj/item/seeds/coffee/robusta)

/obj/item/weapon/reagent_containers/food/snacks/grown/coffee
	seed = /obj/item/seeds/coffee
	name = "coffee arabica beans"
	desc = "Dry them out to make coffee."
	icon_state = "coffee_arabica"
	filling_color = "#DC143C"
	bitesize_mod = 2
	reagents_add = list("vitamin" = 0.04, "coffeepowder" = 0.1)

// Coffee Robusta
/obj/item/seeds/coffee/robusta
	name = "pack of coffee robusta seeds"
	desc = "These seeds grow into coffee robusta bushes."
	icon_state = "seed-coffeer"
	species = "coffeer"
	plantname = "Coffee Robusta Bush"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta
	mutatelist = list()
	rarity = 20

/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta
	seed = /obj/item/seeds/coffee/robusta
	name = "coffee robusta beans"
	icon_state = "coffee_robusta"
	reagents_add = list("morphine" = 0.05, "vitamin" = 0.04, "coffeepowder" = 0.1)