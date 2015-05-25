
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
	result = /obj/item/weapon/reagent_containers/food/snacks/eggwrap

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

/datum/table_recipe/burrito
	name ="Burrito"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burrito

/datum/table_recipe/cheesyburrito
	name ="Cheesy burrito"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyburrito

/datum/table_recipe/carneburrito
	name ="Carne de asada burrito"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/carneburrito

/datum/table_recipe/fuegoburrito
	name ="Fuego plasma burrito"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/tortilla = 1,,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fuegoburrito

/datum/table_recipe/melonfruitbowl
	name ="Melon fruit bowl"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/melonfruitbowl

/datum/table_recipe/spacefreezy
	name ="Space freezy"
	reqs = list(
		/datum/reagent/consumable/bluecherryjelly = 5,
		/datum/reagent/consumable/spacemountainwind = 15,
		/obj/item/weapon/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spacefreezy

/datum/table_recipe/sundae
	name ="Sundae"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/weapon/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sundae

/datum/table_recipe/honkdae
	name ="Honkdae"
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 2,
		/obj/item/weapon/reagent_containers/food/snacks/icecream = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/honkdae

/datum/table_recipe/nachos
	name ="Nachos"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tortilla = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/nachos

/datum/table_recipe/cheesynachos
	name ="Cheesy nachos"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tortilla = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesynachos

/datum/table_recipe/cubannachos
	name ="Cuban nachos"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili = 2,
		/obj/item/weapon/reagent_containers/food/snacks/tortilla = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cubannachos

/datum/table_recipe/melonkeg
	name ="Melon keg"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 25,
		/obj/item/weapon/reagent_containers/food/snacks/grown/holymelon = 1,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 1
	)
	parts = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/melonkeg