
/datum/chemical_reaction/sterilizine
	results = list(/datum/reagent/space_cleaner/sterilizine = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/c2/multiver = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/lube
	results = list(/datum/reagent/lube = 4)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/silicon = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/spraytan
	results = list(/datum/reagent/spraytan = 2)
	required_reagents = list(/datum/reagent/consumable/orangejuice = 1, /datum/reagent/fuel/oil = 1)

/datum/chemical_reaction/spraytan2
	results = list(/datum/reagent/spraytan = 2)
	required_reagents = list(/datum/reagent/consumable/orangejuice = 1, /datum/reagent/consumable/cornoil = 1)

/datum/chemical_reaction/impedrezene
	results = list(/datum/reagent/impedrezene = 2)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/cryptobiolin
	results = list(/datum/reagent/cryptobiolin = 3)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/glycerol
	results = list(/datum/reagent/glycerol = 1)
	required_reagents = list(/datum/reagent/consumable/cornoil = 3, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/sodiumchloride
	results = list(/datum/reagent/consumable/sodiumchloride = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/sodium = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/plasmasolidification
	required_reagents = list(/datum/reagent/iron = 5, /datum/reagent/consumable/frostoil = 5, /datum/reagent/toxin/plasma = 20)
	mob_react = FALSE

/datum/chemical_reaction/plasmasolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/plasma(location)

/datum/chemical_reaction/goldsolidification
	required_reagents = list(/datum/reagent/consumable/frostoil = 5, /datum/reagent/gold = 20, /datum/reagent/iron = 1)
	mob_react = FALSE

/datum/chemical_reaction/goldsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/gold(location)

/datum/chemical_reaction/uraniumsolidification
	required_reagents = list(/datum/reagent/consumable/frostoil = 5, /datum/reagent/uranium = 20, /datum/reagent/potassium = 1)
	mob_react = FALSE

/datum/chemical_reaction/uraniumsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/uranium(location)

/datum/chemical_reaction/capsaicincondensation
	results = list(/datum/reagent/consumable/condensedcapsaicin = 5)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/ethanol = 5)

/datum/chemical_reaction/soapification
	required_reagents = list(/datum/reagent/liquidgibs = 10, /datum/reagent/lye  = 10) // requires two scooped gib tiles
	required_temp = 374
	mob_react = FALSE

/datum/chemical_reaction/soapification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/soap/homemade(location)

/datum/chemical_reaction/omegasoapification
	required_reagents = list(/datum/reagent/consumable/potato_juice = 10, /datum/reagent/consumable/ethanol/lizardwine = 10, /datum/reagent/monkey_powder = 10, /datum/reagent/drug/krokodil = 10, /datum/reagent/toxin/acid/nitracid = 10, /datum/reagent/baldium = 10, /datum/reagent/consumable/ethanol/hooch = 10, /datum/reagent/bluespace = 10, /datum/reagent/drug/pumpup = 10, /datum/reagent/consumable/space_cola = 10)
	required_temp = 999
	mob_react = FALSE

/datum/chemical_reaction/omegasoapification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/soap/omega(location)

/datum/chemical_reaction/candlefication
	required_reagents = list(/datum/reagent/liquidgibs = 5, /datum/reagent/oxygen  = 5) //
	required_temp = 374
	mob_react = FALSE

/datum/chemical_reaction/candlefication/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/candle(location)

/datum/chemical_reaction/meatification
	required_reagents = list(/datum/reagent/liquidgibs = 10, /datum/reagent/consumable/nutriment = 10, /datum/reagent/carbon = 10)
	mob_react = FALSE

/datum/chemical_reaction/meatification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/meat/slab/meatproduct(location)
	return

/datum/chemical_reaction/carbondioxide
	results = list(/datum/reagent/carbondioxide = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/oxygen = 2)
	required_temp = 777 // pure carbon isn't especially reactive.

/datum/chemical_reaction/nitrous_oxide
	results = list(/datum/reagent/nitrous_oxide = 5)
	required_reagents = list(/datum/reagent/ammonia = 2, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 2)
	required_temp = 525

//Technically a mutation toxin
/datum/chemical_reaction/mulligan
	results = list(/datum/reagent/mulligan = 1)
	required_reagents = list(/datum/reagent/mutationtoxin/jelly = 1, /datum/reagent/toxin/mutagen = 1)


////////////////////////////////// VIROLOGY //////////////////////////////////////////

/datum/chemical_reaction/virus_food
	results = list(/datum/reagent/consumable/virus_food = 15)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/milk = 5)

/datum/chemical_reaction/virus_food_mutagen
	results = list(/datum/reagent/toxin/mutagen/mutagenvirusfood = 1)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/consumable/virus_food = 1)

