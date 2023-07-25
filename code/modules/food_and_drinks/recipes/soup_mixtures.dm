/// Abstract parent for soup reagents.
/// These are the majority result from soup recipes,
/// but bear in mind it will(should) have other reagents along side it.
/datum/reagent/consumable/nutriment/soup
	name = "Soup"
	chemical_flags = NONE
	nutriment_factor = 12 * REAGENTS_METABOLISM // Slightly less to that of nutriment as soups will come with nutriments in tow
	burning_temperature = 520
	default_container = /obj/item/reagent_containers/cup/bowl
	glass_price = FOOD_PRICE_CHEAP
	fallback_icon = 'icons/obj/food/soupsalad.dmi'
	fallback_icon_state = "bowl"
	restaurant_order = /datum/custom_order/reagent/soup

/**
 * ## Soup base chemical reaction.
 *
 * Somewhat important note! Keep in mind one serving of soup is roughly 20-25 units. Adjust your results according.
 *
 * Try to aim to have each reaction worth 3 servings of soup (60u - 90u).
 * By default soup reactions require 50 units of water,
 * and they will also inherent the reagents of the ingredients used,
 * so you might end up with more nutrient than you expect.
 */
/datum/chemical_reaction/food/soup
	required_temp = 450
	optimal_temp = 480
	overheat_temp = SOUP_BURN_TEMP
	optimal_ph_min = 1
	optimal_ph_max = 14
	thermic_constant = 10
	required_reagents = null
	mob_react = FALSE
	required_other = TRUE
	required_container_accepts_subtypes = TRUE
	required_container = /obj/item/reagent_containers/cup/soup_pot
	mix_message = "You smell something good coming from the steaming pot of soup."
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

	// General soup guideline:
	// - Soups should produce 60-90 units (3-4 servings)
	// - One serving size is 20-25 units (8-9 sips, with 3u sips)
	// - The first index of the result list should be the soup type

	/// An assoc list of what ingredients are necessary to how much is needed
	var/list/required_ingredients
	/// Tracks the total number of ingredient items needed, for calculating multipliers. Only done once in first on_reaction
	VAR_FINAL/total_ingredient_max

	/// Multiplier applied to all reagents transfered from reagents to pot when the soup is cooked
	var/ingredient_reagent_multiplier = 0.8
	/// What percent of nutriment is converted to "soup" (what percent does not stay final product)?
	/// Raise this if your ingredients have a lot of nutriment and is overpowering your other reagents
	/// Lower this if your ingredients have a small amount of nutriment and isn't filling enough per serving
	/// (EX: A tomato with 10 nutriment will lose 2.5 nutriment before being added to the pot)
	var/percentage_of_nutriment_converted = 0.25

/datum/chemical_reaction/food/soup/pre_reaction_other_checks(datum/reagents/holder)
	var/obj/item/reagent_containers/cup/soup_pot/pot = holder.my_atom
	if(!istype(pot))
		return FALSE
	if(!length(required_ingredients))
		return TRUE

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

/datum/chemical_reaction/food/soup/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	if(!length(required_ingredients))
		return

	if(isnull(total_ingredient_max))
		total_ingredient_max = 0
		// We only need to calculate this once, effectively static per-type
		for(var/ingredient_type in required_ingredients)
			total_ingredient_max += required_ingredients[ingredient_type]

	var/obj/item/reagent_containers/cup/soup_pot/pot = holder.my_atom
	var/list/tracked_ingredients = list()
	for(var/obj/item/ingredient as anything in pot.added_ingredients)
		// Track all ingredients in data. Assoc list of weakref to ingredient to initial total volume.
		tracked_ingredients[WEAKREF(ingredient)] = ingredient.reagents?.total_volume || 1
		// Equalize temps. Otherwise when we add ingredient temps in, it'll lower reaction temp
		ingredient.reagents?.chem_temp = holder.chem_temp

	// Store a list of weakrefs to ingredients as
	reaction.data["ingredients"] = tracked_ingredients

	testing("Soup reaction started of type [type]! [length(pot.added_ingredients)] inside.")

/datum/chemical_reaction/food/soup/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, delta_ph, step_reaction_vol)
	if(!length(required_ingredients))
		return

	testing("Soup reaction step progressing with an increment volume of [step_reaction_vol] and delta_t of [delta_t].")
	var/obj/item/reagent_containers/cup/soup_pot/pot = holder.my_atom
	var/list/cached_ingredients = reaction.data["ingredients"]
	var/num_current_ingredients = length(pot.added_ingredients)
	var/num_cached_ingredients = length(cached_ingredients)

	// Clamp multiplier to ingredient number
	reaction.multiplier = min(reaction.multiplier, num_current_ingredients / total_ingredient_max)

	// An ingredient was removed during the mixing process.
	// Stop reacting immediately, we can't verify the reaction is correct still.
	// If it is still correct it will restart shortly.
	if(num_current_ingredients < num_cached_ingredients)
		testing("Soup reaction ended due to losing ingredients.")
		return END_REACTION

	// An ingredient was added mid mix.
	// Throw it in the ingredients list
	else if(num_current_ingredients > num_cached_ingredients)
		for(var/obj/item/new_ingredient as anything in pot.added_ingredients)
			var/datum/weakref/new_ref = WEAKREF(new_ingredient)
			if(cached_ingredients[new_ref])
				continue
			new_ingredient.reagents?.chem_temp = holder.chem_temp
			cached_ingredients[new_ref] = new_ingredient.reagents?.total_volume || 1

	for(var/datum/weakref/ingredient_ref as anything in cached_ingredients)
		var/obj/item/ingredient = ingredient_ref.resolve()
		// An ingredient has gone missing, stop the reaction
		if(QDELETED(ingredient) || ingredient.loc != holder.my_atom)
			testing("Soup reaction ended due to having an invalid ingredient present.")
			return END_REACTION

		// Don't add any more reagents if we've boiled over
		if(reaction.data["boiled_over"])
			continue

		// Transfer 20% of the initial reagent volume of the ingredient to the soup
		transfer_ingredient_reagents(ingredient, holder, max(cached_ingredients[ingredient_ref] * 0.2, 2))

		// Uh oh we reached the top of the pot, the soup's gonna boil over.
		if(holder.total_volume >= holder.maximum_volume * 0.95)
			boil_over(holder)
			reaction.data["boiled_over"] = TRUE

