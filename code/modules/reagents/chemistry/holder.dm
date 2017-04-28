

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

/datum/reagents/New(maximum=100)
	maximum_volume = maximum

	if(!(flags & REAGENT_NOREACT))
		START_PROCESSING(SSobj, src)

	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!GLOB.chemical_reagents_list)
		//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
		var/paths = subtypesof(/datum/reagent)
		GLOB.chemical_reagents_list = list()
		for(var/path in paths)
			var/datum/reagent/D = new path()
			GLOB.chemical_reagents_list[D.id] = D
	if(!GLOB.chemical_reactions_list)
		//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
		// It is filtered into multiple lists within a list.
		// For example:
		// chemical_reaction_list["plasma"] is a list of all reactions relating to plasma

		var/paths = subtypesof(/datum/chemical_reaction)
		GLOB.chemical_reactions_list = list()

		for(var/path in paths)

			var/datum/chemical_reaction/D = new path()
			var/list/reaction_ids = list()

			if(D.required_reagents && D.required_reagents.len)
				for(var/reaction in D.required_reagents)
					reaction_ids += reaction

			// Create filters based on each reagent id in the required reagents list
			for(var/id in reaction_ids)
				if(!GLOB.chemical_reactions_list[id])
					GLOB.chemical_reactions_list[id] = list()
				GLOB.chemical_reactions_list[id] += D
				break // Don't bother adding ourselves to other reagent ids, it is redundant.

/datum/reagents/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		qdel(R)
	cached_reagents.Cut()
	cached_reagents = null
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null

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
		remove_reagent(R.id, 1)

		current_list_element++
		total_transfered++
		update_total()

	handle_reactions()
	return total_transfered

/datum/reagents/proc/remove_all(amount = 1)
	var/list/cached_reagents = reagent_list
	if(total_volume > 0)
		var/part = amount / total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			remove_reagent(R.id, R.volume * part)

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
	var/id
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			id = R.id

	return id

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

/datum/reagents/proc/trans_to(obj/target, amount=1, multiplier=1, preserve_data=1, no_react = 0)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return
	if(amount < 0)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents || src.total_volume<=0)
			return
		R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		var/transfer_amount = T.volume * part
		if(preserve_data)
			trans_data = copy_data(T)
		R.add_reagent(T.id, transfer_amount * multiplier, trans_data, chem_temp, no_react = 1) //we only handle reaction after every reagent has been transfered.
		remove_reagent(T.id, transfer_amount)

	update_total()
	R.update_total()
	if(!no_react)
		R.handle_reactions()
		src.handle_reactions()
	return amount

/datum/reagents/proc/copy_to(obj/target, amount=1, multiplier=1, preserve_data=1)
	var/list/cached_reagents = reagent_list
	if(!target)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents || src.total_volume<=0)
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
		R.add_reagent(T.id, copy_amount * multiplier, trans_data)

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
		if(current_reagent.id == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.id, amount, trans_data, src.chem_temp)
			remove_reagent(current_reagent.id, amount, 1)
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	return amount

/datum/reagents/proc/metabolize(mob/living/carbon/C, can_overdose = 0)
	var/list/cached_reagents = reagent_list
	var/list/cached_addictions = addiction_list
	if(C)
		chem_temp = C.bodytemperature
		handle_reactions()
	var/need_mob_update = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(QDELETED(R.holder))
			continue
		if(!C)
			C = R.holder.my_atom
		if(C && R)
			if(C.reagent_check(R) != 1)
				if(can_overdose)
					if(R.overdose_threshold)
						if(R.volume >= R.overdose_threshold && !R.overdosed)
							R.overdosed = 1
							need_mob_update += R.overdose_start(C)
					if(R.addiction_threshold)
						if(R.volume >= R.addiction_threshold && !is_type_in_list(R, cached_addictions))
							var/datum/reagent/new_reagent = new R.type()
							cached_addictions.Add(new_reagent)
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
							to_chat(C, "<span class='notice'>You feel like you've gotten over your need for [R.name].</span>")
							cached_addictions.Remove(R)
		addiction_tick++
	if(C && need_mob_update) //some of the metabolized reagents had effects on the mob that requires some updates.
		C.updatehealth()
		C.update_canmove()
		C.update_stamina()
	update_total()

/datum/reagents/process()
	var/list/cached_reagents = reagent_list
	if(flags & REAGENT_NOREACT)
		STOP_PROCESSING(SSobj, src)
		return

	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_tick()

