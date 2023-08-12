/datum/crafting_recipe/food
	/// A rough equivilance for how much nutrition this recipe's result will provide
	var/total_nutriment_factor = 0

/datum/crafting_recipe/food/on_craft_completion(mob/user, atom/result)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(istype(result) && !isnull(user.mind))
		ADD_TRAIT(result, TRAIT_FOOD_CHEF_MADE, REF(user.mind))

/datum/crafting_recipe/food/New()
	. = ..()
	if(ispath(result, /obj/item/food))
		var/obj/item/food/result_food = new result()
		for(var/datum/reagent/consumable/nutriment as anything in result_food.food_reagents)
			total_nutriment_factor += initial(nutriment.nutriment_factor) * result_food.food_reagents[nutriment]
		qdel(result_food)

	parts |= reqs

/datum/crafting_recipe/food/crafting_ui_data()
	var/list/data = list()

	if(ispath(result, /obj/item/food))
		var/obj/item/food/item = result
		data["foodtypes"] = bitfield_to_list(initial(item.foodtypes), FOOD_FLAGS)
	data["nutriments"] = total_nutriment_factor

	return data

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/food
	optimal_temp = 400
	temp_exponent_factor = 1
	optimal_ph_min = 2
	optimal_ph_max = 10
	thermic_constant = 0
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

	/// Typepath of food that is created on reaction
	var/atom/resulting_food_path

/datum/chemical_reaction/food/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	if(resulting_food_path)
		var/atom/location = holder.my_atom.drop_location()
		for(var/i in 1 to created_volume)
			new resulting_food_path(location)

/datum/chemical_reaction/food/tofu
	required_reagents = list(/datum/reagent/consumable/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/tofu

/datum/chemical_reaction/food/candycorn
	required_reagents = list(/datum/reagent/consumable/cornoil = 5)
	required_catalysts = list(/datum/reagent/consumable/sugar = 5)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/candy_corn

/datum/chemical_reaction/food/chocolatepudding
	results = list(/datum/reagent/consumable/chocolatepudding = 20)
	required_reagents = list(/datum/reagent/consumable/cream = 5, /datum/reagent/consumable/coco = 5, /datum/reagent/consumable/eggyolk = 2)

/datum/chemical_reaction/food/vanillapudding
	results = list(/datum/reagent/consumable/vanillapudding = 20)
	required_reagents = list(/datum/reagent/consumable/vanilla = 5, /datum/reagent/consumable/cream = 5, /datum/reagent/consumable/eggyolk = 2)

/datum/chemical_reaction/food/chocolate_bar
	required_reagents = list(/datum/reagent/consumable/soymilk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/chocolatebar

/datum/chemical_reaction/food/chocolate_bar2
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 4, /datum/reagent/consumable/sugar = 2)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/chocolatebar

/datum/chemical_reaction/food/chocolate_bar3
	required_reagents = list(/datum/reagent/consumable/milk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/chocolatebar

/datum/chemical_reaction/food/soysauce
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/food/corn_syrup
	results = list(/datum/reagent/consumable/corn_syrup = 5)
	required_reagents = list(/datum/reagent/consumable/corn_starch = 1, /datum/reagent/toxin/acid = 1)
	required_temp = 374

/datum/chemical_reaction/food/caramel
	results = list(/datum/reagent/consumable/caramel = 1)
	required_reagents = list(/datum/reagent/consumable/sugar = 1)
	required_temp = 413.15
	optimal_temp = 600
	mob_react = FALSE

/datum/chemical_reaction/food/caramel_burned
	results = list(/datum/reagent/carbon = 1)
	required_reagents = list(/datum/reagent/consumable/caramel = 1)
	required_temp = 483.15
	optimal_temp = 1000
	rate_up_lim = 10
	mob_react = FALSE

/datum/chemical_reaction/food/cheesewheel
	required_reagents = list(/datum/reagent/consumable/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/cheese/wheel

/datum/chemical_reaction/food/synthmeat
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/cryoxadone = 1)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/meat/slab/synthmeat

/datum/chemical_reaction/food/hot_ramen
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/food/hell_ramen
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)

/datum/chemical_reaction/food/imitationcarpmeat
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5)
	required_container = /obj/item/food/tofu
	mix_message = "The mixture becomes similar to carp meat."
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/food/imitationcarpmeat/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/food/fishmeat/carp/imitation(location)
	if(holder?.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/food/dough
	required_reagents = list(/datum/reagent/water = 10, /datum/reagent/consumable/flour = 15)
	mix_message = "The ingredients form a dough."
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/dough

/datum/chemical_reaction/food/cakebatter
	required_reagents = list(/datum/reagent/consumable/eggyolk = 6, /datum/reagent/consumable/eggwhite = 12, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)
	mix_message = "The ingredients form a cake batter."
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/cakebatter

/datum/chemical_reaction/food/cakebatter/vegan
	required_reagents = list(/datum/reagent/consumable/soymilk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)

/datum/chemical_reaction/food/pancakebatter
	results = list(/datum/reagent/consumable/pancakebatter = 15)
	required_reagents = list(/datum/reagent/consumable/eggyolk = 6, /datum/reagent/consumable/eggwhite = 12, /datum/reagent/consumable/milk = 10, /datum/reagent/consumable/flour = 5)

/datum/chemical_reaction/food/uncooked_rice
	required_reagents = list(/datum/reagent/consumable/rice = 10, /datum/reagent/water = 10)
	mix_message = "The rice absorbs the water."
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/food/uncooked_rice/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/uncooked_rice(location)

/datum/chemical_reaction/food/nutriconversion
	results = list(/datum/reagent/consumable/nutriment/peptides = 0.5)
	required_reagents = list(/datum/reagent/consumable/nutriment/ = 0.5)
	required_catalysts = list(/datum/reagent/medicine/metafactor = 0.5)

/datum/chemical_reaction/food/protein_peptide
	results = list(/datum/reagent/consumable/nutriment/peptides = 0.5)
	required_reagents = list(/datum/reagent/consumable/nutriment/protein = 0.5)
	required_catalysts = list(/datum/reagent/medicine/metafactor = 0.5)

/datum/chemical_reaction/food/failed_nutriconversion
	results = list(/datum/reagent/peptides_failed = 0.5)
	required_reagents = list(/datum/reagent/consumable/nutriment/ = 0.5)
	required_catalysts = list(/datum/reagent/impurity/probital_failed = 0.5)
	thermic_constant = 100 // a tell

/datum/chemical_reaction/food/failed_protein_peptide
	results = list(/datum/reagent/peptides_failed = 0.5)
	required_reagents = list(/datum/reagent/consumable/nutriment/protein = 0.5)
	required_catalysts = list(/datum/reagent/impurity/probital_failed = 0.5)
	thermic_constant = 100 // a tell

/datum/chemical_reaction/food/bbqsauce
	results = list(/datum/reagent/consumable/bbqsauce = 5)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/medicine/salglu_solution = 3, /datum/reagent/consumable/blackpepper = 1)

