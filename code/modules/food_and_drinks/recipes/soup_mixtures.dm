/datum/chemical_reaction/food/soup
	required_temp = 450
	optimal_temp = 480
	overheat_temp = 600
	optimal_ph_min = 1
	optimal_ph_max = 14
	required_reagents = list(/datum/reagent/water = 50)
	mob_react = FALSE
	require_other = TRUE
	required_container = /obj/item/reagent_containers/cup/soup_pot

	var/list/required_ingredients

/datum/chemical_reaction/food/soup/pre_reaction_other_checks(datum/reagents/holder)
	if(!length(required_ingredients))
		return TRUE

	var/obj/item/reagent_containers/cup/soup_pot/pot = holder.my_atom
	if(!istype(pot))
		return FALSE

	// This is very unoptimized for something ran every handle-reaction for every soup recipe.
	// Look into ways for improving this, cause bleh
	var/list/reqs_copy = required_ingredients.Copy()
	for(var/obj/item/ingredient as anything in pot.added_ingredients)
		// See if we fulfill all reqs
		for(var/ingredient_type in required_ingredients)
			if(!istype(ingredient, ingredient_type))
				continue
			if(isstack(ingredient))
				var/obj/item/stack/stack_ingredient = ingredient
				reqs_copy[ingredient_type] -= stack_ingredient.amount
			else
				reqs_copy[ingredient_type] -= 1

	for(var/fulfilled in reqs_copy)
		if(reqs_copy[fulfilled] > 0)
			return FALSE
	return TRUE

/datum/chemical_reaction/food/soup/meatballsoup
	required_ingredients = list(
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/potato = 1,
	)

/datum/chemical_reaction/food/soup/vegetablesoup
	required_ingredients = list(
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/potato = 1,
	)


/datum/chemical_reaction/food/soup/nettlesoup
	required_ingredients = list(
		/obj/item/food/grown/nettle = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/boiledegg = 1
	)

/datum/chemical_reaction/food/soup/wingfangchu
	required_reagents = list(
		/datum/reagent/water = 50,
		/datum/reagent/consumable/soysauce = 5,
	)
	required_ingredients = list(
		/obj/item/food/meat/cutlet/xeno = 2,
	)

/*
/datum/chemical_reaction/food/soup/wishsoup
	required_ingredients = list(
		/datum/reagent/water = 20,
	)
*/

/datum/chemical_reaction/food/soup/hotchili
	required_ingredients = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1,
	)

/datum/chemical_reaction/food/soup/coldchili
	required_ingredients = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/icepepper = 1,
		/obj/item/food/grown/tomato = 1,
	)

/datum/chemical_reaction/food/soup/clownchili
	required_ingredients = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/clothing/shoes/clown_shoes = 1,
	)
/datum/chemical_reaction/food/soup/tomatosoup
	required_ingredients = list(
		/obj/item/food/grown/tomato = 2,
	)

/datum/chemical_reaction/food/soup/eyeballsoup
	required_ingredients = list(
		/obj/item/food/grown/tomato = 2,
		/obj/item/organ/internal/eyes = 1,
	)

/datum/chemical_reaction/food/soup/misosoup
	required_ingredients = list(
		/obj/item/food/soydope = 2,
		/obj/item/food/tofu = 2,
	)

/datum/chemical_reaction/food/soup/bloodsoup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/blood = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/tomato/blood = 2,
	)

/datum/chemical_reaction/food/soup/slimesoup
	required_other = FALSE
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/toxin/slimejelly = 10,
	)

/datum/chemical_reaction/food/soup/clownstears
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/lube = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/banana = 1,
		/obj/item/stack/sheet/mineral/bananium = 1,
	)

/datum/chemical_reaction/food/soup/mysterysoup
	required_ingredients = list(
		/obj/item/food/badrecipe = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/cheese/wedge = 1,
	)

/datum/chemical_reaction/food/soup/mushroomsoup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/milk = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/chanterelle = 1,
	)

/datum/chemical_reaction/food/soup/beetsoup
	required_ingredients = list(
		/obj/item/food/grown/whitebeet = 1,
		/obj/item/food/grown/cabbage = 1,
	)

