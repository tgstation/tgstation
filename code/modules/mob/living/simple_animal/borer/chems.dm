
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
	name = BICARIDINE

/datum/borer_chem/head/tramadol
	name = TRAMADOL

/datum/borer_chem/head/alkysine
	name = ALKYSINE
	//cost = 0

/datum/borer_chem/head/ryetalyn
	name = RYETALYN

/datum/borer_chem/head/hyperzine
	name = HYPERZINE

/datum/borer_chem/head/charcoal
	name = CHARCOAL
	cost = 2

/datum/borer_chem/head/anti_toxin
	name = ANTI_TOXIN

/datum/borer_chem/head/leporazine
	name = LEPORAZINE

/datum/borer_chem/head/inaprovaline
	name = INAPROVALINE
	cost = 2

/datum/borer_chem/head/kelotane
	name = KELOTANE
	cost = 2

/datum/borer_chem/chest/blood
	name = BLOOD

/datum/borer_chem/chest/imidazoline
	name = IMIDAZOLINE

/datum/borer_chem/chest/inacusiate
	name = INACUSIATE

/datum/borer_chem/chest/lipozine
	name = LIPOZINE

/datum/borer_chem/chest/ethylredoxrazine
	name = ETHYLREDOXRAZINE

/datum/borer_chem/chest/oxycodone
	name = OXYCODONE

/datum/borer_chem/chest/radium
	name = RADIUM

/datum/borer_chem/arm/bicaridine
	name = BICARIDINE
	cost = 2

/datum/borer_chem/arm/kelotane
	name = KELOTANE
	cost = 2

/datum/borer_chem/leg/hyperzine
	name = HYPERZINE

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
	name = SPACE_DRUGS
	cost = 2

/datum/borer_chem/head/unlockable/paracetamol
	name = PARACETAMOL
	cost = 2

/datum/borer_chem/head/unlockable/dermaline
	name = DERMALINE
	cost = 2

/datum/borer_chem/head/unlockable/dexalin
	name = DEXALIN
	cost = 2

/datum/borer_chem/head/unlockable/dexalinp
	name = DEXALINP
	cost = 2

/datum/borer_chem/head/unlockable/peridaxon
	name = PERIDAXON
	cost = 2

/datum/borer_chem/head/unlockable/rezadone
	name = REZADONE
	cost = 2

/datum/borer_chem/chest/unlockable/nutriment
	name = NUTRIMENT
	cost = 2

/datum/borer_chem/chest/unlockable/paismoke
	name = PAISMOKE
	cost = 15

/datum/borer_chem/chest/unlockable/arithrazine
	name = ARITHRAZINE
	cost = 2

/datum/borer_chem/chest/unlockable/capsaicin
	name = CAPSAICIN
	cost = 2

/datum/borer_chem/chest/unlockable/frostoil
	name = FROSTOIL
	cost = 2

/datum/borer_chem/chest/unlockable/clottingagent
	name = CLOTTING_AGENT
	cost = 10

/datum/borer_chem/arm/unlockable/cafe_latte
	name = CAFE_LATTE
	cost = 1

/datum/borer_chem/arm/unlockable/iron
	name = IRON
	cost = 1

/datum/borer_chem/leg/unlockable/bustanut
	name = BUSTANUT
	cost = 2

/datum/borer_chem/leg/unlockable/synaptizine
	name = SYNAPTIZINE
	cost = 2