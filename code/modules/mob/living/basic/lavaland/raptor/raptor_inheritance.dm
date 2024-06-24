#define RANDOM_INHERIT_AMOUNT 2
/datum/raptor_inheritance
	///list of traits we inherit
	var/list/inherit_traits = list()
	///attack modifier
	var/attack_modifier
	///health_modifier
	var/health_modifier

/datum/raptor_inheritance/New(datum/raptor_inheritance/father, datum/raptor_inheritance/mother)
	. = ..()
	randomize_stats()

/datum/raptor_inheritance/proc/randomize_stats()
	attack_modifier = rand(0, RAPTOR_INHERIT_MAX_ATTACK)
	health_modifier = rand(0, RAPTOR_INHERIT_MAX_HEALTH)
	var/list/traits_to_pick = GLOB.raptor_inherit_traits.Copy()
	for(var/i in 1 to RANDOM_INHERIT_AMOUNT)
		inherit_traits += pick_n_take(traits_to_pick)

/datum/raptor_inheritance/proc/set_parents(datum/raptor_inheritance/father, datum/raptor_inheritance/mother)
	if(isnull(father) || isnull(mother))
		return
	if(length(father.inherit_traits))
		inherit_traits += pick(father.inherit_traits)
	if(length(mother.inherit_traits))
		inherit_traits += pick(mother.inherit_traits)
	attack_modifier = rand(min(father.attack_modifier, mother.attack_modifier), max(father.attack_modifier, mother.attack_modifier))
	health_modifier = rand(min(father.health_modifier, mother.health_modifier), max(father.health_modifier, mother.health_modifier))

#undef RANDOM_INHERIT_AMOUNT
