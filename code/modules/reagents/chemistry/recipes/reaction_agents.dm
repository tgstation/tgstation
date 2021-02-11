/datum/chemical_reaction/basic_buffer
	results = list(/datum/reagent/reaction_agent/basic_buffer = 10)
	required_reagents = list(/datum/reagent/ammonia = 3, /datum/reagent/chlorine = 2, /datum/reagent/hydrogen = 2, /datum/reagent/oxygen = 2) //vagely NH4OH + NH4Cl buffer
	mix_message = "The solution fizzes in the beaker."
	//FermiChem vars:
	required_temp = 250
	optimal_temp = 500
	overheat_temp = 9999
	optimal_ph_min = 0
	optimal_ph_max = 14
	determin_ph_range = 0
	temp_exponent_factor = 4
	ph_exponent_factor = 0
	thermic_constant = 0
	H_ion_release = 0.01
	rate_up_lim = 15
	purity_min = 0

/datum/chemical_reaction/acidic_buffer
	results = list(/datum/reagent/reaction_agent/acidic_buffer = 10)
	required_reagents = list(/datum/reagent/sodium = 2, /datum/reagent/hydrogen = 2, /datum/reagent/consumable/ethanol = 2, /datum/reagent/water = 2)
	mix_message = "The solution froths in the beaker."
	required_temp = 250
	optimal_temp = 500
	overheat_temp = 9999
	optimal_ph_min = 0
	optimal_ph_max = 14
	determin_ph_range = 0
	temp_exponent_factor = 4
	ph_exponent_factor = 0
	thermic_constant = 0
	H_ion_release = -0.01
	rate_up_lim = 20
	purity_min = 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////		Example competitive reaction (REACTION_COMPETITIVE)		 //////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/chemical_reaction/prefactor_a
	results = list(/datum/reagent/prefactor_a = 5)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/consumable/ethanol = 3, /datum/reagent/toxin/plasma = 1)
	mix_message = "The solution's viscosity increases."
	is_cold_recipe = TRUE
	required_temp = 800
	optimal_temp = 300
	overheat_temp = -1 //no overheat
	optimal_ph_min = 2
	optimal_ph_max = 12
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 0
	thermic_constant = -400
	H_ion_release = 0
	rate_up_lim = 4
	purity_min = 0.25


/datum/chemical_reaction/prefactor_b
	results = list(/datum/reagent/prefactor_b = 5)
	required_reagents = list(/datum/reagent/prefactor_a = 5)
	mix_message = "The solution's viscosity decreases."
	mix_sound = 'sound/chemistry/bluespace.ogg' //Maybe use this elsewhere instead
	required_temp = 50
	optimal_temp = 500
	overheat_temp = 500
	optimal_ph_min = 5
	optimal_ph_max = 8
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 2
	thermic_constant = -800
	H_ion_release = -0.02
	rate_up_lim = 6
	purity_min = 0.35
	reaction_flags = REACTION_COMPETITIVE //Competes with /datum/chemical_reaction/prefactor_a/competitive

/datum/chemical_reaction/prefactor_b/reaction_step(datum/equilibrium/reaction, datum/reagents/holder, delta_t, delta_ph, step_reaction_vol)
	. = ..()
	if(holder.has_reagent(/datum/reagent/bluespace))
		holder.remove_reagent(/datum/reagent/bluespace, 1)
		reaction.delta_t *= 5

/datum/chemical_reaction/prefactor_b/overheated(datum/reagents/holder, datum/equilibrium/equilibrium)
	. = ..()
	explode_shockwave(holder, equilibrium)
	var/vol = max(20, holder.total_volume/5) //Not letting you have more than 5
	clear_reagents(holder, vol)//Lest we explode forever

/datum/chemical_reaction/prefactor_b/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium)
	explode_fire(holder, equilibrium)
	var/vol = max(20, holder.total_volume/5) //Not letting you have more than 5
	clear_reagents(holder, vol)

/datum/chemical_reaction/prefactor_a/competitive //So we have a back and forth reaction
	results = list(/datum/reagent/prefactor_a = 5)
	required_reagents = list(/datum/reagent/prefactor_b = 5)
	rate_up_lim = 3
	reaction_flags = REACTION_COMPETITIVE //Competes with /datum/chemical_reaction/prefactor_b

//The actual results
/datum/chemical_reaction/prefactor_a/purity_tester
	results = list(/datum/reagent/reaction_agent/purity_tester = 5)
	required_reagents = list(/datum/reagent/prefactor_a = 5, /datum/reagent/stable_plasma = 5)
	H_ion_release = 0.05
	thermic_constant = 0

/datum/chemical_reaction/prefactor_b/speed_agent
	results = list(/datum/reagent/reaction_agent/speed_agent = 5)
	required_reagents = list(/datum/reagent/prefactor_b = 5, /datum/reagent/stable_plasma = 5)
	H_ion_release = -0.15
	thermic_constant = 0

////////////////////////////////End example/////////////////////////////////////////////////////////////////////////////
