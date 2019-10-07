#define CHEMICAL_QUANTISATION_LEVEL 0.0001 //stops floating point errors causing issues with checking reagent amounts


/proc/build_chemical_reagent_list()
	//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id

	if(GLOB.chemical_reagents_list)
		return

	var/paths = subtypesof(/datum/reagent)
	GLOB.chemical_reagents_list = list()

	for(var/path in paths)
		var/datum/reagent/D = new path()
		GLOB.chemical_reagents_list[path] = D

/proc/build_chemical_reactions_list()
	//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
	// It is filtered into multiple lists within a list.
	// For example:
	// chemical_reaction_list[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma

	if(GLOB.chemical_reactions_list)
		return

	//Randomized need to go last since they need to check against conflicts with normal recipes
	var/paths = subtypesof(/datum/chemical_reaction) - typesof(/datum/chemical_reaction/randomized) + subtypesof(/datum/chemical_reaction/randomized)
	GLOB.chemical_reactions_list = list()

	for(var/path in paths)
		var/datum/chemical_reaction/D = new path()
		var/list/reaction_ids = list()

		if(!D.id)
			continue

		if(D.required_reagents && D.required_reagents.len)
			for(var/reaction in D.required_reagents)
				reaction_ids += reaction

		// Create filters based on each reagent id in the required reagents list
		for(var/id in reaction_ids)
			if(!GLOB.chemical_reactions_list[id])
				GLOB.chemical_reactions_list[id] = list()
			GLOB.chemical_reactions_list[id] += D
			break // Don't bother adding ourselves to other reagent ids, it is redundant

///////////////////////////////////////////////////////////////////////////////////

/datum/reagents
	var/list/datum/reagent/reagent_list = new/list()
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/chem_temp = 150
	var/last_tick = 1
	var/addiction_tick = 1
	var/list/datum/reagent/addiction_list = new/list()
	var/flags
	var/pH //potential of hydrogen. Edited on adding new reagents, deleting reagents, and during fermi reactions.
	var/overallPurity
	var/targetVol = 0 //the target volume, i.e. the total amount that can be created during a fermichem reaction.
	var/reactedVol = 0 //how much of the reagent is reacted during a fermireaction
	var/fermiIsReacting = FALSE //that prevents multiple reactions from occurring (i.e. add_reagent calls to process_reactions(), this stops any extra reactions.)
	var/fermiReactID  //type of the chem being made during a fermireaction, kept here so it's cache isn't lost between loops/procs.



/datum/reagents/New(maximum=100, new_flags=0)
	maximum_volume = maximum

	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!GLOB.chemical_reagents_list)
		build_chemical_reagent_list()
	if(!GLOB.chemical_reactions_list)
		build_chemical_reactions_list()

	flags = new_flags

/datum/reagents/Destroy()
	. = ..()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		qdel(R)
	cached_reagents.Cut()
	cached_reagents = null
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null
	my_atom = null

// Used in attack logs for reagents in pills and such
// external list is list of reagent types = amounts
/datum/reagents/proc/log_list(external_list)
	if((external_list && !length(external_list)) || !length(reagent_list))
		return "no reagents"

	var/list/data = list()
	if(external_list)
		for(var/r in external_list)
			data += "[r] ([round(external_list[r], 0.1)]u)"
	else
		for(var/r in reagent_list) //no reagents will be left behind
			var/datum/reagent/R = r
			data += "[R.type] ([round(R.volume, 0.1)]u)"
			//Using types because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)

/datum/reagents/proc/remove_any(amount = 1)
	var/list/cached_reagents = reagent_list
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1, cached_reagents.len)

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break
		if(total_volume <= 0 || !cached_reagents.len)
			break

		if(current_list_element > cached_reagents.len)
			current_list_element = 1

		var/datum/reagent/R = cached_reagents[current_list_element]
		remove_reagent(R.type, 1)

		current_list_element++
		total_transfered++
		update_total()

	handle_reactions()
	return total_transfered

/datum/reagents/proc/remove_all(amount = 1)
	var/list/cached_reagents = reagent_list
	if((total_volume - amount) <= 0)//Because this can result in 0, I don't want it to crash.
		pH = 7
	if(total_volume > 0)
		var/part = amount / total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			remove_reagent(R.type, R.volume * part)
		update_total()
		handle_reactions()
		return amount

/datum/reagents/proc/get_master_reagent_name()
	var/list/cached_reagents = reagent_list
	var/name
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			name = R.name

	return name

/datum/reagents/proc/get_master_reagent_id()
	var/list/cached_reagents = reagent_list
	var/max_type
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			max_type = R.type

	return max_type

/datum/reagents/proc/get_master_reagent()
	var/list/cached_reagents = reagent_list
	var/datum/reagent/master
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			master = R

	return master


