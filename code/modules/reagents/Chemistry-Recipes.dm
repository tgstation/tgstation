///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/result_amount = 0
	var/secondary = 0 // set to nonzero if secondary reaction

/datum/chemical_reaction/proc/on_reaction(var/datum/reagents/holder, var/created_volume)
	return

	//I recommend you set the result amount to the total volume of all components.

/datum/chemical_reaction/explosion_potassium
	name = "Explosion"
	id = "explosion_potassium"
	result = null
	required_reagents = list("water" = 1, "potassium" = 1)
	result_amount = 2
/datum/chemical_reaction/explosion_potassium/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/10, 1), location, 0, 0)
	e.start()
	holder.clear_reagents()
	return

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	result = null
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2

/datum/chemical_reaction/emp_pulse/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
	holder.clear_reagents()
	return
/*
silicate
	name = "Silicate"
	id = "silicate"
	result = "silicate"
	required_reagents = list("aluminium" = 1, "silicon" = 1, "oxygen" = 1)
	result_amount = 3
*/
/datum/chemical_reaction/stoxin
	name = "Sleep Toxin"
	id = "stoxin"
	result = "stoxin"
	required_reagents = list("chloralhydrate" = 1, "sugar" = 4)
	result_amount = 5

/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	result = "sterilizine"
	required_reagents = list("ethanol" = 1, "anti_toxin" = 1, "chlorine" = 1)
	result_amount = 3

