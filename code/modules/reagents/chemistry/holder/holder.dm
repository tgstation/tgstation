///////////////////////////////Main reagents code/////////////////////////////////////////////

/// Holder for a bunch of [/datum/reagent]
/datum/reagents
	/// The reagents being held
	var/list/datum/reagent/reagent_list = list()
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
	///UI lookup stuff
	///Keeps the id of the reaction displayed in the ui
	var/ui_reaction_id = null
	///Keeps the id of the reagent displayed in the ui
	var/ui_reagent_id = null
	///The bitflag of the currently selected tags in the ui
	var/ui_tags_selected = NONE
	///What index we're at if we have multiple reactions for a reagent product
	var/ui_reaction_index = 1
	///If we're syncing with the beaker - so return reactions that are actively happening
	var/ui_beaker_sync = FALSE

/datum/reagents/New(maximum = 100, new_flags = 0)
	maximum_volume = maximum
	flags = new_flags

/datum/reagents/Destroy()
	//We're about to delete all reagents, so lets cleanup
	for(var/datum/reagent/reagent as anything in reagent_list)
		qdel(reagent)
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
 * * list/reagent_added - If not null will contain an map of [reagent datum->amount added] which holds the inverse chems added to mobs. Clear the list to erase old values
 * * creation_callback - Callback to invoke when the reagent is created
 */
/datum/reagents/proc/add_reagent(
	datum/reagent/reagent_type,
	amount,
	list/data = null,
	reagtemp = DEFAULT_REAGENT_TEMPERATURE,
	added_purity = null,
	added_ph = null,
	no_react = FALSE,
	override_base_ph = FALSE,
	list/reagent_added = null,
	datum/callback/creation_callback = null,
)
	if(!ispath(reagent_type))
		stack_trace("invalid reagent passed to add reagent [reagent_type]")
		return FALSE

	if(!IS_FINITE(amount))
		stack_trace("non finite amount passed to add reagent [amount] [reagent_type]")
		return FALSE

	var/datum/reagent/glob_reagent = GLOB.chemical_reagents_list[reagent_type]
	if(!glob_reagent)
		stack_trace("[my_atom] attempted to add a reagent called '[reagent_type]' which doesn't exist. ([usr])")
		return FALSE
	if(!added_purity) //Because purity additions can be 0
		added_purity = glob_reagent.creation_purity //Usually 1
	if(!added_ph)
		added_ph = glob_reagent.ph

	//Split up the reagent if it's in a mob
	if(flags & REAGENT_HOLDER_ALIVE)
		amount = process_mob_reagent_purity(glob_reagent, amount, added_purity, reagent_added)
		if(amount <= 0) //Inverse or nothing was added. return true amount
			return amount * -1

	var/cached_total = total_volume
	if(cached_total + amount > maximum_volume)
		amount = maximum_volume - cached_total //Doesnt fit in. Make it disappear. shouldn't happen. Will happen.
	amount = round(amount, CHEMICAL_QUANTISATION_LEVEL)
	if(amount <= 0)
		return FALSE

	var/cached_temp = chem_temp
	var/list/cached_reagents = reagent_list

	//Equalize temperature - Not using specific_heat() because the new chemical isn't in yet.
	var/old_heat_capacity = 0
	if(reagtemp != cached_temp)
		for(var/datum/reagent/iter_reagent as anything in cached_reagents)
			old_heat_capacity += iter_reagent.specific_heat * iter_reagent.volume

	//add the reagent to the existing if it exists
	for(var/datum/reagent/iter_reagent as anything in cached_reagents)
		if(iter_reagent.type == reagent_type)
			if(override_base_ph)
				added_ph = iter_reagent.ph
			iter_reagent.purity = ((iter_reagent.creation_purity * iter_reagent.volume) + (added_purity * amount)) /(iter_reagent.volume + amount) //This should add the purity to the product
			iter_reagent.creation_purity = iter_reagent.purity
			iter_reagent.ph = ((iter_reagent.ph * (iter_reagent.volume)) + (added_ph * amount)) / (iter_reagent.volume + amount)
			iter_reagent.volume += amount
			update_total()

			iter_reagent.on_merge(data, amount)
			if(reagtemp != cached_temp)
				var/new_heat_capacity = heat_capacity()
				if(new_heat_capacity)
					set_temperature(((old_heat_capacity * cached_temp) + (iter_reagent.specific_heat * amount * reagtemp)) / new_heat_capacity)
				else
					set_temperature(reagtemp)

			if(!isnull(reagent_added))
				reagent_added[iter_reagent] = amount
			if(!no_react && !is_reacting) //To reduce the amount of calculations for a reaction the reaction list is only updated on a reagents addition.
				handle_reactions()
			return amount

	if(!is_reacting && amount < CHEMICAL_VOLUME_ROUNDING)
		return 0

	//otherwise make a new one
	var/datum/reagent/new_reagent = new reagent_type(data)
	cached_reagents += new_reagent
	new_reagent.holder = src
	new_reagent.volume = amount
	new_reagent.purity = added_purity
	new_reagent.creation_purity = added_purity
	new_reagent.ph = added_ph
	new_reagent.on_new(data)
	creation_callback?.Invoke(new_reagent)

	if(isliving(my_atom))
		new_reagent.on_mob_add(my_atom, amount) //Must occur before it could posibly run on_mob_delete

	update_total()
	if(reagtemp != cached_temp)
		var/new_heat_capacity = heat_capacity()
		if(new_heat_capacity)
			set_temperature(((old_heat_capacity * cached_temp) + (new_reagent.specific_heat * amount * reagtemp)) / new_heat_capacity)
		else
			set_temperature(reagtemp)

	if(!isnull(reagent_added))
		reagent_added[new_reagent] = amount
	if(!no_react)
		handle_reactions()
	return amount

