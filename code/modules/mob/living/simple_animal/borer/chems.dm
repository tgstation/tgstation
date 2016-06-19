
/datum/borer_chem
	var/name = ""
	var/cost = 1 // Per dose delivered.
	var/dose_size = 15

	var/unlockable=0

/datum/borer_chem/head
/datum/borer_chem/chest
/datum/borer_chem/arm
/datum/borer_chem/leg

/datum/borer_chem/head/bicaridine
	name = "bicaridine"

/datum/borer_chem/head/tramadol
	name = "tramadol"

/datum/borer_chem/head/alkysine
	name = "alkysine"
	//cost = 0

/datum/borer_chem/head/ryetalyn
	name = "ryetalyn"

/datum/borer_chem/head/hyperzine
	name = "hyperzine"

/datum/borer_chem/head/charcoal
	name = "charcoal"
	cost = 2

/datum/borer_chem/head/anti_toxin
	name = "anti_toxin"

/datum/borer_chem/head/leporazine
	name = "leporazine"

/datum/borer_chem/head/inaprovaline
	name = "inaprovaline"
	cost = 2

/datum/borer_chem/head/kelotane
	name = "kelotane"
	cost = 2

/datum/borer_chem/chest/blood
	name = "blood"

/datum/borer_chem/chest/imidazoline
	name = "imidazoline"

/datum/borer_chem/chest/inacusiate
	name = "inacusiate"

/datum/borer_chem/chest/lipozine
	name = "Lipozine" // SIC

/datum/borer_chem/chest/ethylredoxrazine
	name = "ethylredoxrazine"

/datum/borer_chem/chest/oxycodone
	name = "oxycodone"

/datum/borer_chem/chest/radium
	name = "radium"

/datum/borer_chem/arm/bicaridine
	name = "bicaridine"
	cost = 2

/datum/borer_chem/arm/kelotane
	name = "kelotane"
	cost = 2

/datum/borer_chem/leg/hyperzine
	name = "hyperzine"

////////////////////////////
// UNLOCKABLES
////////////////////////////

//datum/borer_chem/unlockable
//	unlockable=1

/datum/borer_chem/head/unlockable
	unlockable=1
/datum/borer_chem/chest/unlockable
	unlockable=1
/datum/borer_chem/arm/unlockable
	unlockable=1
/datum/borer_chem/leg/unlockable
	unlockable=1

/datum/borer_chem/head/unlockable/space_drugs
	name = "space_drugs"
	cost = 2

/datum/borer_chem/head/unlockable/paracetamol
	name = "paracetamol"
	cost = 2

/datum/borer_chem/head/unlockable/dermaline
	name = "dermaline"
	cost = 2

/datum/borer_chem/head/unlockable/dexalin
	name = "dexalin"
	cost = 2

/datum/borer_chem/head/unlockable/dexalinp
	name = "dexalinp"
	cost = 2

/datum/borer_chem/head/unlockable/peridaxon
	name = "peridaxon"
	cost = 2

/datum/borer_chem/head/unlockable/rezadone
	name = "rezadone"
	cost = 2

/datum/borer_chem/chest/unlockable/nutriment
	name = "nutriment"
	cost = 2

/datum/borer_chem/chest/unlockable/paismoke
	name = "paismoke"
	cost = 15

/datum/borer_chem/chest/unlockable/arithrazine
	name = "arithrazine"
	cost = 2

/datum/borer_chem/chest/unlockable/capsaicin
	name = "capsaicin"
	cost = 2

/datum/borer_chem/chest/unlockable/frostoil
	name = "frostoil"
	cost = 2

/datum/borer_chem/chest/unlockable/clottingagent
	name = "clotting_agent"
	cost = 10

/datum/borer_chem/arm/unlockable/cafe_latte
	name = "cafe_latte"
	cost = 1

/datum/borer_chem/arm/unlockable/iron
	name = "iron"
	cost = 1

/datum/borer_chem/leg/unlockable/bustanut
	name = "bustanut"
	cost = 2

/datum/borer_chem/leg/unlockable/synaptizine
	name = "synaptizine"
	cost = 2