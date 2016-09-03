//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

#define MIN_REAGENT_VOL 0.005 // The minimum volume of a reagent. Used to prevent volumes becoming equal to 1.73e-06 units.

var/const/TOUCH = 1 //splashing
var/const/INGEST = 2 //ingestion
var/const/VAPOR = 3 //foam, spray, blob attack
var/const/PATCH = 4 //patches
var/const/INJECT = 5 //injection

///////////////////////////////////////////////////////////////////////////////////

/datum/chem_holder
	var/list/datum/reagent/reagents = new/list()
	var/list/datum/chemical_reaction/reaction_list = new/list() // Used to prevent the same reaction from occuring more than once.
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/chem_temp = 150
	var/last_tick = 1
	var/addiction_tick = 1
	var/list/datum/reagent/addiction_list = new/list()
	var/reacting = 0 // Used to prevent handle_reactions from being called more than once per tick.
	var/flags

/datum/chem_holder/New(maximum=100, list/starting_reagents = new/list())
	maximum_volume = maximum

	if(!(flags & REAGENT_NOREACT))
		START_PROCESSING(SSfastprocess, src)

	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!chemical_reagents_list)
		//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
		var/paths = subtypesof(/datum/reagent)
		chemical_reagents_list = list()
		for(var/path in paths)
			var/datum/reagent/D = new path()
			chemical_reagents_list[D.id] = D
	if(!chemical_reactions_list)
		//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
		// It is filtered into multiple lists within a list.
		// For example:
		// chemical_reaction_list["plasma"] is a list of all reactions relating to plasma

		var/paths = subtypesof(/datum/chemical_reaction)
		chemical_reactions_list = list()

		for(var/path in paths)

			var/datum/chemical_reaction/D = new path()
			var/list/reaction_ids = list()

			if(D.required_reagents && D.required_reagents.len)
				for(var/reaction in D.required_reagents)
					reaction_ids += reaction

			// Create filters based on each reagent id in the required reagents list
			for(var/id in reaction_ids)
				if(!chemical_reactions_list[id])
					chemical_reactions_list[id] = list()
				chemical_reactions_list[id] += D
				break // Don't bother adding ourselves to other reagent ids, it is redundant.

	if(starting_reagents)
		for(var/reagent in starting_reagents)
			adjust_volume(reagent, starting_reagents[reagent])

/datum/chem_holder/Destroy()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	for(var/reagent in reagents)
		var/datum/reagent/R = reagents[reagent]
		qdel(R)
	for(var/reaction in reaction_list)
		var/datum/active_reaction/R = reaction_list[reaction]
		qdel(R)
	reagents.Cut()
	reagents = null
	reaction_list.Cut()
	reaction_list = null
	if(my_atom && my_atom.chem_holder == src)
		my_atom.chem_holder = null

// Used for adding/removing reagents from nullspace. Ie. you're creating a new reagent, or deleting the reagent.
// Much simpler and cleaner than old ADD/REMOVE_REAGENT procs
/datum/chem_holder/proc/adjust_volume(reagent_id, amount = 0, temperature = 293)
	if(!reagent_id || amount == 0)
		return
	amount = Ceiling(amount, MIN_REAGENT_VOL)

	if(!reagents[reagent]) // If the reagent does not exist, create it.
		reagents[reagent] = new chemical_reagents_list[reagent]
		var/datum/reagent/RN = reagents[reagent]
		RN.holder = src

	if(amount)
		chem_temp = ((amount * temperature) + (total_volume * chem_temp)) / (total_volume + amount)

	var/datum/reagent/R = reagents[reagent]
	R.volume += amount

	update_total()
	my_atom.on_reagent_change()
	set_reacting()
	return R

// Used for removing reagents from the chem_holder by volume. It will remove an equal percentage of each reagent.
/datum/chem_holder/proc/remove_amount(amount = 1)
	if(!amount || !total_volume)
		return
	amount = Ceiling(amount, MIN_REAGENT_VOL)
	if(amount > total_volume)
		amount = total_volume
	var/part = amount / total_volume

	var/list/removed_reagents = new/list()
	for(var/reagent in reagents)
		var/datum/reagent/R = reagents[reagent]
		removed_reagents[reagent] = Ceiling(R.volume * part, MIN_REAGENT_VOL)
		adjust_volume(reagent, -Ceiling(R.volume * part, MIN_REAGENT_VOL))

	update_total()
	set_reacting()
	return removed_reagents // a list of removed reagents, and their respective totals.

