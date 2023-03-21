/// Abstract parent for soup reagents.
/// These are the majority result from soup recipes,
/// but bear in mind it will(should) have other reagents along side it.
/datum/reagent/consumable/nutriment/soup
	chemical_flags = NONE

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
	required_reagents = null
	mob_react = FALSE
	required_other = TRUE
	required_container = /obj/item/reagent_containers/cup/soup_pot
	mix_message = "You smell something good coming from the steaming soup."
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

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
		// Some ingredients are purely flavor (no pun intended) and add no reagents
		if(isnull(ingredient.reagents))
			continue

		// Some of the nutriment goes into "creating the soup reagent" itself, gets deleted.
		// Mainly done so that nutriment doesn't overpower the main course
		var/amount_nutriment = ingredient.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
		ingredient.reagents.remove_reagent(/datum/reagent/consumable/nutriment, amount_nutriment * percentage_of_nutriment_converted)
		// The other half of the nutriment, and the rest of the reagents, will get put directly into the pot
		ingredient.reagents.trans_to(pot, ingredient.reagents.total_volume, 0.8, no_react = TRUE)

		// Uh oh we reached the top of the pot, the soup's gonna boil over.
		if(holder.total_volume >= holder.maximum_volume * 0.95)
			pot.visible_message(span_warning("[pot] starts to boil over!"))
			// Create a spread of dirty foam
			var/datum/effect_system/fluid_spread/foam/dirty/soup_mess = new()
			soup_mess.reagent_scale = 0.1 // (Just a little)
			soup_mess.set_up(range = 1, holder = pot, location = get_turf(pot), carry = holder)
			soup_mess.start()
			// Loses a bit from the foam
			for(var/datum/reagent/reagent as anything in holder.reagent_list)
				reagent.volume = round(reagent.volume * 0.9, 0.05)
			holder.update_total()
			break

	QDEL_LAZYLIST(pot.added_ingredients)

// Meatball Soup
/datum/reagent/consumable/nutriment/soup/meatball_soup
	name = "Meatball Soup"
	description = "You've got balls kid, BALLS!"
	data = list("meat" = 1)

/datum/glass_style/has_foodtype/soup/meatball_soup
	required_drink_type = /datum/reagent/consumable/nutriment/soup/meatball_soup
	icon_state = "meatballsoup"
	drink_type = MEAT

// MELBERT TODO REMOVE ITS FOR TEST
/obj/item/meatball_maker/Initialize(mapload)
	..()
	new /obj/item/food/meatball(loc)
	new /obj/item/food/grown/carrot(loc)
	new /obj/item/food/grown/potato(loc)
	new /obj/item/reagent_containers/cup/soup_pot(loc)
	return INITIALIZE_HINT_QDEL

/datum/chemical_reaction/food/soup/meatballsoup
	required_reagents = list(/datum/reagent/water = 50)
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

// Melbert todo: each of these need a subtype that starts prefilled

// Vegetable Soup
/datum/reagent/consumable/nutriment/soup/vegetable_soup
	name = "Vegetable Soup"
	description = "A true vegan meal."
	data = list("vegetables" = 1)

/datum/glass_style/has_foodtype/soup/vegetable_soup
	required_drink_type = /datum/reagent/consumable/nutriment/soup/vegetable_soup
	icon_state = "vegetablesoup"
	drink_type = VEGETABLES

/datum/chemical_reaction/food/soup/vegetable_soup
	required_reagents = list(/datum/reagent/water = 50)
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
	data = list("nettles" = 1)

/datum/glass_style/has_foodtype/soup/nettle
	required_drink_type = /datum/reagent/consumable/nutriment/soup/nettle
	icon_state = "nettlesoup"
	drink_type = VEGETABLES

/datum/chemical_reaction/food/soup/nettlesoup
	required_reagents = list(/datum/reagent/water = 50)
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

// Wing Fang Chu
/datum/reagent/consumable/nutriment/soup/wingfangchu
	name = "wing fang chu"
	description = "A savory dish of alien wing wang in soy."
	data = list("soy" = 1)

/datum/glass_style/has_foodtype/soup/wingfangchu
	required_drink_type = /datum/reagent/consumable/nutriment/soup/wingfangchu
	icon_state = "wingfangchu"
	drink_type = MEAT

