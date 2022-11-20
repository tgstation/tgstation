/// Abstract parent for soup reagents.
/// These are the majority result from soup recipes,
/// but bear in mind it will(should) have other reagents along side it.
/datum/reagent/consumable/nutriment/soup
	chemical_flags = NONE
	var/bowl_icon_state

/**
 * ## Soup base chemical reaction.
 *
 * Somewhat important note! Keep in mind one serving of soup is roughly 20 units. Adjust your results according.
 *
 * Try to aim to have each reaction worth 3 servings of soup (60u).
 * By default soup reactions require 50 units of water,
 * and they will also inherent the reagents of the ingredients used,
 * so you might end up with more nutrient than you expect.
 */
/datum/chemical_reaction/food/soup
	required_temp = 450
	optimal_temp = 480
	overheat_temp = 540
	optimal_ph_min = 1
	optimal_ph_max = 14
	required_reagents = list(/datum/reagent/water = 50)
	mob_react = FALSE
	required_other = TRUE
	required_container = /obj/item/reagent_containers/cup/soup_pot
	mix_message = "You smell something good coming from the steaming soup."

	/// An assoc list of what ingredients are necessary to how much is needed
	var/list/required_ingredients

	/// What percent of nutriment is converted to "soup" (what percent does not stay final product)?
	/// Raise this if your ingredients have a lot of nutriment and is overpowering your other reagents
	/// Lower this if your ingredients have a small amount of nutriment and isn't filling enough per serving
	var/percentage_of_nutriment_converted = 0.25

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

/datum/chemical_reaction/food/soup/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	. = ..()
	var/obj/item/reagent_containers/cup/soup_pot/pot = holder.my_atom
	if(!istype(pot))
		return

	for(var/obj/item/ingredient as anything in pot.added_ingredients)
		// Some of the nutriment goes into "creating the soup reagent" itself, gets deleted.
		// Mainly done so that nutriment doesn't overpower the main course
		var/amount_nutriment = ingredient.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
		ingredient.reagents.remove_reagent(/datum/reagent/consumable/nutriment, amount_nutriment * percentage_of_nutriment_converted)
		// The other half of the nutriment, and the rest of the reagents, will get put directly into the pot
		ingredient.reagents.trans_to(pot, ingredient.reagents.total_volume, 0.8, no_react = TRUE)

		// Uh oh we reached the top of the pot, the soup's gonna boil over.
		if(pot.reagents.total_volume >= pot.reagents.maximum_volume * 0.95)
			pot.visible_message(span_warning("[pot] starts to boil over!"))
			// melbert todo; Put mess here (foam, dirt?)
			break

	QDEL_LAZYLIST(pot.added_ingredients)

// Meatball Soup
/datum/reagent/consumable/nutriment/soup/meatball_soup
	name = "Meatball Soup"
	description = "You've got balls kid, BALLS!"
	bowl_icon_state = "meatballsoup"
	foodtypes = MEAT
	data = list("meat" = 1)

/datum/chemical_reaction/food/soup/meatballsoup
	required_ingredients = list(
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/potato = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/meatball_soup = 30,
		/datum/reagent/water = 9,
		/*
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		*/
	)

// Vegetable Soup
/datum/reagent/consumable/nutriment/soup/vegetable_soup
	name = "Vegetable Soup"
	description = "A true vegan meal."
	bowl_icon_state = "vegetablesoup"
	foodtypes = VEGETABLES
	data = list("vegetables" = 1)

/datum/chemical_reaction/food/soup/vegetable_soup
	required_ingredients = list(
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/potato = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/vegetable_soup = 30,
		/datum/reagent/water = 9,
		/*
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 10,
		*/
	)

// Nettle soup - gains some omnizine to offset the acid damage
/datum/reagent/consumable/nutriment/soup/nettle
	name = "nettle soup"
	description = "To think, the botanist would've beat you to death with one of these."
	bowl_icon_state = "nettlesoup"
	foodtypes = VEGETABLES
	data = list("nettles" = 1)

/datum/chemical_reaction/food/soup/nettlesoup
	required_ingredients = list(
		/obj/item/food/grown/nettle = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/boiledegg = 1
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/nettle = 30,
		/datum/reagent/water = 9,
		/datum/reagent/medicine/omnizine = 6,
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

// Slime soup
/datum/reagent/consumable/nutriment/soup/slime
	name = "slime soup"
	description = "If no water is available, you may substitute tears."
	bowl_icon_state = "slimesoup"
	data = list("slime" = 1)


/datum/chemical_reaction/food/soup/slimesoup
	required_reagents = list(
		/datum/reagent/water = 40,
	)
	required_ingredients = list(
		/obj/item/slime_extract = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/slime = 30,
		/datum/reagent/toxin/slimejelly = 20,
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/water = 6,
	)

/datum/chemical_reaction/food/soup/slimesoup/alt
	required_other = FALSE
	// Pretty much just a normal chemical reaction at this point
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/toxin/slimejelly = 20,
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
		/datum/reagent/water = 40,
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
		/datum/reagent/water = 40,
		/datum/reagent/consumable/milk = 10,
		/datum/reagent/consumable/blackpepper = 4,
	)
	required_ingredients = list(
		/obj/item/food/fishmeat = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/potato = 1,
	)

// Lizard stuff

/datum/chemical_reaction/food/soup/atrakor_dumplings
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/soysauce = 10,
	)
	required_ingredients = list(
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/lizard_dumplings = 1,
	)

/datum/chemical_reaction/food/soup/meatball_noodles
	required_ingredients = list(
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/spaghetti/nizaya = 1,
		/obj/item/food/meatball = 2,
		/obj/item/food/grown/peanut = 1
	)

/datum/chemical_reaction/food/soup/black_broth
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/vinegar = 8,
		/datum/reagent/blood = 8,
		/datum/reagent/consumable/ice = 4,
	)
	required_ingredients = list(
		/obj/item/food/tiziran_sausage = 1,
		/obj/item/food/grown/onion = 1,
	)

/datum/chemical_reaction/food/soup/jellyfish_stew
	required_ingredients = list(
		/obj/item/food/canned_jellyfish = 1,
		/obj/item/food/grown/soybeans = 1,
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/potato = 1
	)

/datum/chemical_reaction/food/soup/rootbread_soup
	required_ingredients = list(
		/obj/item/food/breadslice/root = 2,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/egg = 1
	)
