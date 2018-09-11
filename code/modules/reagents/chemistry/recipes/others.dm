
/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	results = list("sterilizine" = 3)
	required_reagents = list("ethanol" = 1, "charcoal" = 1, "chlorine" = 1)

/datum/chemical_reaction/lube
	name = "Space Lube"
	id = "lube"
	results = list("lube" = 4)
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)

/datum/chemical_reaction/spraytan
	name = "Spray Tan"
	id = "spraytan"
	results = list("spraytan" = 2)
	required_reagents = list("orangejuice" = 1, "oil" = 1)

/datum/chemical_reaction/spraytan2
	name = "Spray Tan"
	id = "spraytan"
	results = list("spraytan" = 2)
	required_reagents = list("orangejuice" = 1, "cornoil" = 1)

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	results = list("impedrezene" = 2)
	required_reagents = list("mercury" = 1, "oxygen" = 1, "sugar" = 1)

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	results = list("cryptobiolin" = 3)
	required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = "glycerol"
	results = list("glycerol" = 1)
	required_reagents = list("cornoil" = 3, "sacid" = 1)

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	results = list("sodiumchloride" = 3)
	required_reagents = list("water" = 1, "sodium" = 1, "chlorine" = 1)

/datum/chemical_reaction/plasmasolidification
	name = "Solid Plasma"
	id = "solidplasma"
	required_reagents = list("iron" = 5, "frostoil" = 5, "plasma" = 20)
	mob_react = FALSE

/datum/chemical_reaction/plasmasolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/plasma(location)

/datum/chemical_reaction/goldsolidification
	name = "Solid Gold"
	id = "solidgold"
	required_reagents = list("frostoil" = 5, "gold" = 20, "iron" = 1)
	mob_react = FALSE

/datum/chemical_reaction/goldsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/gold(location)

/datum/chemical_reaction/capsaicincondensation
	name = "Capsaicincondensation"
	id = "capsaicincondensation"
	results = list("condensedcapsaicin" = 5)
	required_reagents = list("capsaicin" = 1, "ethanol" = 5)

/datum/chemical_reaction/soapification
	name = "Soapification"
	id = "soapification"
	required_reagents = list("liquidgibs" = 10, "lye"  = 10) // requires two scooped gib tiles
	required_temp = 374
	mob_react = FALSE

/datum/chemical_reaction/soapification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/soap/homemade(location)

/datum/chemical_reaction/candlefication
	name = "Candlefication"
	id = "candlefication"
	required_reagents = list("liquidgibs" = 5, "oxygen"  = 5) //
	required_temp = 374
	mob_react = FALSE

/datum/chemical_reaction/candlefication/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/candle(location)

/datum/chemical_reaction/meatification
	name = "Meatification"
	id = "meatification"
	required_reagents = list("liquidgibs" = 10, "nutriment" = 10, "carbon" = 10)
	mob_react = FALSE

/datum/chemical_reaction/meatification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/meat/slab/meatproduct(location)
	return

/datum/chemical_reaction/carbondioxide
	name = "Direct Carbon Oxidation"
	id = "burningcarbon"
	results = list("co2" = 3)
	required_reagents = list("carbon" = 1, "oxygen" = 2)
	required_temp = 777 // pure carbon isn't especially reactive.

/datum/chemical_reaction/nitrous_oxide
	name = "Nitrous Oxide"
	id = "nitrous_oxide"
	results = list("nitrous_oxide" = 5)
	required_reagents = list("ammonia" = 2, "nitrogen" = 1, "oxygen" = 2)
	required_temp = 525

//Technically a mutation toxin
/datum/chemical_reaction/mulligan
	name = "Mulligan"
	id = "mulligan"
	results = list("mulligan" = 1)
	required_reagents = list("slime_toxin" = 1, "mutagen" = 1)


////////////////////////////////// VIROLOGY //////////////////////////////////////////

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	results = list("virusfood" = 15)
	required_reagents = list("water" = 5, "milk" = 5)

/datum/chemical_reaction/virus_food_mutagen
	name = "mutagenic agar"
	id = "mutagenvirusfood"
	results = list("mutagenvirusfood" = 1)
	required_reagents = list("mutagen" = 1, "virusfood" = 1)

/datum/chemical_reaction/virus_food_synaptizine
	name = "virus rations"
	id = "synaptizinevirusfood"
	results = list("synaptizinevirusfood" = 1)
	required_reagents = list("synaptizine" = 1, "virusfood" = 1)

