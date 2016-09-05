/datum/chemical_reaction/sterilizine
	id = "sterilizine"
	results = list("sterilizine" = 3)
	required_reagents = list("ethanol" = 1, "charcoal" = 1, "chlorine" = 1)

/datum/chemical_reaction/lube
	id = "lube"
	results = list("lube" = 4)
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)

/datum/chemical_reaction/spraytan
	id = "spraytan"
	results = list("spraytan" = 2)
	required_reagents = list("orangejuice" = 1, "oil" = 1)

/datum/chemical_reaction/spraytan2
	id = "spraytan"
	results = list("spraytan" = 2)
	required_reagents = list("orangejuice" = 1, "cornoil" = 1)

/datum/chemical_reaction/impedrezene
	id = "impedrezene"
	results = list("impedrezene" = 2)
	required_reagents = list("mercury" = 1, "oxygen" = 1, "sugar" = 1)

/datum/chemical_reaction/cryptobiolin
	id = "cryptobiolin"
	results = list("cryptobiolin" = 3)
	required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)

/datum/chemical_reaction/glycerol
	id = "glycerol"
	results = list("glycerol" = 1)
	required_reagents = list("cornoil" = 3, "sacid" = 1)

/datum/chemical_reaction/sodiumchloride
	id = "sodiumchloride"
	results = list("sodiumchloride" = 3)
	required_reagents = list("water" = 0, "sodium" = 1, "chlorine" = 1)

/datum/chemical_reaction/plasmasolidification
	id = "solidplasma"
	required_reagents = list("iron" = 5, "frostoil" = 5, "plasma" = 20)
	no_mob_react = 1

/datum/chemical_reaction/plasmasolidification/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/sheet/mineral/plasma(location)

/datum/chemical_reaction/capsaicincondensation
	id = "capsaicincondensation"
	results = list("condensedcapsaicin" = 5)
	required_reagents = list("capsaicin" = 1, "ethanol" = 5)

/datum/chemical_reaction/soapification
	id = "soapification"
	required_reagents = list("liquidgibs" = 10, "lye"  = 10) // requires two scooped gib tiles
	required_temp = 374
	no_mob_react = 1

/datum/chemical_reaction/soapification/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/soap/homemade(location)

/datum/chemical_reaction/candlefication
	id = "candlefication"
	required_reagents = list("liquidgibs" = 5, "oxygen"  = 5) //
	required_temp = 374
	no_mob_react = 1

/datum/chemical_reaction/candlefication/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/candle(location)

/datum/chemical_reaction/meatification
	id = "meatification"
	required_reagents = list("liquidgibs" = 10, "nutriment" = 10, "carbon" = 10)
	no_mob_react = 1

/datum/chemical_reaction/meatification/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/meatproduct(location)
	return

/datum/chemical_reaction/carbondioxide
	id = "burningcarbon"
	results = list("co2" = 3)
	required_reagents = list("carbon" = 1, "oxygen" = 2)
	required_temp = 777 // pure carbon isn't especially reactive.

////////////////////////////////// VIROLOGY //////////////////////////////////////////

/datum/chemical_reaction/virus_food
	id = "virusfood"
	results = list("virusfood" = 15)
	required_reagents = list("water" = 5, "milk" = 5)

/datum/chemical_reaction/virus_food_mutagen
	id = "mutagenvirusfood"
	results = list("mutagenvirusfood" = 1)
	required_reagents = list("mutagen" = 1, "virusfood" = 1)

/datum/chemical_reaction/virus_food_synaptizine
	id = "synaptizinevirusfood"
	results = list("synaptizinevirusfood" = 1)
	required_reagents = list("synaptizine" = 1, "virusfood" = 1)

/datum/chemical_reaction/virus_food_plasma
	id = "plasmavirusfood"
	results = list("plasmavirusfood" = 1)
	required_reagents = list("plasma" = 1, "virusfood" = 1)

/datum/chemical_reaction/virus_food_plasma_synaptizine
	id = "weakplasmavirusfood"
	results = list("weakplasmavirusfood" = 2)
	required_reagents = list("synaptizine" = 1, "plasmavirusfood" = 1)

/datum/chemical_reaction/virus_food_mutagen_sugar
	id = "sugarvirusfood"
	results = list("sugarvirusfood" = 2)
	required_reagents = list("sugar" = 1, "mutagenvirusfood" = 1)

/datum/chemical_reaction/virus_food_mutagen_salineglucose
	id = "salineglucosevirusfood"
	results = list("sugarvirusfood" = 2)
	required_reagents = list("salglu_solution" = 1, "mutagenvirusfood" = 1)

/datum/chemical_reaction/virus_food_uranium
	id = "uraniumvirusfood"
	results = list("uraniumvirusfood" = 1)
	required_reagents = list("uranium" = 1, "virusfood" = 1)

