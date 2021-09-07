/datum/element/crusher_loot
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	var/item_to_drop
	var/chance

/datum/element/crusher_loot/Attach(datum/target, item_to_drop, chance = 25)
	. = ..()
	if(!isliving)
		return ELEMENT_INCOMPATIBLE
	src.item_to_drop = item_to_drop
	src.chance = chance
	RegisterSignal(target, COMSIG_LIVING_DEATH, .proc/on_death)

/datum/element/crusher_loot/Detach(datum/target)
	UnregisterSignal(target, COMSIG_LIVING_DEATH)
	return ..()

/datum/element/crusher_loot/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	var/datum/status_effect/crusher_damage/crusher_effect = target.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	if(crusher_effect && prob((crusher_effect.total_damage/target.maxHealth) * crusher_drop_mod)) //The more damage done by crusher, the more likely the loot is to spawn.
		target.butcher_results[item_to_drop] = 1