/datum/reagents/proc/set_reacting(react = TRUE)
	if(react)
		// Order is important, process() can remove from processing if
		// the flag is present
		flags &= ~(REAGENT_NOREACT)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
		flags |= REAGENT_NOREACT

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
	var/list/cached_reagents = reagent_list
	var/list/cached_reactions = GLOB.chemical_reactions_list
	var/datum/cached_my_atom = my_atom
	if(flags & REAGENT_NOREACT)
		return //Yup, no reactions here. No siree.

	var/reaction_occurred = 0
	do
		reaction_occurred = 0
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			for(var/reaction in cached_reactions[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id
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
				var/list/multipliers = new/list()
				var/required_temp = C.required_temp
				var/is_cold_recipe = C.is_cold_recipe
				var/meets_temp_requirement = 0

				var/list/cached_results = C.results

				for(var/B in cached_required_reagents)
					if(!has_reagent(B, cached_required_reagents[B]))
						break
					total_matching_reagents++
					multipliers += round(get_reagent_amount(B) / cached_required_reagents[B])
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
					if (isliving(cached_my_atom)) //Makes it so certain chemical reactions don't occur in mobs
						if (C.mob_react)
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
					var/multiplier = min(multipliers)
					for(var/B in cached_required_reagents)
						remove_reagent(B, (multiplier * cached_required_reagents[B]), safety = 1)

					for(var/P in C.results)
						SSblackbox.add_details("chemical_reaction", "[P]|[cached_results[P]*multiplier]")
						multiplier = max(multiplier, 1) //this shouldnt happen ...
						add_reagent(P, cached_results[P]*multiplier, null, chem_temp)

					var/list/seen = viewers(4, get_turf(my_atom))
					if(cached_my_atom)
						if(!ismob(cached_my_atom)) // No bubbling mobs
							if(C.mix_sound)
								playsound(get_turf(cached_my_atom), C.mix_sound, 80, 1)
							for(var/mob/M in seen)
								to_chat(M, "<span class='notice'>\icon[my_atom] [C.mix_message]</span>")

						if(istype(cached_my_atom, /obj/item/slime_extract))
							var/obj/item/slime_extract/ME2 = my_atom
							ME2.Uses--
							if(ME2.Uses <= 0) // give the notification that the slime core is dead
								for(var/mob/M in seen)
									to_chat(M, "<span class='notice'>\icon[my_atom] \The [my_atom]'s power is consumed in the reaction.</span>")
									ME2.name = "used slime extract"
									ME2.desc = "This extract has been used up."

					C.on_reaction(src, multiplier)
					reaction_occurred = 1
					break

	while(reaction_occurred)
	update_total()
	return 0

/datum/reagents/proc/isolate_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.id != reagent)
			del_reagent(R.id)
			update_total()

/datum/reagents/proc/del_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.id == reagent)
			if(my_atom && isliving(my_atom))
				var/mob/living/M = my_atom
				R.on_mob_delete(M)
			qdel(R)
			reagent_list -= R
			update_total()
			if(my_atom)
				my_atom.on_reagent_change()
				check_ignoreslow(my_atom)
				check_gofast(my_atom)
				check_goreallyfast(my_atom)
	return 1

/datum/reagents/proc/check_ignoreslow(mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("morphine")||M.reagents.has_reagent("ephedrine"))
			return 1
		else
			M.status_flags &= ~IGNORESLOWDOWN

/datum/reagents/proc/check_gofast(mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("unholywater")||M.reagents.has_reagent("nuka_cola")||M.reagents.has_reagent("stimulants"))
			return 1
		else
			M.status_flags &= ~GOTTAGOFAST

/datum/reagents/proc/check_goreallyfast(mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("methamphetamine"))
			return 1
		else
			M.status_flags &= ~GOTTAGOREALLYFAST

/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	total_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume < 0.1)
			del_reagent(R.id)
		else
			total_volume += R.volume

	return 0

/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		del_reagent(R.id)
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

/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

/datum/reagents/proc/add_reagent(reagent, amount, list/data=null, reagtemp = 300, no_react = 0)
	if(!isnum(amount) || !amount)
		return FALSE

	if(amount < 0)
		return FALSE

	var/list/cached_reagents = reagent_list
	update_total()
	if(total_volume + amount > maximum_volume)
		amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.
	chem_temp = round(((amount * reagtemp) + (total_volume * chem_temp)) / (total_volume + amount)) //equalize with new chems

	for(var/A in cached_reagents)
		var/datum/reagent/R = A
		if (R.id == reagent)
			R.volume += amount
			update_total()
			if(my_atom)
				my_atom.on_reagent_change()
			R.on_merge(data, amount)
			if(!no_react)
				handle_reactions()
			return TRUE

	var/datum/reagent/D = GLOB.chemical_reagents_list[reagent]
	if(D)

		var/datum/reagent/R = new D.type(data)
		cached_reagents += R
		R.holder = src
		R.volume = amount
		if(data)
			R.data = data
			R.on_new(data)

		update_total()
		if(my_atom)
			my_atom.on_reagent_change()
		if(!no_react)
			handle_reactions()
		return TRUE

	else
		WARNING("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")
	return FALSE

/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null) // Like add_reagent but you can enter a list. Format it like this: list("toxin" = 10, "beer" = 15)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)

/datum/reagents/proc/remove_reagent(reagent, amount, safety)//Added a safety check for the trans_id_to

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
		if (R.id == reagent)
			//clamp the removal amount to be between current reagent amount
			//and zero, to prevent removing more than the holder has stored
			amount = Clamp(amount, 0, R.volume)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change()
			return TRUE

	return FALSE

/datum/reagents/proc/has_reagent(reagent, amount = -1)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.id == reagent)
			if(!amount)
				return R
			else
				if(R.volume >= amount)
					return R
				else
					return 0

	return 0

/datum/reagents/proc/get_reagent_amount(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.id == reagent)
			return R.volume

	return 0

/datum/reagents/proc/get_reagents()
	var/list/names = list()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		names += R.name

	return jointext(names, ",")

/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount)) return 1
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
			has_removed_reagent = remove_reagent(R.id, amount, safety)

	return has_removed_reagent

//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.id == reagent_id)
			//to_chat(world, "proffering a data-carrying reagent ([reagent_id])")
			return R.data

/datum/reagents/proc/set_data(reagent_id, new_data)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.id == reagent_id)
			//to_chat(world, "reagent data set ([reagent_id])")
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

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol)
	if(reagents)
		qdel(reagents)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src

/proc/get_random_reagent_id()	// Returns a random reagent ID minus blacklisted reagents
	var/static/list/random_reagents = list()
	if(!random_reagents.len)
		for(var/thing  in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.can_synth))
				random_reagents += initial(R.id)
	var/picked_reagent = pick(random_reagents)
	return picked_reagent
