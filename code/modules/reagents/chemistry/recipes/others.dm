
/datum/chemical_reaction/sterilizine
	results = list(/datum/reagent/space_cleaner/sterilizine = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/c2/multiver = 1, /datum/reagent/chlorine = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/lube
	results = list(/datum/reagent/lube = 4)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/silicon = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/spraytan
	results = list(/datum/reagent/spraytan = 2)
	required_reagents = list(/datum/reagent/consumable/orangejuice = 1, /datum/reagent/fuel/oil = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/spraytan2
	results = list(/datum/reagent/spraytan = 2)
	required_reagents = list(/datum/reagent/consumable/orangejuice = 1, /datum/reagent/consumable/nutriment/fat/oil = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/impedrezene
	results = list(/datum/reagent/impedrezene = 2)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_ORGAN

/datum/chemical_reaction/cryptobiolin
	results = list(/datum/reagent/cryptobiolin = 3)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/glycerol
	results = list(/datum/reagent/glycerol = 1)
	required_reagents = list(/datum/reagent/consumable/nutriment/fat/oil/corn = 3, /datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/sodiumchloride
	results = list(/datum/reagent/consumable/salt = 2)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/chlorine = 1) // That's what I said! Sodium Chloride!
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_FOOD

/datum/chemical_reaction/stable_plasma
	results = list(/datum/reagent/stable_plasma = 1)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_catalysts = list(/datum/reagent/stabilizing_agent = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/plasma_solidification
	required_reagents = list(/datum/reagent/iron = 5, /datum/reagent/consumable/frostoil = 5, /datum/reagent/toxin/plasma = 20)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/plasma_solidification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/plasma(location)

/datum/chemical_reaction/gold_solidification
	required_reagents = list(/datum/reagent/consumable/frostoil = 5, /datum/reagent/gold = 20, /datum/reagent/iron = 1)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/gold_solidification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/gold(location)

/datum/chemical_reaction/uranium_solidification
	required_reagents = list(/datum/reagent/consumable/frostoil = 5, /datum/reagent/uranium = 20, /datum/reagent/potassium = 1)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/uranium_solidification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/uranium(location)

/datum/chemical_reaction/capsaicincondensation
	results = list(/datum/reagent/consumable/condensedcapsaicin = 5)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/ethanol = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/soapification
	required_reagents = list(/datum/reagent/consumable/liquidgibs = 10, /datum/reagent/lye = 10) // requires two scooped gib tiles
	required_temp = 374
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/soapification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/soap/homemade(location)

/datum/chemical_reaction/omegasoapification
	required_reagents = list(/datum/reagent/consumable/potato_juice = 10, /datum/reagent/consumable/ethanol/lizardwine = 10, /datum/reagent/monkey_powder = 10, /datum/reagent/drug/krokodil = 10, /datum/reagent/toxin/acid/nitracid = 10, /datum/reagent/baldium = 10, /datum/reagent/consumable/ethanol/hooch = 10, /datum/reagent/bluespace = 10, /datum/reagent/drug/pumpup = 10, /datum/reagent/consumable/space_cola = 10)
	required_temp = 999
	optimal_temp = 999
	overheat_temp = 1200
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/omegasoapification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/soap/omega(location)

/datum/chemical_reaction/candlefication
	required_reagents = list(/datum/reagent/consumable/liquidgibs = 5, /datum/reagent/oxygen = 5) //
	required_temp = 374
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/candlefication/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/flashlight/flare/candle(location)

/datum/chemical_reaction/meatification
	required_reagents = list(/datum/reagent/consumable/liquidgibs = 10, /datum/reagent/consumable/nutriment = 10, /datum/reagent/carbon = 10)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/meatification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/meat/slab/meatproduct(location)
	return

/datum/chemical_reaction/carbondioxide
	results = list(/datum/reagent/carbondioxide = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/oxygen = 2)
	required_temp = 777 // pure carbon isn't especially reactive.
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/nitrous_oxide
	results = list(/datum/reagent/nitrous_oxide = 5)
	required_reagents = list(/datum/reagent/ammonia = 2, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 2)
	required_temp = 525
	optimal_temp = 550
	overheat_temp = 575
	temp_exponent_factor = 0.2
	purity_min = 0.3
	thermic_constant = 35 //gives a bonus 15C wiggle room
	rate_up_lim = 25 //Give a chance to pull back
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/nitrous_oxide/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	var/turf/exposed_turf = get_turf(holder.my_atom)
	if(!exposed_turf)
		return
	exposed_turf.atmos_spawn_air("[GAS_N2O]=[equilibrium.step_target_vol/2];[TURF_TEMPERATURE(holder.chem_temp)]")
	clear_products(holder, equilibrium.step_target_vol)

/datum/chemical_reaction/nitrous_oxide/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	return //This is empty because the explosion reaction will occur instead (see pyrotechnics.dm). This is just here to update the lookup ui.


//Technically a mutation toxin
/datum/chemical_reaction/mulligan
	results = list(/datum/reagent/mulligan = 1)
	required_reagents = list(/datum/reagent/mutationtoxin/jelly = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE


////////////////////////////////// VIROLOGY //////////////////////////////////////////

/datum/chemical_reaction/virus_food
	results = list(/datum/reagent/consumable/virus_food = 15)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/milk = 5)
	required_temp = 600
	optimal_temp = 625
	overheat_temp = 700

/datum/chemical_reaction/virus_food_mutagen
	results = list(/datum/reagent/toxin/mutagen/mutagenvirusfood = 1)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/consumable/virus_food = 1)

/datum/chemical_reaction/virus_food_synaptizine
	results = list(/datum/reagent/medicine/synaptizine/synaptizinevirusfood = 1)
	required_reagents = list(/datum/reagent/medicine/synaptizine = 1, /datum/reagent/consumable/virus_food = 1)

/datum/chemical_reaction/virus_food_plasma
	results = list(/datum/reagent/toxin/plasma/plasmavirusfood = 1)
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/consumable/virus_food = 1)
	thermic_constant = 20 // To avoid the plasma boiling

/datum/chemical_reaction/virus_food_plasma_synaptizine
	results = list(/datum/reagent/toxin/plasma/plasmavirusfood/weak = 2)
	required_reagents = list(/datum/reagent/medicine/synaptizine = 1, /datum/reagent/toxin/plasma/plasmavirusfood = 1)
	thermic_constant = 20 // To avoid the plasma boiling

/datum/chemical_reaction/virus_food_mutagen_sugar
	results = list(/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar = 2)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/toxin/mutagen/mutagenvirusfood = 1)

/datum/chemical_reaction/virus_food_mutagen_salineglucose
	results = list(/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar = 2)
	required_reagents = list(/datum/reagent/medicine/salglu_solution = 1, /datum/reagent/toxin/mutagen/mutagenvirusfood = 1)

/datum/chemical_reaction/virus_food_uranium
	results = list(/datum/reagent/uranium/uraniumvirusfood = 1)
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/consumable/virus_food = 1)

