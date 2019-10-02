/datum/chemical_reaction/fermi
	mix_sound = 'sound/effects/bubbles.ogg'

//Called for every reaction step
/datum/chemical_reaction/fermi/proc/FermiCreate(holder)
	return

//Called when reaction STOP_PROCESSING
/datum/chemical_reaction/fermi/proc/FermiFinish(datum/reagents/holder)
	return

//Called when temperature is above a certain threshold, or if purity is too low.
/datum/chemical_reaction/fermi/proc/FermiExplode(datum/reagents, var/atom/my_atom, volume, temp, pH, Exploding = FALSE)
	if (Exploding == TRUE)
		return

	if(!pH)//Dunno how things got here without a pH, but just in case
		pH = 7
	var/ImpureTot = 0
	var/turf/T = get_turf(my_atom)

	if(temp>500)//if hot, start a fire
		switch(temp)
			if (500 to 750)
				for(var/turf/turf in range(1,T))
					new /obj/effect/hotspot(turf)

			if (751 to 1100)
				for(var/turf/turf in range(2,T))
					new /obj/effect/hotspot(turf)

			if (1101 to 1500) //If you're crafty
				for(var/turf/turf in range(3,T))
					new /obj/effect/hotspot(turf)

			if (1501 to 2500) //requested
				for(var/turf/turf in range(4,T))
					new /obj/effect/hotspot(turf)

			if (2501 to 5000)
				for(var/turf/turf in range(5,T))
					new /obj/effect/hotspot(turf)

			if (5001 to INFINITY)
				for(var/turf/turf in range(6,T))
					new /obj/effect/hotspot(turf)


	message_admins("Fermi explosion at [T], with a temperature of [temp], pH of [pH], Impurity tot of [ImpureTot].")
	log_game("Fermi explosion at [T], with a temperature of [temp], pH of [pH], Impurity tot of [ImpureTot].")
	var/datum/reagents/R = new/datum/reagents(3000)//Hey, just in case.
	var/datum/effect_system/smoke_spread/chem/s = new()
	R.my_atom = my_atom //Give the gas a fingerprint

	for (var/datum/reagent/reagent in my_atom.reagents.reagent_list) //make gas for reagents, has to be done this way, otherwise it never stops Exploding
		R.add_reagent(reagent.id, reagent.volume/3) //Seems fine? I think I fixed the infinite explosion bug.

		if (reagent.purity < 0.6)
			ImpureTot = (ImpureTot + (1-reagent.purity)) / 2

	if(pH < 4) //if acidic, make acid spray
		R.add_reagent("fermiAcid", (volume/3))
	if(R.reagent_list)
		s.set_up(R, (volume/5), my_atom)
		s.start()

	if (pH > 10) //if alkaline, small explosion.
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round((volume/30)*(pH-9)), T, 0, 0)
		e.start()

	if(!ImpureTot == 0) //If impure, v.small emp (0.6 or less)
		ImpureTot *= volume
		var/empVol = CLAMP (volume/10, 0, 15)
		empulse(T, empVol, ImpureTot/10, 1)

	my_atom.reagents.clear_reagents() //just in case
	return

/datum/chemical_reaction/fermi/eigenstate
	name = "Eigenstasium"
	id = "eigenstate"
	results = list("eigenstate" = 0.1)
	required_reagents = list("bluespace" = 0.1, "stable_plasma" = 0.1, "sugar" = 0.1)
	mix_message = "the reaction zaps suddenly!"
	//FermiChem vars:
	OptimalTempMin 		= 350 // Lower area of bell curve for determining heat based rate reactions
	OptimalTempMax		= 600 // Upper end for above
	ExplodeTemp			= 650 //Temperature at which reaction explodes
	OptimalpHMin		= 7 // Lowest value of pH determining pH a 1 value for pH based rate reactions (Plateu phase)
	OptimalpHMax		= 9 // Higest value for above
	ReactpHLim			= 5 // How far out pH wil react, giving impurity place (Exponential phase)
	CatalystFact		= 0 // How much the catalyst affects the reaction (0 = no catalyst)
	CurveSharpT 		= 1.5 // How sharp the temperature exponential curve is (to the power of value)
	CurveSharppH 		= 3 // How sharp the pH exponential curve is (to the power of value)
	ThermicConstant		= 10 //Temperature change per 1u produced
	HIonRelease 		= -0.02 //pH change per 1u reaction
	RateUpLim 			= 3 //Optimal/max rate possible if all conditions are perfect
	FermiChem 			= TRUE//If the chemical uses the Fermichem reaction mechanics
	FermiExplode 		= FALSE //If the chemical explodes in a special way
	PurityMin			= 0.4 //The minimum purity something has to be above, otherwise it explodes.

