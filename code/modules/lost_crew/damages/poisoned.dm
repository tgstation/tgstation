/// Simulates being killed by poison
/datum/corpse_damage/cause_of_death/poison
	/// The reagent used to kill
	var/datum/reagent/poison

	/// The minimum reagents added to the body
	var/min_reagents = 30
	/// The maximum reagents added to the body
	var/max_reagents = 50
	/// the amount of metabolisations to simulate per reagent added
	var/metabolisations_per_unit = 1

/datum/corpse_damage/cause_of_death/poison/apply_to_body(mob/living/carbon/human/body, severity, list/storage)
	var/reagents_to_add = round(min_reagents + (max_reagents - min_reagents) * severity)

	body.reagents.add_reagent(poison, reagents_to_add)
	// we can just abuse deltatime to instantly simulate a long exposure
	body.reagents.metabolize(body, 2 * metabolisations_per_unit * reagents_to_add, liverless = FALSE, dead = FALSE)

/datum/corpse_damage/cause_of_death/poison/venom
	cause_of_death = "when I got bit by a spider!"
	poison = /datum/reagent/toxin/venom
