/datum/crafting_recipe/food/reaction/soup
	machinery = list(/obj/machinery/stove)
	category = CAT_SOUP
	non_craftable = TRUE
	/// What contained is this reaction expected to be served in?
	/// Used to determine the icon to display in the crafting UI.
	var/expected_container = /obj/item/reagent_containers/cup/bowl

/datum/crafting_recipe/food/reaction/soup/New()
	// What are ya using this path for if it's not a food reaction?
	if(!ispath(reaction, /datum/chemical_reaction/food))
		return ..()

	var/datum/chemical_reaction/food/soup_reaction = reaction
	// If the reaction has a solid food item result, it is prioritized over reagent results
	if(ispath(initial(soup_reaction.resulting_food_path), /obj/item/food))
		result = initial(soup_reaction.resulting_food_path)
		result_amount = 1

	return ..()

/datum/crafting_recipe/food/reaction/soup/crafting_ui_data()
	if(ispath(result, /obj/item/food))
		return ..()

	var/list/data = list()

	var/datum/glass_style/has_foodtype/soup_style = GLOB.glass_style_singletons[expected_container][result]
	if(istype(soup_style))
		data["foodtypes"] = bitfield_to_list(soup_style.drink_type, FOOD_FLAGS)

	return data

/datum/crafting_recipe/food/reaction/soup/setup_chemical_reaction_details(datum/chemical_reaction/food/soup/chemical_reaction)
	. = ..()
	if(!istype(chemical_reaction))
		return
	for(var/obj/item/ingredienttype as anything in chemical_reaction.required_ingredients)
		LAZYSET(reqs, ingredienttype, chemical_reaction.required_ingredients[ingredienttype])

/datum/crafting_recipe/food/reaction/soup/meatball_soup
	reaction = /datum/chemical_reaction/food/soup/meatballsoup

/datum/crafting_recipe/food/reaction/soup/vegetable_soup
	reaction = /datum/chemical_reaction/food/soup/vegetable_soup

/datum/crafting_recipe/food/reaction/soup/nettle
	reaction = /datum/chemical_reaction/food/soup/nettlesoup

/datum/crafting_recipe/food/reaction/soup/wingfangchu
	reaction = /datum/chemical_reaction/food/soup/wingfangchu

/datum/crafting_recipe/food/reaction/soup/hotchili
	reaction = /datum/chemical_reaction/food/soup/hotchili

/datum/crafting_recipe/food/reaction/soup/coldchili
	reaction = /datum/chemical_reaction/food/soup/coldchili

/datum/crafting_recipe/food/reaction/soup/clownchili
	reaction = /datum/chemical_reaction/food/soup/clownchili

/datum/crafting_recipe/food/reaction/soup/tomatosoup
	reaction = /datum/chemical_reaction/food/soup/tomatosoup

/datum/crafting_recipe/food/reaction/soup/bloodsoup
	name = "Blood Soup"
	desc = "Smells like copper."
	reaction = /datum/chemical_reaction/food/soup/bloodsoup
	// Uses tomato soup's icon
	result = /datum/reagent/consumable/nutriment/soup/tomato
	// More of a vague guess than anything
	result_amount = 30

/datum/crafting_recipe/food/reaction/soup/eyeballsoup
	reaction = /datum/chemical_reaction/food/soup/eyeballsoup

/datum/crafting_recipe/food/reaction/soup/misosoup
	reaction = /datum/chemical_reaction/food/soup/misosoup

/datum/crafting_recipe/food/reaction/soup/slimesoup
	reaction = /datum/chemical_reaction/food/soup/slimesoup

/datum/crafting_recipe/food/reaction/soup/slimesoup_alt
	reaction = /datum/chemical_reaction/food/soup/slimesoup/alt

/datum/crafting_recipe/food/reaction/soup/clownstears
	reaction = /datum/chemical_reaction/food/soup/clownstears

/datum/crafting_recipe/food/reaction/soup/mysterysoup
	reaction = /datum/chemical_reaction/food/soup/mysterysoup

/datum/crafting_recipe/food/reaction/soup/monkey
	reaction = /datum/chemical_reaction/food/soup/monkey

/datum/crafting_recipe/food/reaction/soup/mushroomsoup
	reaction = /datum/chemical_reaction/food/soup/mushroomsoup

/datum/crafting_recipe/food/reaction/soup/beetsoup
	reaction = /datum/chemical_reaction/food/soup/beetsoup

/datum/crafting_recipe/food/reaction/soup/stew
	reaction = /datum/chemical_reaction/food/soup/stew

/datum/crafting_recipe/food/reaction/soup/sweetpotatosoup
	reaction = /datum/chemical_reaction/food/soup/sweetpotatosoup

/datum/crafting_recipe/food/reaction/soup/redbeetsoup
	reaction = /datum/chemical_reaction/food/soup/redbeetsoup

/datum/crafting_recipe/food/reaction/soup/onionsoup
	reaction = /datum/chemical_reaction/food/soup/onionsoup

/datum/crafting_recipe/food/reaction/soup/bisque
	reaction = /datum/chemical_reaction/food/soup/bisque

/datum/crafting_recipe/food/reaction/soup/bungocurry
	reaction = /datum/chemical_reaction/food/soup/bungocurry

/datum/crafting_recipe/food/reaction/soup/electron
	reaction = /datum/chemical_reaction/food/soup/electron

/datum/crafting_recipe/food/reaction/soup/peasoup
	reaction = /datum/chemical_reaction/food/soup/peasoup

/datum/crafting_recipe/food/reaction/soup/indian_curry
	reaction = /datum/chemical_reaction/food/soup/indian_curry

/datum/crafting_recipe/food/reaction/soup/oatmeal
	reaction = /datum/chemical_reaction/food/soup/oatmeal

/datum/crafting_recipe/food/reaction/soup/zurek
	reaction = /datum/chemical_reaction/food/soup/zurek

/datum/crafting_recipe/food/reaction/soup/cullen_skink
	reaction = /datum/chemical_reaction/food/soup/cullen_skink

/datum/crafting_recipe/food/reaction/soup/chicken_noodle_soup
	reaction = /datum/chemical_reaction/food/soup/chicken_noodle_soup

/datum/crafting_recipe/food/reaction/soup/corn_chowder
	reaction = /datum/chemical_reaction/food/soup/corn_chowder

// Other

/datum/crafting_recipe/food/wishsoup
	name = "Wish soup"
	reqs = list(
		/datum/reagent/water = 20,
		/obj/item/reagent_containers/cup/bowl = 1
	)
	result= /obj/item/food/bowled/wish
	category = CAT_SOUP