/datum/chemical_reaction/food/soup/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	. = ..()
	var/obj/item/reagent_containers/cup/soup_pot/pot = holder.my_atom
	if(!istype(pot))
		CRASH("[pot ? "Non-pot atom" : "Null pot"]) made it to the end of the [type] reaction chain.")
	reaction.data["ingredients"] = null

	testing("Soup reaction finished with a total react volume of [react_vol] and [length(pot.added_ingredients)] ingredients. Cleaning up.")

	for(var/obj/item/ingredient as anything in pot.added_ingredients)
		// Let's not mess with  indestructible items.
		// Chef doesn't need more ways to delete things with cooking.
		if(ingredient.resistance_flags & INDESTRUCTIBLE)
			continue

		// Things that had reagents or ingredients in the soup will get deleted
		else if(!isnull(ingredient.reagents) || is_type_in_list(ingredient, required_ingredients))
			LAZYREMOVE(pot.added_ingredients, ingredient)
			// Send everything left behind
			transfer_ingredient_reagents(ingredient, holder)
			// Delete, it's done
			qdel(ingredient)

		// Everything else will just get fried
		else
			ingredient.AddElement(/datum/element/fried_item, 30)

	// Anything left in the ingredient list will get dumped out
	pot.dump_ingredients(get_turf(pot))
	// Blackbox log the chemical reaction used, to account for soup reaction that don't produce typical results
	BLACKBOX_LOG_FOOD_MADE(type)

/datum/chemical_reaction/food/soup/proc/transfer_ingredient_reagents(obj/item/ingredient, datum/reagents/holder, amount)
	var/datum/reagents/ingredient_pool = ingredient.reagents
	// Some ingredients are purely flavor (no pun intended) and will have reagents
	if(isnull(ingredient_pool) || ingredient_pool.total_volume <= 0)
		return
	if(isnull(amount))
		amount = ingredient_pool.total_volume
		testing("Soup reaction has made it to the finishing step with ingredients that still contain reagents. [amount] reagents left in [ingredient].")

	// Some of the nutriment goes into "creating the soup reagent" itself, gets deleted.
	// Mainly done so that nutriment doesn't overpower the main course
	ingredient_pool.remove_reagent(/datum/reagent/consumable/nutriment, amount * percentage_of_nutriment_converted)
	ingredient_pool.remove_reagent(/datum/reagent/consumable/nutriment/vitamin, amount * percentage_of_nutriment_converted)
	// The other half of the nutriment, and the rest of the reagents, will get put directly into the pot
	ingredient_pool.trans_to(holder, amount, ingredient_reagent_multiplier, no_react = TRUE)

/datum/chemical_reaction/food/soup/proc/boil_over(datum/reagents/holder)
	var/obj/item/reagent_containers/cup/soup_pot/pot = holder.my_atom
	var/turf/below_pot = get_turf(pot)
	below_pot.visible_message(span_warning("[pot] starts to boil over!"))
	// Create a spread of dirty foam
	var/datum/effect_system/fluid_spread/foam/dirty/soup_mess = new()
	soup_mess.reagent_scale = 0.1 // (Just a little)
	soup_mess.set_up(range = 1, holder = pot, location = below_pot, carry = holder, stop_reactions = TRUE)
	soup_mess.start()
	// Loses a bit from the foam
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		reagent.volume = round(reagent.volume * 0.9, 0.05)
	holder.update_total()

/// Adds text to the requirements list of the recipe
/// Return a list of strings, each string will be a new line in the requirements list
/datum/chemical_reaction/food/soup/proc/describe_recipe_details()
	return

/// Adds text to the results list of the recipe
/// Return a list of strings, each string will be a new line in the results list
/datum/chemical_reaction/food/soup/proc/describe_result()
	return

#ifdef TESTING

/obj/item/soup_test_kit/Initialize(mapload)
	..()
	new /obj/item/food/meatball(loc)
	new /obj/item/food/grown/carrot(loc)
	new /obj/item/food/grown/potato(loc)
	new /obj/item/reagent_containers/cup/soup_pot(loc)
	return INITIALIZE_HINT_QDEL

#endif

/// This subtype is only for easy mapping / spawning in specific types of soup.
/// Do not use it anywhere else.
/obj/item/reagent_containers/cup/bowl/soup
	var/initial_reagent
	var/initial_portion = SOUP_SERVING_SIZE

/obj/item/reagent_containers/cup/bowl/soup/Initialize(mapload)
	. = ..()
	if(initial_reagent)
		reagents.add_reagent(initial_reagent, initial_portion)

/// This style runs dual purpose -
/// Primarily it's just a bowl style for water,
/// but secondarily it lets chefs know if their soup had too much water in it
/datum/glass_style/has_foodtype/soup/watery_soup
	required_drink_type = /datum/reagent/water
	name = "Bowl of water"
	desc = "A very wet bowl."
	icon_state = "wishsoup"

/datum/glass_style/has_foodtype/soup/watery_soup/set_name(obj/item/thing)
	if(length(thing.reagents.reagent_list) <= 2)
		return ..()

	thing.name = "Watery bowl of something"

/datum/glass_style/has_foodtype/soup/watery_soup/set_desc(obj/item/thing)
	if(length(thing.reagents.reagent_list) <= 2)
		return ..()

	thing.desc = "Looks like whatever's in there is very watered down."

