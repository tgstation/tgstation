/datum/chemical_reaction/
	mix_sound = 'sound/effects/bubbles.ogg'

	//use fermicalc.py to calculate how the curves look(i think)
//Called for every reaction step
/datum/chemical_reaction/fermi/proc/FermiCreate(holder)
	return

//Called when reaction STOP_PROCESSING
/datum/chemical_reaction/fermi/proc/FermiFinish(datum/reagents/holder)
	return

//Called when temperature is above a certain threshold, or if purity is too low.
/datum/chemical_reaction/fermi/proc/FermiExplode(datum/reagents, var/atom/my_atom, volume, temp, pH, Exploding = FALSE)
	if (Exploding)
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
		R.add_reagent(type, reagent.volume/3) //Seems fine? I think I fixed the infinite explosion bug.

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

//FOR INSTANT REACTIONS - DO NOT MULTIPLY LIMIT BY 10.
//There's a weird rounding error or something ugh.



/datum/chemical_reaction/fermi/acidic_buffer//done test
	name = "Acetic acid buffer"
	id = "acidic_buffer"
	results = list(/datum/reagent/acidic_buffer = 2) //acetic acid
	required_reagents = list(/datum/reagent/medicine/salglu_solution = 0.2, /datum/reagent/consumable/ethanol = 0.6, /datum/reagent/oxygen = 0.6, /datum/reagent/water = 0.6)
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
	if(!locate(/datum/reagent/acidic_buffer) in my_atom.reagents.reagent_list)
		return
	var/datum/reagent/acidic_buffer/Fa = locate(/datum/reagent/acidic_buffer) in my_atom.reagents.reagent_list
	Fa.data = 0.1//setting it to 0 means byond thinks it's not there.

/datum/chemical_reaction/fermi/basic_buffer//done test
	name = "Ethyl Ethanoate buffer"
	id = "basic_buffer"
	results = list(/datum/reagent/basic_buffer = 1.5)
	required_reagents = list(/datum/reagent/acidic_buffer = 0.5,  /datum/reagent/consumable/ethanol = 0.5, /datum/reagent/water = 0.5)
	required_catalysts = list(/datum/reagent/toxin/acid = 1) //vagely acetic
	//FermiChem vars:x
	OptimalTempMin 	= 250
	OptimalTempMax 	= 500
	ExplodeTemp 	= 9999 //check to see overflow doesn't happen!
	OptimalpHMin 	= 5
	OptimalpHMax 	= 12
	ReactpHLim 		= 0
	CurveSharpT 	= 4
	CurveSharppH 	= 0
	ThermicConstant = 0
	HIonRelease 	= 0.01
	RateUpLim 		= 15
	FermiChem 		= TRUE


/datum/chemical_reaction/fermi/basic_buffer/FermiFinish(datum/reagents/holder, var/atom/my_atom) //might need this
	if(!locate(/datum/reagent/basic_buffer) in my_atom.reagents.reagent_list)
		return
	var/datum/reagent/basic_buffer/Fb = locate(/datum/reagent/basic_buffer) in my_atom.reagents.reagent_list
	Fb.data = 14

/datum/chemical_reaction/fermi/rainbowium
	name = "Polychromatic Rainbowium"
	id = "rainbowium"
	results = list(/datum/reagent/rainbowium = 0.1)
	required_reagents = list(/datum/reagent/colorful_reagent = 0.5, /datum/reagent/drug/happiness = 0.5, /datum/reagent/potassium = 0.25, /datum/reagent/toxin/mindbreaker = 1)
	OptimalTempMin 	= 770
	OptimalTempMax 	= 850
	ExplodeTemp 	= 920 //check to see overflow doesn't happen!
	OptimalpHMin 	= 9
	OptimalpHMax 	= 11
	ReactpHLim 		= 1
	//CatalystFact 	= 0 //To do 1
	CurveSharpT 	= 4
	CurveSharppH 	= 4
	ThermicConstant = 25
	HIonRelease 	= -0.1
	RateUpLim 		= 1
	FermiChem 		= TRUE