/datum/chemical_reaction/food/soup/wingfangchu
	required_reagents = list(
		/datum/reagent/water = 50,
		/datum/reagent/consumable/soysauce = 5,
	)
	required_ingredients = list(
		/obj/item/food/meat/cutlet/xeno = 2,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/wingfangchu = 30,
		/datum/reagent/consumable/soysauce = 10,
		/*
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		*/
	)

// Chili (Hot, not cold)
/datum/reagent/consumable/nutriment/soup/hotchili
	name = "hot chili"
	description = "A five alarm Texan Chili!"
	data = list("hot peppers" = 1)

/datum/glass_style/has_foodtype/soup/hotchili
	required_drink_type = /datum/reagent/consumable/nutriment/soup/hotchili
	icon_state = "hotchili"
	drink_type = VEGETABLES | MEAT

/datum/chemical_reaction/food/soup/hotchili
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/hotchili = 30,
		/datum/reagent/consumable/tomatojuice = 10,
		// Capsaicin comes from the chillis, meaning you can make tame chili.
		/*
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4
		*/
	)
	percentage_of_nutriment_converted = 0.5

// Chili (Cold)
/datum/reagent/consumable/nutriment/soup/coldchili
	name = "cold chili"
	description = "This slush is barely a liquid!"
	data = list("tomato" = 1, "mint" = 1)

/datum/glass_style/has_foodtype/soup/coldchili
	required_drink_type = /datum/reagent/consumable/nutriment/soup/coldchili
	icon_state = "coldchili"
	drink_type = VEGETABLES | MEAT

/datum/chemical_reaction/food/soup/coldchili
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/icepepper = 1,
		/obj/item/food/grown/tomato = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/coldchili = 30,
		/datum/reagent/consumable/tomatojuice = 10,
		// Frost Oil comes from the chilis
		/*
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/frostoil = 3,
		*/
	)
	percentage_of_nutriment_converted = 0.5

// Chili (Clownish)
/datum/reagent/consumable/nutriment/soup/clownchili
	name = "chili con carnival"
	description = "A delicious stew of meat, chiles, and salty, salty clown tears."
	data = list(
		"tomato" = 1,
		"hot peppers" = 2,
		"clown feet" = 2,
		"kind of funny" = 2,
		"someone's parents" = 2,
	)

/datum/glass_style/has_foodtype/soup/clownchili
	required_drink_type = /datum/reagent/consumable/nutriment/soup/clownchili
	icon_state = "clownchili"
	drink_type = VEGETABLES | MEAT

/datum/chemical_reaction/food/soup/clownchili
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/clothing/shoes/clown_shoes = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/clownchili = 30,
		/datum/reagent/consumable/tomatojuice = 8,
		/datum/reagent/consumable/laughter = 4,
		/datum/reagent/consumable/banana = 4,
		/*
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/capsaicin = 1,
		/datum/reagent/consumable/tomatojuice = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		*/
	)
	percentage_of_nutriment_converted = 0.5

// Tomato soup
/datum/reagent/consumable/nutriment/soup/tomato
	name = "tomato soup"
	description = "Drinking this feels like being a vampire! A tomato vampire..."
	data = list("tomato" = 1)

/datum/glass_style/has_foodtype/soup/tomato
	required_drink_type = /datum/reagent/consumable/nutriment/soup/tomato
	icon_state = "tomatosoup"
	drink_type = VEGETABLES | FRUIT // ??

/datum/chemical_reaction/food/soup/tomatosoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/tomato = 2,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/tomato = 30,
		/datum/reagent/consumable/tomatojuice = 20,
		/*
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/tomatojuice = 10,
		/datum/reagent/consumable/nutriment/vitamin = 3
		*/
	)
	percentage_of_nutriment_converted = 0.5

// Tomato-eyeball soup
/datum/reagent/consumable/nutriment/soup/eyeball
	name = "eyeball soup"
	description = "It looks back at you..."
	data = list("tomato" = 1, "squirming" = 1)

/datum/glass_style/has_foodtype/soup/eyeball
	required_drink_type = /datum/reagent/consumable/nutriment/soup/eyeball
	icon_state = "eyeballsoup"
	drink_type = VEGETABLES | FRUIT | MEAT | GORE // Tomato soup + an eyeball

