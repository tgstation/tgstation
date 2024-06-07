/datum/reagent/medicine/potass_iodide
	description = "Heals low toxin damage while the patient is irradiated, and will halt the damaging effects of radiation. Can be used to decontaminate irradiated items."

// Reagents that shouldn't be in the random pool due to the fact they derail everything.
/datum/reagent/romerol
	restricted = TRUE

/datum/reagent/gondola_mutation_toxin/virtual_domain
	restricted = TRUE // STOP SHOVING ALL THE WINDOWS AROUND

// Reagents that shouldn't be in the random pool, as they're either completely useless or shouldn't exist on their own.
/datum/reagent/slime_ooze
	restricted = TRUE

/datum/reagent/reaction_agent
	restricted = TRUE

/datum/reagent/catalyst_agent
	restricted = TRUE

/datum/reagent/universal_indicator
	restricted = TRUE

/datum/reagent/blob
	restricted = TRUE

// Reagents that aren't entirely useless but there's a bajillion subtypes and thus the pick is biased.
/datum/reagent/carpet
	random_weight = 2

/datum/reagent/colorful_reagent
	random_weight = 2
