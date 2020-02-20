/datum/micro_organism
	///Desc, shown by science goggles
	var/desc = "White fluid that tastes like salty coins and milk"
	///All the reagents required for letting this organism grow into whatever it should become
	var/list/required_reagents
	///Reagents that further speed up growth, but aren't needed.  Assoc list of reagent datum || bonus growth per tick
	var/list/supplementary_reagents
	///Reagents that surpress growth. Assoc list of reagent datum || lost growth per tick
	var/list/surpressive_reagents
	///This var modifies how much this micro_organism is affected by viruses. Higher is more slowdown
	var/virus_suspectibility = 1
	///This var defines how much % the organism grows per process(), without modifiers, if you have all required reagents
	var/growth_rate = 4
	///Our petri dish, we check our reagents in this if we can
	var/obj/item/petri_dish/petri_dish

///Handles growth of the micro_organism. This only runs if the micro organism is in a petri dish in the growing vat.
/datum/micro_organism/process()
	. = ..()
	if(!can_grow())
		return


/datum/micro_organism/proc/can_grow()
	if(!petri_dish)
		return FALSE


/datum/micro_organism/proc/calculate_growth()
	. = growth_rate