/**
 * Like add_reagent but you can enter a list.
 * Arguments
 *
 * * [list_reagents][list] - list to add. Format it like this: list(/datum/reagent/toxin = 10, "beer" = 15)
 * * [data][list] - additional data to add
 * * [added_purity][number] - an override to the default purity for each reagent to add.
 */
/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data = null, added_purity = null)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data, added_purity = added_purity)

/**
 * Removes a specific reagent. can supress reactions if needed
 * Arguments
 *
 * * [reagent_type][datum/reagent] - the type of reagent
 * * amount - the volume to remove
 * * safety - if FALSE will initiate reactions upon removing. used for trans_id_to
 * * include_subtypes - if TRUE will remove the specified amount from all subtypes of reagent_type as well
 */
/datum/reagents/proc/remove_reagent(datum/reagent/reagent_type, amount, safety = TRUE, include_subtypes = FALSE)
	if(!ispath(reagent_type))
		stack_trace("invalid reagent passed to remove reagent [reagent_type]")
		return FALSE

	if(!IS_FINITE(amount))
		stack_trace("non finite amount passed to remove reagent [amount] [reagent_type]")
		return FALSE

	amount = round(amount, CHEMICAL_QUANTISATION_LEVEL)
	if(amount <= 0)
		return FALSE

	var/total_removed_amount = 0
	var/remove_amount = 0
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		//check for specific type or subtypes
		if(!include_subtypes)
			if(cached_reagent.type != reagent_type)
				continue
		else if(!istype(cached_reagent, reagent_type))
			continue

		//reduce the volume
		remove_amount = min(cached_reagent.volume, amount)
		cached_reagent.volume -= remove_amount

		total_removed_amount += remove_amount

		//if we reached here means we have found our specific reagent type so break
		if(!include_subtypes)
			break

	//update the holder & handle reactions
	update_total()
	if(!safety)
		handle_reactions()

	return total_removed_amount

/**
 * Removes all reagents either proportionally(amount is the direct volume to remove)
 * when proportional the total volume of all reagents removed will equal to amount
 * or relatively(amount is a percentile between 0->1) when relative amount is the %
 * of each reagent to be removed
 *
 * Arguments
 *
 * * amount - the amount to remove
 * * relative - if TRUE amount is treated as an percentage between 0->1. If FALSE amount is the direct volume to remove
 */
/datum/reagents/proc/remove_all(amount = 1, relative = FALSE)
	if(!total_volume)
		return FALSE

	if(!IS_FINITE(amount))
		stack_trace("non finite amount passed to remove all reagents [amount]")
		return FALSE
	if(relative && (amount < 0 || amount > 1))
		stack_trace("illegal percentage value passed to remove all reagents [amount]")
		return FALSE

	if(!relative)
		amount = min(amount, total_volume)
	amount = round(amount, CHEMICAL_QUANTISATION_LEVEL)
	if(amount <= 0)
		return FALSE

	var/list/cached_reagents = reagent_list
	var/remove_amount
	var/total_removed_amount = 0
	var/part = amount
	if(!relative)
		part /= total_volume
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		//reduce the volume
		remove_amount = cached_reagent.volume * part
		cached_reagent.volume -= remove_amount

		total_removed_amount += remove_amount
	update_total()
	handle_reactions()

	return round(total_removed_amount, CHEMICAL_QUANTISATION_LEVEL)