/datum/chemical_reaction/virus_food_synaptizine
	results = list(/datum/reagent/medicine/synaptizine/synaptizinevirusfood = 1)
	required_reagents = list(/datum/reagent/medicine/synaptizine = 1, /datum/reagent/consumable/virus_food = 1)

/datum/chemical_reaction/virus_food_plasma
	results = list(/datum/reagent/toxin/plasma/plasmavirusfood = 1)
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/consumable/virus_food = 1)

/datum/chemical_reaction/virus_food_plasma_synaptizine
	results = list(/datum/reagent/toxin/plasma/plasmavirusfood/weak = 2)
	required_reagents = list(/datum/reagent/medicine/synaptizine = 1, /datum/reagent/toxin/plasma/plasmavirusfood = 1)

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

/datum/chemical_reaction/mix_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
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

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()

/datum/chemical_reaction/mix_virus/neuter_virus
	required_reagents = list(/datum/reagent/toxin/formaldehyde = 1)
	required_catalysts = list(/datum/reagent/blood = 1)

/datum/chemical_reaction/mix_virus/neuter_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Neuter()



////////////////////////////////// foam and foam precursor ///////////////////////////////////////////////////


/datum/chemical_reaction/surfactant
	results = list(/datum/reagent/fluorosurfactant = 5)
	required_reagents = list(/datum/reagent/fluorine = 2, /datum/reagent/carbon = 2, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/foam
	required_reagents = list(/datum/reagent/fluorosurfactant = 1, /datum/reagent/water = 1)
	mob_react = FALSE

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	holder.create_foam(/datum/effect_system/foam_spread,2*created_volume,notification="<span class='danger'>The solution spews out foam!</span>")

/datum/chemical_reaction/metalfoam
	required_reagents = list(/datum/reagent/aluminium = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/toxin/acid/fluacid = 1)
	mob_react = FALSE

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	holder.create_foam(/datum/effect_system/foam_spread/metal,5*created_volume,1,"<span class='danger'>The solution spews out a metallic foam!</span>")

/datum/chemical_reaction/smart_foam
	required_reagents = list(/datum/reagent/aluminium = 3, /datum/reagent/smart_foaming_agent = 1, /datum/reagent/toxin/acid/fluacid = 1)
	mob_react = TRUE

/datum/chemical_reaction/smart_foam/on_reaction(datum/reagents/holder, created_volume)
	holder.create_foam(/datum/effect_system/foam_spread/metal/smart,5*created_volume,1,"<span class='danger'>The solution spews out metallic foam!</span>")

/datum/chemical_reaction/ironfoam
	required_reagents = list(/datum/reagent/iron = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/toxin/acid/fluacid = 1)
	mob_react = FALSE

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	holder.create_foam(/datum/effect_system/foam_spread/metal,5*created_volume,2,"<span class='danger'>The solution spews out a metallic foam!</span>")

/datum/chemical_reaction/foaming_agent
	results = list(/datum/reagent/foaming_agent = 1)
	required_reagents = list(/datum/reagent/lithium = 1, /datum/reagent/hydrogen = 1)

/datum/chemical_reaction/smart_foaming_agent
	results = list(/datum/reagent/smart_foaming_agent = 3)
	required_reagents = list(/datum/reagent/foaming_agent = 3, /datum/reagent/acetone = 1, /datum/reagent/iron = 1)
	mix_message = "The solution mixes into a frothy metal foam and conforms to the walls of its container."


/////////////////////////////// Cleaning and hydroponics /////////////////////////////////////////////////

/datum/chemical_reaction/ammonia
	results = list(/datum/reagent/ammonia = 3)
	required_reagents = list(/datum/reagent/hydrogen = 3, /datum/reagent/nitrogen = 1)

/datum/chemical_reaction/diethylamine
	results = list(/datum/reagent/diethylamine = 2)
	required_reagents = list (/datum/reagent/ammonia = 1, /datum/reagent/consumable/ethanol = 1)

/datum/chemical_reaction/space_cleaner
	results = list(/datum/reagent/space_cleaner = 2)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/plantbgone
	results = list(/datum/reagent/toxin/plantbgone = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/water = 4)

/datum/chemical_reaction/weedkiller
	results = list(/datum/reagent/toxin/plantbgone/weedkiller = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/ammonia = 4)

/datum/chemical_reaction/pestkiller
	results = list(/datum/reagent/toxin/pestkiller = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/consumable/ethanol = 4)

/datum/chemical_reaction/drying_agent
	results = list(/datum/reagent/drying_agent = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 2, /datum/reagent/consumable/ethanol = 1, /datum/reagent/sodium = 1)

//////////////////////////////////// Other goon stuff ///////////////////////////////////////////

/datum/chemical_reaction/acetone
	results = list(/datum/reagent/acetone = 3)
	required_reagents = list(/datum/reagent/fuel/oil = 1, /datum/reagent/fuel = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/carpet
	results = list(/datum/reagent/carpet = 2)
	required_reagents = list(/datum/reagent/drug/space_drugs = 1, /datum/reagent/blood = 1)

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
	required_reagents = list(/datum/reagent/carpet/ = 1, /datum/reagent/liquidgibs = 1)

/datum/chemical_reaction/carpet/royalblack
	results = list(/datum/reagent/carpet/royal/black = 2)
	required_reagents = list(/datum/reagent/carpet/black = 1, /datum/reagent/royal_bee_jelly = 1)

/datum/chemical_reaction/carpet/royalblue
	results = list(/datum/reagent/carpet/royal/blue = 2)
	required_reagents = list(/datum/reagent/carpet/blue = 1, /datum/reagent/royal_bee_jelly = 1)


/datum/chemical_reaction/oil
	results = list(/datum/reagent/fuel/oil = 3)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1)

/datum/chemical_reaction/phenol
	results = list(/datum/reagent/phenol = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/chlorine = 1, /datum/reagent/fuel/oil = 1)

/datum/chemical_reaction/ash
	results = list(/datum/reagent/ash = 1)
	required_reagents = list(/datum/reagent/fuel/oil = 1)
	required_temp = 480

/datum/chemical_reaction/colorful_reagent
	results = list(/datum/reagent/colorful_reagent = 5)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/uranium/radium = 1, /datum/reagent/drug/space_drugs = 1, /datum/reagent/medicine/cryoxadone = 1, /datum/reagent/consumable/triple_citrus = 1)

