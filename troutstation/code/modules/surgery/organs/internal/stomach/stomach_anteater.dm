/obj/item/organ/stomach/anteater
	name = "anteater stomach"
	desc = "Like a human stomach, but, uh, slower? I guess?? Works great on ants, though."
	metabolism_efficiency = 0.04 // very slightly worse than a human stomach
	var/ant_digestion_efficiency = 0.2 // how many units of nutriment is a unit of ant worth?

/obj/item/organ/stomach/anteater/on_mob_insert(mob/living/carbon/stomach_owner)
	. = ..()
	RegisterSignal(stomach_owner, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose))

/obj/item/organ/stomach/anteater/on_mob_remove(mob/living/carbon/stomach_owner)
	. = ..()
	UnregisterSignal(stomach_owner, COMSIG_ATOM_EXPOSE_REAGENTS)

/obj/item/organ/stomach/anteater/proc/on_expose(atom/source, list/reagents, datum/reagents/source_reagents, methods)
	SIGNAL_HANDLER
	var/mob/living/exposed_mob = source
	if(!exposed_mob)
		return
	if(exposed_mob.stat == DEAD)
		return
	if(!(methods & INGEST))
		return // anteaters are not immune to being bit by ants
	var/ants_amount = 0
	for (var/datum/reagent/ants/ants in reagents)
		ants_amount += ants.volume
	if(ants_amount == 0)
		return
	// take out any ants and replace with the same quantity of nutriment
	source_reagents.del_reagent(/datum/reagent/ants)
	var/amount_added = ants_amount * ant_digestion_efficiency
	source_reagents.add_reagent(/datum/reagent/consumable/nutriment, amount_added)
	to_chat(exposed_mob, span_notice("Yum, ants!"))