/datum/chemical_reaction/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	result = "inaprovaline"
	required_reagents = list("oxygen" = 1, "carbon" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/anti_toxin
	name = "Anti-Toxin (Dylovene)"
	id = "anti_toxin"
	result = "anti_toxin"
	required_reagents = list("silicon" = 1, "potassium" = 1, "nitrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	result = "mutagen"
	required_reagents = list("radium" = 1, "phosphorus" = 1, "chlorine" = 1)
	result_amount = 3

//cyanide
//	name = "Cyanide"
//	id = "cyanide"
//	result = "cyanide"
//	required_reagents = list("hydrogen" = 1, "carbon" = 1, "nitrogen" = 1)
//	result_amount = 1

/datum/chemical_reaction/thermite
	name = "Thermite"
	id = "thermite"
	result = "thermite"
	required_reagents = list("aluminium" = 1, "iron" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	id = "lexorin"
	result = "lexorin"
	required_reagents = list("plasma" = 1, "hydrogen" = 1, "nitrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = "space_drugs"
	result = "space_drugs"
	required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)
	result_amount = 3

/datum/chemical_reaction/lube
	name = "Space Lube"
	id = "lube"
	result = "lube"
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
	result_amount = 4

/datum/chemical_reaction/pacid
	name = "Polytrinic acid"
	id = "pacid"
	result = "pacid"
	required_reagents = list("sacid" = 1, "chlorine" = 1, "potassium" = 1)
	result_amount = 3

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	result = "synaptizine"
	required_reagents = list("sugar" = 1, "lithium" = 1, "water" = 1)
	result_amount = 3

/datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	result = "hyronalin"
	required_reagents = list("radium" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	result = "arithrazine"
	required_reagents = list("hyronalin" = 1, "hydrogen" = 1)
	result_amount = 2

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	result = "impedrezene"
	required_reagents = list("mercury" = 1, "oxygen" = 1, "sugar" = 1)
	result_amount = 2

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = "kelotane"
	result = "kelotane"
	required_reagents = list("silicon" = 1, "carbon" = 1)
	result_amount = 2

/datum/chemical_reaction/leporazine
	name = "Leporazine"
	id = "leporazine"
	result = "leporazine"
	required_reagents = list("silicon" = 1, "copper" = 1)
	required_catalysts = list("plasma" = 5)
	result_amount = 2

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	result = "cryptobiolin"
	required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	result = "tricordrazine"
	required_reagents = list("inaprovaline" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/alkysine
	name = "Alkysine"
	id = "alkysine"
	result = "alkysine"
	required_reagents = list("chlorine" = 1, "nitrogen" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	id = "dexalin"
	result = "dexalin"
	required_reagents = list("oxygen" = 2)
	required_catalysts = list("plasma" = 5)
	result_amount = 1

/datum/chemical_reaction/dermaline
	name = "Dermaline"
	id = "dermaline"
	result = "dermaline"
	required_reagents = list("oxygen" = 1, "phosphorus" = 1, "kelotane" = 1)
	result_amount = 3

/datum/chemical_reaction/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	result = "dexalinp"
	required_reagents = list("dexalin" = 1, "carbon" = 1, "iron" = 1)
	result_amount = 3

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	result = "bicaridine"
	required_reagents = list("inaprovaline" = 1, "carbon" = 1)
	result_amount = 2

/datum/chemical_reaction/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	result = "hyperzine"
	required_reagents = list("sugar" = 1, "phosphorus" = 1, "sulfur" = 1,)
	result_amount = 3

/datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	result = "ryetalyn"
	required_reagents = list("arithrazine" = 1, "carbon" = 1)
	result_amount = 2

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	result = "cryoxadone"
	required_reagents = list("dexalin" = 1, "water" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	result = "clonexadone"
	required_reagents = list("cryoxadone" = 1, "sodium" = 1)
	required_catalysts = list("plasma" = 5)
	result_amount = 2

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	result = "spaceacillin"
	required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)
	result_amount = 2

/datum/chemical_reaction/imidazoline
	name = "imidazoline"
	id = "imidazoline"
	result = "imidazoline"
	required_reagents = list("carbon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	result = "ethylredoxrazine"
	required_reagents = list("oxygen" = 1, "anti_toxin" = 1, "carbon" = 1)
	result_amount = 3

/datum/chemical_reaction/ethanoloxidation
	name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
	id = "ethanoloxidation"		//	react in the body. Also it would be silly if it didn't exist.
	result = "water"
	required_reagents = list("ethylredoxrazine" = 1, "ethanol" = 1)
	result_amount = 2

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = "glycerol"
	result = "glycerol"
	required_reagents = list("cornoil" = 3, "sacid" = 1)
	result_amount = 1

/datum/chemical_reaction/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	result = "nitroglycerin"
	required_reagents = list("glycerol" = 1, "pacid" = 1, "sacid" = 1)
	result_amount = 2
/datum/chemical_reaction/nitroglycerin/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/2, 1), location, 0, 0)
	e.start()

	holder.clear_reagents()
	return

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	result = "sodiumchloride"
	required_reagents = list("sodium" = 1, "chlorine" = 1)
	result_amount = 2

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	result = null
	required_reagents = list("aluminium" = 1, "potassium" = 1, "sulfur" = 1 )
	result_amount = null
/datum/chemical_reaction/flash_powder/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	for(var/mob/living/carbon/M in viewers(world.view, location))
		switch(get_dist(M, location))
			if(0 to 3)
				if(hasvar(M, "glasses"))
					if(istype(M:glasses, /obj/item/clothing/glasses/sunglasses))
						continue

				flick("e_flash", M.flash)
				M.Weaken(5)

			if(4 to 5)
				if(hasvar(M, "glasses"))
					if(istype(M:glasses, /obj/item/clothing/glasses/sunglasses))
						continue

				flick("e_flash", M.flash)
				M.Stun(5)

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	result = null
	required_reagents = list("aluminium" = 1, "plasma" = 1, "sacid" = 1 )
	result_amount = 1
/datum/chemical_reaction/napalm/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	if(istype(T))
		T.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, created_volume)
	holder.del_reagent(id)
	return

/*
/datum/chemical_reaction/smoke
	name = "Smoke"
	id = "smoke"
	result = null
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1 )
	result_amount = null
	secondary = 1
	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		var/datum/effect/system/bad_smoke_spread/S = new /datum/effect/system/bad_smoke_spread
		S.attach(location)
		S.set_up(10, 0, location)
		playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
		spawn(0)
			S.start()
			sleep(10)
			S.start()
			sleep(10)
			S.start()
			sleep(10)
			S.start()
			sleep(10)
			S.start()
		holder.clear_reagents()
		return	*/

/datum/chemical_reaction/chemsmoke
	name = "Chemsmoke"
	id = "chemsmoke"
	result = null
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)
	result_amount = null
	secondary = 1
/datum/chemical_reaction/chemsmoke/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/chem_smoke_spread/S = new /datum/effect/effect/system/chem_smoke_spread
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		if(S)
			S.set_up(holder, 10, 0, location)
			S.start()
			sleep(10)
			S.start()
		if(holder && holder.my_atom)
			holder.clear_reagents()
	return

/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	result = "chloralhydrate"
	required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)
	result_amount = 1

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	result = "zombiepowder"
	required_reagents = list("carpotoxin" = 5, "stoxin" = 5, "copper" = 5)
	result_amount = 2

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = "rezadone"
	result = "rezadone"
	required_reagents = list("carpotoxin" = 1, "cryptobiolin" = 1, "copper" = 1)
	result_amount = 3

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	result = "mindbreaker"
	required_reagents = list("silicon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
	result_amount = 5

/datum/chemical_reaction/lipozine
	name = "Lipozine"
	id = "Lipozine"
	result = "lipozine"
	required_reagents = list("sodiumchloride" = 1, "ethanol" = 1, "radium" = 1)
	result_amount = 3

/datum/chemical_reaction/plasmasolidification
	name = "Solid Plasma"
	id = "solidplasma"
	result = null
	required_reagents = list("iron" = 5, "frostoil" = 5, "plasma" = 20)
	result_amount = 1
/datum/chemical_reaction/plasmasolidification/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/mineral/plasma(location)
	return

/datum/chemical_reaction/capsaicincondensation
	name = "Capsaicincondensation"
	id = "capsaicincondensation"
	result = "condensedcapsaicin"
	required_reagents = list("capsaicin" = 1, "ethanol" = 5)
	result_amount = 5

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	required_reagents = list("water" = 5, "milk" = 5)
	result_amount = 15

/datum/chemical_reaction/mix_virus
	name = "Mix Virus"
	id = "mixvirus"
	result = "blood"
	required_reagents = list("virusfood" = 1)
	required_catalysts = list("blood" = 1)
	var/level_min = 0
	var/level_max = 2

/datum/chemical_reaction/mix_virus/on_reaction(var/datum/reagents/holder, var/created_volume)

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

/datum/chemical_reaction/mix_virus/rem_virus

	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list("synaptizine" = 1)
	required_catalysts = list("blood" = 1)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(var/datum/reagents/holder, var/created_volume)

	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()



///////////////////////////////////////////////////////////////////////////////////

// foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	result = "fluorosurfactant"
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)
	result_amount = 5


/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	result = null
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/foam/on_reaction(var/datum/reagents/holder, var/created_volume)


	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		M << "\red The solution violently bubbles!"

	location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		M << "\red The solution spews out foam!"

	//world << "Holder volume is [holder.total_volume]"
	//for(var/datum/reagent/R in holder.reagent_list)
	//	world << "[R.name] = [R.volume]"

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 0)
	s.start()
	holder.clear_reagents()
	return

/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	result = null
	required_reagents = list("aluminium" = 3, "foaming_agent" = 1, "pacid" = 1)
	result_amount = 5

/datum/chemical_reaction/metalfoam/on_reaction(var/datum/reagents/holder, var/created_volume)


	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		M << "\red The solution spews out a metalic foam!"

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 1)
	s.start()
	return