/datum/chemical_reaction/life
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/c2/synthflesh = 1, /datum/reagent/blood = 1)
	required_temp = 374

/datum/chemical_reaction/life/on_reaction(datum/reagents/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life (hostile)") //defaults to HOSTILE_SPAWN

/datum/chemical_reaction/life_friendly
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/c2/synthflesh = 1, /datum/reagent/consumable/sugar = 1)
	required_temp = 374

/datum/chemical_reaction/life_friendly/on_reaction(datum/reagents/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life (friendly)", FRIENDLY_SPAWN)

/datum/chemical_reaction/corgium
	required_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/colorful_reagent = 1, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/blood = 1)
	required_temp = 374

/datum/chemical_reaction/corgium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = rand(1, created_volume), i <= created_volume, i++) // More lulz.
		new /mob/living/simple_animal/pet/dog/corgi(location)
	..()

//monkey powder heehoo
/datum/chemical_reaction/monkey_powder
	results = list(/datum/reagent/monkey_powder = 3)
	required_reagents = list(/datum/reagent/consumable/banana = 1, /datum/reagent/consumable/nutriment=2,/datum/reagent/liquidgibs = 1)

/datum/chemical_reaction/monkey
	required_reagents = list(/datum/reagent/monkey_powder = 30, /datum/reagent/water = 1)

