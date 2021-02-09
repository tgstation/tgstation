
/*****BRUTE*****/

/datum/chemical_reaction/medicine/helbital
	results = list(/datum/reagent/medicine/c2/helbital = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/fluorine = 1, /datum/reagent/carbon = 1)
	mix_message = "The mixture turns into a thick, yellow powder."
	//FermiChem vars:
	required_temp = 250
	optimal_temp = 1000
	overheat_temp = 650
	optimal_ph_min = 5
	optimal_ph_max = 9.5
	determin_ph_range = 4
	temp_exponent_factor = 1
	ph_exponent_factor = 4
	thermic_constant = 100
	H_ion_release = 4
	rate_up_lim = 55
	purity_min = 0.55
	reaction_flags = REACTION_PH_VOL_CONSTANT


/datum/chemical_reaction/medicine/helbital/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium)
	explode_fire_vortex(holder, equilibrium, 1, 1)
	holder.chem_temp += 2.5
	var/datum/reagent/helbital = holder.get_reagent(/datum/reagent/medicine/c2/helbital)
	if(!helbital)
		return
	if(helbital.purity <= 0.25)
		if(prob(5))
			new /obj/effect/hotspot(holder.my_atom.loc)
			holder.remove_reagent(/datum/reagent/medicine/c2/helbital, 10)
			holder.chem_temp += 5
			holder.my_atom.audible_message("<span class='notice'>[icon2html(holder.my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] The [src] suddenly lets out a hearty burst of flame, evaporating some of the contents!</span>")

/datum/chemical_reaction/medicine/helbital/overheated(datum/reagents/holder, datum/equilibrium/equilibrium)
	. = ..()
	overly_impure(holder, equilibrium)//faster vortex

/datum/chemical_reaction/medicine/helbital/reaction_finish(datum/reagents/holder, react_vol)
	. = ..()
	var/datum/reagent/helbital = holder.get_reagent(/datum/reagent/medicine/c2/helbital)
	if(!helbital)
		return
	if(helbital.purity <= 0.15) //So people don't ezmode this by keeping it at min
		explode_fire(holder, null, 3)
		clear_products(holder)

/datum/chemical_reaction/medicine/libital
	results = list(/datum/reagent/medicine/c2/libital = 3)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/oxygen = 1, /datum/reagent/nitrogen = 1)
	required_temp = 225
	optimal_temp = 700
	overheat_temp = 840
	optimal_ph_min = 5
	optimal_ph_max = 10
	determin_ph_range = 4
	temp_exponent_factor = 1.75
	ph_exponent_factor = 1
	thermic_constant = 75
	H_ion_release = 4
	rate_up_lim = 40
	purity_min = 0
	reaction_flags = REACTION_PH_VOL_CONSTANT

/datum/chemical_reaction/medicine/probital
	results = list(/datum/reagent/medicine/c2/probital = 4)
	required_reagents = list(/datum/reagent/copper = 1, /datum/reagent/acetone = 2,  /datum/reagent/phosphorus = 1)
	required_temp = 225
	optimal_temp = 700
	overheat_temp = 850
	optimal_ph_min = 5
	optimal_ph_max = 14
	determin_ph_range = 2
	temp_exponent_factor = 0.75
	ph_exponent_factor = 4
	thermic_constant = 50
	H_ion_release = 4
	rate_up_lim = 30
	purity_min = 0
	reaction_flags = REACTION_CLEAR_INVERSE | REACTION_PH_VOL_CONSTANT

/*****BURN*****/

/datum/chemical_reaction/medicine/lenturi
	results = list(/datum/reagent/medicine/c2/lenturi = 5)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/silver = 1, /datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/medicine/aiuri
	results = list(/datum/reagent/medicine/c2/aiuri = 4)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/hydrogen = 2)

/datum/chemical_reaction/medicine/hercuri
	results = list(/datum/reagent/medicine/c2/hercuri = 5)
	required_reagents = list(/datum/reagent/cryostylane = 3, /datum/reagent/bromine = 1, /datum/reagent/lye = 1)
	required_temp = 47
	is_cold_recipe = TRUE
	optimal_temp = 10
	overheat_temp = 5
	thermic_constant = -50

/*****OXY*****/

/datum/chemical_reaction/medicine/convermol
	results = list(/datum/reagent/medicine/c2/convermol = 3)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/fluorine = 1, /datum/reagent/fuel/oil = 1)
	required_temp = 370
	mix_message = "The mixture rapidly turns into a dense pink liquid."

/datum/chemical_reaction/medicine/tirimol
	results = list(/datum/reagent/medicine/c2/tirimol = 5)
	required_reagents = list(/datum/reagent/nitrogen = 3, /datum/reagent/acetone = 2)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)

/*****TOX*****/

/datum/chemical_reaction/medicine/seiver
	results = list(/datum/reagent/medicine/c2/seiver = 3)
	required_reagents = list(/datum/reagent/nitrogen = 1, /datum/reagent/potassium = 1, /datum/reagent/aluminium = 1)

/datum/chemical_reaction/medicine/multiver
	results = list(/datum/reagent/medicine/c2/multiver = 2)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/salt = 1)
	mix_message = "The mixture yields a fine black powder."
	required_temp = 380

/datum/chemical_reaction/medicine/syriniver
	results = list(/datum/reagent/medicine/c2/syriniver = 5)
	required_reagents = list(/datum/reagent/sulfur = 1, /datum/reagent/fluorine = 1, /datum/reagent/toxin = 1, /datum/reagent/nitrous_oxide = 2)

/datum/chemical_reaction/medicine/penthrite
	results = list(/datum/reagent/medicine/c2/penthrite = 3)
	required_reagents = list(/datum/reagent/pentaerythritol = 1, /datum/reagent/acetone = 1,  /datum/reagent/toxin/acid/nitracid = 1 , /datum/reagent/wittel = 1)