/datum/chemical_reaction/food/gravy
	results = list(/datum/reagent/consumable/gravy = 3)
	required_reagents = list(/datum/reagent/consumable/milk = 1, /datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/flour = 1)

/datum/chemical_reaction/food/mothic_pizza_dough
	required_reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/quality_oil = 2, /datum/reagent/medicine/salglu_solution = 5, /datum/reagent/consumable/cornmeal = 10, /datum/reagent/consumable/flour = 5)
	mix_message = "The ingredients form a pizza dough."
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/mothic_pizza_dough

/datum/chemical_reaction/food/curd_cheese
	required_reagents = list(/datum/reagent/consumable/milk = 15, /datum/reagent/consumable/vinegar = 5, /datum/reagent/consumable/cream = 5)
	mix_message = "The milk curdles into cheese."
	required_temp = 353
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/cheese/curd_cheese

/datum/chemical_reaction/food/mozzarella
	required_reagents = list(/datum/reagent/consumable/milk = 10, /datum/reagent/consumable/cream = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 1)
	mix_message = "Fine ribbons of curd form in the milk."
	required_temp = 353
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/cheese/mozzarella

/datum/chemical_reaction/food/cornmeal_batter
	results = list(/datum/reagent/consumable/cornmeal_batter = 35)
	required_reagents = list(/datum/reagent/consumable/cornmeal = 20, /datum/reagent/consumable/yoghurt = 10, /datum/reagent/consumable/eggyolk = 5)
	mix_message = "A silky batter forms."

/datum/chemical_reaction/food/cornbread
	required_reagents = list(/datum/reagent/consumable/cornmeal_batter = 25)
	mix_message = "The batter bakes into cornbread- somehow!"
	required_temp = 473
	reaction_flags = REACTION_INSTANT
	resulting_food_path = /obj/item/food/bread/corn

/datum/chemical_reaction/food/yoghurt
	required_reagents = list(/datum/reagent/consumable/cream = 10, /datum/reagent/consumable/virus_food = 2)
	results = list(/datum/reagent/consumable/yoghurt = 10)
	mix_message = "The mixture thickens into yoghurt."
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/food/quality_oil_upconvert
	required_reagents = list(/datum/reagent/consumable/quality_oil = 1, /datum/reagent/consumable/cooking_oil = 2)
	results = list(/datum/reagent/consumable/quality_oil = 2)
	mix_message = "The cooking oil dilutes the quality oil- how delightfully devilish..."
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/food/quality_oil
	results = list(/datum/reagent/consumable/quality_oil = 2)
	required_reagents = list(/datum/reagent/consumable/olivepaste = 4, /datum/reagent/water = 1)
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/food/vinegar
	results = list(/datum/reagent/consumable/vinegar = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/wine = 1, /datum/reagent/water = 1, /datum/reagent/consumable/sugar = 1)
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/food/grounding_neutralise
	results = list(/datum/reagent/consumable/salt = 2)
	required_reagents = list(/datum/reagent/consumable/liquidelectricity/enriched = 2, /datum/reagent/consumable/grounding_solution = 1)
	mix_message = "The mixture lets off a sharp snap as the electricity discharges."
	mix_sound = 'sound/weapons/taser.ogg'
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/food/martian_batter
	results = list(/datum/reagent/consumable/martian_batter = 2)
	required_reagents = list(/datum/reagent/consumable/flour = 1, /datum/reagent/consumable/nutriment/soup/dashi = 1)
	mix_message = "A smooth batter forms."
	reaction_flags = REACTION_INSTANT