/datum/chemical_reaction/monkey/on_reaction(datum/reagents/holder, created_volume)
	var/obj/item/reagent_containers/food/snacks/monkeycube/cube = holder.my_atom
	if(istype(cube))
		cube.Expand()
	else
		var/location = get_turf(holder.my_atom)
		new /mob/living/carbon/monkey(location)

//water electrolysis
/datum/chemical_reaction/electrolysis
	results = list(/datum/reagent/oxygen = 1.5, /datum/reagent/hydrogen = 3)
	required_reagents = list(/datum/reagent/consumable/liquidelectricity = 1, /datum/reagent/water = 5)

//butterflium
/datum/chemical_reaction/butterflium
	required_reagents = list(/datum/reagent/colorful_reagent = 1, /datum/reagent/medicine/omnizine = 1, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/consumable/nutriment = 1)

/datum/chemical_reaction/butterflium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = rand(1, created_volume), i <= created_volume, i++)
		new /mob/living/simple_animal/butterfly(location)
	..()
//scream powder
/datum/chemical_reaction/scream
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/consumable/cream = 5, /datum/reagent/consumable/ethanol/lizardwine = 5	)
	required_temp = 374

/datum/chemical_reaction/scream/on_reaction(datum/reagents/holder, created_volume)
	playsound(holder.my_atom, pick(list( 'sound/voice/human/malescream_1.ogg', 'sound/voice/human/malescream_2.ogg', 'sound/voice/human/malescream_3.ogg', 'sound/voice/human/malescream_4.ogg', 'sound/voice/human/malescream_5.ogg', 'sound/voice/human/malescream_6.ogg', 'sound/voice/human/femalescream_1.ogg', 'sound/voice/human/femalescream_2.ogg', 'sound/voice/human/femalescream_3.ogg', 'sound/voice/human/femalescream_4.ogg', 'sound/voice/human/femalescream_5.ogg', 'sound/voice/human/wilhelm_scream.ogg')), created_volume*5,TRUE)

/datum/chemical_reaction/hair_dye
	results = list(/datum/reagent/hair_dye = 5)
	required_reagents = list(/datum/reagent/colorful_reagent = 1, /datum/reagent/uranium/radium = 1, /datum/reagent/drug/space_drugs = 1)

/datum/chemical_reaction/barbers_aid
	results = list(/datum/reagent/barbers_aid = 5)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/uranium/radium = 1, /datum/reagent/drug/space_drugs = 1)

/datum/chemical_reaction/concentrated_barbers_aid
	results = list(/datum/reagent/concentrated_barbers_aid = 2)
	required_reagents = list(/datum/reagent/barbers_aid = 1, /datum/reagent/toxin/mutagen = 1)

/datum/chemical_reaction/baldium
	results = list(/datum/reagent/baldium = 1)
	required_reagents = list(/datum/reagent/uranium/radium = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/lye = 1)
	required_temp = 395

/datum/chemical_reaction/saltpetre
	results = list(/datum/reagent/saltpetre = 3)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 3)

/datum/chemical_reaction/lye
	results = list(/datum/reagent/lye = 3)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/lye2
	results = list(/datum/reagent/lye = 2)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/water = 1, /datum/reagent/carbon = 1)

/datum/chemical_reaction/royal_bee_jelly
	results = list(/datum/reagent/royal_bee_jelly = 5)
	required_reagents = list(/datum/reagent/toxin/mutagen = 10, /datum/reagent/consumable/honey = 40)

/datum/chemical_reaction/laughter
	results = list(/datum/reagent/consumable/laughter = 10) // Fuck it. I'm not touching this one.
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/banana = 1)