/datum/chemical_reaction/food/soup/eyeballsoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/tomato = 2,
		/obj/item/organ/internal/eyes = 1,
	)
	result = list(
		// Logically this would be more but we wouldn't get the eyeball icon state if it was.
		/datum/reagent/consumable/nutriment/soup/tomato = 10,
		/datum/reagent/consumable/nutriment/soup/eyeball = 20,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/liquidgibs = 6,
	)
	percentage_of_nutriment_converted = 0.5

// Miso soup
/datum/reagent/consumable/nutriment/soup/miso
	name = "miso soup"
	description = "he universes best soup! Yum!!!"
	data = list("miso" = 1)

/datum/glass_style/has_foodtype/soup/miso
	required_drink_type = /datum/reagent/consumable/nutriment/soup/miso
	icon_state = "misosoup"
	drink_type = VEGETABLES | BREAKFAST

/datum/chemical_reaction/food/soup/misosoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/soydope = 2,
		/obj/item/food/tofu = 2,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/miso = 30,
		/datum/reagent/water = 10,
	)
	percentage_of_nutriment_converted = 1 // Soy has very low nutrients.

// Blood soup
// Fake tomato soup.
// Can also appear by pouring blood into a bowl!
/datum/glass_style/has_foodtype/soup/tomato/blood
	required_drink_type = /datum/reagent/blood
	desc = "Smells like copper."
	drink_type = GROSS

/datum/chemical_reaction/food/soup/bloodsoup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/blood = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/tomato/blood = 2,
	)
	results = list(
		// Blood tomatos will give us like 30u blood, so just add in the 10 from the recipe
		/datum/reagent/blood = 10,
		/datum/reagent/water = 8,
		/datum/reagent/consumable/nutriment/protein = 7,
	)
	percentage_of_nutriment_converted = 0.5

// Slime soup
// Made with a slime extract, toxic to non-slime-people.
// Can also be created by mixing water and slime jelly.
/datum/reagent/consumable/nutriment/soup/slime
	name = "slime soup"
	description = "If no water is available, you may substitute tears."
	data = list("slime" = 1)

/datum/glass_style/has_foodtype/soup/slime
	required_drink_type = /datum/reagent/consumable/nutriment/soup/slime
	icon_state = "slimesoup"
	drink_type = GROSS

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
		// Comes out of thin air, as none of our ingredients contain nutrients naturally.
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/water = 6,
	)

/datum/chemical_reaction/food/soup/slimesoup/alt
	// Alt recipe that allows you to create a slime soup by just mixing slime jelly and water.
	// Pretty much just a normal chemical reaction.
	// This also creates nutrients out of thin air.

	required_other = FALSE
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/toxin/slimejelly = 20,
	)
	required_ingredients = null

// Clown Tear soup
/datum/reagent/consumable/nutriment/soup/clown_tears
	name = "Clown's Tears"
	description = "The sorrow and melancholy of a thousand bereaved clowns, forever denied their Honkmechs."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#eef442" // rgb: 238, 244, 66
	ph = 9.2
	data = list("a bad joke" = 1, "mournful honking" = 1)

/datum/glass_style/has_foodtype/soup/clown_tears
	required_drink_type = /datum/reagent/consumable/nutriment/soup/clown_tears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	drink_type = FRUIT | SUGAR

/datum/chemical_reaction/food/soup/clownstears
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/lube = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/banana = 1,
		/obj/item/stack/sheet/mineral/bananium = 1,
	)
	results = list(
		/datum/reagent/lube = 5,
		/datum/reagent/water = 5, // Melbert todo: Bananas have potassium
		/datum/reagent/consumable/banana = 8,
		/datum/reagent/consumable/nutriment/vitamin = 12,
		/datum/reagent/consumable/nutriment/soup/clown_tears = 30,
	)
	percentage_of_nutriment_converted = 1 // Bananas have a small amount of nutrition naturally

// Mystery soup
// Acts a little funny, because when it's mixed it gains a new random reagent as well
/datum/reagent/consumable/nutriment/soup/mystery
	name = "mystery soup"
	description = "The mystery is, why aren't you eating it?"
	data = list("chaos" = 1)

