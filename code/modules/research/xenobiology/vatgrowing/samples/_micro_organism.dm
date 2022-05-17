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
	///Resulting atoms from growing this cell line. List is assoc atom type || amount
	var/list/resulting_atoms = list()

///Handles growth of the micro_organism. This only runs if the micro organism is in the growing vat. Reagents is the growing vats reagents
/datum/micro_organism/cell_line/proc/handle_growth(obj/machinery/plumbing/growing_vat/vat)
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
		reagents.remove_reagent(i, REAGENTS_METABOLISM)
	return TRUE

///Apply modifiers on growth_rate based on supplementary and supressive reagents. Reagents is the growing vats reagents
/datum/micro_organism/cell_line/proc/calculate_growth(datum/reagents/reagents, datum/biological_sample/biological_sample)
	. = growth_rate

	//Handle growth based on supplementary reagents here.
	for(var/i in supplementary_reagents)
		if(!reagents.has_reagent(i, REAGENTS_METABOLISM))
			continue
		. += supplementary_reagents[i]
		reagents.remove_reagent(i, REAGENTS_METABOLISM)

	//Handle degrowth based on supressive reagents here.
	for(var/i in suppressive_reagents)
		if(!reagents.has_reagent(i, REAGENTS_METABOLISM))
			continue
		. += suppressive_reagents[i]
		reagents.remove_reagent(i, REAGENTS_METABOLISM)

	//Handle debuffing growth based on viruses here.
	for(var/datum/micro_organism/virus/active_virus in biological_sample.micro_organisms)
		if(reagents.has_reagent(/datum/reagent/medicine/spaceacillin, REAGENTS_METABOLISM))
			reagents.remove_reagent(/datum/reagent/medicine/spaceacillin, REAGENTS_METABOLISM)
			continue //This virus is stopped, We have antiviral stuff
		. -= virus_suspectibility

///Called once a cell line reaches 100 growth. Then we check if any cell_line is too far so we can perform an epic fail roll
/datum/micro_organism/cell_line/proc/finish_growing(obj/machinery/plumbing/growing_vat/vat)
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

/datum/micro_organism/cell_line/proc/fuck_up_growing(obj/machinery/plumbing/growing_vat/vat)
	vat.visible_message(span_warning("The biological sample in [vat] seems to have dissipated!"))
	if(prob(50))
		new /obj/effect/gibspawner/generic(get_turf(vat)) //Spawn some gibs.
	if(SEND_SIGNAL(vat.biological_sample, COMSIG_SAMPLE_GROWTH_COMPLETED) & SPARE_SAMPLE)
		return
	QDEL_NULL(vat.biological_sample)

/datum/micro_organism/cell_line/proc/succeed_growing(obj/machinery/plumbing/growing_vat/vat)
	process_resulting_spawners(vat)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, location = vat.loc)
	smoke.start()
	for(var/created_thing in resulting_atoms)
		for(var/x in 1 to resulting_atoms[created_thing])
			var/atom/thing = new created_thing(get_turf(vat))
			ADD_TRAIT(thing, TRAIT_VATGROWN, "vatgrowing")
			vat.visible_message(span_nicegreen("[thing] pops out of [vat]!"))
	if(SEND_SIGNAL(vat.biological_sample, COMSIG_SAMPLE_GROWTH_COMPLETED) & SPARE_SAMPLE)
		return
	QDEL_NULL(vat.biological_sample)

///Goes through the resulting_atoms of this cell_line and turns any /obj/effect/spawner/random entries into weighed random picks from its loot list.
///This happens recursively until there are no more random spawners in resulting_atoms. Or unitl enough iterations have happened to give up.
///Returns TRUE if the proc succeeded in processing all random spawners, and false if gave up after going through too many iterations.
///Note that all spawners used in resulting_atoms MUST have spawn_on_init set to FALSE.
/datum/micro_organism/cell_line/proc/process_resulting_spawners(obj/machinery/plumbing/growing_vat/vat, var/iterations = 0)
	if(!is_type_in_list(/obj/effect/spawner/random, resulting_atoms)) //there are no random spawners in here, we can stop
		return TRUE

	if(iterations > 10) //at this rate it might go on forever, we won't stick around to find out though
		WARNING("Could not process all cell_line.resulting_atoms random spawners, exceeded maximum allowed iterations!")
		return FALSE

	var/list/spawner_checked_resulting_atoms = list() //create a list to put the new results into

	for(var/resulting_atom in resulting_atoms) //go through each resulting_atom
		if(ispath(resulting_atom, /obj/effect/spawner/random))
			//if resulting_atom is a random spawner, get a random pick from it and add it to the list
			var/obj/effect/spawner/random/random_spawner = new resulting_atom(get_turf(vat)) //create an instance of the spawner to access its loot
			for(var/x in 1 to resulting_atoms[resulting_atom]) //for each count of this specific spawner
				var/lootspawn = pick_weight(fill_with_ones(random_spawner.loot)) //pick a weighed random thing from the spawner loot list
				while(islist(lootspawn))
					lootspawn = pick_weight(fill_with_ones(lootspawn))
				spawner_checked_resulting_atoms[lootspawn] += 1 //and add it to the new list
			random_spawner.Destroy() //then clean up the used spawner
		else
			//if resulting_atom is not actually a random spawner, you can just put it in the new list as is
			spawner_checked_resulting_atoms[resulting_atom] = resulting_atoms[resulting_atom]

	resulting_atoms = spawner_checked_resulting_atoms //replace the old list with the new one
	return process_resulting_spawners(vat, iterations++) //spawners might spawn more spawners, keep going recursively until there are no spawners
//TODO fix this putting down frog spawners instead of the frogs

///Overriden to show more info like needs, supplementary and supressive reagents and also growth.
/datum/micro_organism/cell_line/get_details(show_details)
	. += "[span_notice("[desc] - growth progress: [growth]%")]\n"
	if(show_details)
		. += return_reagent_text("It requires:", required_reagents)
		. += return_reagent_text("It likes:", supplementary_reagents)
		. += return_reagent_text("It hates:", suppressive_reagents)

///Return a nice list of all the reagents in a specific category with a specific prefix. This needs to be reworked because the formatting sucks ass.
/datum/micro_organism/cell_line/proc/return_reagent_text(prefix_text = "It requires:", list/reagentlist)
	if(!reagentlist.len)
		return
	var/all_reagents_text
	for(var/i in reagentlist)
		var/datum/reagent/reagent = i
		all_reagents_text += " - [initial(reagent.name)]\n"
	return span_notice("[prefix_text]\n[all_reagents_text]")
