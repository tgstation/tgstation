/datum/borer_evolution/diveworm
	evo_type = BORER_EVOLUTION_DIVEWORM

// T1
/datum/borer_evolution/diveworm/health_per_level
	name = "Health Increase"
	desc = "Increase the amount of health per level-up you gain."
	gain_text = "Over time, some of the more aggressive worms became harder to dissect post-mortem. Their skin membrane has become up to thrice as thick."
	tier = 1
	unlocked_evolutions = list(/datum/borer_evolution/diveworm/host_speed)
	evo_cost = 1

/datum/borer_evolution/diveworm/health_per_level/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.health_per_level += 2.5
	cortical_owner.recalculate_stats()

// T2
/datum/borer_evolution/diveworm/host_speed
	name = "Boring Speed"
	desc = "Decrease the time it takes to enter a host when you are not hiding."
	gain_text = "Once or twice, I would blink, and see the non-host monkeys be grappling with a worm that was cross the room just moments before."
	tier = 2
	unlocked_evolutions = list(/datum/borer_evolution/diveworm/expanded_chemicals)

/datum/borer_evolution/diveworm/host_speed/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.upgrade_flags |= BORER_FAST_BORING

// T3 + T1 path
/datum/borer_evolution/diveworm/expanded_chemicals
	name = "Expanded Chemical List"
	desc = "Gain access to a new list of devious chemicals to the unlockable list."
	gain_text = "Sometimes, I would just see a known host monkey... collapse, then get up, then collapse again. It was as if the worm was playing with it..."
	mutually_exclusive = TRUE
	tier = 3
	unlocked_evolutions = list(
		/datum/borer_evolution/diveworm/harm_increase,
		/datum/borer_evolution/diveworm/health_per_level/t2,
	)
	var/static/list/added_chemicals = list(
		/datum/reagent/toxin/fentanyl,
		/datum/reagent/toxin/staminatoxin,
		/datum/reagent/toxin/mutetoxin,
		/datum/reagent/toxin/mutagen,
		/datum/reagent/toxin/cyanide,
		/datum/reagent/drug/mushroomhallucinogen,
		/datum/reagent/inverse/oculine,
	)

/datum/borer_evolution/diveworm/expanded_chemicals/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.potential_chemicals |= added_chemicals

/datum/borer_evolution/diveworm/health_per_level/t2
	name = "Health Increase II"
	tier = -1
	unlocked_evolutions = list(/datum/borer_evolution/diveworm/health_per_level/t3)
	evo_cost = 2

/datum/borer_evolution/diveworm/health_per_level/t3
	name = "Health Increase III"
	tier = -1
	unlocked_evolutions = list()
	evo_cost = 2

// T4 + its path
/datum/borer_evolution/diveworm/harm_increase
	name = "Toxins Increase"
	desc = "Increase the passive and active damage you do to your host, and how often it occurs."
	gain_text = "In captivity, some of the worms became more... brutish, larger. Most notably, hosts succumbed much quicker to them."
	tier = 4
	unlocked_evolutions = list(
		/datum/borer_evolution/diveworm/harm_increase/t2,
		/datum/borer_evolution/diveworm/empowered_offspring,
	)

/datum/borer_evolution/diveworm/harm_increase/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.host_harm_multiplier += 0.25

/datum/borer_evolution/diveworm/harm_increase/t2
	name = "Toxins Increase II"
	desc = "Further increase the passive and active damage you do to your host, and how often it occurs."
	tier = -1
	unlocked_evolutions = list(/datum/borer_evolution/diveworm/harm_increase/t3)

/datum/borer_evolution/diveworm/harm_increase/t3
	name = "Toxins Increase III"
	desc = "Further increase the passive and active damage you do to your host, and how often it occurs."
	tier = -1
	unlocked_evolutions = list()

// T5
/datum/borer_evolution/diveworm/empowered_offspring
	name = "Empowered Offspring"
	desc = "Lay an egg in a deceased host, and after a delay an empowered borer will burst out."
	gain_text = "Most eggs would be regurgitated through the throat from their hosts... but one did not. They exploded out the chest like a horror movie. What a worrying discovery."
	evo_cost = 3
	tier = 5
	unlocked_evolutions = list(
		/datum/borer_evolution/sugar_immunity,
		/datum/borer_evolution/synthetic_borer,
		/datum/borer_evolution/synthetic_chems_negative,
	)
	added_action = /datum/action/cooldown/borer/empowered_offspring
	skip_for_neutered = TRUE