/datum/reagents/proc/remove_reagent(reagent, amount, safety, ignore_pH = FALSE)//Added a safety check for the trans_id_to

	if(isnull(amount))
		amount = 0
		CRASH("null amount passed to reagent code")
		return FALSE

	if(!isnum(amount))
		return FALSE

	if(amount < 0)
		return FALSE

	var/list/cached_reagents = reagent_list

	for(var/A in cached_reagents)
		var/datum/reagent/R = A
		if (R.type == reagent)
			if((total_volume - amount) <= 0)//Because this can result in 0, I don't want it to crash.
				pH = 7
			//In practice this is really confusing and players feel like it randomly melts their beakers, but I'm not sure how else to handle it. We'll see how it goes and I can remove this if it confuses people.
			else if (ignore_pH == FALSE)
				pH = (((pH - R.pH) / total_volume) * amount) + pH
			if(istype(my_atom, /obj/item/reagent_containers/))
				var/obj/item/reagent_containers/RC = my_atom
				RC.pH_check()//checks beaker resilience
			//clamp the removal amount to be between current reagent amount
			//and zero, to prevent removing more than the holder has stored
			amount = CLAMP(amount, 0, R.volume)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change(REM_REAGENT)
			return TRUE

	return FALSE

/datum/reagents/proc/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			if(!amount)
				if(needs_metabolizing && !R.metabolizing)
					return 0
				return R
			else
				if(round(R.volume, CHEMICAL_QUANTISATION_LEVEL) >= amount)
					if(needs_metabolizing && !R.metabolizing)
						return 0
					return R
				else
					return 0


/datum/reagents/proc/trans_to(obj/target, amount = 1, multiplier = 1, preserve_data = TRUE, no_react = FALSE, mob/transfered_by, remove_blacklisted = FALSE, method = null, show_message = TRUE, round_robin = FALSE)
	//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	//if round_robin=TRUE, so transfer 5 from 15 water, 15 sugar and 15 plasma becomes 10, 15, 15 instead of 13.3333, 13.3333 13.3333. Good if you hate floating point errors
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return
	if(amount < 0)
		return

	var/atom/target_atom
	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
		target_atom = R.my_atom
	else
		if(!target.reagents)
			return
		R = target.reagents
		target_atom = target

	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/trans_data = null
	var/transfer_log = list()
	if(!round_robin)
		var/part = amount / src.total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/T = reagent
			if(remove_blacklisted && !T.can_synth)
				continue
			var/transfer_amount = T.volume * part
			if(preserve_data)
				trans_data = copy_data(T)
			R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, T.purity, pH, no_react = TRUE, ignore_pH = TRUE) //we only handle reaction after every reagent has been transfered.
			if(method)
				R.react_single(T, target_atom, method, part, show_message)
				T.on_transfer(target_atom, method, transfer_amount * multiplier)
			remove_reagent(T.type, transfer_amount, ignore_pH = TRUE)
			transfer_log[T.type] = transfer_amount
	else
		var/to_transfer = amount
		for(var/reagent in cached_reagents)
			if(!to_transfer)
				break
			var/datum/reagent/T = reagent
			if(remove_blacklisted && !T.can_synth)
				continue
			if(preserve_data)
				trans_data = copy_data(T)
			var/transfer_amount = amount
			if(amount > T.volume)
				transfer_amount = T.volume
			R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, T.purity, pH, no_react = TRUE)
			to_transfer = max(to_transfer - transfer_amount , 0)
			if(method)
				R.react_single(T, target_atom, method, transfer_amount, show_message)
				T.on_transfer(target_atom, method, transfer_amount * multiplier)
			remove_reagent(T.type, transfer_amount)
			transfer_log[T.type] = transfer_amount

	if(transfered_by && target_atom)
		target_atom.add_hiddenprint(transfered_by) //log prints so admins can figure out who touched it last.
		log_combat(transfered_by, target_atom, "transferred reagents ([log_list(transfer_log)]) from [my_atom] to")

	update_total()
	R.update_total()
	if(!no_react)
		R.handle_reactions()
		src.handle_reactions()
	return amount

