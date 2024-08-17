///A single type of growth.
/datum/micro_organism
	///Name, shown on microscope
	var/name = "Unknown fluids"
	///Desc, shown by science goggles
	var/desc = "White fluid that tastes like salty coins and milk"

///Returns a short description of the cell line
/datum/micro_organism/proc/get_details(show_details)
	return span_notice("[desc]")

///A "mob" cell. Can grow into a mob in a growing vat.
/datum/micro_organism/cell_line
	///Our growth so far, needs to get up to 100
	var/growth = 0
	///All the reagent types required for letting this organism grow into whatever it should become
	var/list/required_reagents
	///Reagent types that further speed up growth, but aren't needed.  Assoc list of reagent datum type || bonus growth per tick
	var/list/supplementary_reagents
	///Reagent types that surpress growth. Assoc list of reagent datum type || lost growth per tick
	var/list/suppressive_reagents
	///This var modifies how much this micro_organism is affected by viruses. Higher is more slowdown
	var/virus_suspectibility = 1
	///This var defines how much % the organism grows per process(), without modifiers, if you have all required reagents
	var/growth_rate = 4
	///This var defines how many units of every reagent is consumed during growth per process()
	var/consumption_rate = REAGENTS_METABOLISM
	///Resulting atom from growing this cell line
	var/atom/resulting_atom
	///The number of resulting atoms
	var/resulting_atom_count = 1

///Handles growth of the micro_organism. This only runs if the micro organism is in the growing vat. Reagents is the growing vats reagents
/datum/micro_organism/cell_line/proc/handle_growth(obj/machinery/vatgrower/vat)
	if(!try_eat(vat.reagents))
		return FALSE
	growth = max(growth, growth + calculate_growth(vat.reagents, vat.biological_sample)) //Prevent you from having minus growth.
	if(growth >= 100)
		finish_growing(vat)
	return TRUE

///Tries to consume the required reagents. Can only do this if all of them are available. Reagents is the growing vats reagents
/datum/micro_organism/cell_line/proc/try_eat(datum/reagents/reagents)
	for(var/i in required_reagents)
		if(!reagents.has_reagent(i))
			return FALSE
	for(var/i in required_reagents) //Delete the required reagents if used
		reagents.remove_reagent(i, consumption_rate)
	return TRUE

///Apply modifiers on growth_rate based on supplementary and supressive reagents. Reagents is the growing vats reagents
/datum/micro_organism/cell_line/proc/calculate_growth(datum/reagents/reagents, datum/biological_sample/biological_sample)
	. = growth_rate

	//Handle growth based on supplementary reagents here.
	for(var/i in supplementary_reagents)
		if(!reagents.has_reagent(i, consumption_rate))
			continue
		. += supplementary_reagents[i]
		reagents.remove_reagent(i, consumption_rate)

	//Handle degrowth based on supressive reagents here.
	for(var/i in suppressive_reagents)
		if(!reagents.has_reagent(i, consumption_rate))
			continue
		. += suppressive_reagents[i]
		reagents.remove_reagent(i, consumption_rate)

	//Handle debuffing growth based on viruses here.
	for(var/datum/micro_organism/virus/active_virus in biological_sample.micro_organisms)
		if(reagents.has_reagent(/datum/reagent/medicine/spaceacillin, consumption_rate))
			reagents.remove_reagent(/datum/reagent/medicine/spaceacillin, consumption_rate)
			continue //This virus is stopped, We have antiviral stuff
		. -= virus_suspectibility

///Called once a cell line reaches 100 growth. Then we check if any cell_line is too far so we can perform an epic fail roll
/datum/micro_organism/cell_line/proc/finish_growing(obj/machinery/vatgrower/vat)
	var/risk = 0 //Penalty for failure, goes up based on how much growth the other cell_lines have

	for(var/datum/micro_organism/cell_line/cell_line in vat.biological_sample.micro_organisms)
		if(cell_line == src) //well duh
			continue
		if(cell_line.growth >= VATGROWING_DANGER_MINIMUM)
			risk += cell_line.growth * 0.6 //60% per cell_line potentially. Kryson should probably tweak this
	playsound(vat, 'sound/effects/splat.ogg', 50, TRUE)
	if(rand(1, 100) < risk) //Fail roll!
		fuck_up_growing(vat)

		return FALSE
	succeed_growing(vat)
	return TRUE

/datum/micro_organism/cell_line/proc/fuck_up_growing(obj/machinery/vatgrower/vat)
	vat.visible_message(span_warning("The biological sample in [vat] seems to have dissipated!"))
	if(prob(50))
		new /obj/effect/gibspawner/generic(get_turf(vat)) //Spawn some gibs.
	if(SEND_SIGNAL(vat.biological_sample, COMSIG_SAMPLE_GROWTH_COMPLETED) & SPARE_SAMPLE)
		return
	QDEL_NULL(vat.biological_sample)

/datum/micro_organism/cell_line/proc/succeed_growing(obj/machinery/vatgrower/vat)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = vat, location = vat.loc)
	smoke.start()
	for(var/x in 1 to resulting_atom_count)
		var/atom/thing = new resulting_atom(get_turf(vat))
		ADD_TRAIT(thing, TRAIT_VATGROWN, "vatgrowing")
		vat.visible_message(span_nicegreen("[thing] pops out of [vat]!"))
	if(SEND_SIGNAL(vat.biological_sample, COMSIG_SAMPLE_GROWTH_COMPLETED) & SPARE_SAMPLE)
		return
	QDEL_NULL(vat.biological_sample)

///Overriden to show more info like needs, supplementary and supressive reagents and also growth.
/datum/micro_organism/cell_line/get_details(show_details)
	. += "[span_notice("[desc] - growth progress: [growth]%")]"
	if(show_details)
		. += "\n- " + return_reagent_text("Requires:", required_reagents)
		. += "\n- " + return_reagent_text("Likes:", supplementary_reagents)
		. += "\n- " + return_reagent_text("Hates:", suppressive_reagents)

///Return a nice list of all the reagents in a specific category with a specific prefix. This needs to be reworked because the formatting sucks ass.
/datum/micro_organism/cell_line/proc/return_reagent_text(prefix_text = "It requires:", list/reagentlist)
	if(!reagentlist.len)
		return
	var/list/reagent_names = list()
	for(var/i in reagentlist)
		var/datum/reagent/reagent = i
		reagent_names += initial(reagent.name)
	return span_notice("[prefix_text] [jointext(reagent_names, ", ")]")
