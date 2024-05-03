/datum/borer_evolution/symbiote
	evo_type = BORER_EVOLUTION_SYMBIOTE

// T1
/datum/borer_evolution/symbiote/willing_host
	name = "Willing Host"
	desc = "Ask a host if they are willing, furthering your objectives."
	gain_text = "Some of the monkeys we gave the worms seemed far more... willing than others to be a host. I could've sworn one let them climb up their arm."
	tier = 1
	unlocked_evolutions = list(/datum/borer_evolution/symbiote/chem_per_level)
	evo_cost = 1
	added_action = /datum/action/cooldown/borer/willing_host
	skip_for_neutered = TRUE

// T2
/datum/borer_evolution/symbiote/chem_per_level
	name = "Chemical Increase"
	desc = "Increase the amount of chemicals per level-up you gain."
	gain_text = "The rate of which we've had to clean the borer pens is increasing. Perhaps their secretions are excess chemicals they cannot use?"
	tier = 2
	unlocked_evolutions = list(/datum/borer_evolution/symbiote/expanded_chemicals)

/datum/borer_evolution/symbiote/chem_per_level/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.chem_storage_per_level += 10
	cortical_owner.chem_regen_per_level += 0.5
	cortical_owner.recalculate_stats()

// T3 + T2 Path
/datum/borer_evolution/symbiote/expanded_chemicals
	name = "Expanded Chemical List"
	desc = "Gain access to a new list of helpful chemicals to the unlockable list."
	gain_text = "The chemicals the worms seem capable of synthesizing are truly remarkable, their hosts are able to get up from amazing amounts of harm."
	mutually_exclusive = TRUE
	tier = 3
	unlocked_evolutions = list(
		/datum/borer_evolution/symbiote/harm_decrease,
		/datum/borer_evolution/symbiote/chem_per_level/t2,
	)
	var/static/list/added_chemicals = list(
		/datum/reagent/medicine/sal_acid,
		/datum/reagent/medicine/oxandrolone,
		/datum/reagent/medicine/atropine,
		/datum/reagent/medicine/neurine,
		/datum/reagent/medicine/leporazine,
		/datum/reagent/medicine/omnizine,
	)

/datum/borer_evolution/symbiote/expanded_chemicals/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.potential_chemicals |= added_chemicals

/datum/borer_evolution/symbiote/chem_per_level/t2
	name = "Chemical Increase II"
	desc = "Increase the amount of chemicals per level-up you gain even further."
	tier = -1
	unlocked_evolutions = list(/datum/borer_evolution/symbiote/chem_per_level/t3)

/datum/borer_evolution/symbiote/chem_per_level/t3
	name = "Chemical Increase III"
	desc = "Increase the amount of chemicals per level-up you gain even further."
	tier = -1
	unlocked_evolutions = list()

// T4 and path
/datum/borer_evolution/symbiote/harm_decrease
	name = "Toxins Decrease"
	desc = "Decrease the passive and active damage you do to your host, and how often it occurs."
	gain_text = "However, some of the others became... if not smaller, certainly longer, more lithe."
	tier = 4
	unlocked_evolutions = list(
		/datum/borer_evolution/symbiote/harm_decrease/t2,
		/datum/borer_evolution/symbiote/revive_host,
	)

/datum/borer_evolution/symbiote/harm_decrease/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.host_harm_multiplier -= 0.25

/datum/borer_evolution/symbiote/harm_decrease/t2
	name = "Toxins Decrease II"
	desc = "Further decrease the passive and active damage you do to your host, and how often it occurs."
	tier = -1
	unlocked_evolutions = list(/datum/borer_evolution/symbiote/harm_decrease/t3)

/datum/borer_evolution/symbiote/harm_decrease/t3
	name = "Toxins Decrease III"
	desc = "Further decrease the passive and active damage you do to your host, and how often it occurs."
	tier = -1
	unlocked_evolutions = list()

// T5
/datum/borer_evolution/symbiote/revive_host
	name = "Revive Host"
	desc = "Revive your host and heal what ails them."
	gain_text = "As I was in the lab, the most curious occurance so far happened. A Cortical Borer went into one of the cadaver's heads, and moments later they were standing again."
	evo_cost = 3
	tier = 5
	unlocked_evolutions = list(
		/datum/borer_evolution/sugar_immunity,
		/datum/borer_evolution/synthetic_borer,
		/datum/borer_evolution/synthetic_chems_positive,
	)
	added_action = /datum/action/cooldown/borer/revive_host