/datum/chemical_reaction/virus_food_uranium_plasma
	id = "uraniumvirusfood_plasma"
	results = list("uraniumplasmavirusfood_unstable" = 1)
	required_reagents = list("uranium" = 5, "plasmavirusfood" = 1)

/datum/chemical_reaction/virus_food_uranium_plasma_gold
	id = "uraniumvirusfood_gold"
	results = list("uraniumplasmavirusfood_stable" = 1)
	required_reagents = list("uranium" = 10, "gold" = 10, "plasma" = 1)

/datum/chemical_reaction/virus_food_uranium_plasma_silver
	id = "uraniumvirusfood_silver"
	results = list("uraniumplasmavirusfood_stable" = 1)
	required_reagents = list("uranium" = 10, "silver" = 10, "plasma" = 1)

/datum/chemical_reaction/mix_virus
	id = "mixvirus"
	results = list("blood" = 1)
	required_reagents = list("virusfood" = 1)
	required_catalysts = list("blood" = 1)
	var/level_min = 0
	var/level_max = 2

/datum/chemical_reaction/mix_virus/on_reaction(datum/chem_holder/holder, created_volume)

	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Evolve(level_min, level_max)


/datum/chemical_reaction/mix_virus/mix_virus_2
	id = "mixvirus2"
	required_reagents = list("mutagen" = 1)
	level_min = 2
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_3
	id = "mixvirus3"
	required_reagents = list("plasma" = 1)
	level_min = 4
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_4
	id = "mixvirus4"
	required_reagents = list("uranium" = 1)
	level_min = 5
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_5
	id = "mixvirus5"
	required_reagents = list("mutagenvirusfood" = 1)
	level_min = 3
	level_max = 3

/datum/chemical_reaction/mix_virus/mix_virus_6
	id = "mixvirus6"
	required_reagents = list("sugarvirusfood" = 1)
	level_min = 4
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_7
	id = "mixvirus7"
	required_reagents = list("weakplasmavirusfood" = 1)
	level_min = 5
	level_max = 5

/datum/chemical_reaction/mix_virus/mix_virus_8
	id = "mixvirus8"
	required_reagents = list("plasmavirusfood" = 1)
	level_min = 6
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_9
	id = "mixvirus9"
	required_reagents = list("synaptizinevirusfood" = 1)
	level_min = 1
	level_max = 1

/datum/chemical_reaction/mix_virus/mix_virus_10
	id = "mixvirus10"
	required_reagents = list("uraniumvirusfood" = 5)
	level_min = 6
	level_max = 7

/datum/chemical_reaction/mix_virus/mix_virus_11
	id = "mixvirus11"
	required_reagents = list("uraniumplasmavirusfood_unstable" = 5)
	level_min = 7
	level_max = 7

/datum/chemical_reaction/mix_virus/mix_virus_12
	id = "mixvirus12"
	required_reagents = list("uraniumplasmavirusfood_stable" = 5)
	level_min = 8
	level_max = 8

/datum/chemical_reaction/mix_virus/rem_virus
	id = "remvirus"
	required_reagents = list("synaptizine" = 1, "blood" = 0)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/chem_holder/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()



////////////////////////////////// foam and foam precursor ///////////////////////////////////////////////////


/datum/chemical_reaction/surfactant
	id = "foam surfactant"
	results = list("fluorosurfactant" = 5)
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)

/datum/chemical_reaction/foam
	id = "foam"
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
	no_mob_react = 1

/datum/chemical_reaction/foam/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		M << "<span class='danger'>The solution spews out foam!</span>"
	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume*2, location, holder)
	s.start()
	holder.clear_reagents()
	return


/datum/chemical_reaction/metalfoam
	id = "metalfoam"
	required_reagents = list("aluminium" = 3, "foaming_agent" = 1, "facid" = 1)
	no_mob_react = 1

/datum/chemical_reaction/metalfoam/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		M << "<span class='danger'>The solution spews out a metallic foam!</span>"

	var/datum/effect_system/foam_spread/metal/s = new()
	s.set_up(created_volume*5, location, holder, 1)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/ironfoam
	id = "ironlfoam"
	required_reagents = list("iron" = 3, "foaming_agent" = 1, "facid" = 1)
	no_mob_react = 1

/datum/chemical_reaction/ironfoam/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		M << "<span class='danger'>The solution spews out a metallic foam!</span>"
	var/datum/effect_system/foam_spread/metal/s = new()
	s.set_up(created_volume*5, location, holder, 2)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/foaming_agent
	id = "foaming_agent"
	results = list("foaming_agent" = 1)
	required_reagents = list("lithium" = 1, "hydrogen" = 1)


/////////////////////////////// Cleaning and hydroponics /////////////////////////////////////////////////