/datum/chemical_reaction/plastic_polymers
	required_reagents = list(/datum/reagent/fuel/oil = 5, /datum/reagent/toxin/acid = 2, /datum/reagent/ash = 3)
	required_temp = 374 //lazily consistent with soap & other crafted objects generically created with heat.

/datum/chemical_reaction/plastic_polymers/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/plastic(location)

/datum/chemical_reaction/pax
	results = list(/datum/reagent/pax = 3)
	required_reagents  = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/medicine/synaptizine = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/yuck
	results = list(/datum/reagent/yuck = 4)
	required_reagents = list(/datum/reagent/fuel = 3)
	required_container = /obj/item/reagent_containers/food/snacks/deadmouse


/datum/chemical_reaction/slimejelly
	results = list(/datum/reagent/toxin/slimejelly = 5)
	required_reagents = list(/datum/reagent/fuel/oil = 3, /datum/reagent/uranium/radium = 2, /datum/reagent/consumable/tinlux =1)
	required_container = /obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom
	mix_message = "The mushroom's insides bubble and pop and it becomes very limp."

/datum/chemical_reaction/slime_extractification
	required_reagents = list(/datum/reagent/toxin/slimejelly = 30, /datum/reagent/consumable/frostoil = 5, /datum/reagent/toxin/plasma = 5)
	mix_message = "The mixture condenses into a ball."

/datum/chemical_reaction/slime_extractification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/slime_extract/grey(location)

/datum/chemical_reaction/metalgen_imprint
	required_reagents = list(/datum/reagent/metalgen = 1, /datum/reagent/liquid_dark_matter = 1)
	results = list(/datum/reagent/metalgen = 1)

/datum/chemical_reaction/metalgen_imprint/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/metalgen/MM = holder.get_reagent(/datum/reagent/metalgen)
	for(var/datum/reagent/R in holder.reagent_list)
		if(R.material && R.volume >= 40)
			MM.data["material"] = R.material
			holder.remove_reagent(R.type, 40)

/datum/chemical_reaction/gravitum
	required_reagents = list(/datum/reagent/wittel = 1, /datum/reagent/sorium = 10)
	results = list(/datum/reagent/gravitum = 10)

/datum/chemical_reaction/cellulose_carbonization
	results = list(/datum/reagent/carbon = 1)
	required_reagents = list(/datum/reagent/cellulose = 1)
	required_temp = 512

/datum/chemical_reaction/hydrogen_peroxide
	results = list(/datum/reagent/hydrogen_peroxide = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/acetone_oxide
	results = list(/datum/reagent/acetone_oxide = 2)
	required_reagents = list(/datum/reagent/acetone = 2, /datum/reagent/oxygen = 1, /datum/reagent/hydrogen_peroxide = 1)

/datum/chemical_reaction/pentaerythritol
	results = list(/datum/reagent/pentaerythritol = 2)
	required_reagents = list(/datum/reagent/acetaldehyde = 1, /datum/reagent/toxin/formaldehyde = 3, /datum/reagent/water = 1 )

/datum/chemical_reaction/acetaldehyde
	results = list(/datum/reagent/acetaldehyde = 3)
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/toxin/formaldehyde = 1, /datum/reagent/water = 1)
	required_temp = 450

/datum/chemical_reaction/holywater
	results = list(/datum/reagent/water/holywater = 1)
	required_reagents = list(/datum/reagent/water/hollowwater = 1)
	required_catalysts = list(/datum/reagent/water/holywater = 1)

/datum/chemical_reaction/gravy
	results = list(/datum/reagent/consumable/gravy = 3)
	required_reagents = list(/datum/reagent/consumable/milk = 1, /datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/flour = 1)

/datum/chemical_reaction/exotic_stabilizer
	results = list(/datum/reagent/exotic_stabilizer = 2)
	required_reagents = list(/datum/reagent/plasma_oxide = 1,/datum/reagent/stabilizing_agent = 1)
