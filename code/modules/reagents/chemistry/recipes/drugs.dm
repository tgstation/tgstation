/datum/chemical_reaction/space_drugs
	results = list(/datum/reagent/drug/space_drugs = 3)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1)

/datum/chemical_reaction/crank
	results = list(/datum/reagent/drug/crank = 5)
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/ammonia = 1, /datum/reagent/lithium = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/fuel = 1)
	mix_message = "The mixture violently reacts, leaving behind a few crystalline shards."
	required_temp = 390

/datum/chemical_reaction/krokodil
	results = list(/datum/reagent/drug/krokodil = 6)
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/medicine/morphine = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/potassium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/fuel = 1)
	mix_message = "The mixture dries into a pale blue powder."
	required_temp = 380


/datum/chemical_reaction/methamphetamine
	results = list(/datum/reagent/drug/methamphetamine = 4)
	required_reagents = list(/datum/reagent/medicine/ephedrine = 1, /datum/reagent/iodine = 1, /datum/reagent/phosphorus = 1, /datum/reagent/hydrogen = 1)
	required_temp = 374
	optimal_temp = 380//Wow this is tight
	overheat_temp = 380 
	optimal_ph_min = 6.5
	optimal_ph_max = 7.5
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 1.4
	thermic_constant = 0.8 //exothermic nature is equal to impurty
	H_ion_release = -0.25 
	rate_up_lim = 4
	purity_min = 0.3//I'll be surprised if you get here
	

//The less pure it is, the faster it heats up.
/datum/chemical_reaction/methamphetamine/reaction_step(datum/equilibrium/reaction, datum/reagents/holder, delta_chem_factor, added_purity)
	var/datum/reagent/meth = holder.get_reagent(type)
	reaction.thermic_mod += (1-meth.purity)*2

/datum/chemical_reaction/bath_salts
	results = list(/datum/reagent/drug/bath_salts = 7)
	required_reagents = list(/datum/reagent/toxin/bad_food = 1, /datum/reagent/saltpetre = 1, /datum/reagent/consumable/nutriment = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/consumable/enzyme = 1, /datum/reagent/consumable/tea = 1, /datum/reagent/mercury = 1)
	required_temp = 374

/datum/chemical_reaction/aranesp
	results = list(/datum/reagent/drug/aranesp = 3)
	required_reagents = list(/datum/reagent/medicine/epinephrine = 1, /datum/reagent/medicine/atropine = 1, /datum/reagent/medicine/morphine = 1)

/datum/chemical_reaction/happiness
	results = list(/datum/reagent/drug/happiness = 4)
	required_reagents = list(/datum/reagent/nitrous_oxide = 2, /datum/reagent/medicine/epinephrine = 1, /datum/reagent/consumable/ethanol = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)

/datum/chemical_reaction/pumpup
	results = list(/datum/reagent/drug/pumpup = 5)
	required_reagents = list(/datum/reagent/medicine/epinephrine = 2, /datum/reagent/consumable/coffee = 5)

/datum/chemical_reaction/maint_tar1
	results = list(/datum/reagent/toxin/acid = 1 ,/datum/reagent/drug/maint/tar = 3)
	required_reagents = list(/datum/reagent/consumable/tea = 1, /datum/reagent/yuck = 1 , /datum/reagent/fuel = 1)

/datum/chemical_reaction/maint_tar2
	results = list(/datum/reagent/toxin/acid = 1 ,/datum/reagent/drug/maint/tar = 3)
	required_reagents = list(/datum/reagent/consumable/tea = 1, /datum/reagent/consumable/enzyme = 3 , /datum/reagent/fuel = 1)

/datum/chemical_reaction/maint_sludge
	results = list(/datum/reagent/drug/maint/sludge = 1)
	required_reagents = list(/datum/reagent/drug/maint/tar = 3 , /datum/reagent/toxin/acid/fluacid = 1)
	required_catalysts = list(/datum/reagent/hydrogen_peroxide = 5)

/datum/chemical_reaction/maint_powder
	results = list(/datum/reagent/drug/maint/powder = 1)
	required_reagents = list(/datum/reagent/drug/maint/sludge = 6 , /datum/reagent/toxin/acid/nitracid = 1 , /datum/reagent/consumable/enzyme = 1)
	required_catalysts = list(/datum/reagent/acetone_oxide = 5)
