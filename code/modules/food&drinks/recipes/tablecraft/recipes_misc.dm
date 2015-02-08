
// see code/module/crafting/table.dm

// MISC

/datum/table_recipe/candiedapple
	name = "Candied apple"
	reqs = list(/datum/reagent/water = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/candiedapple

/datum/table_recipe/chococoin
	name = "Choco coin"
	reqs = list(
		/obj/item/weapon/coin = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chococoin

/datum/table_recipe/chocoorange
	name = "Choco orange"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocoorange

/datum/table_recipe/loadedbakedpotato
	name = "Loaded baked potato"
	time = 40
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato

/datum/table_recipe/cheesyfries
	name = "Cheesy fries"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyfries

/datum/table_recipe/wrap
	name = "Wrap"
	reqs = list(/datum/reagent/consumable/soysauce = 10,
		/obj/item/weapon/reagent_containers/food/snacks/friedegg = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/wrap

/datum/table_recipe/beans
	name = "Beans"
	time = 40
	reqs = list(/datum/reagent/consumable/ketchup = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/beans

/datum/table_recipe/eggplantparm
	name ="Eggplant parmigiana"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/eggplantparm

/datum/table_recipe/baguette
	name = "Baguette"
	time = 40
	reqs = list(/datum/reagent/consumable/sodiumchloride = 1,
				/datum/reagent/consumable/blackpepper = 1,
				/obj/item/weapon/reagent_containers/food/snacks/pastrybase = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/baguette

////////////////////////////////////////////////TOAST////////////////////////////////////////////////

/datum/table_recipe/slimetoast
	name = "Slime toast"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime

/datum/table_recipe/jelliedyoast
	name = "Jellied toast"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry

/datum/table_recipe/twobread
	name = "Two bread"
	reqs = list(
		/datum/reagent/consumable/ethanol/wine = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice/plain = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/twobread

