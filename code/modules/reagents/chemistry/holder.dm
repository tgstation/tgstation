/////////////These are used in the reagents subsystem init() and the reagent_id_typos.dm////////
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

		if(!D.required_reagents || !D.required_reagents.len) //Skip impossible reactions
			continue

		for(var/reaction in D.required_reagents)
			reaction_ids += reaction

		// Create filters based on each reagent id in the required reagents list
		for(var/id in reaction_ids)
			if(!GLOB.chemical_reactions_list[id])
				GLOB.chemical_reactions_list[id] = list()
			GLOB.chemical_reactions_list[id] += D
			break // Don't bother adding ourselves to other reagent ids, it is redundant

///////////////////////////////Main reagents code/////////////////////////////////////////////

/// Holder for a bunch of [/datum/reagent]
/datum/reagents
	/// The reagents being held
	var/list/datum/reagent/reagent_list = new/list()
	/// Current volume of all the reagents
	var/total_volume = 0
	/// Max volume of this holder
	var/maximum_volume = 100
	/// The atom this holder is attached to
	var/atom/my_atom = null
	/// Current temp of the holder volume
	var/chem_temp = 150
	///pH of the whole system
	var/ph = CHEMICAL_NORMAL_PH
	/// unused
	var/last_tick = 1
	/// see [/datum/reagents/proc/metabolize] for usage
	var/addiction_tick = 1
	/// currently addicted reagents
	var/list/datum/reagent/addiction_list
	/// various flags, see code\__DEFINES\reagents.dm
	var/flags
	///list of reactions currently on going, this is a lazylist for optimisation
	var/list/datum/equilibrium/reaction_list
	///cached list of reagents typepaths (not object references), this is a lazylist for optimisation
	var/list/datum/reagent/previous_reagent_list
	///If a reaction fails due to temperature or pH, this tracks the required temperature or pH for it to be enabled. 
	var/list/failed_but_capable_reactions
	///Hard check to see if the reagents is presently reacting
	var/is_reacting = FALSE

/datum/reagents/New(maximum=100, new_flags=0)
	maximum_volume = maximum
	flags = new_flags

/datum/reagents/Destroy()
	//We're about to delete all reagents, so lets cleanup
	addiction_list = null
	for(var/reagent in reagent_list)
		var/datum/reagent/R = reagent
		qdel(R)
	reagent_list = null
	if(is_reacting) //If false, reaction list should be cleaned up
		force_stop_reacting()
	QDEL_LAZYLIST(reaction_list)
	previous_reagent_list = null
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null
	my_atom = null
	return ..()

/**
 * Adds a reagent to this holder
 *
 * Arguments:
 * * reagent - The reagent id to add
 * * amount - Amount to add
 * * list/data - Any reagent data for this reagent, used for transferring data with reagents
 * * reagtemp - Temperature of this reagent, will be equalized
 * * no_react - prevents reactions being triggered by this addition
 * * added_purity - override to force a purity when added
 * * added_ph - override to force a pH when added
 * * override_base_ph - ingore the present pH of the reagent, and instead use the default (i.e. if buffers/reactions alter it)
 */
/datum/reagents/proc/add_reagent(reagent, amount, list/data=null, reagtemp = 300, added_purity = null, added_ph, no_react = 0, override_base_ph = FALSE)
	if(!isnum(amount) || !amount)
		return FALSE

	if(amount <= CHEMICAL_QUANTISATION_LEVEL)//To prevent small amount problems.
		return FALSE

	var/datum/reagent/glob_reagent = GLOB.chemical_reagents_list[reagent]
	if(!glob_reagent)
		stack_trace("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")
		return FALSE

	var/datum/reagent/D = GLOB.chemical_reagents_list[reagent]
	if(isnull(added_purity)) //Because purity additions can be 0
		added_purity = D.creation_purity //Usually 1

	if(!added_ph)
		added_ph = D.ph

	update_total()
	var/cached_total = total_volume
	if(cached_total + amount > maximum_volume)
		amount = (maximum_volume - cached_total) //Doesnt fit in. Make it disappear. shouldn't happen. Will happen.
		if(amount <= 0)
			return FALSE

	var/cached_temp = chem_temp
	var/list/cached_reagents = reagent_list

	//Equalize temperature - Not using specific_heat() because the new chemical isn't in yet.
	var/old_heat_capacity = 0
	if(reagtemp != cached_temp)
		for(var/r in cached_reagents)
			var/datum/reagent/iter_reagent = r
			old_heat_capacity += iter_reagent.specific_heat * iter_reagent.volume

	//add the reagent to the existing if it exists
	for(var/r in cached_reagents)
		var/datum/reagent/iter_reagent = r
		if (iter_reagent.type == reagent)
			if(override_base_ph)
				added_ph = iter_reagent.ph
			iter_reagent.purity = ((iter_reagent.creation_purity * iter_reagent.volume) + (added_purity * amount)) /(iter_reagent.volume + amount) //This should add the purity to the product
			iter_reagent.creation_purity = iter_reagent.purity
			iter_reagent.ph = ((iter_reagent.ph*(iter_reagent.volume))+(added_ph*amount))/(iter_reagent.volume+amount)
			iter_reagent.volume += round(amount, CHEMICAL_QUANTISATION_LEVEL)
			update_total()

			iter_reagent.on_merge(data, amount)
			if(reagtemp != cached_temp)
				var/new_heat_capacity = heat_capacity()
				if(new_heat_capacity)
					set_temperature(((old_heat_capacity * cached_temp) + (iter_reagent.specific_heat * amount * reagtemp)) / new_heat_capacity)
				else
					set_temperature(reagtemp)

			SEND_SIGNAL(src, COMSIG_REAGENTS_ADD_REAGENT, iter_reagent, amount, reagtemp, data, no_react)
			if(!no_react && !is_reacting) //To reduce the amount of calculations for a reaction the reaction list is only updated on a reagents addition.
				handle_reactions()
			return TRUE

	//otherwise make a new one
	var/datum/reagent/new_reagent = new reagent(data)
	cached_reagents += new_reagent
	new_reagent.holder = src
	new_reagent.volume = amount
	new_reagent.purity = added_purity
	new_reagent.creation_purity = added_purity
	new_reagent.ph = added_ph
	if(data)
		new_reagent.data = data
		new_reagent.on_new(data)

	if(isliving(my_atom))
		new_reagent.on_mob_add(my_atom, amount) //Must occur before it could posibly run on_mob_delete

	update_total()
	if(reagtemp != cached_temp)
		var/new_heat_capacity = heat_capacity()
		if(new_heat_capacity)
			set_temperature(((old_heat_capacity * cached_temp) + (new_reagent.specific_heat * amount * reagtemp)) / new_heat_capacity)
		else
			set_temperature(reagtemp)

	SEND_SIGNAL(src, COMSIG_REAGENTS_NEW_REAGENT, new_reagent, amount, reagtemp, data, no_react)
	if(!no_react)
		handle_reactions()
	return TRUE