/// So this one's kind of a "failed" result, but also a "custom" result
/// Getting to this temperature and having no other soup reaction made means you're either messing something up
/// or you simply aren't following a recipe. So it'll just combine
/datum/chemical_reaction/food/soup/custom
	required_temp = SOUP_BURN_TEMP + 40 // Only done if it's been burning for a little bit
	optimal_temp = SOUP_BURN_TEMP + 50
	overheat_temp = SOUP_BURN_TEMP + 60
	thermic_constant = 0
	mix_message = span_warning("You smell something gross coming from the pot of soup.")
	required_reagents = list(/datum/reagent/water = 30)
	results = list(/datum/reagent/water = 10)
	ingredient_reagent_multiplier = 1
	percentage_of_nutriment_converted = 0

	/// Custom recipes will not start mixing until at least this many solid ingredients are present
	var/num_ingredients_needed = 3

/datum/chemical_reaction/food/soup/custom/pre_reaction_other_checks(datum/reagents/holder)
	var/obj/item/reagent_containers/cup/soup_pot/pot = holder.my_atom
	if(!istype(pot))
		return FALSE // Not a pot
	if(holder.is_reacting)
		return FALSE // Another soup is being made
	if(length(pot.added_ingredients) <= num_ingredients_needed)
		return FALSE // Not a lot here to go off of
	return TRUE

/datum/chemical_reaction/food/soup/custom/describe_recipe_details()
	return list("Created from burning soup with at least [num_ingredients_needed] ingredients present")

/datum/chemical_reaction/food/soup/custom/describe_result()
	return list("Whatever's in the pot")

// Meatball Soup
/datum/reagent/consumable/nutriment/soup/meatball_soup
	name = "Meatball Soup"
	description = "You've got balls kid, BALLS!"
	data = list("meat" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#FFFDCF"

/datum/glass_style/has_foodtype/soup/meatball_soup
	required_drink_type = /datum/reagent/consumable/nutriment/soup/meatball_soup
	icon_state = "meatballsoup"
	drink_type = MEAT

/obj/item/reagent_containers/cup/bowl/soup/meatball_soup
	initial_reagent = /datum/reagent/consumable/nutriment/soup/meatball_soup

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
	)

// Vegetable Soup
/datum/reagent/consumable/nutriment/soup/vegetable_soup
	name = "Vegetable Soup"
	description = "A true vegan meal."
	data = list("vegetables" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#FAA810"

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
	)

// Nettle soup - gains some omnizine to offset the acid damage
/datum/reagent/consumable/nutriment/soup/nettle
	name = "Nettle Soup"
	description = "To think, the botanist would've beat you to death with one of these."
	data = list("nettles" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#C1E212"

/datum/glass_style/has_foodtype/soup/nettle
	required_drink_type = /datum/reagent/consumable/nutriment/soup/nettle
	icon_state = "nettlesoup"
	drink_type = VEGETABLES

/obj/item/reagent_containers/cup/bowl/soup/nettle
	initial_reagent = /datum/reagent/consumable/nutriment/soup/nettle

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
	ingredient_reagent_multiplier = 0.2 // Too much acid
	percentage_of_nutriment_converted = 0

// Wing Fang Chu
/datum/reagent/consumable/nutriment/soup/wingfangchu
	name = "Wing Fang Chu"
	description = "A savory dish of alien wing wang in soy."
	data = list("soy" = 1)
	color = "#C1E212"

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
	)

// Chili (Hot, not cold)
/datum/reagent/consumable/nutriment/soup/hotchili
	name = "Hot Chili"
	description = "A five alarm Texan Chili!"
	data = list("hot peppers" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#E23D12"

/datum/glass_style/has_foodtype/soup/hotchili
	required_drink_type = /datum/reagent/consumable/nutriment/soup/hotchili
	icon_state = "hotchili"
	drink_type = VEGETABLES | MEAT

/obj/item/reagent_containers/cup/bowl/soup/hotchili
	initial_reagent = /datum/reagent/consumable/nutriment/soup/hotchili

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
	ingredient_reagent_multiplier = 0.33 // Chilis have a TON of capsaicin naturally
	percentage_of_nutriment_converted = 0

// Chili (Cold)
/datum/reagent/consumable/nutriment/soup/coldchili
	name = "Cold Chili"
	description = "This slush is barely a liquid!"
	data = list("tomato" = 1, "mint" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#3861C2"

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
	)
	ingredient_reagent_multiplier = 0.33 // Chilis have a TON of frost oil naturally
	percentage_of_nutriment_converted = 0

// Chili (Clownish)
/datum/reagent/consumable/nutriment/soup/clownchili
	name = "Chili Con Carnival"
	description = "A delicious stew of meat, chiles, and salty, salty clown tears."
	data = list(
		"tomato" = 1,
		"hot peppers" = 2,
		"clown feet" = 2,
		"kind of funny" = 2,
		"someone's parents" = 2,
	)
	glass_price = FOOD_PRICE_EXOTIC
	color = "#FF0000"

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
	)
	percentage_of_nutriment_converted = 0.15

// Vegan Chili
/datum/reagent/consumable/nutriment/soup/chili_sin_carne
	name = "Chili Sin Carne"
	description = "For the hombres who don't want carne."
	data = list("bitterness" = 1, "sourness" = 1)
	color = "#E23D12"

/datum/glass_style/has_foodtype/soup/chili_sin_carne
	required_drink_type = /datum/reagent/consumable/nutriment/soup/chili_sin_carne
	icon_state = "hotchili"
	drink_type = VEGETABLES

/datum/chemical_reaction/food/soup/chili_sin_carne
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/salt = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/chili_sin_carne = 30,
		/datum/reagent/consumable/tomatojuice = 10,
	)

// Tomato soup
/datum/reagent/consumable/nutriment/soup/tomato
	name = "Tomato Soup"
	description = "Drinking this feels like being a vampire! A tomato vampire..."
	data = list("tomato" = 1)
	color = "#FF0000"

/datum/glass_style/has_foodtype/soup/tomato
	required_drink_type = /datum/reagent/consumable/nutriment/soup/tomato
	name = "Tomato Soup"
	icon_state = "tomatosoup"
	drink_type = VEGETABLES | FRUIT // ??

/datum/chemical_reaction/food/soup/tomatosoup
	required_reagents = list(
		/datum/reagent/water = 50,
		/datum/reagent/consumable/cream = 5
	)
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
	percentage_of_nutriment_converted = 0.1