/datum/chemical_reaction/virus_food_uranium_plasma
	results = list(/datum/reagent/uranium/uraniumvirusfood/unstable = 1)
	required_reagents = list(/datum/reagent/uranium = 5, /datum/reagent/toxin/plasma/plasmavirusfood = 1)

/datum/chemical_reaction/virus_food_uranium_plasma_gold
	results = list(/datum/reagent/uranium/uraniumvirusfood/stable = 1)
	required_reagents = list(/datum/reagent/uranium = 10, /datum/reagent/gold = 10, /datum/reagent/toxin/plasma = 1)

/datum/chemical_reaction/virus_food_uranium_plasma_silver
	results = list(/datum/reagent/uranium/uraniumvirusfood/stable = 1)
	required_reagents = list(/datum/reagent/uranium = 10, /datum/reagent/silver = 10, /datum/reagent/toxin/plasma = 1)

/datum/chemical_reaction/mix_virus
	results = list(/datum/reagent/blood = 1)
	required_reagents = list(/datum/reagent/consumable/virus_food = 1)
	required_catalysts = list(/datum/reagent/blood = 1)
	var/level_min = 1
	var/level_max = 2
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/mix_virus/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B?.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Evolve(level_min, level_max)


/datum/chemical_reaction/mix_virus/mix_virus_2
	required_reagents = list(/datum/reagent/toxin/mutagen = 1)
	level_min = 2
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_3
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	level_min = 4
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_4
	required_reagents = list(/datum/reagent/uranium = 1)
	level_min = 5
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_5
	required_reagents = list(/datum/reagent/toxin/mutagen/mutagenvirusfood = 1)
	level_min = 3
	level_max = 3