/datum/chemical_reaction/fermi/eigenstate/FermiFinish(datum/reagents/holder, var/atom/my_atom)//Strange how this doesn't work but the other does.
	if(!locate(/datum/reagent/fermi/eigenstate) in my_atom.reagents.reagent_list)
		return
	var/turf/open/location = get_turf(my_atom)
	var/datum/reagent/fermi/eigenstate/E = locate(/datum/reagent/fermi/eigenstate) in my_atom.reagents.reagent_list
	if(location)
		E.location_created = location
		E.data.["location_created"] = location


//serum
/datum/chemical_reaction/fermi/SDGF
	name = "Synthetic-derived growth factor"
	id = "SDGF"
	results = list("SDGF" = 0.3)
	required_reagents = list("stable_plasma" = 0.15, "clonexadone" = 0.15, "uranium" = 0.15, "synthflesh" = 0.15)
	mix_message = "the reaction gives off a blorble!"
	required_temp = 1
	//FermiChem vars:
	OptimalTempMin 		= 600 		// Lower area of bell curve for determining heat based rate reactions
	OptimalTempMax 		= 630 		// Upper end for above
	ExplodeTemp 		= 635 		// Temperature at which reaction explodes
	OptimalpHMin 		= 3 		// Lowest value of pH determining pH a 1 value for pH based rate reactions (Plateu phase)
	OptimalpHMax 		= 3.5 		// Higest value for above
	ReactpHLim 			= 2 		// How far out pH wil react, giving impurity place (Exponential phase)
	CatalystFact 		= 0 		// How much the catalyst affects the reaction (0 = no catalyst)
	CurveSharpT 		= 4 		// How sharp the temperature exponential curve is (to the power of value)
	CurveSharppH 		= 4 		// How sharp the pH exponential curve is (to the power of value)
	ThermicConstant		= -10 		// Temperature change per 1u produced
	HIonRelease 		= 0.02 		// pH change per 1u reaction (inverse for some reason)
	RateUpLim 			= 1 		// Optimal/max rate possible if all conditions are perfect
	FermiChem 			= TRUE		// If the chemical uses the Fermichem reaction mechanics
	FermiExplode 		= TRUE		// If the chemical explodes in a special way
	PurityMin 			= 0.2