// Tomato-eyeball soup
/datum/reagent/consumable/nutriment/soup/eyeball
	name = "Eyeball Soup"
	description = "It looks back at you..."
	data = list("tomato" = 1, "squirming" = 1)
	color = "#FF1C1C"

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
	results = list(
		/datum/reagent/consumable/nutriment/soup/eyeball = 20,
		// Logically this would be more but we wouldn't get the eyeball icon state if it was.
		/datum/reagent/consumable/nutriment/soup/tomato = 10,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/liquidgibs = 6,
	)
	percentage_of_nutriment_converted = 0.1

// Miso soup
/datum/reagent/consumable/nutriment/soup/miso
	name = "Miso Soup"
	description = "The universes best soup! Yum!!!"
	data = list("miso" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#E2BD12"

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
	percentage_of_nutriment_converted = 0 // Soy has very low nutrients.

// Blood soup
// Fake tomato soup.
// Can also appear by pouring blood into a bowl!
/datum/glass_style/has_foodtype/soup/tomato/blood
	required_drink_type = /datum/reagent/blood
	name = "Tomato Soup"
	desc = "Smells like copper."
	drink_type = GROSS

/datum/chemical_reaction/food/soup/bloodsoup
	required_reagents = list(
		/datum/reagent/water = 10,
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
	percentage_of_nutriment_converted = 0.1

// Slime soup
// Made with a slime extract, toxic to non-slime-people.
// Can also be created by mixing water and slime jelly.
/datum/reagent/consumable/nutriment/soup/slime
	name = "Slime Soup"
	description = "If no water is available, you may substitute tears."
	data = list("slime" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#41C0C0"

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
	ph = 9.2
	data = list("a bad joke" = 1, "mournful honking" = 1)
	color = "#EEF442"

/datum/glass_style/has_foodtype/soup/clown_tears
	required_drink_type = /datum/reagent/consumable/nutriment/soup/clown_tears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	drink_type = FRUIT | SUGAR

/datum/chemical_reaction/food/soup/clownstears
	required_reagents = list(
		/datum/reagent/lube = 30,
	)
	required_ingredients = list(
		/obj/item/food/grown/banana = 1,
		/obj/item/stack/sheet/mineral/bananium = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/clown_tears = 30,
		/datum/reagent/consumable/banana = 8,
		/datum/reagent/consumable/nutriment/vitamin = 12,
		/datum/reagent/lube = 5,
	)
	percentage_of_nutriment_converted = 0 // Bananas have a small amount of nutrition naturally

// Mystery soup
// Acts a little funny, because when it's mixed it gains a new random reagent as well
/datum/reagent/consumable/nutriment/soup/mystery
	name = "Mystery Soup"
	description = "The mystery is, why aren't you eating it?"
	data = list("chaos" = 1)
	color = "#4C2A18"

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

	/// Number of units of bonus reagent added
	var/num_bonus = 10
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
	holder.add_reagent(pick(extra_reagent_types), num_bonus)

/datum/chemical_reaction/food/soup/mysterysoup/describe_result()
	var/list/extra_sublist = list()
	for(var/datum/reagent/extra_type as anything in extra_reagent_types)
		extra_sublist += "[initial(extra_type.name)]"

	return list("Will also contain [num_bonus] units of one randomly: [jointext(extra_sublist, ", ")]")

// Monkey Soup
/datum/reagent/consumable/nutriment/soup/monkey
	name = "Monkey's Delight"
	description = "A delicious soup with dumplings and hunks of monkey meat simmered to perfection, in a broth that tastes faintly of bananas."
	data = list("the jungle" = 1, "banana" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#4C2A18"

/datum/glass_style/has_foodtype/soup/monkey
	required_drink_type = /datum/reagent/consumable/nutriment/soup/monkey
	icon_state = "monkeysdelight"
	drink_type = FRUIT

/obj/item/reagent_containers/cup/bowl/soup/monkey
	initial_reagent = /datum/reagent/consumable/nutriment/soup/monkey

/datum/chemical_reaction/food/soup/monkey
	required_reagents = list(
		/datum/reagent/water = 25,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/salt = 5,
		/datum/reagent/consumable/blackpepper = 5,
	)
	required_ingredients = list(
		/obj/item/food/monkeycube = 1, // This will make a monkey if a batch of 2 is made
		/obj/item/food/grown/banana = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/monkey = 30,
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/salt = 4,
		/datum/reagent/consumable/blackpepper = 4,
	)

/datum/chemical_reaction/food/soup/monkey/describe_result()
	return list("May contain a monkey.")

// Cream of mushroom soup
/datum/reagent/consumable/nutriment/soup/mushroom
	name = "Chantrelle Soup"
	description = "A delicious and hearty mushroom soup."
	data = list("mushroom" = 1)
	color = "#CEB1B0"

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
// This has a gimmick where it randomizes its name based on common mispellings on Borsch
/datum/reagent/consumable/nutriment/soup/white_beet
	name = "Beet Soup"
	description = "Wait, how do you spell it again..?"
	data = list("beet" = 1)
	color = "#E00000"

/datum/glass_style/has_foodtype/soup/white_beet
	required_drink_type = /datum/reagent/consumable/nutriment/soup/white_beet
	icon_state = "beetsoup"
	drink_type = VEGETABLES | DAIRY

/datum/glass_style/has_foodtype/soup/white_beet/set_name(obj/item/thing)
	var/how_do_you_spell_it = pick("borsch", "bortsch", "borstch", "borsh", "borshch", "borscht")
	thing.name = how_do_you_spell_it

	var/datum/reagent/soup = locate(required_drink_type) in thing.reagents
	if(!soup)
		// Shouldn't happen but things are weird
		return

	// Update tastes with the new name
	LAZYSET(soup.data, how_do_you_spell_it, 1)
	// Not perfect. Doesn't clear when the bowl type is unset. But it'll do well enough

/obj/item/reagent_containers/cup/bowl/soup/white_beet
	initial_reagent = /datum/reagent/consumable/nutriment/soup/white_beet

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
	percentage_of_nutriment_converted = 0.1

/datum/chemical_reaction/food/soup/beetsoup/describe_result()
	return list("Changes name randomly to a common misspelling of \"Borscht\".")

// Stew
/datum/reagent/consumable/nutriment/soup/stew
	name = "Stew"
	description = "A nice and warm stew. Healthy and strong."
	data = list("tomato" = 1, "carrot" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#EB7C82"

/datum/glass_style/has_foodtype/soup/stew
	required_drink_type = /datum/reagent/consumable/nutriment/soup/stew
	icon_state = "stew"
	drink_type = VEGETABLES | FRUIT | MEAT

/obj/item/reagent_containers/cup/bowl/soup/stew
	initial_reagent = /datum/reagent/consumable/nutriment/soup/stew

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

// Sweet potato soup
/datum/reagent/consumable/nutriment/soup/sweetpotato
	name = "Sweet Potato Soup"
	description = "Delicious sweet potato in soup form."
	data = list("sweet potato" = 1)
	color = "#903E22"

/datum/glass_style/has_foodtype/soup/sweetpotato
	required_drink_type = /datum/reagent/consumable/nutriment/soup/sweetpotato
	icon_state = "sweetpotatosoup"
	drink_type = VEGETABLES | SUGAR

/obj/item/reagent_containers/cup/bowl/soup/sweetpotato
	initial_reagent = /datum/reagent/consumable/nutriment/soup/sweetpotato

/datum/chemical_reaction/food/soup/sweetpotatosoup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/milk = 10, // Coconut milk, but, close enough
	)
	required_ingredients = list(
		/obj/item/food/grown/potato/sweet = 2,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/sweetpotato = 30,
		/datum/reagent/water = 10,
	)

// Red beet soup
/datum/reagent/consumable/nutriment/soup/red_beet
	name = "Red Beet Soup"
	description = "Quite a delicacy."
	data = list("beet" = 1)
	color = "#851127"

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
	percentage_of_nutriment_converted = 0.1

// French Onion soup
/datum/reagent/consumable/nutriment/soup/french_onion
	name = "French Onion Soup"
	description = "Good enough to make a grown mime cry."
	data = list("caramelized onions" = 1)
	color = "#E1C47F"

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
	ingredient_reagent_multiplier = 0.5 // Onions are very reagent heavy
	percentage_of_nutriment_converted = 0.1

// Bisque / Crab soup
/datum/reagent/consumable/nutriment/soup/bisque
	name = "Bisque"
	description = "A classic entree from Space-France."
	data = list("creamy texture" = 1, "crab" = 4)
	glass_price = FOOD_PRICE_EXOTIC
	color = "#C8682F"

/datum/glass_style/has_foodtype/soup/bisque
	required_drink_type = /datum/reagent/consumable/nutriment/soup/bisque
	icon_state = "bisque"
	drink_type = MEAT

/datum/chemical_reaction/food/soup/bisque
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/crab = 1,
		/obj/item/food/boiledrice = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/bisque = 30,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/water = 5,
	)

// Bungo Tree Curry
/datum/reagent/consumable/nutriment/soup/bungo
	name = "Bungo Curry"
	description = "A spicy vegetable curry made with the humble bungo fruit, Exotic!"
	data = list("bungo" = 2, "hot curry" = 4, "tropical sweetness" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#E6BC32"

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
		/datum/reagent/consumable/nutriment/soup/bungo = 30,
		/datum/reagent/consumable/bungojuice = 15,
	)
	percentage_of_nutriment_converted = 0.1

// Electron Soup.
// Special soup for Ethereals to consume to gain nutrition (energy) from.
/datum/reagent/consumable/nutriment/soup/electrons
	name = "Electron Soup"
	description = "A gastronomic curiosity of ethereal origin. It is famed for the minature weather system formed over a properly prepared soup."
	data = list("mushroom" = 1, "electrons" = 4)
	glass_price = FOOD_PRICE_EXOTIC
	color = "#E60040"

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
	percentage_of_nutriment_converted = 0.10

// Pea Soup
/datum/reagent/consumable/nutriment/soup/pea
	name = "Pea Soup"
	description = "A humble split pea soup."
	data = list("creamy peas" = 2, "parsnip" = 1)
	color = "#9D7B20"

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
	name = "Indian Chicken Curry"
	description = "A mild, creamy curry from the old subcontinent. Liked by the Space-British, because it reminds them of the Raj."
	data = list("chicken" = 2, "creamy curry" = 4, "earthy heat" = 1)
	glass_price = FOOD_PRICE_NORMAL
	color = "#BB2D1A"

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
		/obj/item/food/butterslice = 1,
		/obj/item/food/boiledrice = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/indian_curry = 30,
		// Gains a ton of other reagents from ingredients.
	)

// Oatmeal (Soup like)
/datum/reagent/consumable/nutriment/soup/oatmeal
	name = "Oatmeal"
	description = "A nice bowl of oatmeal."
	data = list("oats" = 1, "milk" = 1)
	color = "#FFD7B4"

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
	percentage_of_nutriment_converted = 0 // Oats have barely any nutrients

// Zurek, a Polish soup
/datum/reagent/consumable/nutriment/soup/zurek
	name = "Zurek"
	description = "A traditional Polish soup composed of vegetables, meat, and an egg. Goes great with bread."
	data = list("creamy vegetables" = 2, "sausage" = 1)
	color = "#F1CB6D"

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
	ingredient_reagent_multiplier = 0.5
	percentage_of_nutriment_converted = 0.1

// Cullen Skink, a Scottish soup with a funny name
/datum/reagent/consumable/nutriment/soup/cullen_skink
	name = "Cullen Skink"
	description = "A thick Scottish soup made of smoked fish, potatoes and onions."
	data = list("creamy broth" = 1, "fish" = 1, "vegetables" = 1)
	color = "#F6F664"

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
	ingredient_reagent_multiplier = 0.5
	percentage_of_nutriment_converted = 0

// Chicken Noodle Soup
/datum/reagent/consumable/nutriment/soup/chicken_noodle_soup
	name = "Chicken Noodle Soup"
	description = "A hearty bowl of chicken noodle soup, perfect for when you're stuck at home and sick."
	data = list("broth" = 1, "chicken" = 1, "noodles" = 1, "carrots" = 1)
	color = "#DDB23E"

/datum/glass_style/has_foodtype/soup/chicken_noodle_soup
	required_drink_type = /datum/reagent/consumable/nutriment/soup/chicken_noodle_soup
	icon_state = "chicken_noodle_soup"
	drink_type = VEGETABLES | MEAT | GRAIN

/datum/chemical_reaction/food/soup/chicken_noodle_soup
	required_reagents = list(/datum/reagent/water = 30)
	required_ingredients = list(
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/meat/slab/chicken = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/chicken_noodle_soup = 30,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
	)

// Corn Cowder
/datum/reagent/consumable/nutriment/soup/corn_chowder
	name = "Corn Chowder"
	description = "A creamy bowl of corn chowder, with bacon bits and mixed vegetables. One bowl is never enough."
	data = list("creamy broth" = 1, "bacon" = 1, "mixed vegetables" = 1)
	color = "#FFF200"

/datum/glass_style/has_foodtype/soup/corn_chowder
	required_drink_type = /datum/reagent/consumable/nutriment/soup/corn_chowder
	icon_state = "corn_chowder"
	drink_type = VEGETABLES | MEAT

/datum/chemical_reaction/food/soup/corn_chowder
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/cream = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/meat/bacon = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/corn_chowder = 30,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment = 2,
	)

// Lizard stuff

// Atrakor Dumpling soup
/datum/reagent/consumable/nutriment/soup/atrakor_dumplings
	name = "\improper Atrakor dumpling soup"
	description = "A bowl of rich, meaty dumpling soup, traditionally served during the festival of Atrakor's Might on Tizira. The dumplings are shaped like the Night Sky Lord himself."
	data = list("bone broth" = 1, "onion" = 1, "potato" = 1)
	color = "#7B453B"

/datum/glass_style/has_foodtype/soup/atrakor_dumplings
	required_drink_type = /datum/reagent/consumable/nutriment/soup/atrakor_dumplings
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "atrakor_dumplings"
	drink_type = MEAT | VEGETABLES | NUTS

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
	results = list(
		/datum/reagent/consumable/nutriment/soup/atrakor_dumplings = 30,
		/datum/reagent/water = 10,
	)
	ingredient_reagent_multiplier = 0.5
	percentage_of_nutriment_converted = 0.2

// Meatball Soup, but lizard-like
/datum/reagent/consumable/nutriment/soup/meatball_noodles
	name = "Meatball Noodle Soup"
	description = "A hearty noodle soup made from meatballs and nizaya in a rich broth. Commonly topped with a handful of chopped nuts."
	data = list("bone broth" = 1, "meat" = 1, "gnocchi" = 1, "peanuts" = 1)
	color = "#915145"

/datum/glass_style/has_foodtype/soup/meatball_noodles
	required_drink_type = /datum/reagent/consumable/nutriment/soup/meatball_noodles
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "meatball_noodles"
	drink_type = MEAT | VEGETABLES | NUTS

/datum/chemical_reaction/food/soup/meatball_noodles
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/spaghetti/nizaya = 1,
		/obj/item/food/meatball = 2,
		/obj/item/food/grown/peanut = 1
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/meatball_noodles = 30,
		/datum/reagent/water = 10,
	)
	ingredient_reagent_multiplier = 0.5
	percentage_of_nutriment_converted = 0.1

