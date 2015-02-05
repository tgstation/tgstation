
// see code/datums/recipe.dm

////////////////////////////////////////////////SOUP////////////////////////////////////////////////

/datum/table_recipe/soup/meatball
	name = "Meatball soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/meatball

/datum/table_recipe/soup/vegetable
	name = "Vegetable soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/vegetable

/datum/table_recipe/soup/nettle
	name = "Nettle soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/grown/nettle = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/weapon/reagent_containers/food/snacks/egg = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/nettle

/datum/table_recipe/soup/wish
	name = "Wish soup"
	reqs = list(
		/datum/reagent/water = 20,
		/obj/item/weapon/reagent_containers/glass/bowl = 1
	)
	result= /obj/item/weapon/reagent_containers/food/snacks/soup/wish

/datum/table_recipe/soup/hotchili
	name = "Hot chili"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/hotchili

/datum/table_recipe/soup/coldchili
	name = "Cold chili"
	reqs = list(
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/coldchili

/datum/table_recipe/soup/tomato
	name = "Tomato soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/tomato

/datum/table_recipe/soup/milo
	name = "Milo soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/soydope = 2,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/milo

/datum/table_recipe/soup/blood
	name = "Blood soup"
	reqs = list(
		/datum/reagent/blood = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blood = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/blood

/datum/table_recipe/soup/slime
	name = "Slime soup"
	reqs = list(
			/datum/reagent/water = 10,
			/datum/reagent/toxin/slimejelly = 5,
			/obj/item/weapon/reagent_containers/glass/bowl = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/slime

/datum/table_recipe/soup/clownstears
	name = "Clowns tears"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/weapon/ore/bananium = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/clownstears

/datum/table_recipe/soup/mystery
	name = "Mystery soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/badrecipe = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 1,
		/obj/item/weapon/reagent_containers/food/snacks/egg = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/mystery

/datum/table_recipe/soup/mushroom
	name = "Mushroom soup"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/water = 5,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/mushroom

/datum/table_recipe/soup/beet
	name = "Beet soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/beet

/datum/table_recipe/soup/stew
	name = "Stew"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/stew

/datum/table_recipe/soup/spacylibertyduff
	name = "Space liberty duff"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 5,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/spacylibertyduff

/datum/table_recipe/soup/amanitajelly
	name = "Amanita jelly"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 5,
		/obj/item/weapon/reagent_containers/glass/bowl = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/amanitajelly