/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list("iron" = 3, "foaming_agent" = 1, "pacid" = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(var/datum/reagents/holder, var/created_volume)


	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		M << "\red The solution spews out a metalic foam!"

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 2)
	s.start()
	return



/datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	id = "foaming_agent"
	result = "foaming_agent"
	required_reagents = list("lithium" = 1, "hydrogen" = 1)
	result_amount = 1

// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = "ammonia"
	result = "ammonia"
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	result = "diethylamine"
	required_reagents = list ("ammonia" = 1, "ethanol" = 1)
	result_amount = 2

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	result = "cleaner"
	required_reagents = list("ammonia" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	result = "plantbgone"
	required_reagents = list("toxin" = 1, "water" = 4)
	result_amount = 5

datum/chemical_reaction/weedkiller
	name = "Weed Killer"
	id = "weedkiller"
	result = "weedkiller"
	required_reagents = list("toxin" = 1, "ammonia" = 4)
	result_amount = 5

datum/chemical_reaction/pestkiller
	name = "Pest Killer"
	id = "pestkiller"
	result = "pestkiller"
	required_reagents = list("toxin" = 1, "ethanol" = 4)
	result_amount = 5

/////////////////////////////////////OLD SLIME CORE REACTIONS ///////////////////////////////
/*
/datum/chemical_reaction/slimepepper
	name = "Slime Condensedcapaicin"
	id = "m_condensedcapaicin"
	result = "condensedcapsaicin"
	required_reagents = list("sugar" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 1
/datum/chemical_reaction/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	result = "frostoil"
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 1
/datum/chemical_reaction/slimeglycerol
	name = "Slime Glycerol"
	id = "m_glycerol"
	result = "glycerol"
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 1

/datum/chemical_reaction/slime_explosion
	name = "Slime Explosion"
	id = "m_explosion"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 2
/datum/chemical_reaction/slime_explosion/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/10, 1), location, 0, 0)
	e.start()

	holder.clear_reagents()
	return
/datum/chemical_reaction/slimejam
	name = "Slime Jam"
	id = "m_jam"
	result = "slimejelly"
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 2
/datum/chemical_reaction/slimesynthi
	name = "Slime Synthetic Flesh"
	id = "m_flesh"
	result = null
	required_reagents = list("sugar" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 2
/datum/chemical_reaction/slimesynthi/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)
	return

/datum/chemical_reaction/slimeenzyme
	name = "Slime Enzyme"
	id = "m_enzyme"
	result = "enzyme"
	required_reagents = list("blood" = 1, "water" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 3
/datum/chemical_reaction/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	result = "plasma"
	required_reagents = list("sugar" = 1, "blood" = 2)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 3
/datum/chemical_reaction/slimevirus
	name = "Slime Virus"
	id = "m_virus"
	result = null
	required_reagents = list("sugar" = 1, "sacid" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 3
/datum/chemical_reaction/slimevirus/on_reaction(var/datum/reagents/holder, var/created_volume)
	holder.clear_reagents()

	var/virus = pick(/datum/disease/advance/flu, /datum/disease/advance/cold, \
	 /datum/disease/pierrot_throat, /datum/disease/fake_gbs, \
	 /datum/disease/brainrot, /datum/disease/magnitis)


	var/datum/disease/F = new virus(0)
	var/list/data = list("viruses"= list(F))
	holder.add_reagent("blood", 20, data)

	holder.add_reagent("cyanide", rand(1,10))

	return

/datum/chemical_reaction/slimeteleport
	name = "Slime Teleport"
	id = "m_tele"
	result = null
	required_reagents = list("pacid" = 2, "mutagen" = 2)
	required_catalysts = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 4
/datum/chemical_reaction/slimeteleport/on_reaction(var/datum/reagents/holder, var/created_volume)

	// Calculate new position (searches through beacons in world)
	var/obj/item/device/radio/beacon/chosen
	var/list/possible = list()
	for(var/obj/item/device/radio/beacon/W in world)
		possible += W

	if(possible.len > 0)
		chosen = pick(possible)

	if(chosen)
	// Calculate previous position for transition

		var/turf/FROM = get_turf(holder.my_atom) // the turf of origin we're travelling FROM
		var/turf/TO = get_turf(chosen)			 // the turf of origin we're travelling TO

		playsound(TO, 'sound/effects/phasein.ogg', 100, 1)

		var/list/flashers = list()
		for(var/mob/living/carbon/human/M in viewers(TO, null))
			if(M:eyecheck() <= 0)
				flick("e_flash", M.flash) // flash dose faggots
				flashers += M

		var/y_distance = TO.y - FROM.y
		var/x_distance = TO.x - FROM.x
		for (var/atom/movable/A in range(2, FROM )) // iterate thru list of mobs in the area
			if(istype(A, /obj/item/device/radio/beacon)) continue // don't teleport beacons because that's just insanely stupid
			if( A.anchored && !istype(A, /mob/dead/observer) ) continue // don't teleport anchored things (computers, tables, windows, grilles, etc) because this causes problems!
			// do teleport ghosts however because hell why not

			var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
			if(!A.Move(newloc)) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
				A.loc = locate(A.x + x_distance, A.y + y_distance, TO.z)

			spawn()
				if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
					var/mob/M = A
					if(M.client)
						var/obj/blueeffect = new /obj(src)
						blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
						blueeffect.icon = 'icons/effects/effects.dmi'
						blueeffect.icon_state = "shieldsparkles"
						blueeffect.layer = 17
						blueeffect.mouse_opacity = 0
						M.client.screen += blueeffect
						sleep(20)
						M.client.screen -= blueeffect
						qdel(blueeffect)
/datum/chemical_reaction/slimecrit
	name = "Slime Crit"
	id = "m_tele"
	result = null
	required_reagents = list("sacid" = 1, "blood" = 1)
	required_catalysts = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 4
/datum/chemical_reaction/slimecrit/on_reaction(var/datum/reagents/holder, var/created_volume)

	var/blocked = list(/mob/living/simple_animal/hostile,
		/mob/living/simple_animal/hostile/pirate,
		/mob/living/simple_animal/hostile/pirate/ranged,
		/mob/living/simple_animal/hostile/russian,
		/mob/living/simple_animal/hostile/russian/ranged,
		/mob/living/simple_animal/hostile/syndicate,
		/mob/living/simple_animal/hostile/syndicate/melee,
		/mob/living/simple_animal/hostile/syndicate/melee/space,
		/mob/living/simple_animal/hostile/syndicate/ranged,
		/mob/living/simple_animal/hostile/syndicate/ranged/space,
		/mob/living/simple_animal/hostile/alien/queen/large,
		/mob/living/simple_animal/clown
		)//exclusion list for things you don't want the reaction to create.
	var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
		if(M:eyecheck() <= 0)
			flick("e_flash", M.flash)

	for(var/i = 1, i <= created_volume, i++)
		var/chosen = pick(critters)
		var/mob/living/simple_animal/hostile/C = new chosen
		C.loc = get_turf(holder.my_atom)
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(C, pick(NORTH,SOUTH,EAST,WEST))
/datum/chemical_reaction/slimebork
	name = "Slime Bork"
	id = "m_tele"
	result = null
	required_reagents = list("sugar" = 1, "water" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 4
/datum/chemical_reaction/slimebork/on_reaction(var/datum/reagents/holder, var/created_volume)

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - /obj/item/weapon/reagent_containers/food/snacks
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
		if(M:eyecheck() <= 0)
			flick("e_flash", M.flash)

	for(var/i = 1, i <= created_volume + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))



/datum/chemical_reaction/slimechloral
	name = "Slime Chloral"
	id = "m_bunch"
	result = "chloralhydrate"
	required_reagents = list("blood" = 1, "water" = 2)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 5
/datum/chemical_reaction/slimeretro
	name = "Slime Retro"
	id = "m_xeno"
	result = null
	required_reagents = list("sugar" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 5
/datum/chemical_reaction/slimeretro/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/datum/disease/F = new /datum/disease/dna_retrovirus(0)
	var/list/data = list("viruses"= list(F))
	holder.add_reagent("blood", 20, data)
/datum/chemical_reaction/slimefoam
	name = "Slime Foam"
	id = "m_foam"
	result = null
	required_reagents = list("sacid" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 5

/datum/chemical_reaction/slimefoam/on_reaction(var/datum/reagents/holder, var/created_volume)


	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		M << "\red The solution violently bubbles!"

	location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		M << "\red The solution spews out foam!"

	//world << "Holder volume is [holder.total_volume]"
	//for(var/datum/reagent/R in holder.reagent_list)
	//	world << "[R.name] = [R.volume]"

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 0)
	s.start()
	holder.clear_reagents()
	return
*/
/////////////////////////////////////////////NEW SLIME CORE REACTIONS/////////////////////////////////////////////

//Grey
/datum/chemical_reaction/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1
/datum/chemical_reaction/slimespawn/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("\red Infused with plasma, the core begins to quiver and grow, and soon a new baby slime emerges from it!"), 1)
	var/mob/living/carbon/slime/S = new /mob/living/carbon/slime
	S.loc = get_turf(holder.my_atom)