// Black Broth
/datum/reagent/consumable/nutriment/soup/black_broth
	name = "\improper Tiziran black broth"
	description = "A bowl of sausage, onion, blood and vinegar, served ice cold. Every bit as rough as it sounds."
	data = list("vinegar" = 1, "iron" = 1)
	color = "#340010"

/datum/glass_style/has_foodtype/soup/black_broth
	required_drink_type = /datum/reagent/consumable/nutriment/soup/black_broth
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "black_broth"
	drink_type = MEAT | VEGETABLES | GORE

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
	results = list(
		/datum/reagent/consumable/nutriment/soup/black_broth = 30,
		/datum/reagent/blood = 8,
		/datum/reagent/consumable/liquidgibs = 7,
		/datum/reagent/consumable/vinegar = 5,
	)
	ingredient_reagent_multiplier = 0.5
	percentage_of_nutriment_converted = 0.1

// Jellyfish Stew
/datum/reagent/consumable/nutriment/soup/jellyfish
	name = "Jellyfish Stew"
	description = "A slimy bowl of jellyfish stew. It jiggles if you shake it."
	data = list("slime" = 1)
	color = "#3FAA7E"

/datum/glass_style/has_foodtype/soup/jellyfish
	required_drink_type = /datum/reagent/consumable/nutriment/soup/jellyfish
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "jellyfish_stew"
	drink_type = MEAT | VEGETABLES | GORE