/datum/chemical_reaction/virus_food_plasma
	name = "virus plasma"
	id = "plasmavirusfood"
	results = list("plasmavirusfood" = 1)
	required_reagents = list("plasma" = 1, "virusfood" = 1)

/datum/chemical_reaction/virus_food_plasma_synaptizine
	name = "weakened virus plasma"
	id = "weakplasmavirusfood"
	results = list("weakplasmavirusfood" = 2)
	required_reagents = list("synaptizine" = 1, "plasmavirusfood" = 1)

/datum/chemical_reaction/virus_food_mutagen_sugar
	name = "sucrose agar"
	id = "sugarvirusfood"
	results = list("sugarvirusfood" = 2)
	required_reagents = list("sugar" = 1, "mutagenvirusfood" = 1)

/datum/chemical_reaction/virus_food_mutagen_salineglucose
	name = "sucrose agar"
	id = "salineglucosevirusfood"
	results = list("sugarvirusfood" = 2)
	required_reagents = list("salglu_solution" = 1, "mutagenvirusfood" = 1)

/datum/chemical_reaction/virus_food_uranium
	name = "Decaying uranium gel"
	id = "uraniumvirusfood"
	results = list("uraniumvirusfood" = 1)
	required_reagents = list("uranium" = 1, "virusfood" = 1)

/datum/chemical_reaction/virus_food_uranium_plasma
	name = "Unstable uranium gel"
	id = "uraniumvirusfood_plasma"
	results = list("uraniumplasmavirusfood_unstable" = 1)
	required_reagents = list("uranium" = 5, "plasmavirusfood" = 1)

/datum/chemical_reaction/virus_food_uranium_plasma_gold
	name = "Stable uranium gel"
	id = "uraniumvirusfood_gold"
	results = list("uraniumplasmavirusfood_stable" = 1)
	required_reagents = list("uranium" = 10, "gold" = 10, "plasma" = 1)

/datum/chemical_reaction/virus_food_uranium_plasma_silver
	name = "Stable uranium gel"
	id = "uraniumvirusfood_silver"
	results = list("uraniumplasmavirusfood_stable" = 1)
	required_reagents = list("uranium" = 10, "silver" = 10, "plasma" = 1)

/datum/chemical_reaction/mix_virus
	name = "Mix Virus"
	id = "mixvirus"
	results = list("blood" = 1)
	required_reagents = list("virusfood" = 1)
	required_catalysts = list("blood" = 1)
	var/level_min = 1
	var/level_max = 2

/datum/chemical_reaction/mix_virus/on_reaction(datum/reagents/holder, created_volume)

	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Evolve(level_min, level_max)


/datum/chemical_reaction/mix_virus/mix_virus_2

	name = "Mix Virus 2"
	id = "mixvirus2"
	required_reagents = list("mutagen" = 1)
	level_min = 2
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_3

	name = "Mix Virus 3"
	id = "mixvirus3"
	required_reagents = list("plasma" = 1)
	level_min = 4
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_4

	name = "Mix Virus 4"
	id = "mixvirus4"
	required_reagents = list("uranium" = 1)
	level_min = 5
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_5

	name = "Mix Virus 5"
	id = "mixvirus5"
	required_reagents = list("mutagenvirusfood" = 1)
	level_min = 3
	level_max = 3

/datum/chemical_reaction/mix_virus/mix_virus_6

	name = "Mix Virus 6"
	id = "mixvirus6"
	required_reagents = list("sugarvirusfood" = 1)
	level_min = 4
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_7

	name = "Mix Virus 7"
	id = "mixvirus7"
	required_reagents = list("weakplasmavirusfood" = 1)
	level_min = 5
	level_max = 5

/datum/chemical_reaction/mix_virus/mix_virus_8

	name = "Mix Virus 8"
	id = "mixvirus8"
	required_reagents = list("plasmavirusfood" = 1)
	level_min = 6
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_9

	name = "Mix Virus 9"
	id = "mixvirus9"
	required_reagents = list("synaptizinevirusfood" = 1)
	level_min = 1
	level_max = 1

/datum/chemical_reaction/mix_virus/mix_virus_10

	name = "Mix Virus 10"
	id = "mixvirus10"
	required_reagents = list("uraniumvirusfood" = 1)
	level_min = 6
	level_max = 7

