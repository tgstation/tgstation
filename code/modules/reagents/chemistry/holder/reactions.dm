/**
 * Handle any reactions possible in this holder
 * Also UPDATES the reaction list
*/
/datum/reagents/proc/handle_reactions()
	if(QDELING(src))
		CRASH("[my_atom] is trying to handle reactions while being flagged for deletion. It presently has [length(reagent_list)] number of reactants in it. If that is over 0 then something terrible happened.")

	if(!length(reagent_list))//The liver is calling this method a lot, and is often empty of reagents so it's pointless busywork. It should be an easy fix, but I'm nervous about touching things beyond scope. Also since everything is so handle_reactions() trigger happy it might be a good idea having this check anyways.
		return FALSE

	if(flags & NO_REACT)
		if(is_reacting)
			force_stop_reacting() //Force anything that is trying to to stop
		return FALSE //Yup, no reactions here. No siree.

	if(is_reacting)//Prevent wasteful calculations
		if(!(datum_flags & DF_ISPROCESSING))//If we're reacting - but not processing (i.e. we've transferred)
			START_PROCESSING(SSreagents, src)

#ifndef UNIT_TESTS
	// We assert that reagents will not need to react before the map is fully loaded
	// This is the best I can do, sorry :(
	if(!MC_RUNNING())
		return FALSE
#endif

	var/list/cached_reagents = list()
	for(var/datum/reagent/target as anything in reagent_list)
		cached_reagents[target.type] = target.volume
	var/list/cached_reactions = GLOB.chemical_reactions_list_reactant_index
	var/datum/cached_my_atom = my_atom

	. = 0
	for(var/datum/reagent/reagent as anything in cached_reagents)
		for(var/datum/chemical_reaction/reaction as anything in cached_reactions[reagent]) // Was a big list but now it should be smaller since we filtered it with our reagent id
			//is this reaction already going on?
			var/next_reaction = FALSE
			for(var/datum/equilibrium/E_exist as anything in reaction_list)
				if(ispath(E_exist.reaction.type, reaction.type)) //Don't add duplicates
					next_reaction = TRUE
					break
			if(next_reaction)
				continue

			//user defined checks so we don't waste time doing other checks
			if(!reaction.pre_reaction_other_checks(src))
				continue

			//do we have the required reagents?
			var/granularity = 1
			if(!(reaction.reaction_flags & REACTION_INSTANT))
				granularity = CHEMICAL_QUANTISATION_LEVEL
			var/present_volume = 0
			var/list/datum/reagent/requirements = reaction.required_reagents
			if(length(reaction.required_catalysts))
				requirements |= reaction.required_catalysts
			for(var/datum/reagent/requirement as anything in requirements)
				present_volume = cached_reagents[requirement]
				if(!present_volume)
					next_reaction = TRUE
					break

				if(present_volume < requirements[requirement] * granularity)
					next_reaction = TRUE
					break
			if(next_reaction)
				continue

			//do we have the required container?
			if(cached_my_atom)
				if(reaction.required_container)
					if(reaction.required_container_accepts_subtypes)
						if(!istype(cached_my_atom, reaction.required_container))
							continue
					else if(cached_my_atom.type != reaction.required_container)
						continue
				if(isliving(cached_my_atom) && !reaction.mob_react) //Makes it so certain chemical reactions don't occur in mobs
					continue
			else if(reaction.required_container)
				continue

			//do we have the required temps?
			var/required_temp = reaction.required_temp
			var/is_cold_recipe = reaction.is_cold_recipe
			if(required_temp != 0 && (is_cold_recipe && chem_temp > required_temp) || (!is_cold_recipe && chem_temp < required_temp))
				continue

			//do we have the required ph? in range of min - ph_range & max + ph_range
			if(ph < reaction.optimal_ph_min - reaction.determin_ph_range && ph > reaction.optimal_ph_max + reaction.determin_ph_range)
				continue

			//do the actual reactions
			if((reaction.reaction_flags & REACTION_INSTANT) || (flags & REAGENT_HOLDER_INSTANT_REACT) || !length(reaction.results)) //If we have instant reactions, we process them here
				instant_react(reaction)
				.++
			else
				var/datum/equilibrium/equilibrium = new (reaction, src) //Otherwise we add them to the processing list.
				if(equilibrium.to_delete)//failed startup checks
					qdel(equilibrium)
				else
					//Adding is done in new(), deletion is in qdel
					is_reacting = TRUE//Prevent any on_reaction() procs from infinite looping
					equilibrium.reaction.on_reaction(src, equilibrium, equilibrium.multiplier)
					equilibrium.react_timestep(1)//Get an initial

	if(LAZYLEN(reaction_list))
		is_reacting = TRUE //We've entered the reaction phase - this is set here so any reagent handling called in on_reaction() doesn't cause infinite loops
		START_PROCESSING(SSreagents, src) //see process() to see how reactions are handled
	else
		is_reacting = FALSE

	TEST_ONLY_ASSERT(!. || MC_RUNNING(), "We reacted during subsystem init, that shouldn't be happening!")

