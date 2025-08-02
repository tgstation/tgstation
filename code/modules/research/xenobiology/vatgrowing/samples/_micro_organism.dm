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
		. = FALSE
	else
		succeed_growing(vat)
		. = TRUE
	SEND_SIGNAL(vat.biological_sample, COMSIG_SAMPLE_GROWTH_COMPLETED)

/datum/micro_organism/cell_line/proc/fuck_up_growing(obj/machinery/vatgrower/vat)
	vat.visible_message(span_warning("The biological sample in [vat] seems to have dissipated!"))
	if(prob(50))
		new /obj/effect/gibspawner/generic(get_turf(vat)) //Spawn some gibs.

/datum/micro_organism/cell_line/proc/succeed_growing(obj/machinery/vatgrower/vat)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = vat, location = vat.loc)
	smoke.start()
	for(var/x in 1 to resulting_atom_count)
		var/atom/thing = new resulting_atom(get_turf(vat))
		ADD_TRAIT(thing, TRAIT_VATGROWN, "vatgrowing")
		vat.visible_message(span_nicegreen("[thing] pops out of [vat]!"))
		//We maybe add some color. the chance is static for now, but idewally we would be able to manipulate it in the future.
		if(prob(CYTO_SHINY_CHANCE))
			if(isbasicmob(thing))
				var/mob/living/basic/vat_creature = thing
				//if the mob has a special mutation interaction don't do any other mutations. Once we add more mutations that are stackable with shiny we should probably roll for each type independently.
				if(vat_creature.mutate())
					return
			mutate_color(thing)

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

//Adds a hue shift filter and affix to an atom.
/datum/micro_organism/cell_line/proc/mutate_color(atom/beautiful_mutant)
	//This determines how much the hue of the atom is shifted, 0.5 is the most extreme, respresenting a 180° hue shift.
	var/hue_shift = 1
	//This affix is added to the name of the atom, to help players understand and converse about the different rarity levels.
	var/rarity_affix = "glitched"

	switch(rand(1, 100))
		if(1 to 35) //35% chance : painted
			hue_shift = 0.15
			rarity_affix = "painted"
		if(36 to 70) //35% chance : mutant
			hue_shift = 0.85 //this value is equivalent in distance as the painted tier, just in the other direction.
			rarity_affix = "mutant"
		if(71 to 83) //13% chance : rare
			hue_shift = 0.3
			rarity_affix = "rare"
		if(84 to 95) //12% chance : shiny
			hue_shift = 0.7
			rarity_affix = "shiny"
		if(96 to 100) //5% chance : mutant king
			hue_shift = 0.5 //Best in show, most extreme color change.
			rarity_affix = "mutant king" //The name is up to debate, since cyto is all about freaky creatures I thought it was good choice over something like "cosmic" or "regal".

	var/list/mutant_shift_matrix = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, hue_shift,0,0,0) //matrix for our colour shifting.

	//Here we make the changes for the atom, we apply a filter and change the name to indicate rarity.
	beautiful_mutant.add_filter("shiny mutation", 15, color_matrix_filter(mutant_shift_matrix, FILTER_COLOR_HSL))
	beautiful_mutant.name = "[rarity_affix] [beautiful_mutant.name]"
	if(isliving(beautiful_mutant)) //update the real name var if it's actually a living mob
		var/mob/living/living_mutie = beautiful_mutant
		living_mutie.real_name = living_mutie.name