/datum/chemical_reaction/mix_virus/mix_virus_6
	required_reagents = list(/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar = 1)
	level_min = 4
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_7
	required_reagents = list(/datum/reagent/toxin/plasma/plasmavirusfood/weak = 1)
	level_min = 5
	level_max = 5

/datum/chemical_reaction/mix_virus/mix_virus_8
	required_reagents = list(/datum/reagent/toxin/plasma/plasmavirusfood = 1)
	level_min = 6
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_9
	required_reagents = list(/datum/reagent/medicine/synaptizine/synaptizinevirusfood = 1)
	level_min = 1
	level_max = 1

/datum/chemical_reaction/mix_virus/mix_virus_10
	required_reagents = list(/datum/reagent/uranium/uraniumvirusfood = 1)
	level_min = 6
	level_max = 7

/datum/chemical_reaction/mix_virus/mix_virus_11
	required_reagents = list(/datum/reagent/uranium/uraniumvirusfood/unstable = 1)
	level_min = 7
	level_max = 7

/datum/chemical_reaction/mix_virus/mix_virus_12
	required_reagents = list(/datum/reagent/uranium/uraniumvirusfood/stable = 1)
	level_min = 8
	level_max = 8

/datum/chemical_reaction/mix_virus/rem_virus
	required_reagents = list(/datum/reagent/medicine/synaptizine = 1)
	required_catalysts = list(/datum/reagent/blood = 1)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B?.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()

/datum/chemical_reaction/mix_virus/neuter_virus
	required_reagents = list(/datum/reagent/toxin/formaldehyde = 1)
	required_catalysts = list(/datum/reagent/blood = 1)

/datum/chemical_reaction/mix_virus/neuter_virus/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B?.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Neuter()



////////////////////////////////// foam and foam precursor ///////////////////////////////////////////////////


/datum/chemical_reaction/surfactant
	results = list(/datum/reagent/fluorosurfactant = 5)
	required_reagents = list(/datum/reagent/fluorine = 2, /datum/reagent/carbon = 2, /datum/reagent/toxin/acid = 1)
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/foam
	required_reagents = list(/datum/reagent/fluorosurfactant = 1, /datum/reagent/water = 1)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	holder.create_foam(/datum/effect_system/fluid_spread/foam, 2 * created_volume, notification = span_danger("The solution spews out foam!"), log = TRUE)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/metalfoam
	required_reagents = list(/datum/reagent/aluminium = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/toxin/acid/fluacid = 1)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	holder.create_foam(/datum/effect_system/fluid_spread/foam/metal, 5 * created_volume, /obj/structure/foamedmetal, span_danger("The solution spews out a metallic foam!"), log = TRUE)

/datum/chemical_reaction/smart_foam
	required_reagents = list(/datum/reagent/aluminium = 3, /datum/reagent/smart_foaming_agent = 1, /datum/reagent/toxin/acid/fluacid = 1)
	mob_react = TRUE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/smart_foam/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	holder.create_foam(/datum/effect_system/fluid_spread/foam/metal/smart, 5 * created_volume, /obj/structure/foamedmetal, span_danger("The solution spews out metallic foam!"), log = TRUE)

/datum/chemical_reaction/ironfoam
	required_reagents = list(/datum/reagent/iron = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/toxin/acid/fluacid = 1)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	holder.create_foam(/datum/effect_system/fluid_spread/foam/metal/iron, 5 * created_volume, /obj/structure/foamedmetal/iron, span_danger("The solution spews out a metallic foam!"), log = TRUE)