/datum/glass_style/has_foodtype/soup/mystery
	required_drink_type = /datum/reagent/consumable/nutriment/soup/mystery
	icon_state = "mysterysoup"

/datum/chemical_reaction/food/soup/mysterysoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/badrecipe = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/cheese/wedge = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/mystery = 30,
	)
	percentage_of_nutriment_converted = 0.33 // Full of garbage

	/// A list of reagent types we can randomly gain in the soup on creation
	var/list/extra_reagent_types = list(
		/datum/reagent/blood,
		/datum/reagent/carbon,
		/datum/reagent/consumable/banana,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/medicine/oculine,
		/datum/reagent/medicine/omnizine,
		/datum/reagent/toxin,
		/datum/reagent/toxin/slimejelly,
	)

/datum/chemical_reaction/food/soup/mysterysoup/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	. = ..()
	holder.add_reagent(pick(extra_reagent_types), 10)

// Monkey Soup
/datum/reagent/consumable/nutriment/soup/monkey
	name = "monkey's delight"
	desc = "A delicious soup with dumplings and hunks of monkey meat simmered to perfection, in a broth that tastes faintly of bananas."
	data = list("the jungle" = 1, "banana" = 1)

/datum/glass_style/has_foodtype/soup/monkey
	required_drink_type = /datum/reagent/consumable/nutriment/soup/monkey
	icon_state = "monkeysdelight"
	drink_type = FRUIT

/datum/chemical_reaction/food/soup/monkey
	required_reagents = list(
		/datum/reagent/water = 25,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/salt = 5,
		/datum/reagent/consumable/blackpepper = 5,
	)
	required_ingredients = list(
		/obj/item/food/monkeycube = 1, // Melbert todo: Monkey powder + water?
		/obj/item/food/grown/banana = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/monkey = 30,
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/salt = 4,
		/datum/reagent/consumable/blackpepper = 4,
	)

// Cream of mushroom soup
/datum/reagent/consumable/nutriment/soup/mushroom
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	data = list("mushroom" = 1)

/datum/glass_style/has_foodtype/soup/mushroom
	required_drink_type = /datum/reagent/consumable/nutriment/soup/mushroom
	icon_state = "mushroomsoup"
	drink_type = VEGETABLES | DAIRY

/datum/chemical_reaction/food/soup/mushroomsoup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/milk = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/chanterelle = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/mushroom = 30,
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/consumable/milk = 2,
	)

// Beet soup (Borscht)
/datum/reagent/consumable/nutriment/soup/white_beet
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"

/datum/reagent/consumable/nutriment/soup/white_beet/New()
	. = ..()
	var/new_taste = pick("borsch", "bortsch", "borstch", "borsh", "borshch", "borscht")
	tastes = list(new_taste = 1)
	// Melbert todo: Soup bowl needs to pick up this new name

/datum/glass_style/has_foodtype/soup/mushroom
	required_drink_type = /datum/reagent/consumable/nutriment/soup/white_beet
	icon_state = "beetsoup"
	drink_type = VEGETABLES | DAIRY

/datum/chemical_reaction/food/soup/beetsoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/whitebeet = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/white_beet = 30,
		/datum/reagent/water = 10,
	)
	percentage_of_nutriment_converted = 0.66

// Stew
/datum/reagent/consumable/nutriment/soup/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	data = list("tomato" = 1, "carrot" = 1)

/datum/glass_style/has_foodtype/soup/stew
	required_drink_type = /datum/reagent/consumable/nutriment/soup/stew
	icon_state = "stew"
	drink_type = VEGETABLES | FRUIT | MEAT

/datum/chemical_reaction/food/soup/stew
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meat/cutlet = 3,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/mushroom = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/stew = 30,
		/datum/reagent/consumable/tomatojuice = 10,
		// Gains a ton of nutriments from the variety of ingredients.
	)

// Melbert todo: Should this be a soup?
/*
/datum/chemical_reaction/food/soup/spacylibertyduff
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/ethanol/vodka = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/libertycap = 3,
	)
*/


// Melbert todo: Should this be a soup?
/*
/datum/chemical_reaction/food/soup/amanitajelly
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/ethanol/vodka = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/amanita = 3,
	)
*/