/datum/reagents/proc/copy_to(obj/target, amount=1, multiplier=1, preserve_data=1)
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents

	if(amount < 0)
		return
	amount = min(min(amount, total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / total_volume
	var/trans_data = null
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		var/copy_amount = T.volume * part
		if(preserve_data)
			trans_data = T.data
		R.add_reagent(T.type, copy_amount * multiplier, trans_data)

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount

/datum/reagents/proc/trans_id_to(obj/target, reagent, amount=1, preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	var/list/cached_reagents = reagent_list
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return
	if(amount < 0)
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/CR in cached_reagents)
		var/datum/reagent/current_reagent = CR
		if(current_reagent.type == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.type, amount, trans_data, src.chem_temp)
			remove_reagent(current_reagent.type, amount, 1)
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	return amount

/datum/reagents/proc/metabolize(mob/living/carbon/C, can_overdose = FALSE, liverless = FALSE)
	var/list/cached_reagents = reagent_list
	var/list/cached_addictions = addiction_list
	if(C)
		expose_temperature(C.bodytemperature, 0.25)
	var/need_mob_update = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(QDELETED(R.holder))
			continue

		if(!C)
			C = R.holder.my_atom

		if(C && R)
			if(C.reagent_check(R) != TRUE)
				if(liverless && !R.self_consuming) //need to be metabolized
					continue
				if(!R.metabolizing)
					R.metabolizing = TRUE
					R.on_mob_metabolize(C)
				if(can_overdose)
					if(R.overdose_threshold)
						if(R.volume >= R.overdose_threshold && !R.overdosed)
							R.overdosed = 1
							need_mob_update += R.overdose_start(C)
							log_game("[key_name(C)] has started overdosing on [R.name] at [R.volume] units.")
					if(R.addiction_threshold)
						if(R.volume >= R.addiction_threshold && !is_type_in_list(R, cached_addictions))
							var/datum/reagent/new_reagent = new R.type()
							cached_addictions.Add(new_reagent)
							log_game("[key_name(C)] has become addicted to [R.name] at [R.volume] units.")
					if(R.overdosed)
						need_mob_update += R.overdose_process(C)
					if(is_type_in_list(R,cached_addictions))
						for(var/addiction in cached_addictions)
							var/datum/reagent/A = addiction
							if(istype(R, A))
								A.addiction_stage = -15 // you're satisfied for a good while.
				need_mob_update += R.on_mob_life(C)

	if(can_overdose)
		if(addiction_tick == 6)
			addiction_tick = 1
			for(var/addiction in cached_addictions)
				var/datum/reagent/R = addiction
				if(C && R)
					R.addiction_stage++
					switch(R.addiction_stage)
						if(1 to 10)
							need_mob_update += R.addiction_act_stage1(C)
						if(10 to 20)
							need_mob_update += R.addiction_act_stage2(C)
						if(20 to 30)
							need_mob_update += R.addiction_act_stage3(C)
						if(30 to 40)
							need_mob_update += R.addiction_act_stage4(C)
						if(40 to INFINITY)
							remove_addiction(R)
						else
							SEND_SIGNAL(C, COMSIG_CLEAR_MOOD_EVENT, "[R.type]_overdose")
		addiction_tick++
	if(C && need_mob_update) //some of the metabolized reagents had effects on the mob that requires some updates.
		C.updatehealth()
		C.update_mobility()
		C.update_stamina()
	update_total()

/datum/reagents/proc/remove_addiction(datum/reagent/R)
	to_chat(my_atom, "<span class='notice'>You feel like you've gotten over your need for [R.name].</span>")
	SEND_SIGNAL(my_atom, COMSIG_CLEAR_MOOD_EVENT, "[R.type]_overdose")
	addiction_list.Remove(R)
	qdel(R)

//Signals that metabolization has stopped, triggering the end of trait-based effects
/datum/reagents/proc/end_metabolization(mob/living/carbon/C, keep_liverless = TRUE)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(QDELETED(R.holder))
			continue
		if(keep_liverless && R.self_consuming) //Will keep working without a liver
			continue
		if(!C)
			C = R.holder.my_atom
		if(R.metabolizing)
			R.metabolizing = FALSE
			R.on_mob_end_metabolize(C)

/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_move (A, Running)
	update_total()

/datum/reagents/proc/conditional_update(atom/A)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_update (A)
	update_total()

/datum/reagents/proc/handle_reactions()
	if(fermiIsReacting)
		return

	if(flags & NO_REACT)
		return //Yup, no reactions here. No siree.

	var/list/cached_reagents = reagent_list
	var/list/cached_reactions = GLOB.chemical_reactions_list
	var/datum/cached_my_atom = my_atom

	var/reaction_occurred = 0 // checks if reaction, binary variable
	var/continue_reacting = FALSE //Helps keep track what kind of reaction is occuring; standard or fermi.

	do
		var/list/possible_reactions = list()
		reaction_occurred = 0
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			for(var/reaction in cached_reactions[R.type]) // Was a big list but now it should be smaller since we filtered it with our reagent id
				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction
				var/list/cached_required_reagents = C.required_reagents
				var/total_required_reagents = cached_required_reagents.len
				var/total_matching_reagents = 0
				var/list/cached_required_catalysts = C.required_catalysts
				var/total_required_catalysts = cached_required_catalysts.len
				var/total_matching_catalysts= 0
				var/matching_container = 0
				var/matching_other = 0
				var/required_temp = C.required_temp
				var/is_cold_recipe = C.is_cold_recipe
				var/meets_temp_requirement = 0

				for(var/B in cached_required_reagents)
					if(!has_reagent(B, cached_required_reagents[B]))
						break
					total_matching_reagents++
				for(var/B in cached_required_catalysts)
					if(!has_reagent(B, cached_required_catalysts[B]))
						break
					total_matching_catalysts++
				if(cached_my_atom)
					if(!C.required_container)
						matching_container = 1

					else
						if(cached_my_atom.type == C.required_container)
							matching_container = 1
					if (isliving(cached_my_atom) && !C.mob_react) //Makes it so certain chemical reactions don't occur in mobs
						return
					if(!C.required_other)
						matching_other = 1

					else if(istype(cached_my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/M = cached_my_atom

						if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
							matching_other = 1
				else
					if(!C.required_container)
						matching_container = 1
					if(!C.required_other)
						matching_other = 1

				if(required_temp == 0 || (is_cold_recipe && chem_temp <= required_temp) || (!is_cold_recipe && chem_temp >= required_temp))
					meets_temp_requirement = 1

				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other && meets_temp_requirement)
					possible_reactions  += C

		if(possible_reactions.len)
			var/datum/chemical_reaction/selected_reaction = possible_reactions[1]
			//select the reaction with the most extreme temperature requirements
			for(var/V in possible_reactions)
				var/datum/chemical_reaction/competitor = V
				if(selected_reaction.is_cold_recipe) //if there are no recipe conflicts, everything in possible_reactions will have this same value for is_cold_reaction. warranty void if assumption not met.
					if(competitor.required_temp <= selected_reaction.required_temp)
						selected_reaction = competitor
				else
					if(competitor.required_temp >= selected_reaction.required_temp)
						selected_reaction = competitor
			var/list/cached_required_reagents = selected_reaction.required_reagents
			var/list/cached_results = selected_reaction.results
			var/special_react_result = selected_reaction.check_special_react(src)
			var/list/multiplier = INFINITY

			//Splits reactions into two types; FermiChem is advanced reaction mechanics, Other is default reaction.
			//FermiChem relies on two additional properties; pH and impurity
			//Temperature plays into a larger role too.
			var/datum/chemical_reaction/C = selected_reaction

			if (C.FermiChem && !continue_reacting)
				if (chem_temp > C.ExplodeTemp) //This is first to ensure explosions.
					var/datum/chemical_reaction/fermi/Ferm = selected_reaction
					fermiIsReacting = FALSE
					SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[Ferm] explosion"))
					Ferm.FermiExplode(src, my_atom, volume = total_volume, temp = chem_temp, pH = pH)
					return

				for(var/B in cached_required_reagents)
					multiplier = min(multiplier, round((get_reagent_amount(B) / cached_required_reagents[B]), 0.01))
				for(var/P in selected_reaction.results)
					targetVol = cached_results[P]*multiplier

				if( (chem_temp <= C.ExplodeTemp) && (chem_temp >= C.OptimalTempMin))
					if( (pH >= (C.OptimalpHMin - C.ReactpHLim)) && (pH <= (C.OptimalpHMax + C.ReactpHLim)) )//To prevent pointless reactions

						if (fermiIsReacting == TRUE)
							return 0
						else
							START_PROCESSING(SSprocessing, src)
							selected_reaction.on_reaction(src, my_atom, multiplier)
							fermiIsReacting = TRUE
							fermiReactID = selected_reaction
							reaction_occurred = TRUE

					else //It's a little bit of a confusing nest, but esstentially we check if it's a fermireaction, then temperature, then pH. If this is true, the remainer of this handler is run.
						return 0 //If pH is out of range
				else
					return 0 //If not hot enough

		//Standard reaction mechanics:
			else if (C.FermiChem)//Just to make sure
				return 0

				for(var/B in cached_required_reagents) //
					multiplier = min(multiplier, round((get_reagent_amount(B) / cached_required_reagents[B]), 0.01))

				for(var/B in cached_required_reagents)
					remove_reagent(B, (multiplier * cached_required_reagents[B]), safety = 1, ignore_pH = TRUE)

				for(var/P in selected_reaction.results)
					multiplier = max(multiplier, 1) //this shouldnt happen ...
					SSblackbox.record_feedback("tally", "chemical_reaction", cached_results[P]*multiplier, P)//log
					add_reagent(P, cached_results[P]*multiplier, null, chem_temp)


				var/list/seen = viewers(4, get_turf(my_atom))//Sound and sight checkers
				var/iconhtml = icon2html(cached_my_atom, seen)
				if(cached_my_atom)
					if(!ismob(cached_my_atom)) // No bubbling mobs
						if(selected_reaction.mix_sound)
							playsound(get_turf(cached_my_atom), selected_reaction.mix_sound, 80, 1)


						for(var/mob/M in seen)
							M.visible_message("<span class='notice'>[iconhtml] [selected_reaction.mix_message]</span>")

					if(istype(cached_my_atom, /obj/item/slime_extract))//if there's an extract and it's used up.
						var/obj/item/slime_extract/ME2 = my_atom
						ME2.Uses--
						if(ME2.Uses <= 0) // give the notification that the slime core is dead
							for(var/mob/M in seen)
								M.visible_message("<span class='notice'>[iconhtml] \The [my_atom]'s power is consumed in the reaction.</span>")
								ME2.name = "used slime extract"
								ME2.desc = "This extract has been used up."

				selected_reaction.on_reaction(src, multiplier, special_react_result)
				reaction_occurred = TRUE
				continue_reacting = TRUE

	while(reaction_occurred)
	update_total()
	return 0

/datum/reagents/process()
	var/datum/chemical_reaction/fermi/C = fermiReactID

	var/list/cached_required_reagents = C.required_reagents//update reagents list
	var/list/cached_results = C.results//resultant chemical list
	var/multiplier = INFINITY

	for(var/B in cached_required_reagents) //
		multiplier = min(multiplier, round((get_reagent_amount(B) / cached_required_reagents[B]), 0.001))
	if (multiplier == 0)
		fermiEnd()
		return
	for(var/P in cached_results)
		targetVol = cached_results[P]*multiplier

	if (fermiIsReacting == FALSE)
		CRASH("Fermi has refused to stop reacting even though we asked her nicely.")

	if (chem_temp > C.OptimalTempMin && fermiIsReacting)//To prevent pointless reactions
		if( (pH >= (C.OptimalpHMin - C.ReactpHLim)) && (pH <= (C.OptimalpHMax + C.ReactpHLim)) )
			if (reactedVol < targetVol)
				reactedVol = fermiReact(fermiReactID, chem_temp, pH, reactedVol, targetVol, cached_required_reagents, cached_results, multiplier)
			else//Volume is used up
				fermiEnd()
				return
		else//pH is out of range
			fermiEnd()
			return
	else//Temperature is too low, or reaction has stopped.
		fermiEnd()
		return

/datum/reagents/proc/fermiEnd()
	var/datum/chemical_reaction/fermi/C = fermiReactID
	STOP_PROCESSING(SSprocessing, src)
	fermiIsReacting = FALSE
	reactedVol = 0
	targetVol = 0
	//pH check, handled at the end to reduce calls.
	if(istype(my_atom, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = my_atom
		RC.pH_check()
	C.FermiFinish(src, my_atom)
	handle_reactions()
	update_total()
	//Reaction sounds and words
	playsound(get_turf(my_atom), C.mix_sound, 80, 1)
	var/list/seen = viewers(5, get_turf(my_atom))
	var/iconhtml = icon2html(my_atom, seen)
	for(var/mob/M in seen)
		M.visible_message("<span class='notice'>[iconhtml] [C.mix_message]</span>")

/datum/reagents/proc/fermiReact(selected_reaction, cached_temp, cached_pH, reactedVol, targetVol, cached_required_reagents, cached_results, multiplier)
	var/datum/chemical_reaction/fermi/C = selected_reaction
	var/deltaT = 0
	var/deltapH = 0
	var/stepChemAmmount = 0

	//get purity from combined beaker reactant purities HERE.
	var/purity = 1

	//Begin checks
	//For now, purity is handled elsewhere (on add)
	//Calculate DeltapH (Deviation of pH from optimal)
	//Lower range
	if (cached_pH < C.OptimalpHMin)
		if (cached_pH < (C.OptimalpHMin - C.ReactpHLim))
			deltapH = 0
			return//If outside pH range, no reaction
		else
			deltapH = (((cached_pH - (C.OptimalpHMin - C.ReactpHLim))**C.CurveSharppH)/((C.ReactpHLim**C.CurveSharppH)))
	//Upper range
	else if (cached_pH > C.OptimalpHMax)
		if (cached_pH > (C.OptimalpHMax + C.ReactpHLim))
			deltapH = 0
			return //If outside pH range, no reaction
		else
			deltapH = (((- cached_pH + (C.OptimalpHMax + C.ReactpHLim))**C.CurveSharppH)/(C.ReactpHLim**C.CurveSharppH))//Reverse - to + to prevent math operation failures.
	//Within mid range
	else if (cached_pH >= C.OptimalpHMin  && cached_pH <= C.OptimalpHMax)
		deltapH = 1
	//This should never proc:
	else
		WARNING("[my_atom] attempted to determine FermiChem pH for '[C.type]' which broke for some reason! ([usr])")

	//Calculate DeltaT (Deviation of T from optimal)
	if (cached_temp < C.OptimalTempMax && cached_temp >= C.OptimalTempMin)
		deltaT = (((cached_temp - C.OptimalTempMin)**C.CurveSharpT)/((C.OptimalTempMax - C.OptimalTempMin)**C.CurveSharpT))
	else if (cached_temp >= C.OptimalTempMax)
		deltaT = 1
	else
		deltaT = 0

	purity = (deltapH)//set purity equal to pH offset

	//Then adjust purity of result with reagent purity.
	purity *= reactant_purity(C)

	var/removeChemAmmount //remove factor
	var/addChemAmmount //add factor
	//ONLY WORKS FOR ONE PRODUCT AT THE MOMENT
	//Calculate how much product to make and how much reactant to remove factors..
	for(var/P in cached_results)
		//stepChemAmmount = CLAMP(((deltaT * multiplier), 0, ((targetVol - reactedVol)/cached_results[P]))  //used to have multipler, now it does
		stepChemAmmount = (multiplier*cached_results[P])
		if (stepChemAmmount >= C.RateUpLim)
			stepChemAmmount = (C.RateUpLim)
		addChemAmmount = deltaT * stepChemAmmount
		if (addChemAmmount >= (targetVol - reactedVol))
			addChemAmmount = (targetVol - reactedVol)
		if (addChemAmmount < 0.01)
			addChemAmmount = 0.01
		removeChemAmmount = (addChemAmmount/cached_results[P])
		//This is kept for future bugtesters.
		//message_admins("Reaction vars: PreReacted: [reactedVol] of [targetVol]. deltaT [deltaT], multiplier [multiplier], Step [stepChemAmmount], uncapped Step [deltaT*(multiplier*cached_results[P])], addChemAmmount [addChemAmmount], removeFactor [removeChemAmmount] Pfactor [cached_results[P]], adding [addChemAmmount]")

	//remove reactants
	for(var/B in cached_required_reagents)
		remove_reagent(B, (removeChemAmmount * cached_required_reagents[B]), safety = 1, ignore_pH = TRUE)

	//add product
	var/TotalStep = 0
	for(var/P in cached_results)
		SSblackbox.record_feedback("tally", "chemical_reaction", addChemAmmount, P)//log
		SSblackbox.record_feedback("tally", "fermi_chem", addChemAmmount, P)
		add_reagent(P, (addChemAmmount), null, cached_temp, purity)//add reagent function!! I THINK I can do this:
		TotalStep += addChemAmmount//for multiple products
		//Above should reduce yield based on holder purity.
		//Purity Check
		for(var/datum/reagent/R in my_atom.reagents.reagent_list)
			if(P == R.type)
				if (R.purity < C.PurityMin)//If purity is below the min, blow it up.
					fermiIsReacting = FALSE
					SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[P] explosion"))
					C.FermiExplode(src, my_atom, (reactedVol+targetVol), cached_temp, pH)
					STOP_PROCESSING(SSprocessing, src)
					return 0

	C.FermiCreate(src)//proc that calls when step is done

	//Apply pH changes and thermal output of reaction to beaker
	chem_temp = round(cached_temp + (C.ThermicConstant * addChemAmmount))
	pH += (C.HIonRelease * addChemAmmount)
	//keep track of the current reacted amount
	reactedVol = reactedVol + addChemAmmount

	//Check extremes
	if (chem_temp > C.ExplodeTemp)
		//go to explode proc
		fermiIsReacting = FALSE
		SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[C] explosions"))
		C.FermiExplode(src, my_atom, (reactedVol+targetVol), chem_temp, pH)
		STOP_PROCESSING(SSprocessing, src)
		return

	//Make sure things are limited.
	pH = CLAMP(pH, 0, 14)

	//return said amount to compare for next step.
	return (reactedVol)

//Currently calculates it irrespective of required reagents at the start
/datum/reagents/proc/reactant_purity(var/datum/chemical_reaction/fermi/C, holder)
	var/list/cached_reagents = reagent_list
	var/i = 0
	var/cachedPurity
	for(var/datum/reagent/R in my_atom.reagents.reagent_list)
		if (R in cached_reagents)
			cachedPurity += R.purity
			i++
	return cachedPurity/i

/datum/reagents/proc/isolate_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type != reagent)
			del_reagent(R.type)
			update_total()

/datum/reagents/proc/del_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type == reagent)
			if(my_atom && isliving(my_atom))
				var/mob/living/M = my_atom
				if(R.metabolizing)
					R.metabolizing = FALSE
					R.on_mob_end_metabolize(M)
				R.on_mob_delete(M)
			qdel(R)
			reagent_list -= R
			update_total()
			if(my_atom)
				my_atom.on_reagent_change(DEL_REAGENT)
	return 1

/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	total_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume == 0)
			del_reagent(R.type)
		if(R.volume < 0.01 && !fermiIsReacting)
			del_reagent(R.type)
		else
			total_volume += R.volume
		if(!reagent_list)
			pH = 7
	return 0

/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		del_reagent(R.type)
	pH = REAGENT_NORMAL_PH
	return 0

/datum/reagents/proc/reaction(atom/A, method = TOUCH, volume_modifier = 1, show_message = 1)
	var/react_type
	if(isliving(A))
		react_type = "LIVING"
		if(method == INGEST)
			var/mob/living/L = A
			L.taste(src)
	else if(isturf(A))
		react_type = "TURF"
	else if(isobj(A))
		react_type = "OBJ"
	else
		return
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		switch(react_type)
			if("LIVING")
				var/touch_protection = 0
				if(method == VAPOR)
					var/mob/living/L = A
					touch_protection = L.get_permeability_protection()
				R.reaction_mob(A, method, R.volume * volume_modifier, show_message, touch_protection)
			if("TURF")
				R.reaction_turf(A, R.volume * volume_modifier, show_message)
			if("OBJ")
				R.reaction_obj(A, R.volume * volume_modifier, show_message)

/datum/reagents/proc/react_single(datum/reagent/R, atom/A, method = TOUCH, volume_modifier = 1, show_message = TRUE)
	var/react_type
	if(isliving(A))
		react_type = "LIVING"
		if(method == INGEST)
			var/mob/living/L = A
			L.taste(src)
	else if(isturf(A))
		react_type = "TURF"
	else if(isobj(A))
		react_type = "OBJ"
	else
		return
	switch(react_type)
		if("LIVING")
			var/touch_protection = 0
			if(method == VAPOR)
				var/mob/living/L = A
				touch_protection = L.get_permeability_protection()
			R.reaction_mob(A, method, R.volume * volume_modifier, show_message, touch_protection)
		if("TURF")
			R.reaction_turf(A, R.volume * volume_modifier, show_message)
		if("OBJ")
			R.reaction_obj(A, R.volume * volume_modifier, show_message)

/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

//Returns the average specific heat for all reagents currently in this holder.
/datum/reagents/proc/specific_heat()
	. = 0
	var/cached_amount = total_volume		//cache amount
	var/list/cached_reagents = reagent_list		//cache reagents
	for(var/I in cached_reagents)
		var/datum/reagent/R = I
		. += R.specific_heat * (R.volume / cached_amount)

/datum/reagents/proc/adjust_thermal_energy(J, min_temp = 2.7, max_temp = 1000)
	var/S = specific_heat()
	chem_temp = CLAMP(chem_temp + (J / (S * total_volume)), min_temp, max_temp)
	if(istype(my_atom, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = my_atom
		RC.temp_check()

/datum/reagents/proc/add_reagent(reagent, amount, list/data=null, reagtemp = 300, other_purity = 1, other_pH, no_react = 0, ignore_pH = FALSE)
	if(!isnum(amount) || !amount)
		return FALSE

	if(amount <= 0.00)
		return FALSE

	var/datum/reagent/D = GLOB.chemical_reagents_list[reagent]
	if(!D)
		WARNING("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")
		return FALSE


	if (D.type == "water" && no_react == FALSE && !istype(my_atom, /obj/item/reagent_containers/food)) //Do like an otter, add acid to water, but also don't blow up botany.
		if (pH <= 2)
			SSblackbox.record_feedback("tally", "fermi_chem", 1, "water-acid explosions")
			var/datum/effect_system/smoke_spread/chem/s = new
			var/turf/T = get_turf(my_atom)
			var/datum/reagents/R = new/datum/reagents(3000)
			R.add_reagent("fermiAcid", amount)
			for (var/datum/reagent/reagentgas in reagent_list)
				R.add_reagent(reagentgas, amount/5)
				remove_reagent(reagentgas, amount/5)
			s.set_up(R, CLAMP(amount/10, 0, 2), T)
			s.start()
			return FALSE

	if(!pH)
		other_pH = D.pH



	update_total()
	var/cached_total = total_volume
	if(cached_total + amount > maximum_volume)
		amount = (maximum_volume - cached_total) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.
		if(amount <= 0)
			return FALSE
	var/new_total = cached_total + amount
	var/cached_temp = chem_temp
	var/list/cached_reagents = reagent_list

	var/cached_pH = pH


	//Equalize temperature - Not using specific_heat() because the new chemical isn't in yet.
	var/specific_heat = 0
	var/thermal_energy = 0
	for(var/i in cached_reagents)
		var/datum/reagent/R = i
		specific_heat += R.specific_heat * (R.volume / new_total)
		thermal_energy += R.specific_heat * R.volume * cached_temp
	specific_heat += D.specific_heat * (amount / new_total)
	thermal_energy += D.specific_heat * amount * reagtemp
	chem_temp = thermal_energy / (specific_heat * new_total)
	////

		//cacluate reagent based pH shift.
	if(ignore_pH)
		pH = ((cached_pH * cached_total)+(other_pH * amount))/(cached_total + amount)//should be right
	else
		pH = ((cached_pH * cached_total)+(D.pH * amount))/(cached_total + amount)//should be right
	if(istype(my_atom, /obj/item/reagent_containers/))
		var/obj/item/reagent_containers/RC = my_atom
		RC.pH_check()//checks beaker resilience
	//add the reagent to the existing if it exists
	for(var/A in cached_reagents)
		var/datum/reagent/R = A
		if (R.type == reagent)
					//Add amount and equalize purity
			R.volume += amount
			R.purity = ((R.purity * R.volume) + (other_purity * amount)) /((R.volume + amount)) //This should add the purity to the product

			update_total()
			if(my_atom)
				my_atom.on_reagent_change(ADD_REAGENT)
			R.on_merge(data, amount)
			if(!no_react)
				handle_reactions()
			return TRUE

	//otherwise make a new one
	var/datum/reagent/R = new D.type(data)
	cached_reagents += R
	R.holder = src
	R.volume = amount
	R.purity = other_purity
	R.loc = get_turf(my_atom)
	if(data)
		R.data = data
		R.on_new(data)
	if(R.chemical_flags & REAGENT_FORCEONNEW)//Allows on new without data overhead.
		R.on_new(pH) //Add more as desired.
	if(isliving(my_atom))
		if(R.chemical_flags & REAGENT_ONMOBMERGE)//Forces on_mob_add proc when a chem is merged
			R.on_mob_add(my_atom, amount)
		//else
			//	R.on_merge(data, amount, my_atom, other_purity)
		R.on_merge(data, amount, my_atom, other_purity)
	update_total()
	if(my_atom)
		my_atom.on_reagent_change(ADD_REAGENT)
	if(!no_react)
		handle_reactions()
	return TRUE

/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null) // Like add_reagent but you can enter a list. Format it like this: list(/datum/reagent/toxin = 10, "beer" = 15)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)


	return 0

/datum/reagents/proc/get_reagent_amount(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			return round(R.volume, CHEMICAL_QUANTISATION_LEVEL)

	return 0

/datum/reagents/proc/get_reagents()
	var/list/names = list()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		names += R.name

	return jointext(names, ",")

/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount))
		return 1
	var/list/cached_reagents = reagent_list
	var/has_removed_reagent = 0

	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.type, amount, safety)

	return has_removed_reagent

//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			return R.data

/datum/reagents/proc/set_data(reagent_id, new_data)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			R.data = new_data

/datum/reagents/proc/copy_data(datum/reagent/current_reagent)
	if(!current_reagent || !current_reagent.data)
		return null
	if(!istype(current_reagent.data, /list))
		return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	// We do this so that introducing a virus to a blood sample
	// doesn't automagically infect all other blood samples from
	// the same donor.
	//
	// Technically we should probably copy all data lists, but
	// that could possibly eat up a lot of memory needlessly
	// if most data lists are read-only.
	if(trans_data["viruses"])
		var/list/v = trans_data["viruses"]
		trans_data["viruses"] = v.Copy()

	return trans_data

/datum/reagents/proc/get_reagent(type)
	var/list/cached_reagents = reagent_list
	. = locate(type) in cached_reagents

/datum/reagents/proc/generate_taste_message(minimum_percent=15)
	// the lower the minimum percent, the more sensitive the message is.
	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/datum/reagent/R in reagent_list)
			if(!R.taste_mult)
				continue

			if(istype(R, /datum/reagent/consumable/nutriment))
				var/list/taste_data = R.data
				for(var/taste in taste_data)
					var/ratio = taste_data[taste]
					var/amount = ratio * R.taste_mult * R.volume
					if(taste in tastes)
						tastes[taste] += amount
					else
						tastes[taste] = amount
			else
				var/taste_desc = R.taste_description
				var/taste_amount = R.volume * R.taste_mult
				if(taste_desc in tastes)
					tastes[taste_desc] += taste_amount
				else
					tastes[taste_desc] = taste_amount
		//deal with percentages
		// TODO it would be great if we could sort these from strong to weak
		var/total_taste = counterlist_sum(tastes)
		if(total_taste > 0)
			for(var/taste_desc in tastes)
				var/percent = tastes[taste_desc]/total_taste * 100
				if(percent < minimum_percent)
					continue
				var/intensity_desc = "a hint of"
				if(percent > minimum_percent * 2 || percent == 100)
					intensity_desc = ""
				else if(percent > minimum_percent * 3)
					intensity_desc = "the strong flavor of"
				if(intensity_desc != "")
					out += "[intensity_desc] [taste_desc]"
				else
					out += "[taste_desc]"

	return english_list(out, "something indescribable")