/datum/chemical_reaction/food/soup/jellyfish_stew
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/canned/jellyfish = 1,
		/obj/item/food/grown/soybeans = 1,
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/potato = 1
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/jellyfish = 30,
		/datum/reagent/water = 5,
	)

// Rootbread Soup
/datum/reagent/consumable/nutriment/soup/rootbread
	name = "Rootbread Soup"
	description = "A big bowl of spicy, savoury soup made with rootbread. Heavily seasoned, and very tasty."
	data = list("bread" = 1, "egg" = 1, "chili" = 1, "garlic" = 1)
	color = "#AC3232"

/datum/glass_style/has_foodtype/soup/rootbread
	required_drink_type = /datum/reagent/consumable/nutriment/soup/rootbread
	icon = 'icons/obj/food/lizard.dmi'
	icon_state = "rootbread_soup"
	drink_type = MEAT | VEGETABLES

/datum/chemical_reaction/food/soup/rootbread_soup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/breadslice/root = 2,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/egg = 1
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/rootbread = 30,
		/datum/reagent/consumable/nutriment/protein = 8,
	)
	percentage_of_nutriment_converted = 0.2

// Moth stuff

// Cotton Soup
/datum/reagent/consumable/nutriment/soup/cottonball
	name = "Flöfrölenmæsch" //flöf = cotton, rölen = ball, mæsch = soup
	description = "A soup made from raw cotton in a flavourful vegetable broth. Enjoyed only by moths and the criminally tasteless."
	data = list("cotton" = 1, "broth" = 1)
	color = "#E6A625"