/datum/chemical_reaction/mix_virus/mix_virus_11

	name = "Mix Virus 11"
	id = "mixvirus11"
	required_reagents = list("uraniumplasmavirusfood_unstable" = 1)
	level_min = 7
	level_max = 7

/datum/chemical_reaction/mix_virus/mix_virus_12

	name = "Mix Virus 12"
	id = "mixvirus12"
	required_reagents = list("uraniumplasmavirusfood_stable" = 1)
	level_min = 8
	level_max = 8

/datum/chemical_reaction/mix_virus/rem_virus

	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list("synaptizine" = 1)
	required_catalysts = list("blood" = 1)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, created_volume)

	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()

/datum/chemical_reaction/mix_virus/neuter_virus
	name = "Neuter Virus"
	id = "neutervirus"
	required_reagents = list("formaldehyde" = 1)
	required_catalysts = list("blood" = 1)

/datum/chemical_reaction/mix_virus/neuter_virus/on_reaction(datum/reagents/holder, created_volume)

	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Neuter()



////////////////////////////////// foam and foam precursor ///////////////////////////////////////////////////


/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	results = list("fluorosurfactant" = 5)
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)

/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
	mob_react = FALSE

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='danger'>The solution spews out foam!</span>")
	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume*2, location, holder)
	s.start()
	holder.clear_reagents()
	return


/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	required_reagents = list("aluminium" = 3, "foaming_agent" = 1, "facid" = 1)
	mob_react = FALSE

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='danger'>The solution spews out a metallic foam!</span>")

	var/datum/effect_system/foam_spread/metal/s = new()
	s.set_up(created_volume*5, location, holder, 1)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/smart_foam
	name = "Smart Metal Foam"
	id = "smart_metal_foam"
	required_reagents = list("aluminium" = 3, "smart_foaming_agent" = 1, "facid" = 1)
	mob_react = TRUE

/datum/chemical_reaction/smart_foam/on_reaction(datum/reagents/holder, created_volume)
	var/turf/location = get_turf(holder.my_atom)
	location.visible_message("<span class='danger'>The solution spews out metallic foam!</span>")
	var/datum/effect_system/foam_spread/metal/smart/s = new()
	s.set_up(created_volume * 5, location, holder, TRUE)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	required_reagents = list("iron" = 3, "foaming_agent" = 1, "facid" = 1)
	mob_react = FALSE

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='danger'>The solution spews out a metallic foam!</span>")
	var/datum/effect_system/foam_spread/metal/s = new()
	s.set_up(created_volume*5, location, holder, 2)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	id = "foaming_agent"
	results = list("foaming_agent" = 1)
	required_reagents = list("lithium" = 1, "hydrogen" = 1)

/datum/chemical_reaction/smart_foaming_agent
	name = "Smart foaming Agent"
	id = "smart_foaming_agent"
	results = list("smart_foaming_agent" = 3)
	required_reagents = list("foaming_agent" = 3, "acetone" = 1, "iron" = 1)
	mix_message = "The solution mixes into a frothy metal foam and conforms to the walls of its container."


/////////////////////////////// Cleaning and hydroponics /////////////////////////////////////////////////

/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = "ammonia"
	results = list("ammonia" = 3)
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	results = list("diethylamine" = 2)
	required_reagents = list ("ammonia" = 1, "ethanol" = 1)

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	results = list("cleaner" = 2)
	required_reagents = list("ammonia" = 1, "water" = 1)

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	results = list("plantbgone" = 5)
	required_reagents = list("toxin" = 1, "water" = 4)

/datum/chemical_reaction/weedkiller
	name = "Weed Killer"
	id = "weedkiller"
	results = list("weedkiller" = 5)
	required_reagents = list("toxin" = 1, "ammonia" = 4)

/datum/chemical_reaction/pestkiller
	name = "Pest Killer"
	id = "pestkiller"
	results = list("pestkiller" = 5)
	required_reagents = list("toxin" = 1, "ethanol" = 4)

/datum/chemical_reaction/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	results = list("drying_agent" = 3)
	required_reagents = list("stable_plasma" = 2, "ethanol" = 1, "sodium" = 1)

//////////////////////////////////// Other goon stuff ///////////////////////////////////////////

