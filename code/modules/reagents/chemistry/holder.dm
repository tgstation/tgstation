#define REAGENTS_UI_MODE_LOOKUP 0
#define REAGENTS_UI_MODE_REAGENT 1
#define REAGENTS_UI_MODE_RECIPE 2

#define REAGENT_TRANSFER_AMOUNT "amount"
#define REAGENT_PURITY "purity"

/// Initialises all /datum/reagent into a list indexed by reagent id
/proc/init_chemical_reagent_list()
	var/list/reagent_list = list()

	var/paths = subtypesof(/datum/reagent)

	for(var/path in paths)
		if(path in GLOB.fake_reagent_blacklist)
			continue
		var/datum/reagent/D = new path()
		D.mass = rand(10, 800) //This is terrible and should be removed ASAP!
		reagent_list[path] = D

	return reagent_list

/proc/build_chemical_reactions_lists()
	//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
	// It is filtered into multiple lists within a list.
	// For example:
	// chemical_reactions_list_reactant_index[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma
	//For chemical reaction list product index - indexes reactions based off the product reagent type - see get_recipe_from_reagent_product() in helpers
	//For chemical reactions list lookup list - creates a bit list of info passed to the UI. This is saved to reduce lag from new windows opening, since it's a lot of data.

	//Prevent these reactions from appearing in lookup tables (UI code)
	var/list/blacklist = (/datum/chemical_reaction/randomized)

	if(GLOB.chemical_reactions_list_reactant_index)
		return

	//Randomized need to go last since they need to check against conflicts with normal recipes
	var/paths = subtypesof(/datum/chemical_reaction) - typesof(/datum/chemical_reaction/randomized) + subtypesof(/datum/chemical_reaction/randomized)
	GLOB.chemical_reactions_list = list() //typepath to reaction list
	GLOB.chemical_reactions_list_reactant_index = list() //reagents to reaction list
	GLOB.chemical_reactions_results_lookup_list = list() //UI glob
	GLOB.chemical_reactions_list_product_index = list() //product to reaction list

	for(var/path in paths)
		var/datum/chemical_reaction/D = new path()
		var/list/reaction_ids = list()
		var/list/product_ids = list()
		var/list/reagents = list()
		var/list/product_names = list()
		var/bitflags = D.reaction_tags

		if(!D.required_reagents || !D.required_reagents.len) //Skip impossible reactions
			continue

		GLOB.chemical_reactions_list[path] = D

		for(var/reaction in D.required_reagents)
			reaction_ids += reaction
			var/datum/reagent/reagent = find_reagent_object_from_type(reaction)
			reagents += list(list("name" = reagent.name, "id" = reagent.type))

		for(var/product in D.results)
			var/datum/reagent/reagent = find_reagent_object_from_type(product)
			product_names += reagent.name
			product_ids += product

		var/product_name
		if(!length(product_names))
			var/list/names = splittext("[D.type]", "/")
			product_name = names[names.len]
		else
			product_name = product_names[1]

		// Create filters based on each reagent id in the required reagents list - this is specifically for finding reactions from product(reagent) ids/typepaths.
		for(var/id in product_ids)
			if(is_type_in_list(D.type, blacklist))
				continue
			if(!GLOB.chemical_reactions_list_product_index[id])
				GLOB.chemical_reactions_list_product_index[id] = list()
			GLOB.chemical_reactions_list_product_index[id] += D

		//Master list of ALL reactions that is used in the UI lookup table. This is expensive to make, and we don't want to lag the server by creating it on UI request, so it's cached to send to UIs instantly.
		if(!(is_type_in_list(D.type, blacklist)))
			GLOB.chemical_reactions_results_lookup_list += list(list("name" = product_name, "id" = D.type, "bitflags" = bitflags, "reactants" = reagents))

		// Create filters based on each reagent id in the required reagents list - this is used to speed up handle_reactions()
		for(var/id in reaction_ids)
			if(!GLOB.chemical_reactions_list_reactant_index[id])
				GLOB.chemical_reactions_list_reactant_index[id] = list()
			GLOB.chemical_reactions_list_reactant_index[id] += D
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

/datum/reagents/New(maximum=100, new_flags=0)
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
 * * ignore splitting - Don't call the process that handles reagent spliting in a mob (impure/inverse) - generally leave this false unless you care about REAGENTS_DONOTSPLIT flags (see reagent defines)
 */
/datum/reagents/proc/add_reagent(reagent, amount, list/data=null, reagtemp = DEFAULT_REAGENT_TEMPERATURE, added_purity = null, added_ph, no_react = FALSE, override_base_ph = FALSE, ignore_splitting = FALSE)
	if(!isnum(amount) || !amount)
		return FALSE

	if(amount <= CHEMICAL_QUANTISATION_LEVEL)//To prevent small amount problems.
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_REAGENTS_PRE_ADD_REAGENT, reagent, amount, reagtemp, data, no_react) & COMPONENT_CANCEL_REAGENT_ADD)
		return FALSE

	var/datum/reagent/glob_reagent = GLOB.chemical_reagents_list[reagent]
	if(!glob_reagent)
		stack_trace("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")
		return FALSE
	if(isnull(added_purity)) //Because purity additions can be 0
		added_purity = glob_reagent.creation_purity //Usually 1
	if(!added_ph)
		added_ph = glob_reagent.ph

	//Split up the reagent if it's in a mob
	var/has_split = FALSE
	if(!ignore_splitting && (flags & REAGENT_HOLDER_ALIVE)) //Stomachs are a pain - they will constantly call on_mob_add unless we split on addition to stomachs, but we also want to make sure we don't double split
		var/adjusted_vol = process_mob_reagent_purity(glob_reagent, amount, added_purity)
		if(!adjusted_vol) //If we're inverse or FALSE cancel addition
			return TRUE
			/* We return true here because of #63301
			The only cases where this will be false or 0 if its an inverse chem, an impure chem of 0 purity (highly unlikely if even possible), or if glob_reagent is null (which shouldn't happen at all as there's a check for that a few lines up),
			In the first two cases, we would want to return TRUE so trans_to and other similar methods actually delete the corresponding chemical from the original reagent holder.
			*/
		amount = adjusted_vol
		has_split = TRUE

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
		for(var/datum/reagent/iter_reagent as anything in cached_reagents)
			old_heat_capacity += iter_reagent.specific_heat * iter_reagent.volume

	//add the reagent to the existing if it exists
	for(var/datum/reagent/iter_reagent as anything in cached_reagents)
		if(iter_reagent.type == reagent)
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

	if(has_split) //prevent it from splitting again
		new_reagent.chemical_flags |= REAGENT_DONOTSPLIT

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
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		if(cached_reagent.type == reagent)
			//clamp the removal amount to be between current reagent amount
			//and zero, to prevent removing more than the holder has stored
			amount = clamp(amount, 0, cached_reagent.volume)
			cached_reagent.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			SEND_SIGNAL(src, COMSIG_REAGENTS_REM_REAGENT, QDELING(cached_reagent) ? reagent : cached_reagent, amount)

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
		for(var/datum/reagent/reagent as anything in cached_reagents)
			remove_reagent(reagent.type, reagent.volume * part)

		//finish_reacting() //A just in case - update total is in here - should be unneeded, make sure to test this
		handle_reactions()
		return amount

/// Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1)
	if(!isnum(amount))
		return 1
	var/list/cached_reagents = reagent_list
	var/has_removed_reagent = 0

	for(var/datum/reagent/reagent as anything in cached_reagents)
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(reagent.type == reagent_type)
				matches = 1
		else
			if(istype(reagent, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent. Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(reagent.type, amount, safety)

	return has_removed_reagent

/// Fuck this one reagent
/datum/reagents/proc/del_reagent(target_reagent_typepath)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(reagent.type == target_reagent_typepath)
			if(isliving(my_atom))
				if(reagent.metabolizing)
					reagent.metabolizing = FALSE
					reagent.on_mob_end_metabolize(my_atom)
				reagent.on_mob_delete(my_atom)

			reagent_list -= reagent
			LAZYREMOVE(previous_reagent_list, reagent.type)
			qdel(reagent)
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
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		if(cached_reagent.type != reagent)
			del_reagent(cached_reagent.type)
			update_total()

/// Removes all reagents
/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		del_reagent(reagent.type)
	SEND_SIGNAL(src, COMSIG_REAGENTS_CLEAR_REAGENTS)


/**
 * Check if this holder contains this reagent.
 * Reagent takes a PATH to a reagent.
 * Amount checks for having a specific amount of that chemical.
 * Needs matabolizing takes into consideration if the chemical is matabolizing when it's checked.
 */
/datum/reagents/proc/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/holder_reagent as anything in cached_reagents)
		if (holder_reagent.type == reagent)
			if(!amount)
				if(needs_metabolizing && !holder_reagent.metabolizing)
					return FALSE
				return holder_reagent
			else
				if(round(holder_reagent.volume, CHEMICAL_QUANTISATION_LEVEL) >= amount)
					if(needs_metabolizing && !holder_reagent.metabolizing)
						return FALSE
					return holder_reagent
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
		for(var/datum/reagent/reagent as anything in cached_reagents)
			if(remove_blacklisted && !(reagent.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
				continue
			var/transfer_amount = reagent.volume * part
			if(preserve_data)
				trans_data = copy_data(reagent)
			if(reagent.intercept_reagents_transfer(R, cached_amount))//Use input amount instead.
				continue
			if(!R.add_reagent(reagent.type, transfer_amount * multiplier, trans_data, chem_temp, reagent.purity, reagent.ph, no_react = TRUE, ignore_splitting = reagent.chemical_flags & REAGENT_DONOTSPLIT)) //we only handle reaction after every reagent has been transfered.
				continue
			if(methods)
				if(istype(target_atom, /obj/item/organ))
					R.expose_single(reagent, target, methods, part, show_message)
				else
					R.expose_single(reagent, target_atom, methods, part, show_message)
				reagent.on_transfer(target_atom, methods, transfer_amount * multiplier)
			remove_reagent(reagent.type, transfer_amount)
			var/list/reagent_qualities = list(REAGENT_TRANSFER_AMOUNT = transfer_amount, REAGENT_PURITY = reagent.purity)
			transfer_log[reagent.type] = reagent_qualities

	else
		var/to_transfer = amount
		for(var/datum/reagent/reagent as anything in cached_reagents)
			if(!to_transfer)
				break
			if(remove_blacklisted && !(reagent.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
				continue
			if(preserve_data)
				trans_data = copy_data(reagent)
			var/transfer_amount = amount
			if(amount > reagent.volume)
				transfer_amount = reagent.volume
			if(reagent.intercept_reagents_transfer(R, cached_amount))//Use input amount instead.
				continue
			if(!R.add_reagent(reagent.type, transfer_amount * multiplier, trans_data, chem_temp, reagent.purity, reagent.ph, no_react = TRUE, ignore_splitting = reagent.chemical_flags & REAGENT_DONOTSPLIT)) //we only handle reaction after every reagent has been transfered.
				continue
			to_transfer = max(to_transfer - transfer_amount , 0)
			if(methods)
				if(istype(target_atom, /obj/item/organ))
					R.expose_single(reagent, target, methods, transfer_amount, show_message)
				else
					R.expose_single(reagent, target_atom, methods, transfer_amount, show_message)
				reagent.on_transfer(target_atom, methods, transfer_amount * multiplier)
			remove_reagent(reagent.type, transfer_amount)
			var/list/reagent_qualities = list(REAGENT_TRANSFER_AMOUNT = transfer_amount, REAGENT_PURITY = reagent.purity)
			transfer_log[reagent.type] = reagent_qualities

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

	var/datum/reagents/holder
	if(istype(target, /datum/reagents))
		holder = target
	else if(target.reagents && total_volume > 0 && get_reagent_amount(reagent))
		holder = target.reagents
	else
		return
	if(amount < 0)
		return
	var/cached_amount = amount
	if(get_reagent_amount(reagent) < amount)
		amount = get_reagent_amount(reagent)

	amount = min(round(amount, CHEMICAL_VOLUME_ROUNDING), holder.maximum_volume - holder.total_volume)
	var/trans_data = null
	for (var/looping_through_reagents in cached_reagents)
		var/datum/reagent/current_reagent = looping_through_reagents
		if(current_reagent.type == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			if(current_reagent.intercept_reagents_transfer(holder, cached_amount))//Use input amount instead.
				break
			force_stop_reagent_reacting(current_reagent)
			holder.add_reagent(current_reagent.type, amount, trans_data, chem_temp, current_reagent.purity, current_reagent.ph, no_react = TRUE, ignore_splitting = current_reagent.chemical_flags & REAGENT_DONOTSPLIT)
			remove_reagent(current_reagent.type, amount, 1)
			break

	update_total()
	holder.update_total()
	holder.handle_reactions()
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
	for(var/datum/reagent/reagent as anything in cached_reagents)
		var/copy_amount = reagent.volume * part
		if(preserve_data)
			trans_data = reagent.data
		R.add_reagent(reagent.type, copy_amount * multiplier, trans_data, added_purity = reagent.purity, added_ph = reagent.ph, no_react = TRUE, ignore_splitting = reagent.chemical_flags & REAGENT_DONOTSPLIT)

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
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(change > 0)
			add_reagent(reagent.type, reagent.volume * change, added_purity = reagent.purity, ignore_splitting = reagent.chemical_flags & REAGENT_DONOTSPLIT)
		else
			remove_reagent(reagent.type, abs(reagent.volume * change)) //absolute value to prevent a double negative situation (removing -50% would be adding 50%)

	update_total()
	handle_reactions()


/// Get the name of the reagent there is the most of in this holder
/datum/reagents/proc/get_master_reagent_name()
	var/list/cached_reagents = reagent_list
	var/name
	var/max_volume = 0
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(reagent.volume > max_volume)
			max_volume = reagent.volume
			name = reagent.name

	return name

/// Get the id of the reagent there is the most of in this holder
/datum/reagents/proc/get_master_reagent_id()
	var/list/cached_reagents = reagent_list
	var/max_type
	var/max_volume = 0
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(reagent.volume > max_volume)
			max_volume = reagent.volume
			max_type = reagent.type

	return max_type

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
/*							MOB/CARBON RELATED PROCS 								*/

/**
 * Triggers metabolizing for all the reagents in this holder
 *
 * Arguments:
 * * mob/living/carbon/carbon - The mob to metabolize in, if null it uses [/datum/reagents/var/my_atom]
 * * delta_time - the time in server seconds between proc calls (when performing normally it will be 2)
 * * times_fired - the number of times the owner's life() tick has been called aka The number of times SSmobs has fired
 * * can_overdose - Allows overdosing
 * * liverless - Stops reagents that aren't set as [/datum/reagent/var/self_consuming] from metabolizing
 */
/datum/reagents/proc/metabolize(mob/living/carbon/owner, delta_time, times_fired, can_overdose = FALSE, liverless = FALSE)
	var/list/cached_reagents = reagent_list
	if(owner)
		expose_temperature(owner.bodytemperature, 0.25)
	var/need_mob_update = FALSE
	for(var/datum/reagent/reagent as anything in cached_reagents)
		need_mob_update += metabolize_reagent(owner, reagent, delta_time, times_fired, can_overdose, liverless)
	if(owner && need_mob_update) //some of the metabolized reagents had effects on the mob that requires some updates.
		owner.updatehealth()
		owner.update_stamina()
	update_total()

/*
 * Metabolises a single reagent for a target owner carbon mob. See above.
 *
 * Arguments:
 * * mob/living/carbon/owner - The mob to metabolize in, if null it uses [/datum/reagents/var/my_atom]
 * * delta_time - the time in server seconds between proc calls (when performing normally it will be 2)
 * * times_fired - the number of times the owner's life() tick has been called aka The number of times SSmobs has fired
 * * can_overdose - Allows overdosing
 * * liverless - Stops reagents that aren't set as [/datum/reagent/var/self_consuming] from metabolizing
 */
/datum/reagents/proc/metabolize_reagent(mob/living/carbon/owner, datum/reagent/reagent, delta_time, times_fired, can_overdose = FALSE, liverless = FALSE)
	var/need_mob_update = FALSE
	if(QDELETED(reagent.holder))
		return FALSE

	if(!owner)
		owner = reagent.holder.my_atom

	if(owner && reagent)
		if(!owner.reagent_check(reagent, delta_time, times_fired) != TRUE)
			return
		if(liverless && !reagent.self_consuming) //need to be metabolized
			return
		if(!reagent.metabolizing)
			reagent.metabolizing = TRUE
			reagent.on_mob_metabolize(owner)
		if(can_overdose)
			if(reagent.overdose_threshold)
				if(reagent.volume >= reagent.overdose_threshold && !reagent.overdosed)
					reagent.overdosed = TRUE
					need_mob_update += reagent.overdose_start(owner)
					log_game("[key_name(owner)] has started overdosing on [reagent.name] at [reagent.volume] units.")
			for(var/addiction in reagent.addiction_types)
				owner.mind?.add_addiction_points(addiction, reagent.addiction_types[addiction] * REAGENTS_METABOLISM)

			if(reagent.overdosed)
				need_mob_update += reagent.overdose_process(owner, delta_time, times_fired)

		need_mob_update += reagent.on_mob_life(owner, delta_time, times_fired)
	return need_mob_update

/// Signals that metabolization has stopped, triggering the end of trait-based effects
/datum/reagents/proc/end_metabolization(mob/living/carbon/C, keep_liverless = TRUE)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(QDELETED(reagent.holder))
			continue
		if(keep_liverless && reagent.self_consuming) //Will keep working without a liver
			continue
		if(!C)
			C = reagent.holder.my_atom
		if(reagent.metabolizing)
			reagent.metabolizing = FALSE
			reagent.on_mob_end_metabolize(C)

/*Processes the reagents in the holder and converts them, only called in a mob/living/carbon on addition
*
* Arguments:
* * reagent - the added reagent datum/object
* * added_volume - the volume of the reagent that was added (since it can already exist in a mob)
* * added_purity - the purity of the added volume
* returns the volume of the original, pure, reagent to add / keep
*/
/datum/reagents/proc/process_mob_reagent_purity(datum/reagent/reagent, added_volume, added_purity)
	if(!reagent)
		stack_trace("Attempted to process a mob's reagent purity for a null reagent!")
		return FALSE
	if(added_purity == 1)
		return added_volume
	if(reagent.chemical_flags & REAGENT_DONOTSPLIT)
		return added_volume
	if(added_purity < 0)
		stack_trace("Purity below 0 for chem on mob splitting: [reagent.type]!")
		added_purity = 0

	if((reagent.inverse_chem_val > added_purity) && (reagent.inverse_chem))//Turns all of a added reagent into the inverse chem
		add_reagent(reagent.inverse_chem, added_volume, FALSE, added_purity = 1-reagent.creation_purity)
		var/datum/reagent/inverse_reagent = has_reagent(reagent.inverse_chem)
		if(inverse_reagent.chemical_flags & REAGENT_SNEAKYNAME)
			inverse_reagent.name = reagent.name//Negative effects are hidden
		return FALSE //prevent addition
	else if(reagent.impure_chem)
		var/impure_vol = added_volume * (1 - added_purity) //turns impure ratio into impure chem
		add_reagent(reagent.impure_chem, impure_vol, FALSE, added_purity = 1-reagent.creation_purity)
		if(!(reagent.chemical_flags & REAGENT_SPLITRETAINVOL))
			return added_volume - impure_vol
	return added_volume

///Processes any chems that have the REAGENT_IGNORE_STASIS bitflag ONLY
/datum/reagents/proc/handle_stasis_chems(mob/living/carbon/owner, delta_time, times_fired)
	var/need_mob_update = FALSE
	for(var/datum/reagent/reagent as anything in reagent_list)
		if(!(reagent.chemical_flags & REAGENT_IGNORE_STASIS))
			continue
		need_mob_update += metabolize_reagent(owner, reagent, delta_time, times_fired, can_overdose = TRUE)
	if(owner && need_mob_update) //some of the metabolized reagents had effects on the mob that requires some updates.
		owner.updatehealth()
		owner.update_stamina()
	update_total()

/**
 * Calls [/datum/reagent/proc/on_move] on every reagent in this holder
 *
 * Arguments:
 * * atom/A - passed to on_move
 * * Running - passed to on_move
 */
/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		reagent.on_move(A, Running)
	update_total()

/**
 * Calls [/datum/reagent/proc/on_update] on every reagent in this holder
 *
 * Arguments:
 * * atom/A - passed to on_update
 */
/datum/reagents/proc/conditional_update(atom/A)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		reagent.on_update(A)
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
	var/list/cached_reactions = GLOB.chemical_reactions_list_reactant_index
	var/datum/cached_my_atom = my_atom
	LAZYNULL(failed_but_capable_reactions)

	. = 0
	var/list/possible_reactions = list()
	for(var/datum/reagent/reagent as anything in cached_reagents)
		for(var/datum/chemical_reaction/reaction as anything in cached_reactions[reagent.type]) // Was a big list but now it should be smaller since we filtered it with our reagent id
			if(!reaction)
				continue

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
				granularity = CHEMICAL_VOLUME_MINIMUM

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
					possible_reactions += reaction
				else
					LAZYADD(failed_but_capable_reactions, reaction)

	update_previous_reagent_list()
	//This is the point where we have all the possible reactions from a reagent/catalyst point of view, so we set up the reaction list
	for(var/datum/chemical_reaction/selected_reaction as anything in possible_reactions)
		if((selected_reaction.reaction_flags & REACTION_INSTANT) || (flags & REAGENT_HOLDER_INSTANT_REACT)) //If we have instant reactions, we process them here
			instant_react(selected_reaction)
			.++
			update_total()
			continue
		else
			var/exists = FALSE
			for(var/datum/equilibrium/E_exist as anything in reaction_list)
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
					equilibrium.reaction.on_reaction(src, equilibrium, equilibrium.multiplier)
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
	for(var/datum/equilibrium/equilibrium as anything in reaction_list)
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
		my_atom.audible_message(span_notice("[icon2html(my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [mix_message.Join()]"))

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
	equilibrium.reaction.reaction_finish(src, equilibrium, equilibrium.reacted_vol)
	if(!equilibrium.holder || !equilibrium.reaction) //Somehow I'm getting empty equilibrium. This is here to handle them
		LAZYREMOVE(reaction_list, equilibrium)
		qdel(equilibrium)
		stack_trace("The equilibrium datum currently processing in this reagents datum had a nulled holder or nulled reaction. src holder:[my_atom] || src type:[my_atom.type] ") //Shouldn't happen. Does happen
		return
	if(equilibrium.holder != src) //When called from Destroy() eqs are nulled in smoke. This is very strange. This is probably causing it to spam smoke because of the runtime interupting the removal.
		stack_trace("The equilibrium datum currently processing in this reagents datum had a desynced holder to the ending reaction. src holder:[my_atom] | equilibrium holder:[equilibrium.holder.my_atom] || src type:[my_atom.type] | equilibrium holder:[equilibrium.holder.my_atom.type]")
		LAZYREMOVE(reaction_list, equilibrium)

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
	for(var/datum/reagent/reagent as anything in reagent_list)
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
	for(var/datum/equilibrium/equilibrium as anything in reaction_list)
		mix_message += end_reaction(equilibrium)
	if(length(mix_message))
		my_atom.audible_message(span_notice("[icon2html(my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [mix_message.Join()]"))
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
	for(var/datum/equilibrium/equilibrium as anything in reaction_list)
		for(var/result in equilibrium.reaction.results)
			if(result == reagent.type)
				mix_message += end_reaction(equilibrium)
				any_stopped = TRUE
	if(length(mix_message))
		my_atom.audible_message(span_notice("[icon2html(my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))][mix_message.Join()]"))
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
	for(var/datum/equilibrium/reaction_source as anything in reaction_list)
		var/exists = FALSE
		for(var/datum/equilibrium/reaction_target as anything in target.reaction_list) //Don't add duplicates
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
	for(var/datum/chemical_reaction/reaction as anything in failed_but_capable_reactions)
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
	for(var/datum/reagent/reagent as anything in reagent_list)
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
	for(var/_reagent in cached_required_reagents)//this is not an object
		var/datum/reagent/reagent = has_reagent(_reagent)
		if (!reagent)
			continue
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

			my_atom.audible_message(span_notice("[iconhtml] [selected_reaction.mix_message]"))

		if(istype(cached_my_atom, /obj/item/slime_extract))
			var/obj/item/slime_extract/extract = my_atom
			extract.Uses--
			if(extract.Uses <= 0) // give the notification that the slime core is dead
				my_atom.visible_message(span_notice("[iconhtml] \The [my_atom]'s power is consumed in the reaction."))
				extract.name = "used slime extract"
				extract.desc = "This extract has been used up."

	selected_reaction.on_reaction(src, null, multiplier)

///Possibly remove - see if multiple instant reactions is okay (Though, this "sorts" reactions by temp decending)
///Presently unused
/datum/reagents/proc/get_priority_instant_reaction(list/possible_reactions)
	if(!length(possible_reactions))
		return FALSE
	var/datum/chemical_reaction/selected_reaction = possible_reactions[1]
	//select the reaction with the most extreme temperature requirements
	for(var/datum/chemical_reaction/competitor as anything in possible_reactions)
		if(selected_reaction.is_cold_recipe)
			if(competitor.required_temp <= selected_reaction.required_temp)
				selected_reaction = competitor
		else
			if(competitor.required_temp >= selected_reaction.required_temp)
				selected_reaction = competitor
	return selected_reaction

/// Updates [/datum/reagents/var/total_volume]
/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	. = 0 // This is a relatively hot proc.
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if((reagent.volume < 0.05) && !is_reacting)
			del_reagent(reagent.type)
		else if(reagent.volume <= CHEMICAL_VOLUME_MINIMUM)//For clarity
			del_reagent(reagent.type)
		else
			. += reagent.volume
	total_volume = .
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
	for(var/datum/reagent/reagent as anything in cached_reagents)
		reagents[reagent] = reagent.volume * volume_modifier

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
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		if(cached_reagent.type == reagent)
			return round(cached_reagent.volume, CHEMICAL_QUANTISATION_LEVEL)
	return 0

/// Get the purity of this reagent
/datum/reagents/proc/get_reagent_purity(reagent)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		if(cached_reagent.type == reagent)
			return round(cached_reagent.purity, 0.01)
	return 0

/// Get a comma separated string of every reagent name in this holder. UNUSED
/datum/reagents/proc/get_reagent_names()
	var/list/names = list()
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		names += reagent.name

	return jointext(names, ",")

/// helper function to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(reagent.type == reagent_id)
			return reagent.data

/// helper function to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/set_data(reagent_id, new_data)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(reagent.type == reagent_id)
			reagent.data = new_data

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
		for(var/datum/reagent/reagent as anything in reagent_list)
			if(!reagent.taste_mult)
				continue

			var/list/taste_data = reagent.get_taste_description(taster)
			for(var/taste in taste_data)
				if(taste in tastes)
					tastes[taste] += taste_data[taste] * reagent.volume * reagent.taste_mult
				else
					tastes[taste] = taste_data[taste] * reagent.volume * reagent.taste_mult
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
	for(var/datum/reagent/reagent in cached_reagents)
		. += reagent.specific_heat * reagent.volume

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
	chem_temp = clamp(_temperature, 0, CHEMICAL_MAXIMUM_TEMPERATURE)
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
	for(var/datum/reagent/reagent as anything in reagent_list)
		reagent.ph = clamp(reagent.ph + value, lower_limit, upper_limit)

/*
* Adjusts the base pH of all of the listed types
*
* - moves it towards acidic
* + moves it towards basic
* Arguments:
* * input_reagents_list - list of reagent objects to adjust
* * value - How much to adjust the base pH by
*/
/datum/reagents/proc/adjust_specific_reagent_list_ph(list/input_reagents_list, value, lower_limit = 0, upper_limit = 14)
	for(var/datum/reagent/reagent as anything in input_reagents_list)
		if(!reagent) //We can call this with missing reagents.
			continue
		reagent.ph = clamp(reagent.ph + value, lower_limit, upper_limit)

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
	var/datum/reagent/reagent = get_reagent(input_reagent)
	if(!reagent) //We can call this with missing reagents.
		return FALSE
	reagent.ph = clamp(reagent.ph + value, lower_limit, upper_limit)

/*
* Updates the reagents datum pH based off the volume weighted sum of the reagent_list's reagent pH
*/
/datum/reagents/proc/recalculate_sum_ph()
	if(!reagent_list || !total_volume) //Ensure that this is true
		ph = CHEMICAL_NORMAL_PH
		return
	var/total_ph = 0
	for(var/datum/reagent/reagent as anything in reagent_list)
		total_ph += (reagent.ph * reagent.volume)
	//Keep limited
	ph = clamp(total_ph/total_volume, 0, 14)

/**
 * Used in attack logs for reagents in pills and such
 *
 * Arguments:
 * * external_list - assoc list of reagent type = list(REAGENT_TRANSFER_AMOUNT = amounts, REAGENT_PURITY = purity)
 */
/datum/reagents/proc/log_list(external_list)
	if((external_list && !length(external_list)) || !length(reagent_list))
		return "no reagents"



	var/list/data = list()
	if(external_list)
		for(var/r in external_list)
			var/list/qualities = external_list[r]
			data += "[r] ([round(qualities[REAGENT_TRANSFER_AMOUNT], 0.1)]u, [qualities[REAGENT_PURITY]] purity)"
	else
		for(var/datum/reagent/reagent as anything in reagent_list) //no reagents will be left behind
			data += "[reagent.type] ([round(reagent.volume, 0.1)]u, [reagent.purity] purity)"
			//Using types because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)


/////////////////////////////////////////////////////////////////////////////////
///////////////////////////UI / REAGENTS LOOKUP CODE/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////


/datum/reagents/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Reagents", "Reaction search")
		ui.status = UI_INTERACTIVE //How do I prevent a UI from autoclosing if not in LoS
		ui_tags_selected = NONE //Resync with gui on open (gui expects no flags)
		ui_reagent_id = null
		ui_reaction_id = null
		ui.open()


/datum/reagents/ui_status(mob/user)
	return UI_INTERACTIVE //please advise

/datum/reagents/ui_state(mob/user)
	return GLOB.physical_state

/datum/reagents/proc/generate_possible_reactions()
	var/list/cached_reagents = reagent_list
	if(!cached_reagents)
		return null
	var/list/cached_reactions = list()
	var/list/possible_reactions = list()
	if(!length(cached_reagents))
		return null
	cached_reactions = GLOB.chemical_reactions_list_reactant_index
	for(var/_reagent in cached_reagents)
		var/datum/reagent/reagent = _reagent
		for(var/_reaction in cached_reactions[reagent.type]) // Was a big list but now it should be smaller since we filtered it with our reagent id
			var/datum/chemical_reaction/reaction = _reaction
			if(!_reaction)
				continue
			if(!reaction.required_reagents)//Don't bring in empty ones
				continue
			var/list/cached_required_reagents = reaction.required_reagents
			var/total_matching_reagents = 0
			for(var/req_reagent in cached_required_reagents)
				if(!has_reagent(req_reagent, (cached_required_reagents[req_reagent]*0.01)))
					continue
				total_matching_reagents++
			if(total_matching_reagents >= reagent_list.len)
				possible_reactions += reaction
	return possible_reactions

///Generates a (rough) rate vs temperature graph profile
/datum/reagents/proc/generate_thermodynamic_profile(datum/chemical_reaction/reaction)
	var/list/coords = list()
	var/x_temp
	var/increment
	if(reaction.is_cold_recipe)
		coords += list(list(0, 0))
		coords += list(list(reaction.required_temp, 0))
		x_temp = reaction.required_temp
		increment = (reaction.optimal_temp - reaction.required_temp)/10
		while(x_temp < reaction.optimal_temp)
			var/y = (((x_temp - reaction.required_temp)**reaction.temp_exponent_factor)/((reaction.optimal_temp - reaction.required_temp)**reaction.temp_exponent_factor))
			coords += list(list(x_temp, y))
			x_temp += increment
	else
		coords += list(list(reaction.required_temp, 0))
		x_temp = reaction.required_temp
		increment = (reaction.required_temp - reaction.optimal_temp)/10
		while(x_temp > reaction.optimal_temp)
			var/y = (((x_temp - reaction.required_temp)**reaction.temp_exponent_factor)/((reaction.optimal_temp - reaction.required_temp)**reaction.temp_exponent_factor))
			coords += list(list(x_temp, y))
			x_temp -= increment

	coords += list(list(reaction.optimal_temp, 1))
	if(reaction.overheat_temp == NO_OVERHEAT)
		if(reaction.is_cold_recipe)
			coords += list(list(reaction.optimal_temp+10, 1))
		else
			coords += list(list(reaction.optimal_temp-10, 1))
		return coords
	coords += list(list(reaction.overheat_temp, 1))
	coords += list(list(reaction.overheat_temp, 0))
	return coords

/datum/reagents/proc/generate_explosive_profile(datum/chemical_reaction/reaction)
	if(reaction.overheat_temp == NO_OVERHEAT)
		return null
	var/list/coords = list()
	coords += list(list(reaction.overheat_temp, 0))
	coords += list(list(reaction.overheat_temp, 1))
	if(reaction.is_cold_recipe)
		coords += list(list(reaction.overheat_temp-50, 1))
		coords += list(list(reaction.overheat_temp-50, 0))
	else
		coords += list(list(reaction.overheat_temp+50, 1))
		coords += list(list(reaction.overheat_temp+50, 0))
	return coords


///Returns a string descriptor of a reactions themic_constant
/datum/reagents/proc/determine_reaction_thermics(datum/chemical_reaction/reaction)
	var/thermic = reaction.thermic_constant
	if(reaction.reaction_flags & REACTION_HEAT_ARBITARY)
		thermic *= 100 //Because arbitary is a lower scale
	switch(thermic)
		if(-INFINITY to -1500)
			return "Overwhelmingly endothermic"
		if(-1500 to -1000)
			return "Extremely endothermic"
		if(-1000 to -500)
			return "Strongly endothermic"
		if(-500 to -200)
			return "Moderately endothermic"
		if(-200 to -50)
			return "Endothermic"
		if(-50 to 0)
			return "Weakly endothermic"
		if(0)
			return ""
		if(0 to 50)
			return "Weakly Exothermic"
		if(50 to 200)
			return "Exothermic"
		if(200 to 500)
			return "Moderately exothermic"
		if(500 to 1000)
			return "Strongly exothermic"
		if(1000 to 1500)
			return "Extremely exothermic"
		if(1500 to INFINITY)
			return "Overwhelmingly exothermic"

/datum/reagents/proc/parse_addictions(datum/reagent/reagent)
	var/addict_text = list()
	for(var/entry in reagent.addiction_types)
		var/datum/addiction/ref = SSaddiction.all_addictions[entry]
		switch(reagent.addiction_types[entry])
			if(-INFINITY to 0)
				continue
			if(0 to 5)
				addict_text += "Weak [ref.name]"
			if(5 to 10)
				addict_text += "[ref.name]"
			if(10 to 20)
				addict_text += "Strong [ref.name]"
			if(20 to INFINITY)
				addict_text += "Potent [ref.name]"
	return addict_text

/datum/reagents/ui_data(mob/user)
	var/data = list()
	data["selectedBitflags"] = ui_tags_selected
	data["currentReagents"] = previous_reagent_list //This keeps the string of reagents that's updated when handle_reactions() is called
	data["beakerSync"] = ui_beaker_sync
	data["linkedBeaker"] = my_atom.name //To solidify the fact that the UI is linked to a beaker - not a machine.

	//First we check to see if reactions are synced with the beaker
	if(ui_beaker_sync)
		if(reaction_list)//But we don't want to null the previously displayed if there are none
			//makes sure we're within bounds
			if(ui_reaction_index > reaction_list.len)
				ui_reaction_index = reaction_list.len
			ui_reaction_id = reaction_list[ui_reaction_index].reaction.type

	//reagent lookup data
	if(ui_reagent_id)
		var/datum/reagent/reagent = find_reagent_object_from_type(ui_reagent_id)
		if(!reagent)
			to_chat(user, "Could not find reagent!")
			ui_reagent_id = null
		else
			data["reagent_mode_reagent"] = list("name" = reagent.name, "id" = reagent.type, "desc" = reagent.description, "reagentCol" = reagent.color, "pH" = reagent.ph, "pHCol" = convert_ph_to_readable_color(reagent.ph), "metaRate" = (reagent.metabolization_rate/2), "OD" = reagent.overdose_threshold)
			data["reagent_mode_reagent"]["addictions"] = list()
			data["reagent_mode_reagent"]["addictions"] = parse_addictions(reagent)


			var/datum/reagent/impure_reagent = GLOB.chemical_reagents_list[reagent.impure_chem]
			if(impure_reagent)
				data["reagent_mode_reagent"] += list("impureReagent" = impure_reagent.name, "impureId" = impure_reagent.type)

			var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
			if(inverse_reagent)
				data["reagent_mode_reagent"] += list("inverseReagent" = inverse_reagent.name, "inverseId" = inverse_reagent.type)

			var/datum/reagent/failed_reagent = GLOB.chemical_reagents_list[reagent.failed_chem]
			if(failed_reagent)
				data["reagent_mode_reagent"] += list("failedReagent" = failed_reagent.name, "failedId" = failed_reagent.type)

			if(istype(reagent, /datum/reagent/impurity))
				data["reagent_mode_reagent"] += list("isImpure" = TRUE)

			if(reagent.chemical_flags & REAGENT_DEAD_PROCESS)
				data["reagent_mode_reagent"] += list("deadProcess" = TRUE)
	else
		data["reagent_mode_reagent"] = null

	//reaction lookup data
	if (ui_reaction_id)

		var/datum/chemical_reaction/reaction = get_chemical_reaction(ui_reaction_id)
		if(!reaction)
			to_chat(user, "Could not find reaction!")
			ui_reaction_id = null
			return data
		//Required holder
		var/container_name
		if(reaction.required_container)
			var/list/names = splittext("[reaction.required_container]", "/")
			container_name = "[names[names.len-1]] [names[names.len]]"
			container_name = replacetext(container_name, "_", " ")

		//Next, find the product
		var/has_product = TRUE
		//If we have no product, use the typepath to create a name for it
		if(!length(reaction.results))
			has_product = FALSE
			var/list/names = splittext("[reaction.type]", "/")
			var/product_name = names[names.len]
			data["reagent_mode_recipe"] = list("name" = product_name, "id" = reaction.type, "hasProduct" = has_product, "reagentCol" = "#FFFFFF", "thermodynamics" = generate_thermodynamic_profile(reaction), "explosive" = generate_explosive_profile(reaction), "lowerpH" = reaction.optimal_ph_min, "upperpH" = reaction.optimal_ph_max, "thermics" = determine_reaction_thermics(reaction), "thermoUpper" = reaction.rate_up_lim, "minPurity" = reaction.purity_min, "inversePurity" = "N/A", "tempMin" = reaction.required_temp, "explodeTemp" = reaction.overheat_temp, "reqContainer" = container_name, "subReactLen" = 1, "subReactIndex" = 1)

		//If we do have a product then we find it
		else
			//Find out if we have multiple reactions for the same product
			var/datum/reagent/primary_reagent = find_reagent_object_from_type(reaction.results[1])//We use the first product - though it might be worth changing this
			//If we're syncing from the beaker
			var/list/sub_reactions = list()
			if(ui_beaker_sync && reaction_list)
				for(var/_ongoing_eq in reaction_list)
					var/datum/equilibrium/ongoing_eq = _ongoing_eq
					var/ongoing_r = ongoing_eq.reaction
					sub_reactions += ongoing_r
			else
				sub_reactions = get_recipe_from_reagent_product(primary_reagent.type)
			var/sub_reaction_length = length(sub_reactions)
			var/i = 1
			for(var/datum/chemical_reaction/sub_reaction in sub_reactions)
				if(sub_reaction.type == reaction.type)
					ui_reaction_index = i //update our index
					break
				i += 1
			data["reagent_mode_recipe"] = list("name" = primary_reagent.name, "id" = reaction.type, "hasProduct" = has_product, "reagentCol" = primary_reagent.color, "thermodynamics" = generate_thermodynamic_profile(reaction), "explosive" = generate_explosive_profile(reaction), "lowerpH" = reaction.optimal_ph_min, "upperpH" = reaction.optimal_ph_max, "thermics" = determine_reaction_thermics(reaction), "thermoUpper" = reaction.rate_up_lim, "minPurity" = reaction.purity_min, "inversePurity" = primary_reagent.inverse_chem_val, "tempMin" = reaction.required_temp, "explodeTemp" = reaction.overheat_temp, "reqContainer" = container_name, "subReactLen" = sub_reaction_length, "subReactIndex" = ui_reaction_index)

		//Results sweep
		var/has_reagent = "default"
		for(var/_reagent in reaction.results)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			if(has_reagent(_reagent))
				has_reagent = "green"
			data["reagent_mode_recipe"]["products"] += list(list("name" = reagent.name, "id" = reagent.type, "ratio" = reaction.results[reagent.type], "hasReagentCol" = has_reagent))

		//Reactant sweep
		for(var/_reagent in reaction.required_reagents)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			var/color_r = "default" //If the holder is missing the reagent, it's displayed in orange
			if(has_reagent(reagent.type))
				color_r = "green" //It's green if it's present
			var/tooltip
			var/tooltip_bool = FALSE
			var/list/sub_reactions = get_recipe_from_reagent_product(reagent.type)
			//Get sub reaction possibilities, but ignore ones that need a specific holder atom
			var/sub_index = 0
			for(var/datum/chemical_reaction/sub_reaction as anything in sub_reactions)
				if(sub_reaction.required_container)//So we don't have slime reactions confusing things
					sub_index++
					continue
				sub_index++
				break
			if(sub_index)
				var/datum/chemical_reaction/sub_reaction = sub_reactions[sub_index]
				//Subreactions sweep (if any)
				for(var/_sub_reagent in sub_reaction.required_reagents)
					var/datum/reagent/sub_reagent = find_reagent_object_from_type(_sub_reagent)
					tooltip += "[sub_reaction.required_reagents[_sub_reagent]]u [sub_reagent.name]\n" //I forgot the better way of doing this - fix this after this works
					tooltip_bool = TRUE
			data["reagent_mode_recipe"]["reactants"] += list(list("name" = reagent.name, "id" = reagent.type, "ratio" = reaction.required_reagents[reagent.type], "color" = color_r, "tooltipBool" = tooltip_bool, "tooltip" = tooltip))

		//Catalyst sweep
		for(var/_reagent in reaction.required_catalysts)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			var/color_r = "default"
			if(has_reagent(reagent.type))
				color_r = "green"
			var/tooltip
			var/tooltip_bool = FALSE
			var/list/sub_reactions = get_recipe_from_reagent_product(reagent.type)
			if(length(sub_reactions))
				var/datum/chemical_reaction/sub_reaction = sub_reactions[1]
				//Subreactions sweep (if any)
				for(var/_sub_reagent in sub_reaction.required_reagents)
					var/datum/reagent/sub_reagent = find_reagent_object_from_type(_sub_reagent)
					tooltip += "[sub_reaction.required_reagents[_sub_reagent]]u [sub_reagent.name]\n" //I forgot the better way of doing this - fix this after this works
					tooltip_bool = TRUE
			data["reagent_mode_recipe"]["catalysts"] += list(list("name" = reagent.name, "id" = reagent.type, "ratio" = reaction.required_catalysts[reagent.type], "color" = color_r, "tooltipBool" = tooltip_bool, "tooltip" = tooltip))
		data["reagent_mode_recipe"]["isColdRecipe"] = reaction.is_cold_recipe
	else
		data["reagent_mode_recipe"] = null

	return data

/datum/reagents/ui_static_data(mob/user)
	var/data = list()
	//Use GLOB list - saves processing
	data["master_reaction_list"] = GLOB.chemical_reactions_results_lookup_list
	data["bitflags"] = list()
	data["bitflags"]["BRUTE"] = REACTION_TAG_BRUTE
	data["bitflags"]["BURN"] = REACTION_TAG_BURN
	data["bitflags"]["TOXIN"] = REACTION_TAG_TOXIN
	data["bitflags"]["OXY"] = REACTION_TAG_OXY
	data["bitflags"]["CLONE"] = REACTION_TAG_CLONE
	data["bitflags"]["HEALING"] = REACTION_TAG_HEALING
	data["bitflags"]["DAMAGING"] = REACTION_TAG_DAMAGING
	data["bitflags"]["EXPLOSIVE"] = REACTION_TAG_EXPLOSIVE
	data["bitflags"]["OTHER"] = REACTION_TAG_OTHER
	data["bitflags"]["DANGEROUS"] = REACTION_TAG_DANGEROUS
	data["bitflags"]["EASY"] = REACTION_TAG_EASY
	data["bitflags"]["MODERATE"] = REACTION_TAG_MODERATE
	data["bitflags"]["HARD"] = REACTION_TAG_HARD
	data["bitflags"]["ORGAN"] = REACTION_TAG_ORGAN
	data["bitflags"]["DRINK"] = REACTION_TAG_DRINK
	data["bitflags"]["FOOD"] = REACTION_TAG_FOOD
	data["bitflags"]["SLIME"] = REACTION_TAG_SLIME
	data["bitflags"]["DRUG"] = REACTION_TAG_DRUG
	data["bitflags"]["UNIQUE"] = REACTION_TAG_UNIQUE
	data["bitflags"]["CHEMICAL"] = REACTION_TAG_CHEMICAL
	data["bitflags"]["PLANT"] = REACTION_TAG_PLANT
	data["bitflags"]["COMPETITIVE"] = REACTION_TAG_COMPETITIVE

	return data

/* Returns a reaction type by index from an input reagent type
* i.e. the input reagent's associated reactions are found, and the index determines which one to return
* If the index is out of range, it is set to 1
*/
/datum/reagents/proc/get_reaction_from_indexed_possibilities(path, index = null)
	if(index)
		ui_reaction_index = index
	var/list/sub_reactions = get_recipe_from_reagent_product(path)
	if(!length(sub_reactions))
		to_chat(usr, "There is no recipe associated with this product.")
		return FALSE
	if(ui_reaction_index > length(sub_reactions))
		ui_reaction_index = 1
	var/datum/chemical_reaction/reaction = sub_reactions[ui_reaction_index]
	return reaction.type

/datum/reagents/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("find_reagent_reaction")
			ui_reaction_id = get_reaction_from_indexed_possibilities(text2path(params["id"]))
			return TRUE
		if("reagent_click")
			ui_reagent_id = text2path(params["id"])
			return TRUE
		if("recipe_click")
			ui_reaction_id = text2path(params["id"])
			return TRUE
		if("search_reagents")
			var/input_reagent = (input("Enter the name of any reagent", "Input") as text|null)
			input_reagent = get_reagent_type_from_product_string(input_reagent) //from string to type
			var/datum/reagent/reagent = find_reagent_object_from_type(input_reagent)
			if(!reagent)
				to_chat(usr, "Could not find reagent!")
				return FALSE
			ui_reagent_id = reagent.type
			return TRUE
		if("search_recipe")
			var/input_reagent = (input("Enter the name of product reagent", "Input") as text|null)
			input_reagent = get_reagent_type_from_product_string(input_reagent) //from string to type
			var/datum/reagent/reagent = find_reagent_object_from_type(input_reagent)
			if(!reagent)
				to_chat(usr, "Could not find product reagent!")
				return
			ui_reaction_id = get_reaction_from_indexed_possibilities(reagent.type)
			return TRUE
		if("increment_index")
			ui_reaction_index += 1
			if(!ui_beaker_sync || !reaction_list)
				ui_reaction_id = get_reaction_from_indexed_possibilities(get_reagent_type_from_product_string(params["id"]))
			return TRUE
		if("reduce_index")
			if(ui_reaction_index == 1)
				return
			ui_reaction_index -= 1
			if(!ui_beaker_sync || !reaction_list)
				ui_reaction_id = get_reaction_from_indexed_possibilities(get_reagent_type_from_product_string(params["id"]))
			return TRUE
		if("beaker_sync")
			ui_beaker_sync = !ui_beaker_sync
			return TRUE
		if("toggle_tag_brute")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_BRUTE
			return TRUE
		if("toggle_tag_burn")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_BURN
			return TRUE
		if("toggle_tag_toxin")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_TOXIN
			return TRUE
		if("toggle_tag_oxy")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_OXY
			return TRUE
		if("toggle_tag_clone")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_CLONE
			return TRUE
		if("toggle_tag_healing")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_HEALING
			return TRUE
		if("toggle_tag_damaging")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DAMAGING
			return TRUE
		if("toggle_tag_explosive")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_EXPLOSIVE
			return TRUE
		if("toggle_tag_other")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_OTHER
			return TRUE
		if("toggle_tag_easy")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_EASY
			return TRUE
		if("toggle_tag_moderate")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_MODERATE
			return TRUE
		if("toggle_tag_hard")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_HARD
			return TRUE
		if("toggle_tag_organ")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_ORGAN
			return TRUE
		if("toggle_tag_drink")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DRINK
			return TRUE
		if("toggle_tag_food")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_FOOD
			return TRUE
		if("toggle_tag_dangerous")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DANGEROUS
			return TRUE
		if("toggle_tag_slime")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_SLIME
			return TRUE
		if("toggle_tag_drug")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DRUG
			return TRUE
		if("toggle_tag_unique")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_UNIQUE
			return TRUE
		if("toggle_tag_chemical")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_CHEMICAL
			return TRUE
		if("toggle_tag_plant")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_PLANT
			return TRUE
		if("toggle_tag_competitive")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_COMPETITIVE
			return TRUE
		if("update_ui")
			return TRUE


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

/atom/movable/chem_holder
	name = "This atom exists to hold chems. If you can see this, make an issue report"
	desc = "God this is stupid"

#undef REAGENT_TRANSFER_AMOUNT
#undef REAGENT_PURITY

#undef REAGENTS_UI_MODE_LOOKUP
#undef REAGENTS_UI_MODE_REAGENT
#undef REAGENTS_UI_MODE_RECIPE