/datum/glass_style/has_foodtype/soup/cottonball
	required_drink_type = /datum/reagent/consumable/nutriment/soup/cottonball
	name = "flöfrölenmæsch"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "moth_cotton_soup"
	drink_type = VEGETABLES | CLOTH

/datum/chemical_reaction/food/soup/cottonball
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/grown/cotton = 1, // Why are you buying clothes at the soup store?!
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/oven_baked_corn = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/cottonball = 30,
	)
	ingredient_reagent_multiplier = 0.5
	percentage_of_nutriment_converted = 0.1 // Cotton has no nutrition

// Cheese Soup
/datum/reagent/consumable/nutriment/soup/cheese
	name = "Ælosterrmæsch" //ælo = cheese, sterr = melt, mæsch = soup
	description = "A simple and filling soup made from homemade cheese and sweet potato. \
		The curds provide texture while the whey provides volume- and they both provide deliciousness!"
	data = list("cheese" = 1, "cream" = 1, "sweet potato" = 1)
	color = "#F3CE3A"

/datum/glass_style/has_foodtype/soup/cheese
	required_drink_type = /datum/reagent/consumable/nutriment/soup/cheese
	name = "ælosterrmæsch"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "moth_cheese_soup"
	drink_type = DAIRY | GRAIN

/datum/chemical_reaction/food/soup/cheese
	required_reagents = list(
		/datum/reagent/water = 30,
		/datum/reagent/consumable/milk = 10,
	)
	required_ingredients = list(
		/obj/item/food/doughslice = 2,
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/butterslice = 1,
		/obj/item/food/grown/potato/sweet = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/cheese = 30,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/milk = 2,
	)

// Seed Soup
/datum/reagent/consumable/nutriment/soup/seed
	name = "Misklmæsch" //miskl = seed, mæsch = soup
	description = "A seed based soup, made by germinating seeds and then boiling them. \
		Produces a particularly bitter broth which is usually balanced by the addition of vinegar."
	data = list("bitterness" = 1, "sourness" = 1)
	color = "#4F6F31"

/datum/glass_style/has_foodtype/soup/seed
	required_drink_type = /datum/reagent/consumable/nutriment/soup/seed
	name = "misklmæsch"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "moth_seed_soup"
	drink_type = VEGETABLES

/datum/chemical_reaction/food/soup/seed
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/vinegar = 10,
	)
	required_ingredients = list(
		/obj/item/seeds/sunflower = 1,
		/obj/item/seeds/poppy/lily = 1,
		/obj/item/seeds/ambrosia = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/seed = 30,
		/datum/reagent/consumable/nutriment/vitamin = 13,
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/vinegar = 8,
		/datum/reagent/water = 7,
	)

// Bean Soup
/datum/reagent/consumable/nutriment/soup/beans
	name = "Prickeldröndolhaskl" //prickeld = spicy, röndol = bean, haskl = stew
	description = "A spicy bean stew with lots of veggies, commonly served aboard the fleet as a filling and satisfying meal with rice or bread."
	data = list("beans" = 1, "cabbage" = 1, "spicy sauce" = 1)
	color = "#DF7126"

/datum/glass_style/has_foodtype/soup/beans
	required_drink_type = /datum/reagent/consumable/nutriment/soup/beans
	name = "prickeldröndolhaskl"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "moth_bean_stew"
	drink_type = VEGETABLES

/datum/chemical_reaction/food/soup/beans
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/canned/beans = 1,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/oven_baked_corn = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/beans = 30,
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/water = 10,
	)
	ingredient_reagent_multiplier = 0.5
	percentage_of_nutriment_converted = 0.1

// Oat Soup, but not oatmeal
/datum/reagent/consumable/nutriment/soup/moth_oats
	name = "Häfmisklhaskl" //häfmiskl = oat (häf from German hafer meaning oat, miskl meaning seed), haskl = stew
	description = "A spicy bean stew with lots of veggies, commonly served aboard the fleet as a filling and satisfying meal with rice or bread."
	data = list("oats" = 1, "sweet potato" = 1, "carrot" = 1, "parsnip" = 1, "pumpkin" = 1)
	color = "#CAA94E"

/datum/glass_style/has_foodtype/soup/moth_oats
	required_drink_type = /datum/reagent/consumable/nutriment/soup/moth_oats
	name = "häfmisklhaskl"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "moth_oat_stew"
	drink_type = VEGETABLES | GRAIN

/datum/chemical_reaction/food/soup/moth_oats
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/oat = 1,
		/obj/item/food/grown/potato/sweet = 1,
		/obj/item/food/grown/parsnip = 1,
		/obj/item/food/grown/carrot = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/moth_oats = 30,
	)
	percentage_of_nutriment_converted = 0.1

// Fire Soup
/datum/reagent/consumable/nutriment/soup/fire_soup
	name = "Tömpröttkrakklmæsch" //tömprött = heart (tömp = thump, rött = muscle), krakkl = fire, mæsch = soup
	description = "Tömpröttkrakklmæsch, or heartburn soup, is a cold soup dish that originated amongst the jungle moths, \
		and is named for two things- its rosy pink colour, and its scorchingly hot chili heat."
	data = list("love" = 1, "hate" = 1)
	color = "#FBA8F3"

/datum/glass_style/has_foodtype/soup/fire_soup
	required_drink_type = /datum/reagent/consumable/nutriment/soup/fire_soup
	name = "tömpröttkrakklmæsch"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "moth_fire_soup"
	drink_type = VEGETABLES | DAIRY

