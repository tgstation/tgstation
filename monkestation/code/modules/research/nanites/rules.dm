/datum/nanite_rule
	var/name = "Generic Condition"
	var/desc = "When triggered, the program is active"
	var/datum/nanite_program/program

/datum/nanite_rule/New(datum/nanite_program/new_program)
	program = new_program
	if(LAZYLEN(new_program.rules) <= 5) //Avoid infinite stacking rules
		new_program.rules += src
	else
		qdel(src)

/datum/nanite_rule/proc/remove()
	program.rules -= src
	program = null
	qdel(src)

/datum/nanite_rule/proc/check_rule()
	return TRUE

/datum/nanite_rule/proc/display()
	return name

/datum/nanite_rule/proc/copy_to(datum/nanite_program/new_program)
	new type(new_program)

/datum/nanite_rule/health
	name = "Health"
	desc = "Checks the host's health status."

	var/threshold = 50
	var/above = TRUE

/datum/nanite_rule/health/check_rule()
	var/health_percent = program.host_mob.health / program.host_mob.maxHealth * 100

	return above == health_percent >= threshold

/datum/nanite_rule/health/display()
	return "[name] [above ? ">" : "<"] [threshold]%"

/datum/nanite_rule/health/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/health/rule = new(new_program)
	rule.above = above
	rule.threshold = threshold

/datum/nanite_rule/crit
	name = "Crit"
	desc = "Checks if the host is in critical condition."

	var/when_crit = TRUE

/datum/nanite_rule/crit/check_rule()
	return when_crit == HAS_TRAIT(program.host_mob, TRAIT_CRITICAL_CONDITION)

/datum/nanite_rule/crit/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/crit/rule = new(new_program)
	rule.when_crit = when_crit

/datum/nanite_rule/crit/display()
	return when_crit ? name : "Not [name]"

/datum/nanite_rule/death
	name = "Death"
	desc = "Checks if the host is dead."

	var/when_dead = TRUE

/datum/nanite_rule/death/check_rule()
	return when_dead == (program.host_mob.stat == DEAD)

/datum/nanite_rule/death/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/death/rule = new(new_program)
	rule.when_dead = when_dead

/datum/nanite_rule/death/display()
	return when_dead ? "Dead" : "Not Dead"

/datum/nanite_rule/cloud_sync
	name = "Cloud Sync"
	desc = "Checks if the nanites have cloud sync enabled or disabled."
	var/check_type = "Enabled"

/datum/nanite_rule/cloud_sync/check_rule()
	return (check_type == "Enabled") == program.nanites.cloud_active

/datum/nanite_rule/cloud_sync/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/cloud_sync/rule = new(new_program)
	rule.check_type = check_type

/datum/nanite_rule/cloud_sync/display()
	return "[name]:[check_type]"

/datum/nanite_rule/nanites
	name = "Nanite Volume"
	desc = "Checks the host's nanite volume."

	var/threshold = 50
	var/above = TRUE

/datum/nanite_rule/nanites/check_rule()
	var/nanite_percent = (program.nanites.nanite_volume - program.nanites.safety_threshold)/(program.nanites.max_nanites - program.nanites.safety_threshold)*100

	return above == nanite_percent >= threshold

/datum/nanite_rule/nanites/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/nanites/rule = new(new_program)
	rule.above = above
	rule.threshold = threshold

/datum/nanite_rule/nanites/display()
	return "[name] [above ? ">" : "<"] [threshold]%"

/datum/nanite_rule/damage
	name = "Damage"
	desc = "Checks the host's damage."

	var/threshold = 50
	var/above = TRUE
	var/damage_type = BRUTE

/datum/nanite_rule/damage/check_rule()
	var/damage_amt = 0

	switch(lowertext(damage_type))
		if(BRUTE)
			damage_amt = program.host_mob.getBruteLoss()
		if(BURN)
			damage_amt = program.host_mob.getFireLoss()
		if(TOX)
			damage_amt = program.host_mob.getToxLoss()
		if(OXY)
			damage_amt = program.host_mob.getOxyLoss()
		if(CLONE)
			damage_amt = program.host_mob.getCloneLoss()
		if(BRAIN)
			damage_amt = program.host_mob.get_organ_loss(ORGAN_SLOT_BRAIN)

	return above == damage_amt >= threshold

/datum/nanite_rule/damage/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/damage/rule = new(new_program)

	rule.above = above
	rule.threshold = threshold
	rule.damage_type = damage_type

/datum/nanite_rule/damage/display()
	return "[damage_type] [above ? ">" : "<"] [threshold]"

/datum/nanite_rule/blood
	name = "Blood"
	desc = "Checks the host's blood volume."

	var/threshold = 90
	var/above = TRUE

/datum/nanite_rule/blood/check_rule()
	var/host_blood_percent = program.host_mob.blood_volume / BLOOD_VOLUME_NORMAL * 100

	return above == host_blood_percent >= threshold

/datum/nanite_rule/blood/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/blood/rule = new(new_program)

	rule.threshold = threshold
	rule.above = above

/datum/nanite_rule/blood/display()
	return "[name] [above ? ">" : "<"] [threshold]%"

/datum/nanite_rule/nutrition
	name = "Nutrition"
	desc = "Checks the host's nutrition level."

	var/threshold = 90
	var/above = TRUE

/datum/nanite_rule/nutrition/check_rule()
	var/host_nutrition_percent = program.host_mob.nutrition / NUTRITION_LEVEL_FED * 100

	return above == host_nutrition_percent >= threshold

/datum/nanite_rule/nutrition/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/nutrition/rule = new(new_program)
	rule.threshold = threshold
	rule.above = above

/datum/nanite_rule/nutrition/display()
	return "[name] [above ? ">" : "<"] [threshold]%"

/datum/nanite_rule/species
	name = "Species"
	desc = "Checks the host's species."

	var/when_is_species
	var/list/species_list
	var/species_name

/datum/nanite_rule/species/check_rule()
	var/species_type = species_list[species_name]

	if (!species_type) // "Other" check
		for (var/name in species_list)
			if (is_species(program.host_mob, species_type))
				return !when_is_species
		return when_is_species

	return when_is_species == is_species(program.host_mob, species_type)

/datum/nanite_rule/species/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/species/rule = new(new_program)

	rule.when_is_species = when_is_species
	rule.species_list = species_list
	rule.species_name = species_name

	return rule

/datum/nanite_rule/species/display()
	return "[name] [when_is_species ? "Is" : "Isn't"] [species_name]"