/datum/chemical_reaction/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1
/datum/chemical_reaction/slimemonkey/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/i = 1, i <= 3, i++)
		var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
		M.loc = get_turf(holder.my_atom)

//Green
/datum/chemical_reaction/slimemutate
	name = "Mutation Toxin"
	id = "mutationtoxin"
	result = "mutationtoxin"
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/green
/datum/chemical_reaction/slimemutate/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

//Metal
/datum/chemical_reaction/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1
/datum/chemical_reaction/slimemetal/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal
	M.amount = 15
	M.loc = get_turf(holder.my_atom)
	var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel
	P.amount = 5
	P.loc = get_turf(holder.my_atom)

//Gold
/datum/chemical_reaction/slimecrit
	name = "Slime Crit"
	id = "m_tele"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = 1
/datum/chemical_reaction/slimecrit/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
	spawn(50)

		if(holder && holder.my_atom)

			var/blocked = list(/mob/living/simple_animal/hostile,
				/mob/living/simple_animal/hostile/pirate,
				/mob/living/simple_animal/hostile/pirate/ranged,
				/mob/living/simple_animal/hostile/russian,
				/mob/living/simple_animal/hostile/russian/ranged,
				/mob/living/simple_animal/hostile/syndicate,
				/mob/living/simple_animal/hostile/syndicate/melee,
				/mob/living/simple_animal/hostile/syndicate/melee/space,
				/mob/living/simple_animal/hostile/syndicate/ranged,
				/mob/living/simple_animal/hostile/syndicate/ranged/space,
				/mob/living/simple_animal/hostile/alien/queen/large,
				/mob/living/simple_animal/hostile/retaliate,
				/mob/living/simple_animal/hostile/retaliate/clown,
				/mob/living/simple_animal/hostile/mushroom,
				/mob/living/simple_animal/hostile/asteroid,
				/mob/living/simple_animal/hostile/asteroid/basilisk,
				/mob/living/simple_animal/hostile/asteroid/goldgrub,
				/mob/living/simple_animal/hostile/asteroid/goliath,
				/mob/living/simple_animal/hostile/asteroid/hivelord,
				/mob/living/simple_animal/hostile/asteroid/hivelordbrood,
				/mob/living/simple_animal/hostile/carp/holocarp
				)//exclusion list for things you don't want the reaction to create.
			var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

			var/atom/A = holder.my_atom
			var/turf/T = get_turf(A)
			var/area/my_area = get_area(T)
			var/message = "A gold slime reaction has occured in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>)"
			message += " (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>)"

			var/mob/M = get(A, /mob)
			if(M)
				message += " - Carried By: [M.real_name] ([M.key]) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"
			else
				message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

			message_admins(message, 0, 1)

			playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

			for(var/mob/living/carbon/human/H in viewers(get_turf(holder.my_atom), null))
				if(H:eyecheck() <= 0)
					flick("e_flash", H.flash)

			for(var/i = 1, i <= 5, i++)
				var/chosen = pick(critters)
				var/mob/living/simple_animal/hostile/C = new chosen
				C.faction = list("slimesummon")
				C.loc = get_turf(holder.my_atom)
				if(prob(50))
					for(var/j = 1, j <= rand(1, 3), j++)
						step(C, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/slimecritlesser
	name = "Slime Crit Lesser"
	id = "m_tele3"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = 1
/datum/chemical_reaction/slimecritlesser/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
	spawn(50)

		if(holder && holder.my_atom)

			var/blocked = list(/mob/living/simple_animal/hostile,
				/mob/living/simple_animal/hostile/pirate,
				/mob/living/simple_animal/hostile/pirate/ranged,
				/mob/living/simple_animal/hostile/russian,
				/mob/living/simple_animal/hostile/russian/ranged,
				/mob/living/simple_animal/hostile/syndicate,
				/mob/living/simple_animal/hostile/syndicate/melee,
				/mob/living/simple_animal/hostile/syndicate/melee/space,
				/mob/living/simple_animal/hostile/syndicate/ranged,
				/mob/living/simple_animal/hostile/syndicate/ranged/space,
				/mob/living/simple_animal/hostile/alien/queen/large,
				/mob/living/simple_animal/hostile/retaliate,
				/mob/living/simple_animal/hostile/retaliate/clown,
				/mob/living/simple_animal/hostile/mushroom,
				/mob/living/simple_animal/hostile/asteroid,
				/mob/living/simple_animal/hostile/asteroid/basilisk,
				/mob/living/simple_animal/hostile/asteroid/goldgrub,
				/mob/living/simple_animal/hostile/asteroid/goliath,
				/mob/living/simple_animal/hostile/asteroid/hivelord,
				/mob/living/simple_animal/hostile/asteroid/hivelordbrood,
				/mob/living/simple_animal/hostile/carp/holocarp
				)//exclusion list for things you don't want the reaction to create.
			var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

			playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

			for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
				if(M:eyecheck() <= 0)
					flick("e_flash", M.flash)

			var/chosen = pick(critters)
			var/mob/living/simple_animal/hostile/C = new chosen
			C.faction = list("neutral")
			C.loc = get_turf(holder.my_atom)

//Silver
/datum/chemical_reaction/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1
/datum/chemical_reaction/slimebork/on_reaction(var/datum/reagents/holder)

	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - /obj/item/weapon/reagent_containers/food/snacks
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
		if(M:eyecheck() <= 0)
			flick("e_flash", M.flash)

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))


