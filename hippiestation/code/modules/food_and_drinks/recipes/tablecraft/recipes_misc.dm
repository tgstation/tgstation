/datum/crafting_recipe/food/haggis
	name = "Haggis"
	reqs = list(
		/obj/item/organ/heart = 1,
		/obj/item/organ/liver = 1,
		/obj/item/organ/lungs = 1,
		/obj/item/organ/stomach = 1,
		/obj/item/reagent_containers/food/snacks/grown/onion = 1,
		/obj/item/reagent_containers/food/snacks/salad/oatmeal = 1,
		/datum/reagent/consumable/sodiumchloride = 1,
	)
	result = /obj/item/reagent_containers/food/snacks/store/bread/haggis
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/neep_tatty_haggis
	name = "Haggis with neeps and tatties"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/breadslice/haggis = 1,
		/obj/item/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/reagent_containers/food/snacks/grown/redbeet = 1,
		/obj/item/reagent_containers/food/snacks/grown/whitebeet = 1
		)
	result = /obj/item/reagent_containers/food/snacks/neep_tatty_haggis
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/l_legtaco
	name ="Leg Taco L"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/bodypart/l_leg = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1,
	)
	result = /obj/item/reagent_containers/food/snacks/taco/leg
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/r_legtaco
	name ="Leg Taco R"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tortilla = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/bodypart/r_leg = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1,
	)
	result = /obj/item/reagent_containers/food/snacks/taco/leg
	subcategory = CAT_MISCFOOD