/*
* Main Reaction loop handler, Do not call this directly
*
* Checks to see if there's a reaction, then processes over the reaction list, removing them if flagged
* If any are ended, it displays the reaction message and removes it from the reaction list
* If the list is empty at the end it finishes reacting.
* Arguments:
* * seconds_per_tick - the time between each time step
*/
/datum/reagents/process(seconds_per_tick)
	if(!is_reacting)
		force_stop_reacting()
		stack_trace("[src] | [my_atom] was forced to stop reacting. This might be unintentional.")
	//sum of output messages.
	var/list/mix_message = list()
	//Process over our reaction list
	//See equilibrium.dm for mechanics
	var/num_reactions = 0
	for(var/datum/equilibrium/equilibrium as anything in reaction_list)
		//Continue reacting
		equilibrium.react_timestep(seconds_per_tick)
		num_reactions++
		//if it's been flagged to delete
		if(equilibrium.to_delete)
			var/temp_mix_message = end_reaction(equilibrium)
			if(!text_in_list(temp_mix_message, mix_message))
				mix_message += temp_mix_message
			continue
		SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[equilibrium.reaction.type] total reaction steps")
	if(num_reactions)
		SEND_SIGNAL(src, COMSIG_REAGENTS_REACTION_STEP, num_reactions, seconds_per_tick)

	if(length(mix_message) && !HAS_TRAIT(my_atom, TRAIT_SILENT_REACTIONS)) //This is only at the end
		my_atom.audible_message(span_notice("[icon2html(my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [mix_message.Join()]"))

	if(!LAZYLEN(reaction_list))
		finish_reacting()
	else
		handle_reactions()

/*
* This ends a single instance of an ongoing reaction
*
* Arguments:
* * [equilibrium][datum/equilibrium] - the equilibrium that will be ended
* Returns:
* * mix_message - the associated mix message of a reaction
*/
/datum/reagents/proc/end_reaction(datum/equilibrium/equilibrium)
	PRIVATE_PROC(TRUE)

	equilibrium.reaction.reaction_finish(src, equilibrium, equilibrium.reacted_vol)
	if(!equilibrium.holder || !equilibrium.reaction) //Somehow I'm getting empty equilibrium. This is here to handle them
		LAZYREMOVE(reaction_list, equilibrium)
		qdel(equilibrium)
		stack_trace("The equilibrium datum currently processing in this reagents datum had a nulled holder or nulled reaction. src holder:[my_atom] || src type:[my_atom.type] ") //Shouldn't happen. Does happen
		return
	if(equilibrium.holder != src) //When called from Destroy() eqs are nulled in smoke. This is very strange. This is probably causing it to spam smoke because of the runtime interupting the removal.
		stack_trace("The equilibrium datum currently processing in this reagents datum had a desynced holder to the ending reaction. src holder:[my_atom] | equilibrium holder:[equilibrium.holder.my_atom] || src type:[my_atom.type] | equilibrium holder:[equilibrium.holder.my_atom.type]")
		LAZYREMOVE(reaction_list, equilibrium)

	var/reaction_message = null

	if (!isnull(my_atom) && !HAS_TRAIT(my_atom, TRAIT_SILENT_REACTIONS))
		reaction_message = equilibrium.reaction.mix_message
		if(equilibrium.reaction.mix_sound)
			playsound(get_turf(my_atom), equilibrium.reaction.mix_sound, 80, TRUE)
	qdel(equilibrium)
	update_total()

	return reaction_message