/datum/chemical_reaction/ammonia
	id = "ammonia"
	results = list("ammonia" = 3)
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)

/datum/chemical_reaction/diethylamine
	id = "diethylamine"
	results = list("diethylamine" = 2)
	required_reagents = list ("ammonia" = 1, "ethanol" = 1)

/datum/chemical_reaction/space_cleaner
	id = "cleaner"
	results = list("cleaner" = 2)
	required_reagents = list("ammonia" = 1, "water" = 1)

/datum/chemical_reaction/plantbgone
	id = "plantbgone"
	results = list("plantbgone" = 5)
	required_reagents = list("toxin" = 1, "water" = 4)

/datum/chemical_reaction/weedkiller
	id = "weedkiller"
	results = list("weedkiller" = 5)
	required_reagents = list("toxin" = 1, "ammonia" = 4)

/datum/chemical_reaction/pestkiller
	id = "pestkiller"
	results = list("pestkiller" = 5)
	required_reagents = list("toxin" = 1, "ethanol" = 4)

/datum/chemical_reaction/drying_agent
	id = "drying_agent"
	results = list("drying_agent" = 3)
	required_reagents = list("stable_plasma" = 2, "ethanol" = 1, "sodium" = 1)

//////////////////////////////////// Other goon stuff ///////////////////////////////////////////

/datum/chemical_reaction/acetone
	id = "acetone"
	results = list("acetone" = 3)
	required_reagents = list("oil" = 1, "welding_fuel" = 1, "oxygen" = 1)

/datum/chemical_reaction/carpet
	id = "carpet"
	results = list("carpet" = 2)
	required_reagents = list("space_drugs" = 1, "blood" = 1)

/datum/chemical_reaction/oil
	id = "oil"
	results = list("oil" = 3)
	required_reagents = list("welding_fuel" = 1, "carbon" = 1, "hydrogen" = 1)

/datum/chemical_reaction/phenol
	id = "phenol"
	results = list("phenol" = 3)
	required_reagents = list("water" = 1, "chlorine" = 1, "oil" = 1)

/datum/chemical_reaction/ash
	id = "ash"
	results = list("ash" = 1)
	required_reagents = list("oil" = 1)
	required_temp = 480

/datum/chemical_reaction/colorful_reagent
	id = "colorful_reagent"
	results = list("colorful_reagent" = 5)
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "space_drugs" = 1, "cryoxadone" = 1, "triple_citrus" = 1)

/datum/chemical_reaction/life
	id = "life"
	required_reagents = list("strange_reagent" = 1, "synthflesh" = 1, "blood" = 1)
	required_temp = 374

/datum/chemical_reaction/life/on_reaction(datum/chem_holder/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life") // Lol.

/datum/chemical_reaction/corgium
	id = "corgium"
	required_reagents = list("nutriment" = 1, "colorful_reagent" = 1, "strange_reagent" = 1, "blood" = 1)
	required_temp = 374

/datum/chemical_reaction/corgium/on_reaction(datum/chem_holder/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = rand(1, created_volume), i <= created_volume, i++) // More lulz.
		new /mob/living/simple_animal/pet/dog/corgi(location)
	..()

/datum/chemical_reaction/hair_dye
	id = "hair_dye"
	results = list("hair_dye" = 5)
	required_reagents = list("colorful_reagent" = 1, "radium" = 1, "space_drugs" = 1)

/datum/chemical_reaction/barbers_aid
	id = "barbers_aid"
	results = list("barbers_aid" = 5)
	required_reagents = list("carpet" = 1, "radium" = 1, "space_drugs" = 1)

/datum/chemical_reaction/concentrated_barbers_aid
	id = "concentrated_barbers_aid"
	results = list("concentrated_barbers_aid" = 2)
	required_reagents = list("barbers_aid" = 1, "mutagen" = 1)

/datum/chemical_reaction/saltpetre
	id = "saltpetre"
	results = list("saltpetre" = 3)
	required_reagents = list("potassium" = 1, "nitrogen" = 1, "oxygen" = 3)

/datum/chemical_reaction/lye
	id = "lye"
	results = list("lye" = 3)
	required_reagents = list("sodium" = 1, "hydrogen" = 1, "oxygen" = 1)

/datum/chemical_reaction/lye2
	id = "lye"
	results = list("lye" = 2)
	required_reagents = list("ash" = 1, "water" = 1)

/datum/chemical_reaction/royal_bee_jelly
	id = "royal_bee_jelly"
	results = list("royal_bee_jelly" = 5)
	required_reagents = list("mutagen" = 10, "honey" = 40)

/datum/chemical_reaction/laughter
	id = "laughter"
	results = list("laughter" = 10) // Fuck it. I'm not touching this one.
	required_reagents = list("sugar" = 1, "banana" = 1)
