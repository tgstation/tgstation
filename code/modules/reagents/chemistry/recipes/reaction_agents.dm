/datum/chemical_reaction/basic_buffer
	results = list(/datum/reagent/reaction_agent/basic_buffer = 5)
	required_reagents = list(/datum/reagent/lye = 1, /datum/reagent/consumable/ethanol = 2, /datum/reagent/water = 2)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)//vagely acetic
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
	rate_up_lim = 7.5
	purity_min = 0

/datum/chemical_reaction/acidic_buffer
	results = list(/datum/reagent/reaction_agent/acidic_buffer = 10)
	required_reagents = list(/datum/reagent/medicine/salglu_solution = 1, /datum/reagent/consumable/ethanol = 3, /datum/reagent/oxygen = 3, /datum/reagent/water = 3)
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
	rate_up_lim = 10
	purity_min = 0

/datum/chemical_reaction/purity_tester
	results = list(/datum/reagent/reaction_agent/purity_tester = 5)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/consumable/ethanol = 3, /datum/reagent/toxin/plasma = 1)
	mix_message = "The solution's viscosity increases."
	is_cold_recipe = TRUE
	required_temp = 600
	optimal_temp = 300
	overheat_temp = -1 //no overheat 
	optimal_ph_min = 2
	optimal_ph_max = 12
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 0
	thermic_constant = -500
	H_ion_release = -0.05
	rate_up_lim = 2
	purity_min = 0.25


/datum/chemical_reaction/speed_agent
	results = list(/datum/reagent/reaction_agent/speed_agent = 5)
	required_reagents = list(/datum/reagent/reaction_agent/purity_tester = 5)
	mix_message = "The solution's viscosity decreases."
	mix_sound = 'sound/chemistry/bluespace.ogg' //Maybe use this elsewhere instead
	required_temp = 100
	optimal_temp = 500
	overheat_temp = 500 
	optimal_ph_min = 5
	optimal_ph_max = 9
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 2
	thermic_constant = -1500
	H_ion_release = -0.5
	rate_up_lim = 1
	purity_min = 0.35

/datum/chemical_reaction/speed_agent/reaction_step(datum/equilibrium/reaction, datum/reagents/holder, delta_t, delta_ph, step_reaction_vol)
	. = ..()
	if(holder.has_reagent(/datum/reagent/bluespace))
		holder.remove_reagent(/datum/reagent/bluespace, 10)
		reaction.delta_t *= 5

/datum/chemical_reaction/speed_agent/overheated(datum/reagents/holder, datum/equilibrium/equilibrium)
	. = ..()
	explode_shockwave(holder, equilibrium)

/datum/chemical_reaction/speed_agent/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium)
	explode_fire(holder, equilibrium)
	clear_reactants(holder, 20)

/datum/chemical_reaction/purity_tester/competitive //So we have a back and forth reaction
	results = list(/datum/reagent/reaction_agent/purity_tester = 5)
	required_reagents = list(/datum/reagent/reaction_agent/speed_agent = 5)