/**
 * Removes an specific reagent from this holder
 * Arguments
 *
 * * [target_reagent_typepath][datum/reagent] - type typepath of the reagent to remove
 */
/datum/reagents/proc/del_reagent(datum/reagent/target_reagent_typepath)
	if(!ispath(target_reagent_typepath))
		stack_trace("invalid reagent path passed to del reagent [target_reagent_typepath]")
		return FALSE

	//setting the volume to 0 will allow update_total() to clear it up for us
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(reagent.type == target_reagent_typepath)
			reagent.volume = 0
			update_total()
			return TRUE

	return FALSE

/**
 * Turn one reagent into another, preserving volume, temp, purity, ph
 * Arguments
 *
 * * [source_reagent_typepath][/datum/reagent] - the typepath of the reagent you are trying to convert
 * * [target_reagent_typepath][/datum/reagent] - the final typepath the source_reagent_typepath will be converted into
 * * conversion_volume - how much of the reagent volume to convert
 * * multiplier - the multiplier applied on the source_reagent_typepath volume before converting
 * * include_source_subtypes- if TRUE will convert all subtypes of source_reagent_typepath into target_reagent_typepath as well
 * * keep_data - works only when include_source_subtypes is FALSE. Transfers over the data of the converted reagent
 */
/datum/reagents/proc/convert_reagent(
	datum/reagent/source_reagent_typepath,
	datum/reagent/target_reagent_typepath,
	conversion_volume = total_volume,
	multiplier = 1,
	include_source_subtypes = FALSE,
	keep_data = FALSE,
)
	if(!ispath(source_reagent_typepath))
		stack_trace("invalid reagent path passed to convert reagent [source_reagent_typepath]")
		return FALSE
	if(!ispath(target_reagent_typepath))
		stack_trace("invalid reagent path passed to convert reagent [target_reagent_typepath]")
		return FALSE
	if(conversion_volume <= 0 || conversion_volume > total_volume)
		stack_trace("conversion volume [conversion_volume] out of bounds range is 0<value<=[total_volume]")
		return FALSE
	keep_data = keep_data && !include_source_subtypes

	var/weighted_volume = 0
	var/weighted_purity = 0
	var/weighted_ph = 0
	var/reagent_volume = 0
	var/list/reagent_data

	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		//check for specific type or subtypes
		if(!include_source_subtypes)
			if(cached_reagent.type != source_reagent_typepath)
				continue
		else if(!istype(cached_reagent, source_reagent_typepath))
			continue

		//check conversion threshold. stop if we have reached our target
		reagent_volume = cached_reagent.volume
		if(cached_reagent.volume > conversion_volume)
			reagent_volume = conversion_volume
			cached_reagent.volume -= conversion_volume
			conversion_volume = 0
		else
			conversion_volume -= cached_reagent.volume
			cached_reagent.volume = 0

		//compute average of everything. preserve data if nessassary
		weighted_purity += cached_reagent.purity * reagent_volume
		weighted_ph += cached_reagent.ph * reagent_volume
		weighted_volume += reagent_volume
		if(keep_data)
			reagent_data = copy_data(cached_reagent)

		//stop if we found our specific reagent or reached the conversion threshold
		if(!include_source_subtypes || !conversion_volume)
			break

	//add the new target reagent with the averaged values from the source reagents
	if(weighted_volume > 0)
		update_total()
		add_reagent(
			target_reagent_typepath,
			weighted_volume * multiplier,
			data = reagent_data,
			reagtemp = chem_temp,
			added_purity = (weighted_purity / weighted_volume),
			added_ph = (weighted_ph / weighted_volume),
		)

/// Removes all reagents
/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list

	//setting volume to 0 will allow update_total() to clean it up
	for(var/datum/reagent/reagent as anything in cached_reagents)
		reagent.volume = 0
	update_total()

/**
 * Transfer some stuff from this holder to a target object
 *
 * Arguments:
 * * obj/target - Target to attempt transfer to
 * * amount - amount of reagent volume to transfer
 * * multiplier - multiplies each reagent amount by this number well byond their available volume before transfering. used to create reagents from thin air if you ever need to
 * * datum/reagent/target_id - transfer only this reagent in this holder leaving others untouched
 * * preserve_data - if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
 * * no_react - passed through to [/datum/reagents/proc/add_reagent]
 * * mob/transferred_by - used for logging
 * * remove_blacklisted - skips transferring of reagents without REAGENT_CAN_BE_SYNTHESIZED in chemical_flags
 * * methods - passed through to [/datum/reagents/proc/expose] and [/datum/reagent/proc/on_transfer]
 * * show_message - passed through to [/datum/reagents/proc/expose]
 * * ignore_stomach - when using methods INGEST will not use the stomach as the target
 * * copy_only - transfers the reagents without removing it from this holder
 */