/// Like add_reagent but you can enter a list. Format it like this: list(/datum/reagent/toxin = 10, "beer" = 15)
/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)


/// Remove a specific reagent
/datum/reagents/proc/remove_reagent(reagent, amount, safety = TRUE)//Added a safety check for the trans_id_to
	if(isnull(amount))
		amount = 0
		CRASH("null amount passed to reagent code")

	if(!isnum(amount))
		return FALSE

	if(amount < 0)
		return FALSE

	var/list/cached_reagents = reagent_list
	for(var/A in cached_reagents)
		var/datum/reagent/R = A
		if (R.type == reagent)
			//clamp the removal amount to be between current reagent amount
			//and zero, to prevent removing more than the holder has stored
			amount = clamp(amount, 0, R.volume)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			SEND_SIGNAL(src, COMSIG_REAGENTS_REM_REAGENT, QDELING(R) ? reagent : R, amount)

			return TRUE
	return FALSE

/// Remove an amount of reagents without caring about what they are
/datum/reagents/proc/remove_any(amount = 1)
	var/list/cached_reagents = reagent_list
	var/total_removed = 0
	var/current_list_element = 1
	var/initial_list_length = cached_reagents.len //stored here because removing can cause some reagents to be deleted, ergo length change.

	current_list_element = rand(1, cached_reagents.len)

	while(total_removed != amount)
		if(total_removed >= amount)
			break
		if(total_volume <= 0 || !cached_reagents.len)
			break

		if(current_list_element > cached_reagents.len)
			current_list_element = 1

		var/datum/reagent/R = cached_reagents[current_list_element]
		var/remove_amt = min(amount-total_removed,round(amount/rand(2,initial_list_length),round(amount/10,0.01))) //double round to keep it at a somewhat even spread relative to amount without getting funky numbers.
		//min ensures we don't go over amount.
		remove_reagent(R.type, remove_amt)

		current_list_element++
		total_removed += remove_amt
		update_total()

	handle_reactions()
	return total_removed //this should be amount unless the loop is prematurely broken, in which case it'll be lower. It shouldn't ever go OVER amount.

/// Removes all reagents from this holder
/datum/reagents/proc/remove_all(amount = 1)
	var/list/cached_reagents = reagent_list
	if(total_volume > 0)
		var/part = amount / total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			remove_reagent(R.type, R.volume * part)

		//finish_reacting() //A just in case - update total is in here - should be unneeded, make sure to test this
		handle_reactions()
		return amount

/// Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1)
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
		// We found a match, proceed to remove the reagent. Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.type, amount, safety)

	return has_removed_reagent

/// Fuck this one reagent
/datum/reagents/proc/del_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type == reagent)
			if(isliving(my_atom))
				if(R.metabolizing)
					R.metabolizing = FALSE
					R.on_mob_end_metabolize(my_atom)
				R.on_mob_delete(my_atom)

			//Clear from relevant lists
			LAZYREMOVE(addiction_list, R)
			reagent_list -= R
			LAZYREMOVE(previous_reagent_list, R.type)
			qdel(R)
			update_total()
			SEND_SIGNAL(src, COMSIG_REAGENTS_DEL_REAGENT, reagent)
	return TRUE

//Converts the creation_purity to purity
/datum/reagents/proc/uncache_creation_purity(id)
	var/datum/reagent/R = has_reagent(id)
	if(!R)
		return
	R.purity = R.creation_purity

/// Remove every reagent except this one
/datum/reagents/proc/isolate_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type != reagent)
			del_reagent(R.type)
			update_total()

/// Removes all reagents
/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		del_reagent(R.type)
	SEND_SIGNAL(src, COMSIG_REAGENTS_CLEAR_REAGENTS)


/**
 * Check if this holder contains this reagent.
 * Reagent takes a PATH to a reagent.
 * Amount checks for having a specific amount of that chemical.
 * Needs matabolizing takes into consideration if the chemical is matabolizing when it's checked.
 */
/datum/reagents/proc/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			if(!amount)
				if(needs_metabolizing && !R.metabolizing)
					return FALSE
				return R
			else
				if(round(R.volume, CHEMICAL_QUANTISATION_LEVEL) >= amount)
					if(needs_metabolizing && !R.metabolizing)
						return FALSE
					return R
	return FALSE


/**
 * Transfer some stuff from this holder to a target object
 *
 * Arguments:
 * * obj/target - Target to attempt transfer to
 * * amount - amount of reagent volume to transfer
 * * multiplier - multiplies amount of each reagent by this number
 * * preserve_data - if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
 * * no_react - passed through to [/datum/reagents/proc/add_reagent]
 * * mob/transfered_by - used for logging
 * * remove_blacklisted - skips transferring of reagents without REAGENT_CAN_BE_SYNTHESIZED in chemical_flags
 * * methods - passed through to [/datum/reagents/proc/expose_single] and [/datum/reagent/proc/on_transfer]
 * * show_message - passed through to [/datum/reagents/proc/expose_single]
 * * round_robin - if round_robin=TRUE, so transfer 5 from 15 water, 15 sugar and 15 plasma becomes 10, 15, 15 instead of 13.3333, 13.3333 13.3333. Good if you hate floating point errors
 * * ignore_stomach - when using methods INGEST will not use the stomach as the target
 */
