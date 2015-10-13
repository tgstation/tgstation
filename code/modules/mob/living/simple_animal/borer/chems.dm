
/datum/borer_chem
	var/name = ""
	var/cost = 1 // Per dose delivered.
	var/dose_size = 15

	var/unlockable=0

/datum/borer_chem/bicaridine
	name = "bicaridine"

/datum/borer_chem/tramadol
	name = "tramadol"

/datum/borer_chem/alkysine
	name = "alkysine"
	//cost = 0

/datum/borer_chem/hyperzine
	name = "hyperzine"

/datum/borer_chem/charcoal
	name = "charcoal"
	cost = 2

/datum/borer_chem/lipozine
	name = "Lipozine" // SIC

/datum/borer_chem/anti_toxin
	name = "anti_toxin"

/datum/borer_chem/leporazine
	name = "leporazine"

/datum/borer_chem/inaprovaline
	name = "inaprovaline"
	cost = 2

/datum/borer_chem/kelotane
	name = "kelotane"
	cost = 2


////////////////////////////
// UNLOCKABLES
////////////////////////////

/datum/borer_chem/unlockable
	unlockable=1
/datum/borer_chem/unlockable/space_drugs
	name = "space_drugs"
	cost = 2

/datum/borer_chem/unlockable/paracetamol
	name = "paracetamol"
	cost = 2

/datum/borer_chem/unlockable/dermaline
	name = "dermaline"
	cost = 2

/datum/borer_chem/unlockable/dexalin
	name = "dexalin"
	cost = 2

/datum/borer_chem/unlockable/dexalinp
	name = "dexalinp"
	cost = 2

/datum/borer_chem/unlockable/peridaxon
	name = "peridaxon"
	cost = 2

/datum/borer_chem/unlockable/rezadone
	name = "rezadone"
	cost = 2