/datum/chemical_reaction/acetone
	name = "acetone"
	id = "acetone"
	results = list("acetone" = 3)
	required_reagents = list("oil" = 1, "welding_fuel" = 1, "oxygen" = 1)

/datum/chemical_reaction/carpet
	name = "carpet"
	id = "carpet"
	results = list("carpet" = 2)
	required_reagents = list("space_drugs" = 1, "blood" = 1)

/datum/chemical_reaction/oil
	name = "Oil"
	id = "oil"
	results = list("oil" = 3)
	required_reagents = list("welding_fuel" = 1, "carbon" = 1, "hydrogen" = 1)

/datum/chemical_reaction/phenol
	name = "phenol"
	id = "phenol"
	results = list("phenol" = 3)
	required_reagents = list("water" = 1, "chlorine" = 1, "oil" = 1)

/datum/chemical_reaction/ash
	name = "Ash"
	id = "ash"
	results = list("ash" = 1)
	required_reagents = list("oil" = 1)
	required_temp = 480

/datum/chemical_reaction/colorful_reagent
	name = "colorful_reagent"
	id = "colorful_reagent"
	results = list("colorful_reagent" = 5)
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "space_drugs" = 1, "cryoxadone" = 1, "triple_citrus" = 1)

/datum/chemical_reaction/life
	name = "Life"
	id = "life"
	required_reagents = list("strange_reagent" = 1, "synthflesh" = 1, "blood" = 1)
	required_temp = 374

/datum/chemical_reaction/life/on_reaction(datum/reagents/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life") // Lol.

/datum/chemical_reaction/corgium
	name = "corgium"
	id = "corgium"
	required_reagents = list("nutriment" = 1, "colorful_reagent" = 1, "strange_reagent" = 1, "blood" = 1)
	required_temp = 374

/datum/chemical_reaction/corgium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = rand(1, created_volume), i <= created_volume, i++) // More lulz.
		new /mob/living/simple_animal/pet/dog/corgi(location)
	..()

/datum/chemical_reaction/hair_dye
	name = "hair_dye"
	id = "hair_dye"
	results = list("hair_dye" = 5)
	required_reagents = list("colorful_reagent" = 1, "radium" = 1, "space_drugs" = 1)

/datum/chemical_reaction/barbers_aid
	name = "barbers_aid"
	id = "barbers_aid"
	results = list("barbers_aid" = 5)
	required_reagents = list("carpet" = 1, "radium" = 1, "space_drugs" = 1)

/datum/chemical_reaction/concentrated_barbers_aid
	name = "concentrated_barbers_aid"
	id = "concentrated_barbers_aid"
	results = list("concentrated_barbers_aid" = 2)
	required_reagents = list("barbers_aid" = 1, "mutagen" = 1)

/datum/chemical_reaction/saltpetre
	name = "saltpetre"
	id = "saltpetre"
	results = list("saltpetre" = 3)
	required_reagents = list("potassium" = 1, "nitrogen" = 1, "oxygen" = 3)

/datum/chemical_reaction/lye
	name = "lye"
	id = "lye"
	results = list("lye" = 3)
	required_reagents = list("sodium" = 1, "hydrogen" = 1, "oxygen" = 1)

/datum/chemical_reaction/lye2
	name = "lye"
	id = "lye"
	results = list("lye" = 2)
	required_reagents = list("ash" = 1, "water" = 1, "carbon" = 1)

/datum/chemical_reaction/royal_bee_jelly
	name = "royal bee jelly"
	id = "royal_bee_jelly"
	results = list("royal_bee_jelly" = 5)
	required_reagents = list("mutagen" = 10, "honey" = 40)

/datum/chemical_reaction/laughter
	name = "laughter"
	id = "laughter"
	results = list("laughter" = 10) // Fuck it. I'm not touching this one.
	required_reagents = list("sugar" = 1, "banana" = 1)

/datum/chemical_reaction/plastic_polymers
	name = "plastic polymers"
	id = "plastic_polymers"
	required_reagents = list("oil" = 5, "sacid" = 2, "ash" = 3)
	required_temp = 374 //lazily consistent with soap & other crafted objects generically created with heat.

/datum/chemical_reaction/plastic_polymers/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/plastic(location)

/datum/chemical_reaction/pax
	name = "pax"
	id = "pax"
	results = list("pax" = 3)
	required_reagents  = list("mindbreaker" = 1, "synaptizine" = 1, "water" = 1)
