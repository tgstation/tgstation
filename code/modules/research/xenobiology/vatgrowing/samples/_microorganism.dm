///A single type of growth.
/datum/micro_organism
	///Desc, shown by science goggles
	var/desc = "White fluid that tastes like salty coins and milk"
	///Our petri dish. This lets us be interacted with after the swabbing process
	var/obj/item/petri_dish/petri_dish

///A "mob" cell. Can grow into a mob in a growing vat.
/datum/micro_organism/cell_line
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
	///Resulting mobs from growing this cell line
	var/list/resulting_mobs = list()

///Handles growth of the micro_organism. This only runs if the micro organism is in a petri dish in the growing vat.
/datum/micro_organism/cell_line/proc/HandleGrowth(var/datum/reagents/reagents)
	. = ..()
	if(!can_grow(reagents))
		return

/datum/micro_organism/cell_line/proc/can_grow(var/datum/reagents/reagents)
	if(!petri_dish)
		return FALSE
	for(var/i in required_reagents)
		if(!has_reagent())
			return FALSE

/datum/micro_organism/cell_line/proc/calculate_growth(var/datum/reagents/reagents)
	. = growth_rate