/datum/chemical_reaction/food/soup/fire_soup
	required_reagents = list(
		/datum/reagent/water = 30,
		/datum/reagent/consumable/yoghurt = 15,
		/datum/reagent/consumable/vinegar = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/ghost_chili = 1,
		/obj/item/food/tofu = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/fire_soup = 30,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/vinegar = 2,
	)
	ingredient_reagent_multiplier = 0.33 // Chilis have a TON of capsaicin naturally
	percentage_of_nutriment_converted = 0

// Rice Porridge (Soup-ish)
/datum/reagent/consumable/nutriment/soup/rice_porridge
	name = "Rice Porridge"
	description = "A plate of rice porridge. It's mostly flavourless, but it does fill a spot. \
		To the Chinese it's congee, and moths call it höllflöfmisklsløsk." //höllflöfmiskl = rice (höllflöf = cloud, miskl = seed), sløsk = porridge
	data = list("nothing" = 1)
	color = "#EDE3E3"

/datum/glass_style/has_foodtype/soup/rice_porridge
	required_drink_type = /datum/reagent/consumable/nutriment/soup/rice_porridge
	name = "rice porridge"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "rice_porridge"
	drink_type = GRAIN

/datum/chemical_reaction/food/soup/rice_porridge
	required_reagents = list(
		/datum/reagent/water = 30,
		/datum/reagent/consumable/salt = 5,
	)
	required_ingredients = list(
		/obj/item/food/boiledrice = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/rice_porridge = 20,
		/datum/reagent/consumable/salt = 5,
	)
	percentage_of_nutriment_converted = 0.15

// Cornmeal Porridge (Soup-ish)
// Also, pretty much just a normal chemical reaction. Used in other stuff
/datum/reagent/consumable/nutriment/soup/cornmeal_porridge
	name = "Cornmeal Porridge"
	description = "A plate of cornmeal porridge. It's more flavourful than most porridges, and makes a good base for other flavours, too."
	data = list("cornmeal" = 1)
	color = "#ECDA7B"

/datum/glass_style/has_foodtype/soup/cornmeal_porridge
	required_drink_type = /datum/reagent/consumable/nutriment/soup/cornmeal_porridge
	name = "cornmeal porridge"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "cornmeal_porridge"
	drink_type = GRAIN

/datum/chemical_reaction/food/soup/cornmeal_porridge
	required_other = FALSE
	required_reagents = list(
		/datum/reagent/consumable/cornmeal = 20,
		/datum/reagent/water = 20,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/cornmeal_porridge = 20,
	)

// Cheese Porridge (Soup-ish)
/datum/reagent/consumable/nutriment/soup/cheese_porridge
	name = "Cheesy Porridge" //milk, polenta, firm cheese, curd cheese, butter
	description = "A rich and creamy bowl of cheesy cornmeal porridge."
	data = list("cornmeal" = 1, "cheese" = 1, "more cheese" = 1, "lots of cheese" = 1)
	color = "#F0DD5A"

/datum/glass_style/has_foodtype/soup/cheese_porridge
	required_drink_type = /datum/reagent/consumable/nutriment/soup/cheese_porridge
	name = "cheesy porridge"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "cheesy_porridge"
	drink_type = DAIRY | GRAIN

/datum/chemical_reaction/food/soup/cheese_porridge
	required_reagents = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/nutriment/soup/cornmeal_porridge = 20,
		/datum/reagent/water = 20,
	)
	required_ingredients = list(
		/obj/item/food/cheese/firm_cheese_slice = 1,
		/obj/item/food/cheese/curd_cheese = 1,
		/obj/item/food/butterslice = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/cheese_porridge = 30,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/consumable/nutriment/protein = 4,
	)

// Rice Porridge again but with Toechtause
/datum/reagent/consumable/nutriment/soup/toechtauese_rice_porridge
	name = "Töchtaüse Rice Porridge"
	description = "Commonly served aboard the mothic fleet, rice porridge with töchtaüse syrup is more palatable than the regular stuff, if even just because it's spicier than normal."
	data = list("sugar" = 1, "spice" = 1)
	color = "#D8CFCC"

/datum/glass_style/has_foodtype/soup/toechtauese_rice_porridge
	required_drink_type = /datum/reagent/consumable/nutriment/soup/toechtauese_rice_porridge
	name = "töchtaüse rice porridge"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "toechtauese_rice_porridge"
	drink_type = GRAIN | VEGETABLES

/datum/chemical_reaction/food/soup/toechtauese_rice_porridge
	required_reagents = list(
		/datum/reagent/consumable/nutriment/soup/rice_porridge = 20,
		/datum/reagent/consumable/toechtauese_syrup = 10,
		/datum/reagent/water = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/chili = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/toechtauese_rice_porridge = 30,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/toechtauese_syrup = 6,
	)

// Red Porridge
/datum/reagent/consumable/nutriment/soup/red_porridge
	name = "Eltsløsk ül a priktæolk" //eltsløsk = red porridge, ül a = with, prikt = sour, æolk = cream
	description = "Red porridge with yoghurt. The name and vegetable ingredients obscure the sweet nature of the dish, which is commonly served as a dessert aboard the fleet."
	data = list("sweet beets" = 1, "sugar" = 1, "sweetened yoghurt" = 1)
	color = "#FF858B"

/datum/glass_style/has_foodtype/soup/red_porridge
	required_drink_type = /datum/reagent/consumable/nutriment/soup/red_porridge
	name = "eltsløsk ül a priktæolk"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "red_porridge"
	drink_type = VEGETABLES | SUGAR | DAIRY

/datum/chemical_reaction/food/soup/red_porridge
	required_temp = WATER_BOILING_POINT
	optimal_temp = 400
	overheat_temp = 415 // Caramel forms
	thermic_constant = 0
	required_reagents = list(
		/datum/reagent/consumable/vanilla = 10,
		/datum/reagent/consumable/yoghurt = 20,
		/datum/reagent/consumable/sugar = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/redbeet = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/red_porridge = 24,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/sugar = 8,
	)
	percentage_of_nutriment_converted = 0.1