// Sweet potato soup
/datum/reagent/consumable/nutriment/soup/sweetpotato
	name = "sweet potato soup"
	desc = "Delicious sweet potato in soup form."
	data = list("sweet potato" = 1)

/datum/glass_style/has_foodtype/soup/sweetpotato
	required_drink_type = /datum/reagent/consumable/nutriment/soup/sweetpotato
	icon_state = "sweetpotatosoup"
	drink_type = VEGETABLES | SUGAR

/datum/chemical_reaction/food/soup/sweetpotatosoup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/sugar = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/potato/sweet = 2,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/sweetpotato = 30,
		/datum/reagent/water = 10,
		/datum/reagent/sugar = 5,
	)

// Red beet soup
/datum/reagent/consumable/nutriment/soup/red_beet
	name = "red beet soup"
	desc = "Quite a delicacy."
	data = list("beet" = 1)

/datum/glass_style/has_foodtype/soup/red_beet
	required_drink_type = /datum/reagent/consumable/nutriment/soup/red_beet
	icon_state = "redbeetsoup"
	drink_type = VEGETABLES

/datum/chemical_reaction/food/soup/redbeetsoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/red_beet = 30,
		/datum/reagent/water = 10,
	)
	percentage_of_nutriment_converted = 0.66

// French Onion soup
/datum/reagent/consumable/nutriment/soup/french_onion
	name = "french onion soup"
	desc = "Good enough to make a grown mime cry."
	data = list("caramelized onions" = 1)

/datum/glass_style/has_foodtype/soup/french_onion
	required_drink_type = /datum/reagent/consumable/nutriment/soup/french_onion
	icon_state = "onionsoup"
	drink_type = VEGETABLES | DAIRY

/datum/chemical_reaction/food/soup/onionsoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/onion = 1,
		/obj/item/food/cheese/wedge = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/french_onion = 30,
		/datum/reagent/consumable/nutriment/protein = 8, // No idea where this comes from
		/datum/reagent/consumable/tomatojuice = 8, // No idea where this comes from
	)
	percentage_of_nutriment_converted = 0.66

// Bisque / Crab soup
/datum/reagent/consumable/nutriment/soup/bisque
	name = "bisque"
	desc = "A classic entree from Space-France."
	data = list("creamy texture" = 1, "crab" = 4)

/datum/glass_style/has_foodtype/soup/bisque
	required_drink_type = /datum/reagent/consumable/nutriment/soup/bisque
	icon_state = "bisque"
	drink_type = MEAT

/datum/chemical_reaction/food/soup/bisque
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/crab = 1,
		/obj/item/food/salad/boiledrice = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/bisque = 30,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/water = 5,
	)

// Bungo Tree Curry
/datum/reagent/consumable/nutriment/soup/bungo
	name = "bungo curry"
	desc = "A spicy vegetable curry made with the humble bungo fruit, Exotic!"
	data = list("bungo" = 2, "hot curry" = 4, "tropical sweetness" = 1)

/datum/glass_style/has_foodtype/soup/bungo
	required_drink_type = /datum/reagent/consumable/nutriment/soup/bungo
	icon_state = "bungocurry"
	drink_type = VEGETABLES | FRUIT | DAIRY

/datum/chemical_reaction/food/soup/bungocurry
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/cream = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/bungofruit = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/bungo = 30
		/datum/reagent/consumable/bungojuice = 15,
	)
	percentage_of_nutriment_converted = 0.5

// Electron Soup.
// Special soup for Ethereals to consume to gain nutrition (energy) from.
/datum/reagent/consumable/nutriment/soup/electrons
	name = "electron soup"
	desc = "A gastronomic curiosity of ethereal origin. It is famed for the minature weather system formed over a properly prepared soup."
	data = list("mushroom" = 1, "electrons" = 4)

/datum/glass_style/has_foodtype/soup/electrons
	required_drink_type = /datum/reagent/consumable/nutriment/soup/electrons
	icon_state = "electronsoup"
	drink_type = VEGETABLES | TOXIC