/*
* This stops the holder from processing at the end of a series of reactions (i.e. when all the equilibriums are completed)
* Also resets reaction variables to be null/empty/FALSE so that it can restart correctly in the future
*/
/datum/reagents/proc/finish_reacting()
	PRIVATE_PROC(TRUE)

	STOP_PROCESSING(SSreagents, src)
	is_reacting = FALSE
	update_total()

/*
* Force stops the current holder/reagents datum from reacting
* Calls end_reaction() for each equlilbrium datum in reaction_list and finish_reacting()
* Usually only called when a datum is transferred into a NO_REACT container
*/
/datum/reagents/proc/force_stop_reacting()
	var/list/mix_message = list()
	for(var/datum/equilibrium/equilibrium as anything in reaction_list)
		mix_message += end_reaction(equilibrium)
	if(!QDELETED(my_atom) && length(mix_message))
		my_atom.audible_message(span_notice("[icon2html(my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [mix_message.Join()]"))
	finish_reacting()

/**
 * Old reaction mechanics, edited to work on one only
 * This is changed from the old - purity of the reagents will affect yield
 *
 * Arguments
 * * [selected_reaction][datum/chemical_reaction] - the chemical reaction to finish instantly
 */
/datum/reagents/proc/instant_react(datum/chemical_reaction/selected_reaction)
	PRIVATE_PROC(TRUE)

	var/list/cached_required_reagents = selected_reaction.required_reagents
	var/list/cached_results = selected_reaction.results
	var/datum/cached_my_atom = my_atom

	//find how much ration of products to create
	var/multiplier = INFINITY
	for(var/datum/reagent/requirement as anything in cached_required_reagents)
		multiplier = min(multiplier, get_reagent_amount(requirement) / cached_required_reagents[requirement])
	multiplier = round(multiplier, CHEMICAL_QUANTISATION_LEVEL)
	if(!multiplier)//Incase we're missing reagents - usually from on_reaction being called in an equlibrium when the results.len == 0 handler catches a misflagged reaction
		return FALSE

	//average purity to be used in scaling the yield of products formed
	var/average_purity = get_average_purity()

	//remove the required reagents
	for(var/datum/reagent/requirement as anything in cached_required_reagents)//this is not an object
		remove_reagent(requirement, cached_required_reagents[requirement] * multiplier)

	//add the result reagents whose yield depend on the average purity
	var/yield
	for(var/datum/reagent/product as anything in cached_results)
		yield = cached_results[product] * multiplier * average_purity
		SSblackbox.record_feedback("tally", "chemical_reaction", yield, product)
		add_reagent(product, yield, null, chem_temp, average_purity)

	//play sounds on the target atom
	var/list/seen = viewers(4, get_turf(my_atom))
	var/iconhtml = icon2html(cached_my_atom, seen)
	if(cached_my_atom)
		if(!ismob(cached_my_atom) && !HAS_TRAIT(my_atom, TRAIT_SILENT_REACTIONS)) // No bubbling mobs
			if(selected_reaction.mix_sound)
				playsound(get_turf(cached_my_atom), selected_reaction.mix_sound, 80, TRUE)
			my_atom.audible_message(span_notice("[iconhtml] [selected_reaction.mix_message]"))

		//use slime extract
		if(istype(cached_my_atom, /obj/item/slime_extract))
			var/obj/item/slime_extract/extract = my_atom
			extract.extract_uses--
			if(extract.extract_uses <= 0) // give the notification that the slime core is dead
				my_atom.visible_message(span_notice("[iconhtml] \The [my_atom]'s power is consumed in the reaction."))
				extract.name = "used slime extract"
				extract.desc = "This extract has been used up."
				extract.can_grind = FALSE

	//finish the reaction
	selected_reaction.on_reaction(src, null, multiplier)