// Gets the master reagent. (reagent with the most volume.)
/datum/chem_holder/proc/get_master_reagent()
	var/datum/reagent/master
	var/max_volume = 0
	for(var/reagent in reagents)
		var/datum/reagent/R = reagents[reagent]
		if(R.volume > max_volume)
			max_volume = R.volume
			master = R
	return master

/datum/chem_holder/proc/get_master_reagent_name()
	var/datum/reagent/master = get_master_reagent()
	if(master)
		return master.name

/datum/chem_holder/proc/get_master_reagent_id()
	var/datum/reagent/master = get_master_reagent()
	if(master)
		return master.id

// Transfers 'amount' reagents from this container to another container.
/datum/chem_holder/proc/transfer(datum/chem_holder/target, amount = 1, preserve_data=1)
	if(!istype(target) || !amount || total_volume <= 0)
		return

	amount = Ceiling(amount, MIN_REAGENT_VOL)
	if(amount > total_volume)
		amount = total_volume
	var/part = amount / total_volume

	for(var/reagent in reagents)
		var/datum/reagent/R = reagents[reagent]
		var/datum/reagent/TR = target.adjust_volume(reagent, R.volume*part)

		if(preserve_data)
			trans_data(R, TR, R.volume*part)

		adjust_volume(reagent, -R.volume*part)

	set_reacting()
	target.set_reacting()
	return amount

// Transfers 'amount' reagents from this container to another container, without deleting the original reagents.
/datum/chem_holder/proc/copy_to(datum/chem_holder/target, amount = 1, preserve_data=1)
	if(!istype(target) || !amount || total_volume <= 0)
		return

	amount = Ceiling(amount, MIN_REAGENT_VOL)
	if(amount > total_volume)
		amount = total_volume
	var/part = amount / total_volume

	for(var/reagent in reagents)
		var/datum/reagent/R = reagents[reagent]
		var/datum/reagent/TR = target.adjust_volume(reagent, R.volume*part)

		if(preserve_data)
			trans_data(R, TR, R.volume*part)

	set_reacting()
	target.set_reacting()
	return amount

// Transfers 'amount' of a single reagent from this container to another container.
/datum/chem_holder/proc/transfer_id(datum/chem_holder/target, reagent_id, amount = 1, preserve_data=1)
	if(!istype(target) || !amount || total_volume <= 0 || !reagent_id)
		return

	amount = Ceiling(amount, MIN_REAGENT_VOL)

	var/datum/reagent/R = reagents[reagent_id]
	if(!R)
		return 0
	if(amount > R.volume)
		amount = R.volume

	var/datum/reagent/TR = target.adjust_volume(reagent_id, amount)
	if(preserve_data)
		trans_data(R, TR, amount)
	adjust_volume(reagent_id, -amount)

	set_reacting()
	target.set_reacting()
	return amount

// Transfers 'amount' of a single reagent from this container to another container. Without deleting the original reagent.
/datum/chem_holder/proc/copy_id_to(datum/chem_holder/target, reagent_id, amount = 1, preserve_data=1)
	if(!istype(target) || !amount || total_volume <= 0 || !reagent_id)
		return

	amount = Ceiling(amount, MIN_REAGENT_VOL)

	var/datum/reagent/R = reagents[reagent_id]
	if(!R)
		return 0
	if(amount > R.volume)
		amount = R.volume

	var/datum/reagent/TR = target.adjust_volume(reagent_id, amount)
	if(preserve_data)
		trans_data(R, TR, amount)

	set_reacting()
	target.set_reacting()
	return amount

