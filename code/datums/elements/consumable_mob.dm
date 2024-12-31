/**
 * element for mobs that can be consumed!
 */
/datum/element/consumable_mob
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///reagents to give our consumer
	var/list/reagents_list

/datum/element/consumable_mob/Attach(datum/target, list/reagents_list)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(isnull((reagents_list)))
		stack_trace("No valid reagents list provided!")

	src.reagents_list = reagents_list
	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_consume))

/datum/element/consumable_mob/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_ATTACK_HAND)

/datum/element/consumable_mob/proc/on_consume(atom/movable/source, mob/living/consumer)
	SIGNAL_HANDLER
	if(!consumer.combat_mode || !consumer.reagents || HAS_TRAIT(consumer, TRAIT_PACIFISM))
		return
	for(var/reagent_type in reagents_list)
		if(isnull(reagents_list[reagent_type]))
			return
		consumer.reagents.add_reagent(reagent_type, reagents_list[reagent_type])