/datum/chemical_reaction/food/soup/electron
	required_reagents = list(
		/datum/reagent/water = 45,
		/datum/reagent/consumable/salt = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/jupitercup = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/electrons = 30,
		// Jupiter cups obviously contain a fair amount of LE naturally,
		// but to make it "worthwhile" for Ethereals to eat we add a bit extra
		/datum/reagent/consumable/liquidelectricity/enriched = 10,
	)
	percentage_of_nutriment_converted = 0.5

// Pea Soup
/datum/reagent/consumable/nutriment/soup/pea
	name = "pea soup"
	desc = "A humble split pea soup."
	data = list("creamy peas" = 2, "parsnip" = 1)

/datum/glass_style/has_foodtype/soup/pea
	required_drink_type = /datum/reagent/consumable/nutriment/soup/pea
	icon_state = "peasoup"
	drink_type = VEGETABLES

/datum/chemical_reaction/food/soup/peasoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/peas = 2,
		/obj/item/food/grown/parsnip = 1,
		/obj/item/food/grown/carrot = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/pea = 30,
		/datum/reagent/water = 10,
	)

// Indian curry
/datum/reagent/consumable/nutriment/soup/indian_curry
	name = "indian chicken curry"
	desc = "A mild, creamy curry from the old subcontinent. Liked by the Space-British, because it reminds them of the Raj."
	data = ist("chicken" = 2, "creamy curry" = 4, "earthy heat" = 1)

/datum/glass_style/has_foodtype/soup/indian_curry
	required_drink_type = /datum/reagent/consumable/nutriment/soup/indian_curry
	icon_state = "indian_curry"
	drink_type = VEGETABLES | MEAT | DAIRY

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
	results = list(
		/datum/reagent/consumable/nutriment/soup/indian_curry = 30,
		// Gains a ton of other reagents from ingredients.
	)

// Oatmeal (Soup like)
/datum/reagent/consumable/nutriment/soup/oatmeal
	name = "oatmeal"
	desc = "A nice bowl of oatmeal."
	data = list("oats" = 1, "milk" = 1)

/datum/glass_style/has_foodtype/soup/oatmeal
	required_drink_type = /datum/reagent/consumable/nutriment/soup/oatmeal
	icon_state = "oatmeal"
	drink_type = DAIRY | GRAIN | BREAKFAST

/datum/chemical_reaction/food/soup/oatmeal
	required_reagents = list(
		/datum/reagent/consumable/milk = 20,
	)
	required_ingredients = list(
		/obj/item/food/grown/oat = 2,
	)
	results =  list(
		/datum/reagent/consumable/nutriment/soup/oatmeal = 20,
		/datum/reagent/consumable/milk = 12,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	percentage_of_nutriment_converted = 1 // Oats have barely any nutrients

// Zurek, a Polish soup
/datum/reagent/consumable/nutriment/soup/zurek
	name = "zurek"
	desc = "A traditional Polish soup composed of vegetables, meat, and an egg. Goes great with bread."
	data = list("creamy vegetables" = 2, "sausage" = 1)

/datum/glass_style/has_foodtype/soup/zurek
	required_drink_type = /datum/reagent/consumable/nutriment/soup/zurek
	icon_state = "zurek"
	drink_type = VEGETABLES | MEAT | GRAIN | BREAKFAST

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
	results = list(
		/datum/reagent/consumable/nutriment/soup/zurek = 30,
	)

// Cullen Skink, a Scottish soup with a funny name
/datum/reagent/consumable/nutriment/soup/cullen_skink
	name = "cullen skink"
	desc = "A thick Scottish soup made of smoked fish, potatoes and onions."
	data = list("creamy broth" = 1, "fish" = 1, "vegetables" = 1)

/datum/glass_style/has_foodtype/soup/cullen_skink
	required_drink_type = /datum/reagent/consumable/nutriment/soup/cullen_skink
	icon_state = "cullen_skink"
	drink_type = VEGETABLES | SEAFOOD | DAIRY

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
	results = list(
		/datum/reagent/consumable/nutriment/soup/cullen_skink = 30,
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/water = 6,
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
	required_reagents = list(/datum/reagent/water = 50)
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
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/canned_jellyfish = 1,
		/obj/item/food/grown/soybeans = 1,
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/potato = 1
	)

/datum/chemical_reaction/food/soup/rootbread_soup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/breadslice/root = 2,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/egg = 1
	)
