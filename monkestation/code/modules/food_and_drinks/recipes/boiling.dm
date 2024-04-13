/datum/chemical_reaction/food/soup/boiledspaghetti
	required_ingredients = list(/obj/item/food/spaghetti/raw = 1)
	required_reagents = list(/datum/reagent/water = 50)
	outputted_ingredients = list(/obj/item/food/spaghetti/boiledspaghetti = 1)
	results = list(/datum/reagent/water = 5)
	max_outputs = 10
	Nonsouprecipe = TRUE

/datum/chemical_reaction/food/soup/boiledrice
	required_ingredients = list(/obj/item/food/uncooked_rice = 1)
	required_reagents = list(/datum/reagent/water = 50)
	outputted_ingredients = list(/obj/item/food/boiledrice = 1)
	results = list(/datum/reagent/water = 5)
	max_outputs = 10
	Nonsouprecipe = TRUE

// Machinery: Stove
/datum/crafting_recipe/food/stove
	machinery = list(/obj/machinery/stove)
	steps = list("Add all ingredients into a soup pot","Heat up to 450K")
	category = CAT_SPAGHETTI
	non_craftable = TRUE

/datum/crafting_recipe/food/stove/boiledspaghetti
	reqs = list(/datum/reagent/water = 50, /obj/item/reagent_containers/cup/soup_pot, /obj/item/food/spaghetti/raw = 1)
	result = /obj/item/food/spaghetti/boiledspaghetti

/datum/crafting_recipe/food/stove/boiledrice
	reqs = list(/datum/reagent/water = 50, /obj/item/reagent_containers/cup/soup_pot, /obj/item/food/uncooked_rice = 1)
	result = /obj/item/food/boiledrice
	category = CAT_SALAD
