/datum/borer_chem
	var/chemname
	var/chem_desc = "This is a chemical"
	var/chemuse = 35
	var/quantity = 10

/datum/borer_chem/epinephrine
	chemname = "epinephrine"
	chem_desc = "Stabilizes critical condition and slowly restores oxygen damage. If overdosed, it will deal toxin and oxyloss damage."

/datum/borer_chem/mannitol
	chemname = "mannitol"
	chem_desc = "Quickly heals brain damage."

/datum/borer_chem/bicaridine
	chemname = "bicaridine"
	chem_desc = "Heals brute damage."

/datum/borer_chem/kelotane
	chemname = "kelotane"
	chem_desc = "Heals burn damage."

/datum/borer_chem/charcoal
	chemname = "charcoal"
	chem_desc = "Slowly heals toxin damage, will also slowly remove any other chemicals."

/datum/borer_chem/methamphetamine
	chemname = "methamphetamine"
	chem_desc = "Reduces stun times, increases stamina and run speed while dealing brain damage. If overdosed it will deal toxin and brain damage."

/datum/borer_chem/perfluorodecalin
	chemname = "perfluorodecalin"
	chem_desc = "Heals suffocation damage quickly but mutes your voice. Has a 33% chance of healing brute and burn damage per cycle as well."
	chemuse = 75

/datum/borer_chem/spacedrugs
	chemname = "space_drugs"
	chem_desc = "Get your host high as a kite."
	chemuse = 75

/*/datum/borer_chem/creagent
	chemname = "colorful_reagent"
	chem_desc = "Change the colour of your host."
	chemuse = 50*/

/datum/borer_chem/ethanol
	chemname = "ethanol"
	chem_desc = "The most potent alcoholic 'beverage', with the fastest toxicity."
	chemuse = 50

/datum/borer_chem/rezadone
	chemname = "rezadone"
	chem_desc = "Heals cellular damage."
	chemuse = 75