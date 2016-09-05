/datum/chemical_reaction/space_drugs
	id = "drugs_space"
	results = list("space_drugs" = 3)
	required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)

/datum/chemical_reaction/crank
	id = "drugs_crank"
	results = list("crank" = 5)
	required_reagents = list("diphenhydramine" = 1, "ammonia" = 1, "lithium" = 1, "sacid" = 1, "welding_fuel" = 1)
	required_temp = 390

/datum/chemical_reaction/crank/react(datum/chem_holder/holder)
	simple_react(holder, mix_message = "The mixture violently reacts, leaving behind a few crystalline shards.")

/datum/chemical_reaction/krokodil
	id = "drugs_krokodil"
	results = list("krokodil" = 6)
	required_reagents = list("diphenhydramine" = 1, "morphine" = 1, "cleaner" = 1, "potassium" = 1, "phosphorus" = 1, "welding_fuel" = 1)
	required_temp = 380

/datum/chemical_reaction/krokodil/react(datum/chem_holder/holder)
	simple_react(holder, mix_message = "The mixture dries into a pale blue powder.")

/datum/chemical_reaction/methamphetamine
	id = "drugs_meth"
	results = list("methamphetamine" = 4)
	required_reagents = list("ephedrine" = 1, "iodine" = 1, "phosphorus" = 1, "hydrogen" = 1)
	required_temp = 374

/datum/chemical_reaction/methamphetamine/react(datum/chem_holder/holder)
	simple_react(holder)

/datum/chemical_reaction/bath_salts
	id = "drugs_bathsalts"
	results = list("bath_salts" = 7)
	required_reagents = list("????" = 1, "saltpetre" = 1, "nutriment" = 1, "cleaner" = 1, "enzyme" = 1, "tea" = 1, "mercury" = 1)
	required_temp = 374

/datum/chemical_reaction/aranesp
	id = "drugs_aranesp"
	results = list("aranesp" = 3)
	required_reagents = list("epinephrine" = 1, "atropine" = 1, "morphine" = 1)
