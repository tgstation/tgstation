///Element used for interfacing with the plumbing people milker machine
/datum/element/plumbing_milkable
	var/list/required_reagents = list(/datum/reagent/water = 2)
	var/list/returned_reagents = list(/datum/reagent/consumable/lemonade = 1)

	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH

/datum/element/plumbing_milkable/Attach(datum/target, list/required_reagents, list/returned_reagents)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE

	if(required_reagents)
		required_reagents = src.required_reagents
	if(returned_reagents)
		returned_reagents = src.returned_reagents

///Check if all required reagents are present
/datum/element/plumbing_milkable/proc/has_required(datum/reagents/victim)
	for(var/A in required_reagents)
		if(!victim.has_reagent(A, required_reagents[A]))
			return FALSE
	return TRUE

///Remove the required reagents
/datum/element/plumbing/milkable/proc/take_required(datum/reagents/victim)
	for(var/A in required_reagents)
		victim.remove_reagent(A, required_reagents[A])

///Add the returned reagents to  whoever wants it
/datum/element/plumbing_milkable/proc/grant_reagents(datum/reagents/target)
	for(var/A in returned_reagents)
		target.add_reagent(A, returned_reagents[A])

///Attempt to trade reagents from the victim to the target
/datum/element/plumbing_milkable/proc/try_trade(datum/reagents/target, datum/reagents/victim)
	if(!has_required(victim))
		return FALSE

	take_required(victim)
	grant_reagents(target)

	return TRUE