/datum/chemical_reaction/fermi/SDGF/FermiExplode(datum/reagents, var/atom/my_atom, volume, temp, pH)//Spawns an angery teratoma!
	var/turf/T = get_turf(my_atom)
	var/mob/living/simple_animal/slime/S = new(T,"green")
	S.damage_coeff = list(BRUTE = 0.9 , BURN = 2, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	S.name = "Living teratoma"
	S.real_name = "Living teratoma"
	S.rabid = 1//Make them an angery boi
	S.color = "#810010"
	my_atom.reagents.clear_reagents()
	var/list/seen = viewers(8, get_turf(my_atom))
	for(var/mob/M in seen)
		to_chat(M, "<span class='warning'>The cells clump up into a horrifying tumour!</span>")

/datum/chemical_reaction/fermi/breast_enlarger
	name = "Sucubus milk"
	id = "breast_enlarger"
	results = list("breast_enlarger" = 0.8)
	required_reagents = list("salglu_solution" = 0.1, "milk" = 0.1, "synthflesh" = 0.2, "silicon" = 0.3, "aphro" = 0.3)
	mix_message = "the reaction gives off a mist of milk."
	//FermiChem vars:
	OptimalTempMin 			= 200
	OptimalTempMax			= 800
	ExplodeTemp 			= 900
	OptimalpHMin 			= 6
	OptimalpHMax 			= 10
	ReactpHLim 				= 3
	CatalystFact 			= 0
	CurveSharpT 			= 2
	CurveSharppH 			= 1
	ThermicConstant 		= 1
	HIonRelease 			= -0.1
	RateUpLim 				= 5
	FermiChem				= TRUE
	FermiExplode 			= TRUE
	PurityMin 				= 0.1

/datum/chemical_reaction/fermi/breast_enlarger/FermiFinish(datum/reagents/holder, var/atom/my_atom)
	var/datum/reagent/fermi/breast_enlarger/BE = locate(/datum/reagent/fermi/breast_enlarger) in my_atom.reagents.reagent_list
	var/cached_volume = BE.volume
	if(BE.purity < 0.35)
		holder.remove_reagent(src.id, cached_volume)
		holder.add_reagent("BEsmaller", cached_volume)


/datum/chemical_reaction/fermi/breast_enlarger/FermiExplode(datum/reagents, var/atom/my_atom, volume, temp, pH)
	var/obj/item/organ/genital/breasts/B = new /obj/item/organ/genital/breasts(get_turf(my_atom))
	var/list/seen = viewers(8, get_turf(my_atom))
	for(var/mob/M in seen)
		to_chat(M, "<span class='warning'>The reaction suddenly condenses, creating a pair of breasts!</b></span>")
	var/datum/reagent/fermi/breast_enlarger/BE = locate(/datum/reagent/fermi/breast_enlarger) in my_atom.reagents.reagent_list
	B.size = ((BE.volume * BE.purity) / 10) //half as effective.
	my_atom.reagents.clear_reagents()

/datum/chemical_reaction/fermi/penis_enlarger
	name = "Incubus draft"
	id = "penis_enlarger"
	results = list("penis_enlarger" = 0.8)
	required_reagents = list("blood" = 0.5, "synthflesh" = 0.2, "carbon" = 0.2, "aphro" = 0.2, "salglu_solution" = 0.1,)
	mix_message = "the reaction gives off a spicy mist."
	//FermiChem vars:
	OptimalTempMin 			= 200
	OptimalTempMax			= 800
	ExplodeTemp 			= 900
	OptimalpHMin 			= 2
	OptimalpHMax 			= 6
	ReactpHLim 				= 3
	CatalystFact 			= 0
	CurveSharpT 			= 2
	CurveSharppH 			= 1
	ThermicConstant 		= 1
	HIonRelease 			= 0.1
	RateUpLim 				= 5
	FermiChem				= TRUE
	FermiExplode 			= TRUE
	PurityMin 				= 0.1

/datum/chemical_reaction/fermi/penis_enlarger/FermiExplode(datum/reagents, var/atom/my_atom, volume, temp, pH)
	var/obj/item/organ/genital/penis/P = new /obj/item/organ/genital/penis(get_turf(my_atom))
	var/list/seen = viewers(8, get_turf(my_atom))
	for(var/mob/M in seen)
		to_chat(M, "<span class='warning'>The reaction suddenly condenses, creating a penis!</b></span>")
	var/datum/reagent/fermi/penis_enlarger/PE = locate(/datum/reagent/fermi/penis_enlarger) in my_atom.reagents.reagent_list
	P.length = ((PE.volume * PE.purity) / 10)//half as effective.
	my_atom.reagents.clear_reagents()

/datum/chemical_reaction/fermi/penis_enlarger/FermiFinish(datum/reagents/holder, var/atom/my_atom)
	var/datum/reagent/fermi/penis_enlarger/PE = locate(/datum/reagent/fermi/penis_enlarger) in my_atom.reagents.reagent_list
	var/cached_volume = PE.volume
	if(PE.purity < 0.35)
		holder.remove_reagent(src.id, cached_volume)
		holder.add_reagent("PEsmaller", cached_volume)

/datum/chemical_reaction/fermi/astral
	name = "Astrogen"
	id = "astral"
	results = list("astral" = 0.5)
	required_reagents = list("eigenstate" = 0.1, "plasma" = 0.3, "synaptizine" = 0.1, "aluminium" = 0.5)
	//FermiChem vars:
	OptimalTempMin 			= 700
	OptimalTempMax			= 800
	ExplodeTemp 			= 1150
	OptimalpHMin 			= 10
	OptimalpHMax 			= 13
	ReactpHLim 				= 2
	CatalystFact 			= 0
	CurveSharpT 			= 1
	CurveSharppH 			= 1
	ThermicConstant 		= 25
	HIonRelease 			= 0.02
	RateUpLim 				= 15
	FermiChem				= TRUE
	FermiExplode 			= TRUE
	PurityMin 				= 0.25


/datum/chemical_reaction/fermi/enthrall/ //check this
	name = "MKUltra"
	id = "enthrall"
	results = list("enthrall" = 0.5)
	//required_reagents = list("iron" = 1, "iodine" = 1) Test vars
	//required_reagents = list("cocoa" = 0.1, "astral" = 0.1, "mindbreaker" = 0.1, "psicodine" = 0.1, "happiness" = 0.1)
	required_reagents = list("cocoa" = 0.1, "bluespace" = 0.1, "mindbreaker" = 0.1, "psicodine" = 0.1, "happiness" = 0.1) //TEMPORARY UNTIL HEADMINS GIVE THE OKAY FOR MK USE.
	required_catalysts = list("blood" = 1)
	mix_message = "the reaction gives off a burgundy plume of smoke!"
	//FermiChem vars:
	OptimalTempMin 			= 780
	OptimalTempMax			= 820
	ExplodeTemp 			= 840
	OptimalpHMin 			= 12
	OptimalpHMax 			= 13
	ReactpHLim 				= 2
	//CatalystFact 			= 0
	CurveSharpT 			= 0.5
	CurveSharppH 			= 4
	ThermicConstant 		= 15
	HIonRelease 			= 0.1
	RateUpLim 				= 1
	FermiChem				= TRUE
	FermiExplode 			= TRUE
	PurityMin 				= 0.2

/datum/chemical_reaction/fermi/enthrall/FermiFinish(datum/reagents/holder, var/atom/my_atom)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in my_atom.reagents.reagent_list
	var/datum/reagent/fermi/enthrall/E = locate(/datum/reagent/fermi/enthrall) in my_atom.reagents.reagent_list
	if(!B)
		return
	if(!B.data)
		var/list/seen = viewers(5, get_turf(my_atom))
		for(var/mob/M in seen)
			to_chat(M, "<span class='warning'>The reaction splutters and fails to react properly.</span>") //Just in case
			E.purity = 0
	if (B.data.["gender"] == "female")
		E.data.["creatorGender"] = "Mistress"
		E.creatorGender = "Mistress"
	else
		E.data.["creatorGender"] = "Master"
		E.creatorGender = "Master"
	E.data["creatorName"] = B.data.["real_name"]
	E.creatorName = B.data.["real_name"]
	E.data.["creatorID"] = B.data.["ckey"]
	E.creatorID = B.data.["ckey"]

//So slimes can play too.
/datum/chemical_reaction/fermi/enthrall/slime
	required_catalysts = list("slimejelly" = 1)

/datum/chemical_reaction/fermi/enthrall/slime/FermiFinish(datum/reagents/holder, var/atom/my_atom)
	var/datum/reagent/toxin/slimejelly/B = locate(/datum/reagent/toxin/slimejelly) in my_atom.reagents.reagent_list//The one line change.
	var/datum/reagent/fermi/enthrall/E = locate(/datum/reagent/fermi/enthrall) in my_atom.reagents.reagent_list
	if(!B.data)
		var/list/seen = viewers(5, get_turf(my_atom))
		for(var/mob/M in seen)
			to_chat(M, "<span class='warning'>The reaction splutters and fails to react.</span>") //Just in case
			E.purity = 0
	if (B.data.["gender"] == "female")
		E.data.["creatorGender"] = "Mistress"
		E.creatorGender = "Mistress"
	else
		E.data.["creatorGender"] = "Master"
		E.creatorGender = "Master"
	E.data["creatorName"] = B.data.["real_name"]
	E.creatorName = B.data.["real_name"]
	E.data.["creatorID"] = B.data.["ckey"]
	E.creatorID = B.data.["ckey"]

/datum/chemical_reaction/fermi/enthrall/FermiExplode(datum/reagents, var/atom/my_atom, volume, temp, pH)
	var/turf/T = get_turf(my_atom)
	var/datum/reagents/R = new/datum/reagents(1000)
	var/datum/effect_system/smoke_spread/chem/s = new()
	R.add_reagent("enthrallExplo", volume)
	s.set_up(R, volume/2, T)
	s.start()
	my_atom.reagents.clear_reagents()

/datum/chemical_reaction/fermi/hatmium // done
	name = "Hat growth serum"
	id = "hatmium"
	results = list("hatmium" = 0.5)
	required_reagents = list("ethanol" = 0.1, "nutriment" = 0.3, "cooking_oil" = 0.2, "iron" = 0.1, "gold" = 0.3)
	//mix_message = ""
	//FermiChem vars:
	OptimalTempMin 	= 500
	OptimalTempMax 	= 700
	ExplodeTemp 	= 750
	OptimalpHMin 	= 2
	OptimalpHMax 	= 5
	ReactpHLim 		= 3
	//CatalystFact 	= 0 //To do 1
	CurveSharpT 	= 8
	CurveSharppH 	= 0.5
	ThermicConstant = -2
	HIonRelease 	= -0.1
	RateUpLim 		= 2
	FermiChem 		= TRUE
	FermiExplode 	= TRUE
	PurityMin		= 0.5

/datum/chemical_reaction/fermi/hatmium/FermiExplode(src, var/atom/my_atom, volume, temp, pH)
	var/obj/item/clothing/head/hattip/hat = new /obj/item/clothing/head/hattip(get_turf(my_atom))
	hat.animate_atom_living()
	var/list/seen = viewers(8, get_turf(my_atom))
	for(var/mob/M in seen)
		to_chat(M, "<span class='warning'>The makes an off sounding pop, as a hat suddenly climbs out of the beaker!</b></span>")
	my_atom.reagents.clear_reagents()

/datum/chemical_reaction/fermi/furranium
	name = "Furranium"
	id = "furranium"
	results = list("furranium" = 0.5)
	required_reagents = list("aphro" = 0.1, "moonsugar" = 0.1, "silver" = 0.2, "salglu_solution" = 0.1)
	mix_message = "You think you can hear a howl come from the beaker."
	//FermiChem vars:
	OptimalTempMin 	= 350
	OptimalTempMax 	= 600
	ExplodeTemp 	= 700
	OptimalpHMin 	= 8
	OptimalpHMax 	= 10
	ReactpHLim 		= 2
	//CatalystFact 	= 0 //To do 1
	CurveSharpT 	= 2
	CurveSharppH 	= 0.5
	ThermicConstant = -10
	HIonRelease 	= -0.1
	RateUpLim 		= 2
	FermiChem 		= TRUE
	PurityMin		= 0.3

//FOR INSTANT REACTIONS - DO NOT MULTIPLY LIMIT BY 10.
//There's a weird rounding error or something ugh.

//Nano-b-gone
/datum/chemical_reaction/fermi/nanite_b_gone//done test
	name = "Naninte bain"
	id = "nanite_b_gone"
	results = list("nanite_b_gone" = 4)
	required_reagents = list("synthflesh" = 1, "uranium" = 1, "iron" = 1, "salglu_solution" = 1)
	mix_message = "the reaction gurgles, encapsulating the reagents in flesh before the emp can be set off."
	required_temp = 450//To force fermireactions before EMP.
	//FermiChem vars:
	OptimalTempMin 	= 500
	OptimalTempMax 	= 600
	ExplodeTemp 	= 700
	OptimalpHMin 	= 6
	OptimalpHMax 	= 6.25
	ReactpHLim 		= 3
	//CatalystFact 	= 0 //To do 1
	CurveSharpT 	= 0
	CurveSharppH 	= 1
	ThermicConstant = 5
	HIonRelease 	= 0.01
	RateUpLim 		= 1
	FermiChem 		= TRUE

/datum/chemical_reaction/fermi/acidic_buffer//done test
	name = "Acetic acid buffer"
	id = "acidic_buffer"
	results = list("acidic_buffer" = 2) //acetic acid
	required_reagents = list("salglu_solution" = 0.2, "ethanol" = 0.6, "oxygen" = 0.6, "water" = 0.6)
	//FermiChem vars:
	OptimalTempMin 	= 250
	OptimalTempMax 	= 500
	ExplodeTemp 	= 9999 //check to see overflow doesn't happen!
	OptimalpHMin 	= 2
	OptimalpHMax 	= 6
	ReactpHLim 		= 0
	//CatalystFact 	= 0 //To do 1
	CurveSharpT 	= 4
	CurveSharppH 	= 0
	ThermicConstant = 0
	HIonRelease 	= -0.01
	RateUpLim 		= 20
	FermiChem 		= TRUE


/datum/chemical_reaction/fermi/acidic_buffer/FermiFinish(datum/reagents/holder, var/atom/my_atom) //might need this
	if(!locate(/datum/reagent/fermi/acidic_buffer) in my_atom.reagents.reagent_list)
		return
	var/datum/reagent/fermi/acidic_buffer/Fa = locate(/datum/reagent/fermi/acidic_buffer) in my_atom.reagents.reagent_list
	Fa.data = 0.1//setting it to 0 means byond thinks it's not there.

/datum/chemical_reaction/fermi/basic_buffer//done test
	name = "Ethyl Ethanoate buffer"
	id = "basic_buffer"
	results = list("basic_buffer" = 1.5)
	required_reagents = list("acidic_buffer" = 0.5, "ethanol" = 0.5, "water" = 0.5)
	required_catalysts = list("sacid" = 1) //vagely acetic
	//FermiChem vars:x
	OptimalTempMin 	= 250
	OptimalTempMax 	= 500
	ExplodeTemp 	= 9999 //check to see overflow doesn't happen!
	OptimalpHMin 	= 5
	OptimalpHMax 	= 12
	ReactpHLim 		= 0
	//CatalystFact 	= 0 //To do 1
	CurveSharpT 	= 4
	CurveSharppH 	= 0
	ThermicConstant = 0
	HIonRelease 	= 0.01
	RateUpLim 		= 15
	FermiChem 		= TRUE


/datum/chemical_reaction/fermi/basic_buffer/FermiFinish(datum/reagents/holder, var/atom/my_atom) //might need this
	if(!locate(/datum/reagent/fermi/basic_buffer) in my_atom.reagents.reagent_list)
		return
	var/datum/reagent/fermi/basic_buffer/Fb = locate(/datum/reagent/fermi/basic_buffer) in my_atom.reagents.reagent_list
	Fb.data = 14

//secretcatchemcode, shh!! Of couse I hide it amongst cats. Though, I moved it with your requests.
//I'm not trying to be sneaky, I'm trying to keep it a secret!
//I don't know how to do hidden chems like Aurora
//ChemReactionVars:
/datum/chemical_reaction/fermi/secretcatchem //DONE
	name = "secretcatchem"
	id = "secretcatchem"
	results = list("secretcatchem" = 0.5)
	required_reagents = list("stable_plasma" = 0.1, "sugar" = 0.1, "cream" = 0.1, "clonexadone" = 0.1)//Yes this will make a plushie if you don't lucky guess. It'll eat all your reagents too.
	required_catalysts = list("SDGF" = 1)
	required_temp = 600
	mix_message = "the reaction gives off a meow!"
	mix_sound = "modular_citadel/sound/voice/merowr.ogg"
	//FermiChem vars:
	OptimalTempMin 		= 650
	OptimalpHMin 		= 0
	ReactpHLim 			= 2
	CurveSharpT 		= 0
	CurveSharppH 		= 0
	ThermicConstant		= 0
	HIonRelease 		= 0
	RateUpLim 			= 0.1
	FermiChem 			= TRUE
	FermiExplode 		= FALSE
	PurityMin 			= 0.2

/datum/chemical_reaction/fermi/secretcatchem/New()
	//rand doesn't seem to work with n^-e
	OptimalTempMin 		+= rand(-100, 100)
	OptimalTempMax 		= (OptimalTempMin+rand(20, 200))
	ExplodeTemp 		= (OptimalTempMax+rand(20, 200))
	OptimalpHMin 		+= rand(1, 10)
	OptimalpHMax 		= (OptimalpHMin + rand(1, 5))
	ReactpHLim 			+= rand(-1.5, 2.5)
	CurveSharpT 		+= (rand(1, 500)/100)
	CurveSharppH 		+= (rand(1, 500)/100)
	ThermicConstant		+= rand(-20, 20)
	HIonRelease 		+= (rand(-25, 25)/100)
	RateUpLim 			+= (rand(1, 1000)/100)
	PurityMin 			+= (rand(-1, 1)/10)
	var/additions = list("aluminium", "silver", "gold", "plasma", "silicon", "uranium", "milk")
	required_reagents[pick(additions)] = rand(0.1, 0.5)//weird

/datum/chemical_reaction/fermi/secretcatchem/FermiFinish(datum/reagents/holder, var/atom/my_atom)
	SSblackbox.record_feedback("tally", "catgirlium")//log

/datum/chemical_reaction/fermi/secretcatchem/FermiExplode(datum/reagents, var/atom/my_atom, volume, temp, pH)
	var/mob/living/simple_animal/pet/cat/custom_cat/catto = new(get_turf(my_atom))
	var/list/seen = viewers(8, get_turf(my_atom))
	for(var/mob/M in seen)
		to_chat(M, "<span class='warning'>The reaction suddenly gives out a meow, condensing into a chemcat!</b></span>")//meow!
	playsound(get_turf(my_atom), 'modular_citadel/sound/voice/merowr.ogg', 50, 1, -1)
	catto.name = "Chemcat"
	catto.desc = "A cute chem cat, created by a lot of compicated and confusing chemistry!"
	catto.color = "#770000"
	my_atom.reagents.remove_all(5)

/datum/chemical_reaction/fermi/yamerol//done test
	name = "Yamerol"
	id = "yamerol"
	results = list("yamerol" = 1.5)
	required_reagents = list("perfluorodecalin" = 0.5, "salbutamol" = 0.5, "water" = 0.5)
	//FermiChem vars:
	OptimalTempMin 	= 300
	OptimalTempMax 	= 500
	ExplodeTemp 	= 800 //check to see overflow doesn't happen!
	OptimalpHMin 	= 6.8
	OptimalpHMax 	= 7.2
	ReactpHLim 		= 4
	//CatalystFact 	= 0 //To do 1
	CurveSharpT 	= 5
	CurveSharppH 	= 0.5
	ThermicConstant = -15
	HIonRelease 	= 0.1
	RateUpLim 		= 2
	FermiChem 		= TRUE