// This really shouldn't exist here, so im going to move it, eventually.
/datum/chem_holder/proc/metabolize(mob/living/carbon/C, can_overdose = 0)
	if(!istype(C))
		return
	chem_temp = C.bodytemperature
	set_reacting()

	var/need_mob_update = 0
	for(var/reagent in reagents)
		var/datum/reagent/R = reagents[reagent]
		if(C.reagent_check(R) != 1)
			if(can_overdose)
				if(R.overdose_threshold)
					if(R.volume >= R.overdose_threshold && !R.overdosed)
						R.overdosed = 1
						need_mob_update += R.overdose_start(C)
				if(R.addiction_threshold)
					if(R.volume >= R.addiction_threshold && !is_type_in_list(R, addiction_list))
						var/datum/reagent/new_reagent = new R.type()
						addiction_list.Add(new_reagent)
				if(R.overdosed)
					need_mob_update += R.overdose_process(C)
				if(is_type_in_list(R,addiction_list))
					for(var/addiction in addiction_list)
						var/datum/reagent/A = addiction
						if(istype(R, A))
							A.addiction_stage = -15 // you're satisfied for a good while.
			need_mob_update += R.on_mob_life(C)

	if(can_overdose)
		if(addiction_tick == 6)
			addiction_tick = 1
			for(var/addiction in addiction_list)
				var/datum/reagent/R = addiction
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
						C << "<span class='notice'>You feel like you've gotten over your need for [R.name].</span>"
						addiction_list.Remove(R)
		addiction_tick++
	if(need_mob_update) //some of the metabolized reagents had effects on the mob that requires some updates.
		C.updatehealth()
		C.update_canmove()
		C.update_stamina()
	update_total()

/datum/chem_holder/proc/conditional_update_move(atom/A, Running = 0)
	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		R.on_move (A, Running)
	update_total()

/datum/chem_holder/proc/conditional_update(atom/A, trigger = null)
	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		R.on_update (A, trigger)
	update_total()

// Attempt to react, and remove yourself from the processing queue if no reactions took place.
/datum/chem_holder/process()
	reacting = 2
	handle_reactions()
	if(reacting == 2)
		STOP_PROCESSING(SSfastprocess, src)
		reacting = 0
	if(flags & REAGENT_IGNITER)
		flags &= ~(REAGENT_IGNITER)

// Flag this chem_holder as 'ready' to react. It will react once this tick, and again every two ticks if it still needs to react.
/datum/chem_holder/proc/set_reacting()
	if(reacting == 2) // Caused by secondary reaction step. Prevents reacting more than once per tick.
		reacting = 1
	if(!reacting)
		reacting = 1
		START_PROCESSING(SSfastprocess, src)
		handle_reactions()

// Set this chem_holder to NOREACT mode, preventing it from reacting. Set to false to do inverse.
/datum/chem_holder/proc/set_noreact(on = TRUE)
	if(on)
		flags |= REAGENT_NOREACT
	else
		flags &= ~(REAGENT_NOREACT)
		set_reacting()

// Set this chem_holder to IGNITER mode, causing it to trigger some special reactions for a short time.
/datum/chem_holder/proc/set_igniting(on = TRUE)
	if(on)
		flags |= REAGENT_IGNITER
		set_reacting()
	else
		flags &= ~(REAGENT_IGNITER)