/datum/reagents/proc/expose_temperature(var/temperature, var/coeff=0.02)
	if(istype(my_atom,/obj/item/reagent_containers))
		var/obj/item/reagent_containers/RCs = my_atom
		if(RCs.reagent_flags & NO_REACT) //stasis holders IE cryobeaker
			return
	var/temp_delta = (temperature - chem_temp) * coeff
	if(temp_delta > 0)
		chem_temp = min(chem_temp + max(temp_delta, 1), temperature)
	else
		chem_temp = max(chem_temp + min(temp_delta, -1), temperature)
	chem_temp = round(chem_temp)
	for(var/i in reagent_list)
		var/datum/reagent/R = i
		R.on_temp_change()
	handle_reactions()

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol, flags)
	if(reagents)
		qdel(reagents)
	reagents = new /datum/reagents(max_vol, flags)
	reagents.my_atom = src

/proc/get_random_reagent_id()	// Returns a random reagent ID minus blacklisted reagents
	var/static/list/random_reagents = list()
	if(!random_reagents.len)
		for(var/thing  in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.can_synth))
				random_reagents += R
	var/picked_reagent = pick(random_reagents)
	return picked_reagent

/proc/get_chem_id(chem_name)
	for(var/X in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[X]
		if(chem_name == replacetext(lowertext(R.name), " ", ""))
			return X