/datum/chemical_reaction/food/soup/stew
	required_ingredients = list(
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meat/cutlet = 3,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/mushroom = 1,
	)

/datum/chemical_reaction/food/soup/spacylibertyduff
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/ethanol/vodka = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/libertycap = 3,
	)

/datum/chemical_reaction/food/soup/amanitajelly
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/ethanol/vodka = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/amanita = 3,
	)

/datum/chemical_reaction/food/soup/sweetpotatosoup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/sugar = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/potato/sweet = 2,
	)

/datum/chemical_reaction/food/soup/redbeetsoup
	required_ingredients = list(
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/cabbage = 1,
	)

/datum/chemical_reaction/food/soup/onionsoup
	required_ingredients = list(
		/obj/item/food/grown/onion = 1,
		/obj/item/food/cheese/wedge = 1,
	)

/datum/chemical_reaction/food/soup/bisque
	required_ingredients = list(
		/obj/item/food/meat/crab = 1,
		/obj/item/food/salad/boiledrice = 1,
	)

/datum/chemical_reaction/food/soup/bungocurry
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/cream = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/bungofruit = 1,
	)

/datum/chemical_reaction/food/soup/electron
	required_reagents = list(
		/datum/reagent/water = 45,
		/datum/reagent/consumable/salt = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/jupitercup = 1,
	)

/datum/chemical_reaction/food/soup/peasoup
	required_ingredients = list(
		/obj/item/food/grown/peas = 2,
		/obj/item/food/grown/parsnip = 1,
		/obj/item/food/grown/carrot = 1,
	)

/datum/chemical_reaction/food/soup/indian_curry
	required_reagents = list(
		/datum/reagent/water = 50,
		/datum/reagent/consumable/cream = 5,
	)
	required_ingredients = list(
		/obj/item/food/meat/slab/chicken = 1,
		/obj/item/food/grown/onion = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/butter = 1,
		/obj/item/food/salad/boiledrice = 1,
	)

/datum/chemical_reaction/food/soup/oatmeal
	required_reagents = list(
		/datum/reagent/consumable/milk = 20,
	)
	required_ingredients = list(
		/obj/item/food/grown/oat = 2,
	)

/datum/chemical_reaction/food/soup/zurek
	required_reagents = list(
		/datum/reagent/consumable/water = 40,
		/datum/reagent/consumable/flour = 10,
	)
	required_ingredients = list(
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/onion = 1,
	)

/datum/chemical_reaction/food/soup/cullen_skink
	required_reagents = list(
		/datum/reagent/consumable/water = 40,
		/datum/reagent/consumable/milk = 10,
		/datum/reagent/consumable/blackpepper = 4,
	)
	required_ingredients = list(
		/obj/item/food/fishmeat = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/potato = 1,
	)

// Lizard stuff

/datum/crafting_recipe/food/soup/atrakor_dumplings
	required_reagents = list(
		/datum/reagent/consumable/water = 40,
		/datum/reagent/consumable/soysauce = 10,
	)
	required_ingredients = list(
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/lizard_dumplings = 1,
	)

/datum/crafting_recipe/food/soup/meatball_noodles
	required_ingredients = list(
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/spaghetti/nizaya = 1,
		/obj/item/food/meatball = 2,
		/obj/item/food/grown/peanut = 1
	)

/datum/crafting_recipe/food/black_broth
	required_reagents = list(
		/datum/reagent/consumable/water = 40,
		/datum/reagent/consumable/vinegar = 8,
		/datum/reagent/blood = 8,
		/datum/reagent/consumable/ice = 4,
	)
	required_ingredients = list(
		/obj/item/food/tiziran_sausage = 1,
		/obj/item/food/grown/onion = 1,
	)

/datum/crafting_recipe/food/jellyfish_stew
	required_ingredients = list(
		/obj/item/food/canned_jellyfish = 1,
		/obj/item/food/grown/soybeans = 1,
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/potato = 1
	)

/datum/crafting_recipe/food/rootbread_soup
	required_ingredients = list(
		/obj/item/food/breadslice/root = 2,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/egg = 1
	)