/datum/chemical_reaction/slimebork2
	name = "Slime Bork 2"
	id = "m_tele4"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1
/datum/chemical_reaction/slimebork2/on_reaction(var/datum/reagents/holder)

	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/drinks) - /obj/item/weapon/reagent_containers/food/drinks
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
		if(M:eyecheck() <= 0)
			flick("e_flash", M.flash)

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))


//Blue
/datum/chemical_reaction/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	result = "frostoil"
	required_reagents = list("plasma" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/blue
	required_other = 1
/datum/chemical_reaction/slimefrost/on_reaction(var/datum/reagents/holder)
		feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

//Dark Blue
/datum/chemical_reaction/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1
/datum/chemical_reaction/slimefreeze/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
	spawn(50)
		if(holder && holder.my_atom)
			playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)
			for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
				M.bodytemperature -= 240
				M << "\blue You feel a chill!"

//Orange
/datum/chemical_reaction/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	result = "capsaicin"
	required_reagents = list("blood" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/orange
	required_other = 1
/datum/chemical_reaction/slimecasp/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

/datum/chemical_reaction/slimefire
	name = "Slime fire"
	id = "m_fire"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/orange
	required_other = 1
/datum/chemical_reaction/slimefire/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
	spawn(50)
		if(holder && holder.my_atom)
			var/turf/simulated/T = get_turf(holder.my_atom)
			if(istype(T))
				T.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 50)

//Yellow

/datum/chemical_reaction/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1
/datum/chemical_reaction/slimeoverload/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	empulse(get_turf(holder.my_atom), 3, 7)


/datum/chemical_reaction/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1
/datum/chemical_reaction/slimecell/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/stock_parts/cell/slime/P = new /obj/item/weapon/stock_parts/cell/slime
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimeglow
	name = "Slime Glow"
	id = "m_glow"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1
/datum/chemical_reaction/slimeglow/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("\red The slime begins to emit a soft light. Squeezing it will cause it to grow brightly."), 1)
	var/obj/item/device/flashlight/slime/F = new /obj/item/device/flashlight/slime
	F.loc = get_turf(holder.my_atom)

//Purple

/datum/chemical_reaction/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/purple
	required_other = 1
