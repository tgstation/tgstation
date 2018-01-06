//This file exists purely to assign mass assign density values to reagents for use with the reagent forge without making a ton of unwanted references in our other reagent files
//assign any value that isn't density or a special effect in here and there will be space hell to pay


//BASE TYPES

/datum/reagent
	var/density = 2
	var/list/special_traits

/datum/reagent/toxin//ahaha no you can't have high force and traitorchem effects
	density = 1

/datum/reagent/consumable//meh
	density = 1.5

/datum/reagent/drug//drugs are on average less lethal than toxins
	density = 1.8

/datum/reagent/medicine//good man
	density = 0.5

//METALS

/datum/reagent/iron
	density = 6
	special_traits = list(SPECIAL_TRAIT_METALLIC, SPECIAL_TRAIT_SHARP)

/datum/reagent/uranium
	density = 12
	special_traits = list(SPECIAL_TRAIT_METALLIC, SPECIAL_TRAIT_RADIOACTIVE, SPECIAL_TRAIT_ULTRADENSE)

/datum/reagent/sodium
	density = 3
	special_traits = list(SPECIAL_TRAIT_METALLIC)

/datum/reagent/potassium
	density = 3.5
	special_traits = list(SPECIAL_TRAIT_METALLIC)

/datum/reagent/aluminium
	density = 4.5
	special_traits = list(SPECIAL_TRAIT_METALLIC, SPECIAL_TRAIT_SHARP, SPECIAL_TRAIT_MAGNETIC)

/datum/reagent/mercury
	density = 7
	special_traits = list(SPECIAL_TRAIT_METALLIC)

/datum/reagent/copper
	density = 5
	special_traits = list(SPECIAL_TRAIT_METALLIC, SPECIAL_TRAIT_SHARP)

/datum/reagent/lithium
	density = 2.5
	special_traits = list(SPECIAL_TRAIT_METALLIC)

/datum/reagent/gold
	density = 9
	special_traits = list(SPECIAL_TRAIT_METALLIC, SPECIAL_TRAIT_ULTRADENSE)

/datum/reagent/silver
	density = 6.5
	special_traits = list(SPECIAL_TRAIT_METALLIC)

/datum/reagent/toxin/polonium
	density = 6
	special_traits = list(SPECIAL_TRAIT_METALLIC, SPECIAL_TRAIT_RADIOACTIVE)

//RADIOACTIVES

/datum/reagent/toxin/mutagen
	special_traits = list(SPECIAL_TRAIT_METALLIC, SPECIAL_TRAIT_RADIOACTIVE)

/datum/reagent/radium
	special_traits = list(SPECIAL_TRAIT_RADIOACTIVE)

/datum/reagent/toxin/radgoop
	special_traits  = list(SPECIAL_TRAIT_RADIOACTIVE)

/datum/reagent/arclumin
	special_traits  = list(SPECIAL_TRAIT_RADIOACTIVE, SPECIAL_TRAIT_MAGNETIC)

//BOUNCY

/datum/reagent/lube
	special_traits = list(SPECIAL_TRAIT_BOUNCY, SPECIAL_TRAIT_FLUIDIC)

/datum/reagent/plastic_polymers
	special_traits = list(SPECIAL_TRAIT_BOUNCY, SPECIAL_TRAIT_REFLECTIVE)

/datum/reagent/toxin/slimejelly
	special_traits = list(SPECIAL_TRAIT_BOUNCY)

//PYROTECHNICS

/datum/reagent/dizinc
	special_traits = list(SPECIAL_TRAIT_FIRE)

/datum/reagent/oxyplas
	special_traits = list(SPECIAL_TRAIT_FIRE)

/datum/reagent/proto
	special_traits = list(SPECIAL_TRAIT_FIRE)

/datum/reagent/clf3
	special_traits = list(SPECIAL_TRAIT_FIRE)

/datum/reagent/phlogiston
	special_traits = list(SPECIAL_TRAIT_FIRE)

/datum/reagent/cryogenic_fluid
	special_traits = list(SPECIAL_TRAIT_CRYO)

/datum/reagent/cryostylane
	special_traits = list(SPECIAL_TRAIT_CRYO)

//ACIDS

/datum/reagent/toxin/acid
	special_traits = list(SPECIAL_TRAIT_ACID)

//EXPLOSIVES

/datum/reagent/superboom
	special_traits = list(SPECIAL_TRAIT_EXPLOSIVE)

/datum/reagent/toxin/sazide
	special_traits = list(SPECIAL_TRAIT_EXPLOSIVE)

/datum/reagent/nitroglycerin
	special_traits = list(SPECIAL_TRAIT_EXPLOSIVE)

/datum/reagent/blackpowder
	special_traits = list(SPECIAL_TRAIT_EXPLOSIVE)

/datum/reagent/nitrous_oxide
	special_traits = list(SPECIAL_TRAIT_EXPLOSIVE)

//MISC

/datum/reagent/oxygen
	special_traits = list(SPECIAL_TRAIT_MAGNETIC)

/datum/reagent/water
	special_traits = list(SPECIAL_TRAIT_REFLECTIVE)

/datum/reagent/arclumin
	special_traits = list(SPECIAL_TRAIT_UNSTABLE)

/datum/reagent/bluespace
	special_traits = list(SPECIAL_TRAIT_UNSTABLE)

/datum/reagent/drug/flipout
	special_traits = list(SPECIAL_TRAIT_FLUIDIC)

/datum/reagent/colorful_reagent
	special_traits = list(SPECIAL_TRAIT_FLUIDIC)