// Check if any reactions are able to take place. And if so, react them.
/datum/chem_holder/proc/handle_reactions()
	reacting = 0
	if(flags & REAGENT_NOREACT)
		return //Yup, no reactions here. No siree.
	var/reaction_occured = 0
	do
		reaction_occured = 0
		for(var/reagent in reagents)
			var/datum/reagent/R = reagents[reagent]
			for(var/reaction in chemical_reactions_list[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id
				if(!reaction || reactions[reaction.id]) // skip recipe checking if its already reacting.
					continue

				var/datum/chemical_reaction/C = reaction
				var/total_required_reagents = C.required_reagents.len
				var/total_matching_reagents = 0
				var/matching_other = 0
				var/required_temp = C.required_temp
				var/is_cold_recipe = C.is_cold_recipe
				var/meets_temp_requirement = 0

				for(var/B in C.required_reagents)
					if(!get_reagent_amount(B) >= C.required_reagents[B])
						break
					total_matching_reagents++

				if (isliving(my_atom)) //Makes it so certain chemical reactions don't occur in mobs
					if (C.no_mob_react)
						return

				if(!C.required_other)
					matching_other = 1
				else if(C.special_reqs(src)) // Now more reusable than ever!
					matching_other = 1

				if(required_temp <= 0 || (is_cold_recipe && chem_temp <= required_temp) || (!is_cold_recipe && chem_temp >= required_temp))
					meets_temp_requirement = 1

				if(total_matching_reagents == total_required_reagents && matching_other && meets_temp_requirement)
					if (C.react(src))
						reaction_occured = 1
						break

	while(reaction_occured && world.tick_usage < CURRENT_TICKLIMIT)

	if(world.tick_usage > CURRENT_TICKLIMIT && !reacting) // Reaction was cut due to tick limitations. Try and process again later.
		reacting = 1
		START_PROCESSING(SSfastprocess, src)
		warning("Potential Recursive Reaction: [pretty_string_from_reagents(reagents)]")

	update_total()

/*
/datum/chem_holder/proc/check_ignoreslow(mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("morphine")||M.reagents.has_reagent("ephedrine"))
			return 1
		else
			M.status_flags &= ~IGNORESLOWDOWN

/datum/chem_holder/proc/check_gofast(mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("unholywater")||M.reagents.has_reagent("nuka_cola")||M.reagents.has_reagent("stimulants"))
			return 1
		else
			M.status_flags &= ~GOTTAGOFAST

/datum/chem_holder/proc/check_goreallyfast(mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("methamphetamine"))
			return 1
		else
			M.status_flags &= ~GOTTAGOREALLYFAST
*/

/datum/chem_holder/proc/update_total()
	total_volume = 0
	for(var/reagent in reagents)
		var/datum/reagent/R = reagents[reagent]
		if(R.volume < MIN_REAGENT_VOL)
			reagents -= reagent
			qdel(R)
		else
			R.volume = Round(R.volume, MIN_REAGENT_VOL)
			total_volume += R.volume

	if(total_volume > maximum_volume) // Eventually proper spillover effects should be added.
		remove_amount(total_volume-maximum_volume)

	return 0

/datum/chem_holder/proc/clear_reagents()
	for(var/reagent in reagents)
		var/datum/reagent/R = reagents[reagent]
		reagents -= reagent
		qdel(R)
	return 0

// WHY IS THIS HERE?
/*
/datum/chem_holder/proc/reaction(atom/A, method = TOUCH, volume_modifier = 1, show_message = 1)
	if(isliving(A))
		var/touch_protection = 0
		if(method == VAPOR)
			var/mob/living/L = A
			touch_protection = L.get_permeability_protection()
		for(var/reagent in reagents)
			var/datum/reagent/R = reagent
			R.reaction_mob(A, method, R.volume * volume_modifier, show_message, touch_protection)
	else if(isturf(A))
		for(var/reagent in reagents)
			var/datum/reagent/R = reagent
			R.reaction_turf(A, R.volume * volume_modifier, show_message)
	else if(isobj(A))
		for(var/reagent in reagents)
			var/datum/reagent/R = reagent
			R.reaction_obj(A, R.volume * volume_modifier, show_message)
*/

// returns the amount of a reagent. Replaces both get_reagent_amount and has_reagent
/datum/chem_holder/proc/get_volume(id)
	var/datum/reagent/R = reagents[id]
	if(R)
		return R.volume
	return -1

// Returns a string of all reagent names. Ie. "Water, Oxygen, Silicon"
/datum/chem_holder/proc/get_reagents()
	var/list/names = list()
	for(var/reagent in reagents)
		var/datum/reagent/R = reagents[reagent]
		names += R.name

	return jointext(names, ",")

/* nullbear is moving this to recipes.
/datum/chem_holder/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount)) return 1

	var/has_removed_reagent = 0

	for(var/reagent in reagents)
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
*/

//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/chem_holder/proc/get_data(reagent_id)
	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		if(R.id == reagent_id)
			//world << "proffering a data-carrying reagent ([reagent_id])"
			return R.data

/datum/chem_holder/proc/set_data(reagent_id, new_data)
	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		if(R.id == reagent_id)
			//world << "reagent data set ([reagent_id])"
			R.data = new_data

/datum/chem_holder/proc/trans_data(datum/reagent/copy_from, datum/reagent/copy_to, delta_vol)
	if(!copy_from || !copy_to || !copy_from.data)
		return null
	if(!istype(copy_from.data, /list))
		return copy_from.data

	var/list/old_data = copy_from.data.Copy()

	copy_to.merge_data(old_data, delta_vol)

	return old_data

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol, list/starting_reagents)
	if(reagents)
		qdel(reagents)
	reagents = new/datum/chem_holder(max_vol, starting_reagents)
	reagents.my_atom = src