/datum/reagents/proc/trans_to(
	atom/target,
	amount = 1,
	multiplier = 1,
	datum/reagent/target_id,
	preserve_data = TRUE,
	no_react = FALSE,
	mob/transferred_by,
	remove_blacklisted = FALSE,
	methods = NONE,
	show_message = TRUE,
	ignore_stomach = FALSE,
	copy_only = FALSE
)
	if(QDELETED(target) || !total_volume)
		return FALSE

	if(!IS_FINITE(amount))
		stack_trace("non finite amount passed to trans_to [amount] amount of reagents")
		return FALSE

	if(!isnull(target_id) && !ispath(target_id))
		stack_trace("invalid target reagent id [target_id] passed to trans_to")
		return FALSE

	var/list/cached_reagents = reagent_list

	var/atom/target_atom
	var/datum/reagents/target_holder
	if(istype(target, /datum/reagents))
		target_holder = target
		target_atom = target_holder.my_atom
	else
		if(!ignore_stomach && (methods & INGEST) && iscarbon(target))
			var/mob/living/carbon/eater = target
			var/obj/item/organ/stomach/belly = eater.get_organ_slot(ORGAN_SLOT_STOMACH)
			if(!belly)
				var/expel_amount = round(amount, CHEMICAL_QUANTISATION_LEVEL)
				if(expel_amount > 0 )
					eater.expel_ingested(my_atom, expel_amount)
				return
			target_holder = belly.reagents
			target_atom = belly
		else if(!target.reagents)
			return
		else
			target_holder = target.reagents
			target_atom = target

	// Prevents small amount problems, as well as zero and below zero amounts.
	amount = round(min(amount, total_volume, target_holder.maximum_volume - target_holder.total_volume), CHEMICAL_QUANTISATION_LEVEL)
	if(amount <= 0)
		return FALSE

	var/trans_data = null
	var/list/r_to_send = methods ? list() : null // Validated list of reagents to be exposed
	var/list/transfer_log = list()

	var/part = isnull(target_id) ? (amount / total_volume) : 1
	var/transfer_amount
	var/transfered_amount
	var/total_transfered_amount = 0

	//first add reagents to target
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(remove_blacklisted && !(reagent.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
			continue

		if(!isnull(target_id))
			if(reagent.type == target_id)
				force_stop_reagent_reacting(reagent)
				transfer_amount = min(amount, reagent.volume)
			else
				continue
		else
			transfer_amount = reagent.volume * part

		if(preserve_data)
			trans_data = copy_data(reagent)
		if(reagent.intercept_reagents_transfer(target_holder, transfer_amount, copy_only))
			continue
		transfered_amount = target_holder.add_reagent(reagent.type, transfer_amount * multiplier, trans_data, chem_temp, reagent.purity, reagent.ph, no_react = TRUE, reagent_added = r_to_send, creation_callback = CALLBACK(src, PROC_REF(_on_transfer_creation), reagent, target_holder)) //we only handle reaction after every reagent has been transferred.
		if(!transfered_amount)
			continue

		total_transfered_amount += transfered_amount
		if(!copy_only)
			reagent.volume -= transfer_amount
		transfer_log += "[reagent.type] ([transfered_amount]u, [reagent.purity] purity)"

		if(!isnull(target_id))
			break
	if(!copy_only)
		update_total()

	//expose target to reagent changes
	if(methods)
		target_holder.expose(isorgan(target_atom) ? target : target_atom, methods, 1, show_message, r_to_send)

	//combat log
	if(transferred_by && target_atom)
		//logging mob holder
		var/atom/log_target = target_atom
		if(isorgan(target_atom))
			var/obj/item/organ/organ_item = target_atom
			log_target = organ_item.owner ? organ_item.owner : organ_item
		log_target.add_hiddenprint(transferred_by) //log prints so admins can figure out who touched it last.

		//logging reagents
		log_combat(transferred_by, log_target, "transferred reagents to", my_atom, "which had [english_list(transfer_log)]")

	if(!no_react)
		transfer_reactions(target_holder)
		if(!copy_only)
			handle_reactions()
		target_holder.handle_reactions()

	return total_transfered_amount

///For internal purposes. Sends a signal when a new reagent has been created in the target reagent holder upon transfer
/datum/reagents/proc/_on_transfer_creation(datum/reagent/reagent, datum/reagents/target_holder, datum/reagent/new_reagent)
	PRIVATE_PROC(TRUE)

	SEND_SIGNAL(reagent, COMSIG_REAGENT_ON_TRANSFER, target_holder, new_reagent)

/**
 * Multiplies reagents inside this holder by a specific amount
 * Arguments
 *
 * * multiplier - the amount to multiply each reagent, its a percentile value where < 1 will reduce the volume and
 * * > 1 will increase the volume. Final multiplier applied to the reagent volume is (1 - multiplier)
 * * datum/reagent/target_id - multiply only this reagent in this holder leaving others untouched
 */
/datum/reagents/proc/multiply(multiplier = 1, datum/reagent/target_id)
	if(!total_volume)
		return

	multiplier = round(min(multiplier, maximum_volume / total_volume), CHEMICAL_QUANTISATION_LEVEL)
	if(multiplier < 0 || multiplier == 1)
		return

	if(!isnull(target_id) && !ispath(target_id))
		stack_trace("Bad reagent path [target_id] passed to multiply")
		return

	var/change = (multiplier - 1) //Get the % change
	var/reagent_change
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(!isnull(target_id) && reagent.type != target_id)
			continue

		reagent_change = reagent.volume * change
		if(change > 0)
			add_reagent(reagent.type, reagent_change, added_purity = reagent.purity, added_ph = reagent.ph, no_react = TRUE)
		else
			reagent.volume += reagent_change

		if(!isnull(target_id))
			break

	if(change < 0)
		update_total()
	handle_reactions()

/// Updates [/datum/reagents/var/total_volume]
/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	var/list/deleted_reagents = list()
	var/chem_index = 1
	var/num_reagents = length(cached_reagents)
	var/total_ph = 0
	var/reagent_volume = 0
	. = 0

	//responsible for removing reagents and computing total ph & volume
	//all its code was taken out of del_reagent() initially for efficiency purposes
	while(chem_index <= num_reagents)
		var/datum/reagent/reagent = cached_reagents[chem_index]
		chem_index += 1
		reagent_volume = round(reagent.volume, CHEMICAL_QUANTISATION_LEVEL) //round to this many decimal places

		//remove very small amounts of reagents
		if(reagent_volume <= 0 || (!is_reacting && reagent_volume < CHEMICAL_VOLUME_ROUNDING))
			//end metabolization
			if(isliving(my_atom))
				if(reagent.metabolizing)
					reagent.metabolizing = FALSE
					reagent.on_mob_end_metabolize(my_atom)
				reagent.on_mob_delete(my_atom)

			//removing it and store in a seperate list for processing later
			cached_reagents -= reagent
			LAZYREMOVE(previous_reagent_list, reagent.type)
			deleted_reagents += reagent

			//move pointer back so we don't overflow & decrease length
			chem_index -= 1
			num_reagents -= 1
			continue

		//compute volume & ph like we would normally
		. += reagent_volume
		total_ph += reagent.ph * reagent_volume

		//reasign rounded value
		reagent.volume = reagent_volume

	//assign the final values, rounding up can sometimes cause overflow so bring it down
	total_volume = min(round(., CHEMICAL_VOLUME_ROUNDING), maximum_volume)
	if(!total_volume)
		ph = CHEMICAL_NORMAL_PH
	else
		ph = clamp(total_ph / total_volume, CHEMICAL_MIN_PH, CHEMICAL_MAX_PH)

	//clear out deleted reagents
	QDEL_LIST(deleted_reagents)

	//inform hooks about reagent changes
	SEND_SIGNAL(src, COMSIG_REAGENTS_HOLDER_UPDATED)

/**
 * Shallow copies (deep copy of viruses) data from the provided reagent into our copy of that reagent
 * Arguments
 * [current_reagent][datum/reagent] - the reagent(not typepath) to copy data from
 */
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
		var/list/viruses = list()
		for (var/datum/disease/disease as anything in trans_data["viruses"])
			viruses += disease.Copy()
		trans_data["viruses"] = viruses

	return trans_data

//===============================Generic getters=======================================
/**
 * Returns a reagent from this holder if it matches all the specified arguments
 * Arguments
 *
 * * [target_reagent][datum/reagent] - the reagent typepath to check for. can be null to return any reagent
 * * amount - checks for having a specific amount of that chemical
 * * needs_metabolizing - takes into consideration if the chemical is matabolizing when it's checked.
 * * check_subtypes - controls whether it should it should also include subtypes: ispath(type, reagent) versus type == reagent.
 * * chemical_flags - checks for reagent flags.
 */
/datum/reagents/proc/has_reagent(
	datum/reagent/target_reagent,
	amount = -1,
	needs_metabolizing = FALSE,
	check_subtypes = FALSE,
	chemical_flags = NONE
)
	if(!isnull(target_reagent) && !ispath(target_reagent))
		stack_trace("invalid reagent path passed to has reagent [target_reagent]")
		return FALSE

	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/holder_reagent as anything in cached_reagents)
		//finding for a specific reagent
		if(!isnull(target_reagent))
			//first find for specific type or subtype
			if(!check_subtypes)
				if(holder_reagent.type != target_reagent)
					continue
			else if(!istype(holder_reagent, target_reagent))
				continue

		//next check if we have the requested amount
		if(amount > 0 && holder_reagent.volume < amount)
			continue

		//next check for metabolization
		if(needs_metabolizing && !holder_reagent.metabolizing)
			continue

		//next check if it has the specified flag
		if(chemical_flags && !(holder_reagent.chemical_flags & chemical_flags))
			continue

		//after all that if we get here then we have found our reagent
		return holder_reagent

	return FALSE


/// Get a reference to the reagent there is the most of in this holder
/datum/reagents/proc/get_master_reagent()
	var/list/cached_reagents = reagent_list
	var/datum/reagent/master
	var/max_volume = 0
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(reagent.volume > max_volume)
			max_volume = reagent.volume
			master = reagent

	return master


//================================Exposure(to apply reagent effects)======================
/**
 * Applies the relevant expose_ proc for every reagent in this holder
 * * [/datum/reagent/proc/expose_mob]
 * * [/datum/reagent/proc/expose_turf]
 * * [/datum/reagent/proc/expose_obj]
 *
 * Arguments
 * - Atom/target: What mob/turf/object is being exposed to reagents? This is your reaction target.
 * - Methods: What reaction type is the reagent itself going to call on the reaction target? Types are TOUCH, INGEST, VAPOR, PATCH, INJECT and INHALE.
 * - Volume_modifier: reagent volume modifier applied to the reagents(passed to r_to_expose or this holder) before exposing. Must be between 0->1
 * - Show_message: Whether to display anything to mobs when they are exposed.
 * - list/datum/reagent/r_to_expose: map of[/datum/reagent -> amount] when you to want to expose specific reagents with precise amounts
 */
/datum/reagents/proc/expose(atom/target, methods = TOUCH, volume_modifier = 1, show_message = 1, list/datum/reagent/r_to_expose = null)
	if(isnull(target))
		return

	if(volume_modifier <= 0)
		stack_trace("Volume modifier [volume_modifier] must be +ve")
		return

	var/list/datum/reagent/reagents = list()
	if(isnull(r_to_expose))
		for(var/datum/reagent/reagent as anything in reagent_list)
			reagents[reagent] = reagent.volume * volume_modifier
	else
		for(var/datum/reagent/reagent as anything in r_to_expose)
			reagents[reagent] = r_to_expose[reagent] * volume_modifier

	return target.expose_reagents(reagents, src, methods, show_message)

/**
 * Applies heat to this holder
 * Arguments
 *
 * * temperature - the temperature we to heat/cool by
 * * coeff - multiplier to be applied on temp diff between param temp and current temp
 */
/datum/reagents/proc/expose_temperature(temperature, coeff = 0.02)
	if(flags & NO_REACT) //stasis holders IE cryobeaker
		return
	var/temp_delta = (temperature - chem_temp) * coeff
	if(temp_delta > 0)
		chem_temp = min(chem_temp + max(temp_delta, 1), temperature)
	else
		chem_temp = max(chem_temp + min(temp_delta, -1), temperature)
	set_temperature(round(chem_temp))
	handle_reactions()


//===============================Logging==========================================
/// Outputs a log-friendly list of reagents based on the internal reagent_list.
/datum/reagents/proc/get_reagent_log_string()
	if(!length(reagent_list))
		return "no reagents"

	var/list/data = list()

	for(var/datum/reagent/reagent as anything in reagent_list)
		data += "[reagent.type] [reagent.volume]u, [reagent.purity] purity)"

	return english_list(data)
