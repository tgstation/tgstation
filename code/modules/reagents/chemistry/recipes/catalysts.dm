
///////////////////////////MEDICINES////////////////////////////

/datum/chemical_reaction/medical_speed_catalyst
	results = list(/datum/reagent/reaction_agent/speed_agent = 3)
	required_reagents = list(/datum/reagent/medicine/c2/libital = 4, /datum/reagent/medicine/c2/probital = 6, /datum/reagent/toxin/plasma = 8)
	mix_message = "The reaction evaporates slightly as the mixture solidifies"
	mix_sound = 'sound/chemistry/catalyst.ogg'
	required_temp = 0
	optimal_temp = 500
	overheat_temp = 800 
	optimal_ph_min = 11
	optimal_ph_max = 12
	determin_ph_range = 5
	temp_exponent_factor = 0.5
	ph_exponent_factor = 4
	thermic_constant = 50
	H_ion_release = -0.5
	rate_up_lim = 1
	purity_min = 0.5

/datum/chemical_reaction/medical_speed_catalyst/overheated(datum/reagents/holder, datum/equilibrium/equilibrium)
	explode_invert_smoke(holder, equilibrium) //Will be better when the inputs have proper invert chems

/datum/chemical_reaction/medical_speed_catalyst/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium)
	explode_invert_smoke(holder, equilibrium)