/datum/chemical_reaction/foaming_agent
	results = list(/datum/reagent/foaming_agent = 1)
	required_reagents = list(/datum/reagent/lithium = 1, /datum/reagent/hydrogen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/smart_foaming_agent
	results = list(/datum/reagent/smart_foaming_agent = 3)
	required_reagents = list(/datum/reagent/foaming_agent = 3, /datum/reagent/acetone = 1, /datum/reagent/iron = 1)
	mix_message = "The solution mixes into a frothy metal foam and conforms to the walls of its container."
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE


/////////////////////////////// Cleaning and hydroponics /////////////////////////////////////////////////

/datum/chemical_reaction/ammonia
	results = list(/datum/reagent/ammonia = 3)
	required_reagents = list(/datum/reagent/hydrogen = 3, /datum/reagent/nitrogen = 1)
	optimal_ph_min = 1  // Lets increase our range for this basic chem
	optimal_ph_max = 12
	H_ion_release = -0.02 //handmade is more neutral
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/datum/chemical_reaction/diethylamine
	results = list(/datum/reagent/diethylamine = 2)
	required_reagents = list (/datum/reagent/ammonia = 1, /datum/reagent/consumable/ethanol = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/datum/chemical_reaction/space_cleaner
	results = list(/datum/reagent/space_cleaner = 2)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/water = 1)
	rate_up_lim = 40
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/plantbgone
	results = list(/datum/reagent/toxin/plantbgone = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/water = 4)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT

/datum/chemical_reaction/weedkiller
	results = list(/datum/reagent/toxin/plantbgone/weedkiller = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/ammonia = 4)
	H_ion_release = -0.05		// Push towards acidic
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT

/datum/chemical_reaction/pestkiller
	results = list(/datum/reagent/toxin/pestkiller = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/consumable/ethanol = 4)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT

/datum/chemical_reaction/drying_agent
	results = list(/datum/reagent/drying_agent = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 2, /datum/reagent/consumable/ethanol = 1, /datum/reagent/sodium = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

//////////////////////////////////// Other goon stuff ///////////////////////////////////////////

/datum/chemical_reaction/acetone
	results = list(/datum/reagent/acetone = 3)
	required_reagents = list(/datum/reagent/fuel/oil = 1, /datum/reagent/fuel = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/carpet
	results = list(/datum/reagent/carpet = 2)
	required_reagents = list(/datum/reagent/drug/space_drugs = 1, /datum/reagent/blood = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/carpet/black
	results = list(/datum/reagent/carpet/black = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/fuel/oil = 1)

/datum/chemical_reaction/carpet/blue
	results = list(/datum/reagent/carpet/blue = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/cryostylane = 1)

/datum/chemical_reaction/carpet/cyan
	results = list(/datum/reagent/carpet/cyan = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/toxin/cyanide = 1)
	//cyan = cyanide get it huehueuhuehuehheuhe

/datum/chemical_reaction/carpet/green
	results = list(/datum/reagent/carpet/green = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/ethanol/beer/green = 1)
	//make green beer by grinding up green crayons and mixing with beer

/datum/chemical_reaction/carpet/orange
	results = list(/datum/reagent/carpet/orange = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/orangejuice = 1)

/datum/chemical_reaction/carpet/purple
	results = list(/datum/reagent/carpet/purple = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/medicine/regen_jelly = 1)
	//slimes only party

/datum/chemical_reaction/carpet/red
	results = list(/datum/reagent/carpet/red = 2)
	required_reagents = list(/datum/reagent/carpet/ = 1, /datum/reagent/consumable/liquidgibs = 1)

/datum/chemical_reaction/carpet/royalblack
	results = list(/datum/reagent/carpet/royal/black = 2)
	required_reagents = list(/datum/reagent/carpet/black = 1, /datum/reagent/royal_bee_jelly = 1)

/datum/chemical_reaction/carpet/royalblue
	results = list(/datum/reagent/carpet/royal/blue = 2)
	required_reagents = list(/datum/reagent/carpet/blue = 1, /datum/reagent/royal_bee_jelly = 1)

/datum/chemical_reaction/carpet/simple_neon_white
	results = list(/datum/reagent/carpet/neon/simple_white = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/sodium = 1)

/datum/chemical_reaction/carpet/simple_neon_red
	results = list(/datum/reagent/carpet/neon/simple_red = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/toxin/mindbreaker = 1)

/datum/chemical_reaction/carpet/simple_neon_orange
	results = list(/datum/reagent/carpet/neon/simple_orange = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/consumable/vitfro = 1)

/datum/chemical_reaction/carpet/simple_neon_yellow
	results = list(/datum/reagent/carpet/neon/simple_yellow = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/stabilizing_agent = 1)

/datum/chemical_reaction/carpet/simple_neon_lime
	results = list(/datum/reagent/carpet/neon/simple_lime = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/carpet/simple_neon_green
	results = list(/datum/reagent/carpet/neon/simple_green = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/toxin/mutagen = 1)

/datum/chemical_reaction/carpet/simple_neon_cyan
	results = list(/datum/reagent/carpet/neon/simple_cyan = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/medicine/salbutamol = 1)

/datum/chemical_reaction/carpet/simple_neon_teal
	results = list(/datum/reagent/carpet/neon/simple_teal = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/drug/nicotine = 1)

/datum/chemical_reaction/carpet/simple_neon_blue
	results = list(/datum/reagent/carpet/neon/simple_blue = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/drug/happiness = 1)

/datum/chemical_reaction/carpet/simple_neon_purple
	results = list(/datum/reagent/carpet/neon/simple_purple = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/plasma_oxide = 1)

/datum/chemical_reaction/carpet/simple_neon_violet
	results = list(/datum/reagent/carpet/neon/simple_violet = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/medicine/c2/helbital = 1)

/datum/chemical_reaction/carpet/simple_neon_pink
	results = list(/datum/reagent/carpet/neon/simple_pink = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/impedrezene = 1)

/datum/chemical_reaction/carpet/simple_neon_black
	results = list(/datum/reagent/carpet/neon/simple_black = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/tinlux = 1, /datum/reagent/medicine/c2/multiver = 1)

/datum/chemical_reaction/oil
	results = list(/datum/reagent/fuel/oil = 3)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/phenol
	results = list(/datum/reagent/phenol = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/chlorine = 1, /datum/reagent/fuel/oil = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/ash
	results = list(/datum/reagent/ash = 1)
	required_reagents = list(/datum/reagent/fuel/oil = 1)
	required_temp = 480
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/datum/chemical_reaction/colorful_reagent
	results = list(/datum/reagent/colorful_reagent = 5)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/uranium/radium = 1, /datum/reagent/drug/space_drugs = 1, /datum/reagent/medicine/cryoxadone = 1, /datum/reagent/consumable/triple_citrus = 1)

/datum/chemical_reaction/life
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/c2/synthflesh = 1, /datum/reagent/blood = 1)
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/life/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life (hostile)") //defaults to HOSTILE_SPAWN

/datum/chemical_reaction/life_friendly
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/c2/synthflesh = 1, /datum/reagent/consumable/sugar = 1)
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/life_friendly/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life (friendly)", FRIENDLY_SPAWN, mob_faction = FACTION_NEUTRAL)

/datum/chemical_reaction/corgium
	required_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/colorful_reagent = 1, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/blood = 1)
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/corgium/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in rand(1, created_volume) to created_volume) // More lulz.
		new /mob/living/basic/pet/dog/corgi(location)
	..()

//monkey powder heehoo
/datum/chemical_reaction/monkey_powder
	results = list(/datum/reagent/monkey_powder = 5)
	required_reagents = list(/datum/reagent/consumable/banana = 1, /datum/reagent/consumable/nutriment=2, /datum/reagent/consumable/liquidgibs = 1)
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/monkey
	required_reagents = list(/datum/reagent/monkey_powder = 50, /datum/reagent/water = 1)
	reaction_flags = REACTION_INSTANT
	mix_message = "<span class='danger'>Expands into a brown mass before shaping itself into a monkey!.</span>"

/datum/chemical_reaction/monkey/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/mob/living/carbon/M = holder.my_atom
	var/location = get_turf(M)
	if(iscarbon(M))
		if(ismonkey(M))
			M.gib(DROP_ALL_REMAINS)
		else
			M.vomit(VOMIT_CATEGORY_BLOOD)
	new /mob/living/carbon/human/species/monkey(location, TRUE)

//water electrolysis
/datum/chemical_reaction/electrolysis
	results = list(/datum/reagent/oxygen = 2.5, /datum/reagent/hydrogen = 5)
	required_reagents = list(/datum/reagent/consumable/liquidelectricity = 1, /datum/reagent/water = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/electrolysis2
	results = list(/datum/reagent/oxygen = 2.5, /datum/reagent/hydrogen = 5)
	required_reagents = list(/datum/reagent/consumable/liquidelectricity/enriched = 1, /datum/reagent/water = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL
//butterflium
/datum/chemical_reaction/butterflium
	required_reagents = list(/datum/reagent/colorful_reagent = 1, /datum/reagent/medicine/omnizine = 1, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/consumable/nutriment = 1)
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/butterflium/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in rand(1, created_volume) to created_volume)
		new /mob/living/basic/butterfly(location)
	..()
//scream powder
/datum/chemical_reaction/scream
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/consumable/cream = 5, /datum/reagent/consumable/ethanol/lizardwine = 5 )
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/scream/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	/// List of screams to play.
	var/static/list/screams = list(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		'sound/voice/human/femalescream_5.ogg',
		'sound/voice/human/malescream_1.ogg',
		'sound/voice/human/malescream_2.ogg',
		'sound/voice/human/malescream_3.ogg',
		'sound/voice/human/malescream_4.ogg',
		'sound/voice/human/malescream_5.ogg',
		'sound/voice/human/malescream_6.ogg',
		'sound/voice/human/wilhelm_scream.ogg',
	)

	playsound(holder.my_atom, pick(screams), created_volume*5,TRUE)

/datum/chemical_reaction/hair_dye
	results = list(/datum/reagent/hair_dye = 5)
	required_reagents = list(/datum/reagent/colorful_reagent = 1, /datum/reagent/chlorine = 1, /datum/reagent/drug/space_drugs = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/barbers_aid
	results = list(/datum/reagent/barbers_aid = 5)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/uranium/radium = 1, /datum/reagent/drug/space_drugs = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/concentrated_barbers_aid
	results = list(/datum/reagent/concentrated_barbers_aid = 2)
	required_reagents = list(/datum/reagent/barbers_aid = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/baldium
	results = list(/datum/reagent/baldium = 1)
	required_reagents = list(/datum/reagent/uranium/radium = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/lye = 1)
	required_temp = 395
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/saltpetre
	results = list(/datum/reagent/saltpetre = 3)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 3)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT

/datum/chemical_reaction/lye
	results = list(/datum/reagent/lye = 3)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1)
	required_temp = 10 //So hercuri still shows life.
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/lye2
	results = list(/datum/reagent/lye = 2)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/water = 1, /datum/reagent/carbon = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/royal_bee_jelly
	results = list(/datum/reagent/royal_bee_jelly = 5)
	required_reagents = list(/datum/reagent/toxin/mutagen = 10, /datum/reagent/consumable/honey = 40)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT

/datum/chemical_reaction/laughter
	results = list(/datum/reagent/consumable/laughter = 10) // Fuck it. I'm not touching this one.
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/banana = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/plastic_polymers
	required_reagents = list(/datum/reagent/fuel/oil = 5, /datum/reagent/toxin/acid = 2, /datum/reagent/ash = 3)
	required_temp = 374 //lazily consistent with soap & other crafted objects generically created with heat.
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/plastic_polymers/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/plastic(location)

/datum/chemical_reaction/pax
	results = list(/datum/reagent/pax = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/medicine/synaptizine = 1, /datum/reagent/water = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/yuck
	results = list(/datum/reagent/yuck = 4)
	required_reagents = list(/datum/reagent/fuel = 3)
	required_container = /obj/item/food/deadmouse
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_FOOD | REACTION_TAG_DAMAGING


/datum/chemical_reaction/slimejelly
	results = list(/datum/reagent/toxin/slimejelly = 5)
	required_reagents = list(/datum/reagent/fuel/oil = 3, /datum/reagent/uranium/radium = 2, /datum/reagent/consumable/tinlux =1)
	required_container = /obj/item/food/grown/mushroom/glowshroom
	mix_message = "The mushroom's insides bubble and pop and it becomes very limp."
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT | REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_SLIME

/datum/chemical_reaction/slime_extractification
	required_reagents = list(/datum/reagent/toxin/slimejelly = 30, /datum/reagent/consumable/frostoil = 5, /datum/reagent/toxin/plasma = 5)
	mix_message = "The mixture condenses into a ball."
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime_extractification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/slime_extract/grey(location)

/datum/chemical_reaction/metalgen_imprint
	required_reagents = list(/datum/reagent/metalgen = 1, /datum/reagent/liquid_dark_matter = 1)
	results = list(/datum/reagent/metalgen = 1)
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/metalgen_imprint/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/datum/reagent/metalgen/MM = holder.has_reagent(/datum/reagent/metalgen)
	for(var/datum/reagent/R in holder.reagent_list)
		if(R.material && R.volume >= 40)
			MM.data["material"] = R.material
			holder.remove_reagent(R.type, 40)

/datum/chemical_reaction/gravitum
	required_reagents = list(/datum/reagent/wittel = 1, /datum/reagent/sorium = 10)
	results = list(/datum/reagent/gravitum = 10)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/cellulose_carbonization
	results = list(/datum/reagent/carbon = 1)
	required_reagents = list(/datum/reagent/cellulose = 1)
	required_temp = 512
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_PLANT

/datum/chemical_reaction/hydrogen_peroxide
	results = list(/datum/reagent/hydrogen_peroxide = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_DAMAGING | REACTION_TAG_BURN

/datum/chemical_reaction/acetone_oxide
	results = list(/datum/reagent/acetone_oxide = 2)
	required_reagents = list(/datum/reagent/acetone = 2, /datum/reagent/oxygen = 1, /datum/reagent/hydrogen_peroxide = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_DAMAGING | REACTION_TAG_BURN

/datum/chemical_reaction/pentaerythritol
	results = list(/datum/reagent/pentaerythritol = 2)
	required_reagents = list(/datum/reagent/acetaldehyde = 1, /datum/reagent/toxin/formaldehyde = 3, /datum/reagent/lye = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/acetaldehyde
	results = list(/datum/reagent/acetaldehyde = 3)
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/toxin/formaldehyde = 1, /datum/reagent/water = 1)
	required_temp = 450
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/holywater
	results = list(/datum/reagent/water/holywater = 1)
	required_reagents = list(/datum/reagent/water/hollowwater = 1)
	required_catalysts = list(/datum/reagent/water/holywater = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_PLANT | REACTION_TAG_OTHER

/datum/chemical_reaction/saltwater
	results = list(/datum/reagent/water/salt = 2)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/salt = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRINK | REACTION_TAG_ORGAN

/datum/chemical_reaction/exotic_stabilizer
	results = list(/datum/reagent/exotic_stabilizer = 2)
	required_reagents = list(/datum/reagent/plasma_oxide = 1,/datum/reagent/stabilizing_agent = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/silver_solidification
	required_reagents = list(/datum/reagent/silver = 20, /datum/reagent/carbon = 10)
	required_temp = 630
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/silver_solidification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/silver(location)

/datum/chemical_reaction/bone_gel
	required_reagents = list(/datum/reagent/bone_dust = 10, /datum/reagent/carbon = 10)
	required_temp = 630
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL
	mix_message = "The solution clarifies, leaving an ashy gel."

/datum/chemical_reaction/bone_gel/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/medical/bone_gel/one(location)

////Ice and water

/datum/chemical_reaction/ice
	results = list(/datum/reagent/consumable/ice = 1.09)//density
	required_reagents = list(/datum/reagent/water = 1)
	is_cold_recipe = TRUE
	required_temp = WATER_MATTERSTATE_CHANGE_TEMP-0.5 //274 So we can be sure that basic ghetto rigged stuff can freeze
	optimal_temp = 200
	overheat_temp = 0
	optimal_ph_min = 0
	optimal_ph_max = 14
	thermic_constant = 0
	H_ion_release = 0
	rate_up_lim = 50
	purity_min = 0
	mix_message = "The solution freezes up into ice!"
	reaction_flags = REACTION_COMPETITIVE
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_DRINK

/datum/chemical_reaction/water
	results = list(/datum/reagent/water = 0.92)//rough density excahnge
	required_reagents = list(/datum/reagent/consumable/ice = 1)
	required_temp = WATER_MATTERSTATE_CHANGE_TEMP+0.5
	optimal_temp = 350
	overheat_temp = NO_OVERHEAT
	optimal_ph_min = 0
	optimal_ph_max = 14
	thermic_constant = 0
	H_ion_release = 0
	rate_up_lim = 50
	purity_min = 0
	mix_message = "The ice melts back into water!"
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_DRINK

////////////////////////////////////

/datum/chemical_reaction/universal_indicator
	results = list(/datum/reagent/universal_indicator = 3)//rough density excahnge
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/ethanol = 1, /datum/reagent/iodine = 1)
	required_temp = 274
	optimal_temp = 350
	overheat_temp = NO_OVERHEAT
	optimal_ph_min = 0
	optimal_ph_max = 14
	thermic_constant = 0
	H_ion_release = 0
	rate_up_lim = 50
	purity_min = 0
	mix_message = "The mixture's colors swirl together."
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/eigenstate
	results = list(/datum/reagent/eigenstate = 1)
	required_reagents = list(/datum/reagent/bluespace = 1, /datum/reagent/stable_plasma = 1, /datum/reagent/consumable/caramel = 1)
	mix_message = "the reaction zaps suddenly!"
	mix_sound = 'sound/chemistry/bluespace.ogg'
	//FermiChem vars:
	required_temp = 350
	optimal_temp = 600
	overheat_temp = 650
	optimal_ph_min = 9
	optimal_ph_max = 12
	determin_ph_range = 5
	temp_exponent_factor = 1.5
	ph_exponent_factor = 3
	thermic_constant = 12
	H_ion_release = -0.05
	rate_up_lim = 10
	purity_min = 0.4
	reaction_flags = REACTION_HEAT_ARBITARY
	reaction_tags = REACTION_TAG_HARD | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/eigenstate/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	. = ..()
	var/turf/open/location = get_turf(holder.my_atom)
	if(reaction.data["ducts_teleported"] == TRUE) //If we teleported an duct, then we reconnect it at the end
		for(var/obj/item/stack/ducts/duct in range(location, 3))
			duct.check_attach_turf(duct.loc)

	var/datum/reagent/eigenstate/eigen = holder.has_reagent(/datum/reagent/eigenstate)
	if(!eigen)
		return
	if(location)
		eigen.location_created = location
		eigen.data["location_created"] = location

	do_sparks(5,FALSE,location)
	playsound(location, 'sound/effects/phasein.ogg', 80, TRUE)

/datum/chemical_reaction/eigenstate/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	if(!off_cooldown(holder, equilibrium, 0.5, "eigen"))
		return
	var/turf/location = get_turf(holder.my_atom)
	do_sparks(3,FALSE,location)
	playsound(location, 'sound/effects/phasein.ogg', 80, TRUE)
	for(var/mob/living/nearby_mob in range(location, 3))
		do_sparks(3,FALSE,nearby_mob)
		do_teleport(nearby_mob, get_turf(holder.my_atom), 3, no_effects=TRUE)
		nearby_mob.Knockdown(20, TRUE)
		nearby_mob.add_atom_colour("#cebfff", WASHABLE_COLOUR_PRIORITY)
		do_sparks(3,FALSE,nearby_mob)
	clear_products(holder, step_volume_added)

/datum/chemical_reaction/eigenstate/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	if(!off_cooldown(holder, equilibrium, 1, "eigen"))
		return
	var/turf/location = get_turf(holder.my_atom)
	do_sparks(3,FALSE,location)
	holder.chem_temp += 10
	playsound(location, 'sound/effects/phasein.ogg', 80, TRUE)
	for(var/obj/machinery/duct/duct in range(location, 3))
		do_teleport(duct, location, 3, no_effects=TRUE)
		equilibrium.data["ducts_teleported"] = TRUE //If we teleported a duct - call the process in
	var/lets_not_go_crazy = 15 //Teleport 15 items at max
	var/list/items = list()
	for(var/obj/item/item in range(location, 3))
		items += item
	shuffle(items)
	for(var/obj/item/item in items)
		do_teleport(item, location, 3, no_effects=TRUE)
		lets_not_go_crazy -= 1
		item.add_atom_colour("#c4b3fd", WASHABLE_COLOUR_PRIORITY)
		if(!lets_not_go_crazy)
			clear_products(holder, step_volume_added)
			return
	clear_products(holder, step_volume_added)
	holder.my_atom.audible_message(span_notice("[icon2html(holder.my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] The reaction gives out a fizz, teleporting items everywhere!"))

/datum/chemical_reaction/ants // Breeding ants together, high sugar cost makes this take a while to farm.
	results = list(/datum/reagent/ants = 3)
	required_reagents = list(/datum/reagent/ants = 2, /datum/reagent/consumable/sugar = 8)
	//FermiChem vars:
	optimal_ph_min = 3
	optimal_ph_max = 12
	required_temp = 50
	reaction_flags = REACTION_INSTANT | REAGENT_SPLITRETAINVOL
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/ant_slurry // We're basically gluing ants together with synthflesh & maint sludge to make a bigger ant.
	required_reagents = list(/datum/reagent/ants = 50, /datum/reagent/medicine/c2/synthflesh = 20, /datum/reagent/drug/maint/sludge = 5)
	required_temp = 480
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/ant_slurry/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in rand(1, created_volume) to created_volume)
		new /mob/living/basic/ant(location)
	..()

/datum/chemical_reaction/hauntium_solidification
	required_reagents = list(/datum/reagent/water/holywater = 10, /datum/reagent/hauntium = 20, /datum/reagent/iron = 1)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/hauntium_solidification/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/hauntium(location)