/datum/chemical_reaction/slimepsteroid/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimesteroid/P = new /obj/item/weapon/slimesteroid
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimejam
	name = "Slime Jam"
	id = "m_jam"
	result = "slimejelly"
	required_reagents = list("sugar" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/purple
	required_other = 1
/datum/chemical_reaction/slimejam/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")


//Dark Purple
/datum/chemical_reaction/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkpurple
	required_other = 1
/datum/chemical_reaction/slimeplasma/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/stack/sheet/mineral/plasma/P = new /obj/item/stack/sheet/mineral/plasma
	P.amount = 10
	P.loc = get_turf(holder.my_atom)

//Red
/datum/chemical_reaction/slimeglycerol
	name = "Slime Glycerol"
	id = "m_glycerol"
	result = "glycerol"
	required_reagents = list("plasma" = 1)
	result_amount = 8
	required_container = /obj/item/slime_extract/red
	required_other = 1
/datum/chemical_reaction/slimeglycerol/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")


/datum/chemical_reaction/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = 1
/datum/chemical_reaction/slimebloodlust/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/living/carbon/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid = 1
		for(var/mob/O in viewers(get_turf(holder.my_atom), null))
			O.show_message(text("\red The [slime] is driven into a frenzy!."), 1)

//Pink
/datum/chemical_reaction/slimeppotion
	name = "Slime Potion"
	id = "m_potion"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/pink
	required_other = 1
/datum/chemical_reaction/slimeppotion/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimepotion/P = new /obj/item/weapon/slimepotion
	P.loc = get_turf(holder.my_atom)


//Black
/datum/chemical_reaction/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	result = "amutationtoxin"
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/black
/datum/chemical_reaction/slimemutate2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

//Oil
/datum/chemical_reaction/slimeexplosion
	name = "Slime Explosion"
	id = "m_explosion"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/oil
	required_other = 1
/datum/chemical_reaction/slimeexplosion/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
	spawn(50)
		if(holder && holder.my_atom)
			explosion(get_turf(holder.my_atom), 1 ,3, 6)
//Light Pink
/datum/chemical_reaction/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	result = null
	result_amount = 1
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list("plasma" = 1)
	required_other = 1
/datum/chemical_reaction/slimepotion2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimepotion2/P = new /obj/item/weapon/slimepotion2
	P.loc = get_turf(holder.my_atom)
//Adamantine
/datum/chemical_reaction/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1
/datum/chemical_reaction/slimegolem/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/effect/golemrune/Z = new /obj/effect/golemrune
	Z.loc = get_turf(holder.my_atom)
	notify_ghosts("Golem rune created in [get_area(Z)].", 'sound/effects/ghost2.ogg')

//Bluespace

/datum/chemical_reaction/slimecrystal
	name = "Slime Crystal"
	id = "m_crystal"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1
/datum/chemical_reaction/slimecrystal/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if(holder.my_atom)
		var/obj/item/bluespace_crystal/BC = new(get_turf(holder.my_atom))
		BC.visible_message("<span class='notice'>The [BC.name] appears out of thin air!</span>")

//Cerulean

/datum/chemical_reaction/slimepsteroid2
	name = "Slime Steroid 2"
	id = "m_steroid2"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1
/datum/chemical_reaction/slimepsteroid2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimesteroid2/P = new /obj/item/weapon/slimesteroid2
	P.loc = get_turf(holder.my_atom)

//Sepia
/datum/chemical_reaction/slimecamera
	name = "Slime Camera"
	id = "m_camera"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1
/datum/chemical_reaction/slimecamera/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/device/camera/P = new /obj/item/device/camera
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimefilm
	name = "Slime Film"
	id = "m_film"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1
/datum/chemical_reaction/slimefilm/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/device/camera_film/P = new /obj/item/device/camera_film
	P.loc = get_turf(holder.my_atom)


//Pyrite

/datum/chemical_reaction/slimepaint
	name = "Slime Paint"
	id = "s_paint"
	result = null
	required_reagents = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/pyrite
	required_other = 1
/datum/chemical_reaction/slimepaint/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/list/paints = typesof(/obj/item/weapon/paint) - /obj/item/weapon/paint
	var/chosen = pick(paints)
	var/obj/P = new chosen
	if(P)
		P.loc = get_turf(holder.my_atom)


//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	required_reagents = list("soymilk" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1
/datum/chemical_reaction/tofu/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("soymilk" = 2, "coco" = 2, "sugar" = 2)
	result_amount = 1
/datum/chemical_reaction/chocolate_bar/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("milk" = 2, "coco" = 2, "sugar" = 2)
	result_amount = 1
/datum/chemical_reaction/chocolate_bar2/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = "hot_coco"
	result = "hot_coco"
	required_reagents = list("water" = 5, "coco" = 1)
	result_amount = 5

/datum/chemical_reaction/coffee
	name = "Coffee"
	id = "coffee"
	result = "coffee"
	required_reagents = list("coffeepowder" = 1, "water" = 5)
	result_amount = 5

/datum/chemical_reaction/tea
	name = "Tea"
	id = "tea"
	result = "tea"
	required_reagents = list("teapowder" = 1, "water" = 5)
	result_amount = 5

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	result = "soysauce"
	required_reagents = list("soymilk" = 4, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1
/datum/chemical_reaction/cheesewheel/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel(location)
	return

/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	result = null
	required_reagents = list("blood" = 5, "clonexadone" = 1)
	result_amount = 1
/datum/chemical_reaction/syntiflesh/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)
	return

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	result = "hot_ramen"
	required_reagents = list("water" = 1, "dry_ramen" = 3)
	result_amount = 3

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	result = "hell_ramen"
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
	result_amount = 6


////////////////////////////////////////// COCKTAILS //////////////////////////////////////


/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	result = "goldschlager"
	required_reagents = list("vodka" = 10, "gold" = 1)
	result_amount = 10

/datum/chemical_reaction/patron
	name = "Patron"
	id = "patron"
	result = "patron"
	required_reagents = list("tequilla" = 10, "silver" = 1)
	result_amount = 10

/datum/chemical_reaction/bilk
	name = "Bilk"
	id = "bilk"
	result = "bilk"
	required_reagents = list("milk" = 1, "beer" = 1)
	result_amount = 2

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	id = "icetea"
	result = "icetea"
	required_reagents = list("ice" = 1, "tea" = 3)
	result_amount = 4

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	result = "icecoffee"
	required_reagents = list("ice" = 1, "coffee" = 3)
	result_amount = 4

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	result = "nuka_cola"
	required_reagents = list("uranium" = 1, "cola" = 6)
	result_amount = 6

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	id = "moonshine"
	result = "moonshine"
	required_reagents = list("nutriment" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/wine
	name = "Wine"
	id = "wine"
	result = "wine"
	required_reagents = list("berryjuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	id = "spacebeer"
	result = "beer"
	required_reagents = list("flour" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/vodka
	name = "Vodka"
	id = "vodka"
	result = "vodka"
	required_reagents = list("potato" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	id = "kahlua"
	result = "kahlua"
	required_reagents = list("coffee" = 5, "sugar" = 5)
	required_catalysts = list("enzyme" = 5)
	result_amount = 5

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	id = "gintonic"
	result = "gintonic"
	required_reagents = list("gin" = 2, "tonic" = 1)
	result_amount = 3

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	result = "cubalibre"
	required_reagents = list("rum" = 2, "cola" = 1)
	result_amount = 3

/datum/chemical_reaction/martini
	name = "Classic Martini"
	id = "martini"
	result = "martini"
	required_reagents = list("gin" = 2, "vermouth" = 1)
	result_amount = 3

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	result = "vodkamartini"
	required_reagents = list("vodka" = 2, "vermouth" = 1)
	result_amount = 3

/datum/chemical_reaction/white_russian
	name = "White Russian"
	id = "whiterussian"
	result = "whiterussian"
	required_reagents = list("blackrussian" = 3, "cream" = 2)
	result_amount = 5

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	result = "whiskeycola"
	required_reagents = list("whiskey" = 2, "cola" = 1)
	result_amount = 3

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	id = "screwdrivercocktail"
	result = "screwdrivercocktail"
	required_reagents = list("vodka" = 2, "orangejuice" = 1)
	result_amount = 3

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	result = "bloodymary"
	required_reagents = list("vodka" = 1, "tomatojuice" = 2, "limejuice" = 1)
	result_amount = 4

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	result = "gargleblaster"
	required_reagents = list("vodka" = 1, "gin" = 1, "whiskey" = 1, "cognac" = 1, "limejuice" = 1)
	result_amount = 5

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	result = "bravebull"
	required_reagents = list("tequilla" = 2, "kahlua" = 1)
	result_amount = 3

/datum/chemical_reaction/tequilla_sunrise
	name = "Tequilla Sunrise"
	id = "tequillasunrise"
	result = "tequillasunrise"
	required_reagents = list("tequilla" = 2, "orangejuice" = 1)
	result_amount = 3

/datum/chemical_reaction/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	result = "toxinsspecial"
	required_reagents = list("rum" = 2, "vermouth" = 1, "plasma" = 2)
	result_amount = 5

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	id = "beepksysmash"
	result = "beepskysmash"
	required_reagents = list("limejuice" = 2, "whiskey" = 2, "iron" = 1)
	result_amount = 4

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	id = "doctordelight"
	result = "doctorsdelight"
	required_reagents = list("limejuice" = 1, "tomatojuice" = 1, "orangejuice" = 1, "cream" = 1, "tricordrazine" = 1)
	result_amount = 5

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	result = "irishcream"
	required_reagents = list("whiskey" = 2, "cream" = 1)
	result_amount = 3

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	result = "manlydorf"
	required_reagents = list ("beer" = 1, "ale" = 2)
	result_amount = 3

/datum/chemical_reaction/greenbeer
	name = "Green Beer"
	id = "greenbeer"
	result = "greenbeer"
	required_reagents = list("greencrayonpowder" = 1, "beer" = 10)
	result_amount = 10

/datum/chemical_reaction/hooch
	name = "Hooch"
	id = "hooch"
	result = "hooch"
	required_reagents = list ("sugar" = 1, "ethanol" = 2, "fuel" = 1)
	result_amount = 3

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	id = "irishcoffee"
	result = "irishcoffee"
	required_reagents = list("irishcream" = 1, "coffee" = 1)
	result_amount = 2

/datum/chemical_reaction/b52
	name = "B-52"
	id = "b52"
	result = "b52"
	required_reagents = list("irishcream" = 1, "kahlua" = 1, "cognac" = 1)
	result_amount = 3

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	result = "atomicbomb"
	required_reagents = list("b52" = 10, "uranium" = 1)
	result_amount = 10

/datum/chemical_reaction/margarita
	name = "Margarita"
	id = "margarita"
	result = "margarita"
	required_reagents = list("tequilla" = 2, "limejuice" = 1)
	result_amount = 3

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	result = "longislandicedtea"
	required_reagents = list("vodka" = 1, "gin" = 1, "tequilla" = 1, "cubalibre" = 1)
	result_amount = 4

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	result = "threemileisland"
	required_reagents = list("longislandicedtea" = 10, "uranium" = 1)
	result_amount = 10

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	result = "whiskeysoda"
	required_reagents = list("whiskey" = 2, "sodawater" = 1)
	result_amount = 3

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	id = "blackrussian"
	result = "blackrussian"
	required_reagents = list("vodka" = 3, "kahlua" = 2)
	result_amount = 5

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	id = "manhattan"
	result = "manhattan"
	required_reagents = list("whiskey" = 2, "vermouth" = 1)
	result_amount = 3

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	result = "manhattan_proj"
	required_reagents = list("manhattan" = 10, "uranium" = 1)
	result_amount = 10

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	result = "vodkatonic"
	required_reagents = list("vodka" = 2, "tonic" = 1)
	result_amount = 3

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	id = "ginfizz"
	result = "ginfizz"
	required_reagents = list("gin" = 2, "sodawater" = 1, "limejuice" = 1)
	result_amount = 4

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	result = "bahama_mama"
	required_reagents = list("rum" = 2, "orangejuice" = 2, "limejuice" = 1, "ice" = 1)
	result_amount = 6

/datum/chemical_reaction/singulo
	name = "Singulo"
	id = "singulo"
	result = "singulo"
	required_reagents = list("vodka" = 5, "radium" = 1, "wine" = 5)
	result_amount = 10

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	result = "alliescocktail"
	required_reagents = list("martini" = 1, "vodka" = 1)
	result_amount = 2

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	result = "demonsblood"
	required_reagents = list("rum" = 1, "spacemountainwind" = 1, "blood" = 1, "dr_gibb" = 1)
	result_amount = 4

/datum/chemical_reaction/booger
	name = "Booger"
	id = "booger"
	result = "booger"
	required_reagents = list("cream" = 1, "banana" = 1, "rum" = 1, "watermelonjuice" = 1)
	result_amount = 4

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	result = "antifreeze"
	required_reagents = list("vodka" = 2, "cream" = 1, "ice" = 1)
	result_amount = 4

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	id = "barefoot"
	result = "barefoot"
	required_reagents = list("berryjuice" = 1, "cream" = 1, "vermouth" = 1)
	result_amount = 3


////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	id = "sbiten"
	result = "sbiten"
	required_reagents = list("vodka" = 10, "capsaicin" = 1)
	result_amount = 10

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	id = "red_mead"
	result = "red_mead"
	required_reagents = list("blood" = 1, "mead" = 1)
	result_amount = 2

/datum/chemical_reaction/mead
	name = "Mead"
	id = "mead"
	result = "mead"
	required_reagents = list("sugar" = 1, "water" = 1)
	required_catalysts = list("enzyme" = 5)
	result_amount = 2

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	result = "iced_beer"
	required_reagents = list("beer" = 10, "frostoil" = 1)
	result_amount = 10

/datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	id = "iced_beer"
	result = "iced_beer"
	required_reagents = list("beer" = 5, "ice" = 1)
	result_amount = 6

/datum/chemical_reaction/grog
	name = "Grog"
	id = "grog"
	result = "grog"
	required_reagents = list("rum" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	result = "soy_latte"
	required_reagents = list("coffee" = 1, "soymilk" = 1)
	result_amount = 2

/datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	result = "cafe_latte"
	required_reagents = list("coffee" = 1, "milk" = 1)
	result_amount = 2

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	id = "acidspit"
	result = "acidspit"
	required_reagents = list("sacid" = 1, "wine" = 5)
	result_amount = 6

/datum/chemical_reaction/amasec
	name = "Amasec"
	id = "amasec"
	result = "amasec"
	required_reagents = list("iron" = 1, "wine" = 5, "vodka" = 5)
	result_amount = 10

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	result = "changelingsting"
	required_reagents = list("screwdrivercocktail" = 1, "limejuice" = 1, "lemonjuice" = 1)
	result_amount = 5

/datum/chemical_reaction/aloe
	name = "Aloe"
	id = "aloe"
	result = "aloe"
	required_reagents = list("irishcream" = 1, "watermelonjuice" = 1)
	result_amount = 2

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	id = "andalusia"
	result = "andalusia"
	required_reagents = list("rum" = 1, "whiskey" = 1, "lemonjuice" = 1)
	result_amount = 3

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	result = "neurotoxin"
	required_reagents = list("gargleblaster" = 1, "stoxin" = 1)
	result_amount = 2

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	id = "snowwhite"
	result = "snowwhite"
	required_reagents = list("beer" = 1, "lemon_lime" = 1)
	result_amount = 2

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	result = "irishcarbomb"
	required_reagents = list("ale" = 1, "irishcream" = 1)
	result_amount = 2

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	result = "syndicatebomb"
	required_reagents = list("beer" = 1, "whiskeycola" = 1)
	result_amount = 2

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	result = "erikasurprise"
	required_reagents = list("ale" = 1, "limejuice" = 1, "whiskey" = 1, "banana" = 1, "ice" = 1)
	result_amount = 5

/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	result = "devilskiss"
	required_reagents = list("blood" = 1, "kahlua" = 1, "rum" = 1)
	result_amount = 3

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	id = "hippiesdelight"
	result = "hippiesdelight"
	required_reagents = list("mushroomhallucinogen" = 1, "gargleblaster" = 1)
	result_amount = 2

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	id = "bananahonk"
	result = "bananahonk"
	required_reagents = list("banana" = 1, "cream" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/silencer
	name = "Silencer"
	id = "silencer"
	result = "silencer"
	required_reagents = list("nothing" = 1, "cream" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	result = "driestmartini"
	required_reagents = list("nothing" = 1, "gin" = 1)
	result_amount = 2

/datum/chemical_reaction/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	result = "thirteenloko"
	required_reagents = list("vodka" = 1, "coffee" = 1, "limejuice" = 1)
	result_amount = 3