/datum/reagents/proc/trans_to(obj/target, amount = 1, multiplier = 1, preserve_data = TRUE, no_react = FALSE, mob/transfered_by, remove_blacklisted = FALSE, methods = NONE, show_message = TRUE, round_robin = FALSE, ignore_stomach = FALSE)
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return
	if(amount < 0)
		return

	var/cached_amount = amount
	var/atom/target_atom
	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
		target_atom = R.my_atom
	else
		if(!ignore_stomach && (methods & INGEST) && istype(target, /mob/living/carbon))
			var/mob/living/carbon/eater = target
			var/obj/item/organ/stomach/belly = eater.getorganslot(ORGAN_SLOT_STOMACH)
			if(!belly)
				eater.expel_ingested(my_atom, amount)
				return
			R = belly.reagents
			target_atom = belly
		else if(!target.reagents)
			return
		else
			R = target.reagents
			target_atom = target

	//Set up new reagents to inherit the old ongoing reactions
	if(!no_react)
		transfer_reactions(R)

	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/trans_data = null
	var/transfer_log = list()
	if(!round_robin)
		var/part = amount / src.total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/T = reagent
			if(remove_blacklisted && !(T.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
				continue
			var/transfer_amount = T.volume * part
			if(preserve_data)
				trans_data = copy_data(T)
			if(T.intercept_reagents_transfer(R, cached_amount))//Use input amount instead.
				continue
			R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, T.purity, T.ph, no_react = TRUE) //we only handle reaction after every reagent has been transfered.
			if(methods)
				if(istype(target_atom, /obj/item/organ))
					R.expose_single(T, target, methods, part, show_message)
				else
					R.expose_single(T, target_atom, methods, part, show_message)
				T.on_transfer(target_atom, methods, transfer_amount * multiplier)
			remove_reagent(T.type, transfer_amount)
			transfer_log[T.type] = transfer_amount
			if(is_type_in_list(target_atom, list(/mob/living/carbon, /obj/item/organ/stomach)))
				R.process_mob_reagent_purity(T.type, transfer_amount * multiplier, T.purity)
	else
		var/to_transfer = amount
		for(var/reagent in cached_reagents)
			if(!to_transfer)
				break
			var/datum/reagent/T = reagent
			if(remove_blacklisted && !(T.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
				continue
			if(preserve_data)
				trans_data = copy_data(T)
			var/transfer_amount = amount
			if(amount > T.volume)
				transfer_amount = T.volume
			if(T.intercept_reagents_transfer(R, cached_amount))//Use input amount instead.
				continue
			R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, T.purity, T.ph, no_react = TRUE) //we only handle reaction after every reagent has been transfered.
			to_transfer = max(to_transfer - transfer_amount , 0)
			if(methods)
				if(istype(target_atom, /obj/item/organ))
					R.expose_single(T, target, methods, transfer_amount, show_message)
				else
					R.expose_single(T, target_atom, methods, transfer_amount, show_message)
				T.on_transfer(target_atom, methods, transfer_amount * multiplier)
			remove_reagent(T.type, transfer_amount)
			transfer_log[T.type] = transfer_amount
			if(is_type_in_list(target_atom, list(/mob/living/carbon, /obj/item/organ/stomach)))
				R.process_mob_reagent_purity(T.type, transfer_amount * multiplier, T.purity)

	if(transfered_by && target_atom)
		target_atom.add_hiddenprint(transfered_by) //log prints so admins can figure out who touched it last.
		log_combat(transfered_by, target_atom, "transferred reagents ([log_list(transfer_log)]) from [my_atom] to")


	update_total()
	R.update_total()
	if(!no_react)
		R.handle_reactions()
		src.handle_reactions()
	return amount

/// Transfer a specific reagent id to the target object
/datum/reagents/proc/trans_id_to(obj/target, reagent, amount=1, preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	var/list/cached_reagents = reagent_list
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return
	if(amount < 0)
		return
	
	var/cached_amount = amount
	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)

	amount = min(round(amount, CHEMICAL_VOLUME_ROUNDING), R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/CR in cached_reagents)
		var/datum/reagent/current_reagent = CR
		if(current_reagent.type == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			if(current_reagent.intercept_reagents_transfer(R, cached_amount))//Use input amount instead.
				break
			force_stop_reagent_reacting(current_reagent)
			R.add_reagent(current_reagent.type, amount, trans_data, chem_temp, current_reagent.purity, current_reagent.ph, no_react = TRUE)
			remove_reagent(current_reagent.type, amount, 1)
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	return amount

/// Copies the reagents to the target object
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
		R.add_reagent(T.type, copy_amount * multiplier, trans_data, added_purity = T.purity, added_ph = T.ph, no_react = TRUE)

	//pass over previous ongoing reactions before handle_reactions is called
	transfer_reactions(R)

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount

///Multiplies the reagents inside this holder by a specific amount
/datum/reagents/proc/multiply_reagents(multiplier=1)
	var/list/cached_reagents = reagent_list
	if(!total_volume)
		return
	var/change = (multiplier - 1) //Get the % change
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		if(change > 0)
			add_reagent(T.type, T.volume * change, added_purity = T.purity)
		else
			remove_reagent(T.type, abs(T.volume * change)) //absolute value to prevent a double negative situation (removing -50% would be adding 50%)

	update_total()
	handle_reactions()


/// Get the name of the reagent there is the most of in this holder
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

/// Get the id of the reagent there is the most of in this holder
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

/// Get a reference to the reagent there is the most of in this holder
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

/**
 * Triggers metabolizing the reagents in this holder
 *
 * Arguments:
 * * mob/living/carbon/C - The mob to metabolize in, if null it uses [/datum/reagents/var/my_atom]
 * * can_overdose - Allows overdosing
 * * liverless - Stops reagents that aren't set as [/datum/reagent/var/self_consuming] from metabolizing
 */
/datum/reagents/proc/metabolize(mob/living/carbon/C, can_overdose = FALSE, liverless = FALSE)
	var/list/cached_reagents = reagent_list
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
							R.overdosed = TRUE
							need_mob_update += R.overdose_start(C)
							log_game("[key_name(C)] has started overdosing on [R.name] at [R.volume] units.")
					var/is_addicted_to = addiction_list && is_type_in_list(R, addiction_list)
					if(R.addiction_threshold)
						if(R.volume >= R.addiction_threshold && !is_addicted_to)
							var/datum/reagent/new_reagent = new R.addiction_type()
							LAZYADD(addiction_list, new_reagent)
							is_addicted_to = TRUE
							log_game("[key_name(C)] has become addicted to [R.name] at [R.volume] units.")
					if(R.overdosed)
						need_mob_update += R.overdose_process(C)
					var/datum/reagent/addiction_type = new R.addiction_type()
					if(is_addicted_to)
						for(var/addiction in addiction_list)
							var/datum/reagent/A = addiction
							if(istype(addiction_type, A))
								A.addiction_stage = -15 // you're satisfied for a good while.
				need_mob_update += R.on_mob_life(C)

	if(can_overdose)
		if(addiction_tick == 6)
			addiction_tick = 1
			for(var/addiction in addiction_list)
				var/datum/reagent/R = addiction
				if(!C)
					break
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
		C.update_stamina()
	update_total()

/// Signals that metabolization has stopped, triggering the end of trait-based effects
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

/// Removes addiction to a specific reagent on [/datum/reagents/var/my_atom]
/datum/reagents/proc/remove_addiction(datum/reagent/R)
	to_chat(my_atom, "<span class='notice'>You feel like you've gotten over your need for [R.name].</span>")
	SEND_SIGNAL(my_atom, COMSIG_CLEAR_MOOD_EVENT, "[R.type]_overdose")
	LAZYREMOVE(addiction_list, R)
	qdel(R)


/**
 * Calls [/datum/reagent/proc/on_move] on every reagent in this holder
 *
 * Arguments:
 * * atom/A - passed to on_move
 * * Running - passed to on_move
 */
/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_move(A, Running)
	update_total()

/**
 * Calls [/datum/reagent/proc/on_update] on every reagent in this holder
 *
 * Arguments:
 * * atom/A - passed to on_update
 */
/datum/reagents/proc/conditional_update(atom/A)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_update(A)
	update_total()

/// Handle any reactions possible in this holder
/// Also UPDATES the reaction list
/// High potential for infinite loopsa if you're editing this.
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
		if(datum_flags != DF_ISPROCESSING)//If we're reacting - but not processing (i.e. we've transfered)
			START_PROCESSING(SSreagents, src)
		if(!(has_changed_state()))
			return FALSE

	var/list/cached_reagents = reagent_list
	var/list/cached_reactions = GLOB.chemical_reactions_list
	var/datum/cached_my_atom = my_atom
	LAZYNULL(failed_but_capable_reactions)

	. = 0
	var/list/possible_reactions = list()
	for(var/_reagent in cached_reagents)
		var/datum/reagent/reagent = _reagent
		for(var/_reaction in cached_reactions[reagent.type]) // Was a big list but now it should be smaller since we filtered it with our reagent id
			if(!_reaction)
				continue

			var/datum/chemical_reaction/reaction = _reaction
			if(!reaction.required_reagents)//Don't bring in empty ones
				continue
			var/list/cached_required_reagents = reaction.required_reagents
			var/total_required_reagents = cached_required_reagents.len
			var/total_matching_reagents = 0
			var/list/cached_required_catalysts = reaction.required_catalysts
			var/total_required_catalysts = cached_required_catalysts.len
			var/total_matching_catalysts= 0
			var/matching_container = FALSE
			var/matching_other = FALSE
			var/required_temp = reaction.required_temp
			var/is_cold_recipe = reaction.is_cold_recipe
			var/meets_temp_requirement = FALSE
			var/meets_ph_requirement = FALSE
			var/granularity = 1
			if(!(reaction.reaction_flags & REACTION_INSTANT))
				granularity = 0.01

			for(var/req_reagent in cached_required_reagents)
				if(!has_reagent(req_reagent, (cached_required_reagents[req_reagent]*granularity)))
					break
				total_matching_reagents++
			for(var/_catalyst in cached_required_catalysts)
				if(!has_reagent(_catalyst, (cached_required_catalysts[_catalyst]*granularity)))
					break
				total_matching_catalysts++
			if(cached_my_atom)
				if(!reaction.required_container)
					matching_container = TRUE
				else
					if(cached_my_atom.type == reaction.required_container)
						matching_container = TRUE
				if (isliving(cached_my_atom) && !reaction.mob_react) //Makes it so certain chemical reactions don't occur in mobs
					matching_container = FALSE
				if(!reaction.required_other)
					matching_other = TRUE

				else if(istype(cached_my_atom, /obj/item/slime_extract))
					var/obj/item/slime_extract/extract = cached_my_atom

					if(extract.Uses > 0) // added a limit to slime cores -- Muskets requested this
						matching_other = TRUE
			else
				if(!reaction.required_container)
					matching_container = TRUE
				if(!reaction.required_other)
					matching_other = TRUE

			if(required_temp == 0 || (is_cold_recipe && chem_temp <= required_temp) || (!is_cold_recipe && chem_temp >= required_temp))
				meets_temp_requirement = TRUE
			
			if(((ph >= (reaction.optimal_ph_min - reaction.determin_ph_range)) && (ph <= (reaction.optimal_ph_max + reaction.determin_ph_range))))
				meets_ph_requirement = TRUE

			if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other)
				if(meets_temp_requirement && meets_ph_requirement)
					possible_reactions  += reaction
				else
					LAZYADD(failed_but_capable_reactions, reaction)

	update_previous_reagent_list()
	//This is the point where we have all the possible reactions from a reagent/catalyst point of view, so we set up the reaction list
	for(var/_possible_reaction in possible_reactions)
		var/datum/chemical_reaction/selected_reaction = _possible_reaction
		if((selected_reaction.reaction_flags & REACTION_INSTANT) || (flags & REAGENT_HOLDER_INSTANT_REACT)) //If we have instant reactions, we process them here
			instant_react(selected_reaction)
			.++
			update_total()
			continue
		else
			var/exists = FALSE
			for(var/_equilibrium in reaction_list)
				var/datum/equilibrium/E_exist = _equilibrium
				if(ispath(E_exist.reaction.type, selected_reaction.type)) //Don't add duplicates
					exists = TRUE 

			//Add it if it doesn't exist in the list
			if(!exists)
				is_reacting = TRUE//Prevent any on_reaction() procs from infinite looping
				var/datum/equilibrium/equilibrium = new (selected_reaction, src) //Otherwise we add them to the processing list.
				if(equilibrium.to_delete)//failed startup checks
					qdel(equilibrium)
				else
					//Adding is done in new(), deletion is in qdel
					equilibrium.reaction.on_reaction(equilibrium, src, equilibrium.multiplier)
					equilibrium.react_timestep(1)//Get an initial step going so there's not a delay between setup and start - DO NOT ADD THIS TO equilibrium.NEW()

	if(LAZYLEN(reaction_list))
		is_reacting = TRUE //We've entered the reaction phase - this is set here so any reagent handling called in on_reaction() doesn't cause infinite loops
		START_PROCESSING(SSreagents, src) //see process() to see how reactions are handled
	else
		is_reacting = FALSE

	if(.)
		SEND_SIGNAL(src, COMSIG_REAGENTS_REACTED, .)

/*
* Main Reaction loop handler, Do not call this directly
*
* Checks to see if there's a reaction, then processes over the reaction list, removing them if flagged
* If any are ended, it displays the reaction message and removes it from the reaction list
* If the list is empty at the end it finishes reacting.
* Arguments:
* * delta_time - the time between each time step
*/
/datum/reagents/process(delta_time)
	if(!is_reacting)
		force_stop_reacting()
		stack_trace("[src] | [my_atom] was forced to stop reacting. This might be unintentional.")
	//sum of output messages.
	var/list/mix_message = list()
	//Process over our reaction list
	//See equilibrium.dm for mechanics
	var/num_reactions = 0
	for(var/_equilibrium in reaction_list)
		var/datum/equilibrium/equilibrium = _equilibrium
		//Continue reacting
		equilibrium.react_timestep(delta_time)
		num_reactions++
		//if it's been flagged to delete
		if(equilibrium.to_delete)
			var/temp_mix_message = end_reaction(equilibrium)
			if(!text_in_list(temp_mix_message, mix_message))
				mix_message += temp_mix_message
			continue
		SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[equilibrium.reaction.type] total reaction steps")
	
	if(num_reactions)
		SEND_SIGNAL(src, COMSIG_REAGENTS_REACTION_STEP, num_reactions, delta_time)

	if(length(mix_message)) //This is only at the end
		my_atom.audible_message("<span class='notice'>[icon2html(my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [mix_message.Join()]</span>")

	if(!LAZYLEN(reaction_list))
		finish_reacting()
	else
		update_total()
		handle_reactions()

/*
* This ends a single instance of an ongoing reaction
*
* Arguments:
* * E - the equilibrium that will be ended
* Returns:
* * mix_message - the associated mix message of a reaction
*/
/datum/reagents/proc/end_reaction(datum/equilibrium/equilibrium)
	if(!equilibrium.holder || !equilibrium.reaction) //Somehow I'm getting empty equilibrium. This is here to handle them
		LAZYREMOVE(reaction_list, equilibrium)
		qdel(equilibrium)
		stack_trace("The equilibrium datum currently processing in this reagents datum had a nulled holder or nulled reaction. src holder:[my_atom] || src type:[my_atom.type] ") //Shouldn't happen. Does happen
		return
	if(equilibrium.holder != src) //When called from Destroy() eqs are nulled in smoke. This is very strange. This is probably causing it to spam smoke because of the runtime interupting the removal.
		stack_trace("The equilibrium datum currently processing in this reagents datum had a desynced holder to the ending reaction. src holder:[my_atom] | equilibrium holder:[equilibrium.holder.my_atom] || src type:[my_atom.type] | equilibrium holder:[equilibrium.holder.my_atom.type]")
		LAZYREMOVE(reaction_list, equilibrium)
	equilibrium.reaction.reaction_finish(src, equilibrium.reacted_vol)
	var/reaction_message = equilibrium.reaction.mix_message
	if(equilibrium.reaction.mix_sound)
		playsound(get_turf(my_atom), equilibrium.reaction.mix_sound, 80, TRUE)
	qdel(equilibrium) 
	update_total()
	SEND_SIGNAL(src, COMSIG_REAGENTS_REACTED, .)
	return reaction_message

/*
* This stops the holder from processing at the end of a series of reactions (i.e. when all the equilibriums are completed)
*
* Also resets reaction variables to be null/empty/FALSE so that it can restart correctly in the future
*/
/datum/reagents/proc/finish_reacting()
	STOP_PROCESSING(SSreagents, src)
	is_reacting = FALSE
	//Cap off values
	for(var/_reagent in reagent_list)
		var/datum/reagent/reagent = _reagent
		reagent.volume = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING)//To prevent runaways.
	LAZYNULL(previous_reagent_list) //reset it to 0 - because any change will be different now.
	update_total()
	if(!QDELING(src))
		handle_reactions() //Should be okay without. Each step checks.

/*
* Force stops the current holder/reagents datum from reacting
*
* Calls end_reaction() for each equlilbrium datum in reaction_list and finish_reacting()
* Usually only called when a datum is transfered into a NO_REACT container
*/
/datum/reagents/proc/force_stop_reacting()
	var/list/mix_message = list()
	for(var/_equilibrium in reaction_list)
		var/datum/equilibrium/equilibrium = _equilibrium
		mix_message += end_reaction(equilibrium)
	if(length(mix_message))
		my_atom.audible_message("<span class='notice'>[icon2html(my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [mix_message.Join()]</span>")
	finish_reacting()

/*
* Force stops a specific reagent's associated reaction if it exists
*
* Mostly used if a reagent is being taken out by trans_id_to
* Might have some other applciations
* Returns TRUE if it stopped something, FALSE if it didn't
* Arguments:
* * reagent - the reagent PRODUCT that we're seeking reactions for, any and all found will be shut down
*/
/datum/reagents/proc/force_stop_reagent_reacting(datum/reagent/reagent)
	var/any_stopped = FALSE
	var/list/mix_message = list()
	for(var/_equilibrium in reaction_list)
		var/datum/equilibrium/equilibrium = _equilibrium
		for(var/result in equilibrium.reaction.results)
			if(result == reagent.type)
				mix_message += end_reaction(equilibrium)
				any_stopped = TRUE
	if(length(mix_message))
		my_atom.audible_message("<span class='notice'>[icon2html(my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [mix_message.Join()]</span>")
	return any_stopped

/*
* Transfers the reaction_list to a new reagents datum
*
* Arguments:
* * target - the datum/reagents that this src is being transfered into
*/
/datum/reagents/proc/transfer_reactions(datum/reagents/target)
	if(QDELETED(target))
		CRASH("transfer_reactions() had a [target] ([target.type]) passed to it when it was set to qdel, or it isn't a reagents datum.")
	if(!reaction_list)
		return
	for(var/reaction in reaction_list)
		var/datum/equilibrium/reaction_source = reaction
		var/exists = FALSE
		for(var/reaction2 in target.reaction_list) //Don't add duplicates
			var/datum/equilibrium/reaction_target = reaction2
			if(reaction_source.reaction.type == reaction_target.reaction.type) 
				exists = TRUE
		if(exists)
			continue
		if(!reaction_source.holder)
			CRASH("reaction_source is missing a holder in transfer_reactions()!")

		var/datum/equilibrium/new_E = new (reaction_source.reaction, target)//addition to reaction_list is done in new()
		if(new_E.to_delete)//failed startup checks
			qdel(new_E)

	target.previous_reagent_list = LAZYLISTDUPLICATE(previous_reagent_list)
	target.is_reacting = is_reacting
	

///Checks to see if the reagents has a difference in reagents_list and previous_reagent_list (I.e. if there's a difference between the previous call and the last)
///Also checks to see if the saved reactions in failed_but_capable_reactions can start as a result of temp/pH change
/datum/reagents/proc/has_changed_state()
	//Check if reagents are different
	var/total_matching_reagents = 0
	for(var/reagent in previous_reagent_list)
		if(has_reagent(reagent))
			total_matching_reagents++
	if(total_matching_reagents != reagent_list.len)
		return TRUE
	
	//Check our last reactions
	for(var/_reaction in failed_but_capable_reactions)
		var/datum/chemical_reaction/reaction = _reaction
		if(reaction.is_cold_recipe)
			if(reaction.required_temp < chem_temp)
				return TRUE
		else
			if(reaction.required_temp < chem_temp)
				return TRUE
		if(((ph >= (reaction.optimal_ph_min - reaction.determin_ph_range)) && (ph <= (reaction.optimal_ph_max + reaction.determin_ph_range))))
			return TRUE
	return FALSE

/datum/reagents/proc/update_previous_reagent_list()
	LAZYNULL(previous_reagent_list)
	for(var/_reagent in reagent_list)
		var/datum/reagent/reagent = _reagent
		LAZYADD(previous_reagent_list, reagent.type)

///Old reaction mechanics, edited to work on one only
///This is changed from the old - purity of the reagents will affect yield
/datum/reagents/proc/instant_react(datum/chemical_reaction/selected_reaction)
	var/list/cached_required_reagents = selected_reaction.required_reagents
	var/list/cached_results = selected_reaction.results
	var/datum/cached_my_atom = my_atom
	var/multiplier = INFINITY
	for(var/reagent in cached_required_reagents)
		multiplier = min(multiplier, round(get_reagent_amount(reagent) / cached_required_reagents[reagent]))

	if(multiplier == 0)//Incase we're missing reagents - usually from on_reaction being called in an equlibrium when the results.len == 0 handlier catches a misflagged reaction
		return FALSE
	var/sum_purity = 0
	for(var/_reagent in cached_required_reagents)
		var/datum/reagent/reagent = has_reagent(_reagent)
		sum_purity += reagent.purity
		remove_reagent(_reagent, (multiplier * cached_required_reagents[_reagent]), safety = 1)
	sum_purity /= cached_required_reagents.len

	for(var/product in selected_reaction.results)
		multiplier = max(multiplier, 1) //this shouldn't happen ...
		var/yield = (cached_results[product]*multiplier)*sum_purity
		SSblackbox.record_feedback("tally", "chemical_reaction", yield, product)
		add_reagent(product, yield, null, chem_temp, sum_purity)

	var/list/seen = viewers(4, get_turf(my_atom))
	var/iconhtml = icon2html(cached_my_atom, seen)
	if(cached_my_atom)
		if(!ismob(cached_my_atom)) // No bubbling mobs
			if(selected_reaction.mix_sound)
				playsound(get_turf(cached_my_atom), selected_reaction.mix_sound, 80, TRUE)

			my_atom.audible_message("<span class='notice'>[iconhtml] [selected_reaction.mix_message]</span>")

		if(istype(cached_my_atom, /obj/item/slime_extract))
			var/obj/item/slime_extract/extract = my_atom
			extract.Uses--
			if(extract.Uses <= 0) // give the notification that the slime core is dead
				my_atom.visible_message("<span class='notice'>[iconhtml] \The [my_atom]'s power is consumed in the reaction.</span>")
				extract.name = "used slime extract"
				extract.desc = "This extract has been used up."

	selected_reaction.on_reaction(null, src, multiplier)

///Possibly remove - see if multiple instant reactions is okay (Though, this "sorts" reactions by temp decending)
///Presently unused
/datum/reagents/proc/get_priority_instant_reaction(list/possible_reactions)
	if(!length(possible_reactions))
		return FALSE
	var/datum/chemical_reaction/selected_reaction = possible_reactions[1]
	//select the reaction with the most extreme temperature requirements
	for(var/_reaction in possible_reactions)
		var/datum/chemical_reaction/competitor = _reaction
		if(selected_reaction.is_cold_recipe)
			if(competitor.required_temp <= selected_reaction.required_temp)
				selected_reaction = competitor
		else
			if(competitor.required_temp >= selected_reaction.required_temp)
				selected_reaction = competitor
	return selected_reaction

/*Processes the reagents in the holder and converts them, only called in a mob/living/carbon on addition
*
* Arguments:
* * reagent - the added reagent datum/object
* * added_volume - the volume of the reagent that was added (since it can already exist in a mob)
* * added_purity - the purity of the added volume
*/
/datum/reagents/proc/process_mob_reagent_purity(_reagent, added_volume, added_purity)
	var/datum/reagent/R = has_reagent(_reagent)
	if(!R)
		stack_trace("Tried to process reagent purity for [_reagent], but 0 volume was found right after it was added!") //This can happen from smoking, where the volume is 0 after adding?
		return
	if (R.purity == 1)
		return
	if(R.chemical_flags & REAGENT_DONOTSPLIT)
		R.purity = 1
		return
	if(R.purity < 0)
		stack_trace("Purity below 0 for chem: [type]!")
		R.purity = 0

	if ((R.inverse_chem_val > R.purity) && (R.inverse_chem))//Turns all of a added reagent into the inverse chem
		remove_reagent(R.type, added_volume, FALSE)
		add_reagent(R.inverse_chem, added_volume, FALSE, added_purity = 1-R.creation_purity)
		var/datum/reagent/inverse_reagent = has_reagent(R.inverse_chem)
		if(inverse_reagent.chemical_flags & REAGENT_SNEAKYNAME)
			inverse_reagent.name = R.name//Negative effects are hidden
			if(inverse_reagent.chemical_flags & REAGENT_INVISIBLE)
				inverse_reagent.chemical_flags |= (REAGENT_INVISIBLE)
	else if (R.impure_chem)
		var/impureVol = added_volume * (1 - R.purity) //turns impure ratio into impure chem
		if(!(R.chemical_flags & REAGENT_SPLITRETAINVOL))
			remove_reagent(R.type, impureVol, FALSE)
		add_reagent(R.impure_chem, impureVol, FALSE, added_purity = 1-R.creation_purity)
	R.purity = 1 //prevent this process from repeating (this is why creation_purity exists)

/// Updates [/datum/reagents/var/total_volume]
/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	total_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if((R.volume < 0.05) && !is_reacting)
			del_reagent(R.type)
		else if(R.volume <= CHEMICAL_VOLUME_MINIMUM)//For clarity
			del_reagent(R.type)
		else
			total_volume += R.volume
	recalculate_sum_ph()


/**
 * Applies the relevant expose_ proc for every reagent in this holder
 * * [/datum/reagent/proc/expose_mob]
 * * [/datum/reagent/proc/expose_turf]
 * * [/datum/reagent/proc/expose_obj]
 *
 * Arguments
 * - Atom/A: What mob/turf/object is being exposed to reagents? This is your reaction target.
 * - Methods: What reaction type is the reagent itself going to call on the reaction target? Types are TOUCH, INGEST, VAPOR, PATCH, and INJECT.
 * - Volume_modifier: What is the reagent volume multiplied by when exposed? Note that this is called on the volume of EVERY reagent in the base body, so factor in your Maximum_Volume if necessary!
 * - Show_message: Whether to display anything to mobs when they are exposed.
 */
/datum/reagents/proc/expose(atom/A, methods = TOUCH, volume_modifier = 1, show_message = 1)
	if(isnull(A))
		return null

	var/list/cached_reagents = reagent_list
	if(!cached_reagents.len)
		return null

	var/list/reagents = list()
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		reagents[R] = R.volume * volume_modifier

	return A.expose_reagents(reagents, src, methods, volume_modifier, show_message)


/// Same as [/datum/reagents/proc/expose] but only for one reagent
/datum/reagents/proc/expose_single(datum/reagent/R, atom/A, methods = TOUCH, volume_modifier = 1, show_message = TRUE)
	if(isnull(A))
		return null

	if(ispath(R))
		R = get_reagent(R)
	if(isnull(R))
		return null

	// Yes, we need the parentheses.
	return A.expose_reagents(list((R) = R.volume * volume_modifier), src, methods, volume_modifier, show_message)

/// Is this holder full or not
/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

/// Get the amount of this reagent
/datum/reagents/proc/get_reagent_amount(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			return round(R.volume, CHEMICAL_QUANTISATION_LEVEL)
	return 0

/// Get the purity of this reagent
/datum/reagents/proc/get_reagent_purity(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			return round(R.purity, 0.01)
	return 0 

/// Get a comma separated string of every reagent name in this holder. UNUSED
/datum/reagents/proc/get_reagent_names()
	var/list/names = list()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		names += R.name

	return jointext(names, ",")

/// helper function to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			return R.data

/// helper function to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/set_data(reagent_id, new_data)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			R.data = new_data

/// Shallow copies (deep copy of viruses) data from the provided reagent into our copy of that reagent
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

/// Get a reference to the reagent if it exists
/datum/reagents/proc/get_reagent(type)
	var/list/cached_reagents = reagent_list
	. = locate(type) in cached_reagents

/**
 * Returns what this holder's reagents taste like
 *
 * Arguments:
 * * mob/living/taster - who is doing the tasting. Some mobs can pick up specific flavours.
 * * minimum_percent - the lower the minimum percent, the more sensitive the message is.
 */
/datum/reagents/proc/generate_taste_message(mob/living/taster, minimum_percent)
	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/datum/reagent/R in reagent_list)
			if(!R.taste_mult)
				continue

			var/list/taste_data = R.get_taste_description(taster)
			for(var/taste in taste_data)
				if(taste in tastes)
					tastes[taste] += taste_data[taste] * R.volume * R.taste_mult
				else
					tastes[taste] = taste_data[taste] * R.volume * R.taste_mult
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


/// Returns the total heat capacity for all of the reagents currently in this holder.
/datum/reagents/proc/heat_capacity()
	. = 0
	var/list/cached_reagents = reagent_list //cache reagents
	for(var/I in cached_reagents)
		var/datum/reagent/R = I
		. += R.specific_heat * R.volume

/** Adjusts the thermal energy of the reagents in this holder by an amount.
 *
 * Arguments:
 * - delta_energy: The amount to change the thermal energy by.
 * - min_temp: The minimum temperature that can be reached.
 * - max_temp: The maximum temperature that can be reached.
 */
/datum/reagents/proc/adjust_thermal_energy(delta_energy, min_temp = 2.7, max_temp = 1000)
	var/heat_capacity = heat_capacity()
	if(!heat_capacity)
		return // no div/0 please
	set_temperature(clamp(chem_temp + (delta_energy / heat_capacity), min_temp, max_temp))

/// Applies heat to this holder
/datum/reagents/proc/expose_temperature(temperature, coeff=0.02)
	if(istype(my_atom,/obj/item/reagent_containers))
		var/obj/item/reagent_containers/RCs = my_atom
		if(RCs.reagent_flags & NO_REACT) //stasis holders IE cryobeaker
			return
	var/temp_delta = (temperature - chem_temp) * coeff
	if(temp_delta > 0)
		chem_temp = min(chem_temp + max(temp_delta, 1), temperature)
	else
		chem_temp = max(chem_temp + min(temp_delta, -1), temperature)
	set_temperature(round(chem_temp))
	handle_reactions()

/** Sets the temperature of this reagent container to a new value.
 *
 * Handles setter signals.
 *
 * Arguments:
 * - _temperature: The new temperature value.
 */
/datum/reagents/proc/set_temperature(_temperature)
	if(_temperature == chem_temp)
		return

	. = chem_temp
	chem_temp = _temperature
	SEND_SIGNAL(src, COMSIG_REAGENTS_TEMP_CHANGE, _temperature, .)

/*
* Adjusts the base pH of all of the reagents in a beaker
*
* - moves it towards acidic
* + moves it towards basic
* Arguments:
* * value - How much to adjust the base pH by
*/
/datum/reagents/proc/adjust_all_reagents_ph(value, lower_limit = 0, upper_limit = 14)
	for(var/reagent in reagent_list)
		var/datum/reagent/R = reagent
		R.ph = clamp(R.ph + value, lower_limit, upper_limit)

/*
* Adjusts the base pH of all of the listed types
*
* - moves it towards acidic
* + moves it towards basic
* Arguments:
* * input_reagents_list - list of reagents to adjust
* * value - How much to adjust the base pH by
*/
/datum/reagents/proc/adjust_specific_reagent_list_ph(list/input_reagents_list, value, lower_limit = 0, upper_limit = 14)
	for(var/reagent in input_reagents_list)
		var/datum/reagent/R = get_reagent(reagent)
		if(!R) //We can call this with missing reagents.
			continue
		R.ph = clamp(R.ph + value, lower_limit, upper_limit)

/*
* Adjusts the base pH of a specific type
*
* - moves it towards acidic
* + moves it towards basic
* Arguments:
* * input_reagent - type path of the reagent
* * value - How much to adjust the base pH by
* * lower_limit - how low the pH can go
* * upper_limit - how high the pH can go
*/
/datum/reagents/proc/adjust_specific_reagent_ph(input_reagent, value, lower_limit = 0, upper_limit = 14)
	var/datum/reagent/R = get_reagent(input_reagent)
	if(!R) //We can call this with missing reagents.
		return FALSE
	R.ph = clamp(R.ph + value, lower_limit, upper_limit)

/*
* Updates the reagents datum pH based off the volume weighted sum of the reagent_list's reagent pH
*/
/datum/reagents/proc/recalculate_sum_ph()
	if(!reagent_list || !total_volume) //Ensure that this is true
		ph = CHEMICAL_NORMAL_PH
		return
	var/total_ph = 0
	for(var/reagent in reagent_list)
		var/datum/reagent/R = get_reagent(reagent) //we need the specific instance
		total_ph += (R.ph * R.volume)
	//Keep limited
	ph = clamp(total_ph/total_volume, 0, 14)

/**
 * Used in attack logs for reagents in pills and such
 *
 * Arguments:
 * * external_list - list of reagent types = amounts
 */
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

///////////////////////////////////////////////////////////////////////////////////


/**
 * Convenience proc to create a reagents holder for an atom
 *
 * Arguments:
 * * max_vol - maximum volume of holder
 * * flags - flags to pass to the holder
 */
/atom/proc/create_reagents(max_vol, flags)
	if(reagents)
		qdel(reagents)
	reagents = new /datum/reagents(max_vol, flags)
	reagents.my_atom = src

/proc/get_random_reagent_id() // Returns a random reagent ID minus blacklisted reagents
	var/static/list/random_reagents = list()
	if(!random_reagents.len)
		for(var/thing in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.chemical_flags) & REAGENT_CAN_BE_SYNTHESIZED)
				random_reagents += R
	var/picked_reagent = pick(random_reagents)
	return picked_reagent

/proc/get_chem_id(chem_name)
	for(var/X in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[X]
		if(ckey(chem_name) == ckey(lowertext(R.name)))
			return X
