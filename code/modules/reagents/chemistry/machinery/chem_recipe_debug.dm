/*
* A debug chem tester that will process through all recipies automatically and try to react them.
* Highlights low purity reactions and and reactions that don't happen
*/
/obj/machinery/chem_recipe_debug
	name = "chemical reaction tester"
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "HPLC"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	///List of every reaction in the game kept locally for easy access
	var/list/cached_reactions = list()
	///What index in the cached_reactions we're in
	var/index = 1
	///If the machine is currently processing through the list
	var/processing = FALSE
	///Final output that highlights all of the reactions with inoptimal purity/voolume at base
	var/problem_string
	///Final output that highlights all of the reactions with inoptimal purity/voolume at base
	var/impure_string
	///The count of reactions that resolve between 1 - 0.9 purity
	var/minorImpurity
	///The count of reactions that resolve below 0.9 purity
	var/majorImpurity
	///If we failed to react this current chem so use a lower temp
	var/failed = 0

///Create reagents datum
/obj/machinery/chem_recipe_debug/Initialize()
	. = ..()
	create_reagents(9000)//I want to make sure everything fits

///Enable the machine
/obj/machinery/chem_recipe_debug/attackby(obj/item/I, mob/user, params)
	. = .()
	if(processing)
		say("currently processing reaction [index]: [cached_reactions[index]] of [cached_reactions.len]")
		return
	say("Starting processing")
	setup_reactions()
	begin_processing()

///Enable the machine
/obj/machinery/chem_recipe_debug/AltClick(mob/living/user)
	. = ..()
	if(processing)
		say("currently processing reaction [index]: [cached_reactions[index]] of [cached_reactions.len]")
		return
	say("Starting processing")
	setup_reactions()
	begin_processing()

///Resets the index, and creates the cached_reaction list from all possible reactions
/obj/machinery/chem_recipe_debug/proc/setup_reactions()
	cached_reactions = list()
	for(var/V in GLOB.chemical_reactions_list)
		if(is_type_in_list(GLOB.chemical_reactions_list[V], cached_reactions))
			continue
		cached_reactions += GLOB.chemical_reactions_list[V]
	reagents.clear_reagents()
	index = 1
	processing = TRUE

/*
* The main loop that sets up, creates and displays results from a reaction
* warning: this code is a hot mess
*/
/obj/machinery/chem_recipe_debug/process(delta_time)
	if(processing == FALSE)
		setup_reactions()
	if(reagents.is_reacting == TRUE)
		return
	if(index >= cached_reactions.len)
		say("Completed testing, missing reactions products (may have exploded) are:")
		say("[problem_string]")
		say("Problem with results are:")
		say("[impure_string]")
		say("Reactions with minor impurity: [minorImpurity], reactions with major impurity: [majorImpurity]")
		processing = FALSE
		end_processing()
	if(reagents.reagent_list)
		say("Reaction completed for [cached_reactions[index]] final temperature = [reagents.chem_temp], ph = [reagents.ph].")
		var/datum/chemical_reaction/C = cached_reactions[index]
		for(var/R in C.results)
			var/datum/reagent/R2 =  reagents.get_reagent(R)
			if(!R2)
				say("<span class='warning'>Unable to find product [R] in holder after reaction! reagents found are:</span>")
				for(var/R3 in reagents.reagent_list)
					say("[R3]")
				var/obj/item/reagent_containers/glass/beaker/bluespace/B = new /obj/item/reagent_containers/glass/beaker/bluespace(loc)
				reagents.trans_to(B)
				B.name = "[cached_reactions[index]]"
				if(failed > 0)
					problem_string += "[cached_reactions[index]] <span class='warning'>Unable to find product [R] in holder after reaction! index:[index]</span>\n"
				failed++
				continue
			say("Reaction has a product [R] [R2.volume]u purity of [R2.purity]")
			if(R2.purity < 0.9)
				impure_string += "Reaction [cached_reactions[index]] has a product [R] [R2.volume]u <span class='boldwarning'>purity of [R2.purity]</span> index:[index]\n"
				majorImpurity++
			else if (R2.purity < 1)
				impure_string += "Reaction [cached_reactions[index]] has a product [R] [R2.volume]u <span class='warning'>purity of [R2.purity]</span> index:[index]\n"
				minorImpurity++
			if(R2.volume < C.results[R])
				impure_string += "Reaction [cached_reactions[index]] has a product [R] <span class='warning'>[R2.volume]u</span> purity of [R2.purity] index:[index]\n"
		reagents.clear_reagents()
		if(failed > 1)
			index++
			failed = 0
		if(failed == 0)
			index++
	var/datum/chemical_reaction/C = cached_reactions[index]
	if(!C)
		say("Unable to find reaction on index: [index]")
	for(var/R in C.required_reagents)
		reagents.add_reagent(R, C.required_reagents[R]*20)
	for(var/cat in C.required_catalysts)
		reagents.add_reagent(cat, C.required_catalysts[cat])
	if(failed == 0)
		reagents.chem_temp = C.optimal_temp
	if(failed == 1)
		reagents.chem_temp = C.required_temp+25
		failed++
	say("Reacting <span class='nicegreen'>[cached_reactions[index]]</span> starting pH: [reagents.ph] index [index] of [cached_reactions.len]")
	if(C.reaction_flags & REACTION_INSTANT)
		say("This reaction is instant")

