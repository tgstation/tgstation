
// The all-important merger between gas_mixtures and reagent_holders!!!

 /*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/
#define MINIMUM_HEAT_CAPACITY	0.0003
#define QUANTIZE(variable)		(round(variable,0.0000001))/*I feel the need to document what happens here. Basically this is used to catch most rounding errors, however it's previous value made it so that
															once gases got hot enough, most procedures wouldnt occur due to the fact that the mole counts would get rounded away. Thus, we lowered it a few orders of magnititude */
var/list/meta_mat_info = meta_gas_list()
var/list/matlist_cache = null

/proc/matlist(id)
	var/list/cached_mat

	//only instantiate the first time it's needed
	if(!matlist_cache)
		matlist_cache = new(meta_mat_info.len)

	//only setup the individual lists the first time they're needed
	if(!matlist_cache[id])
		if(!meta_mat_info[id])
			CRASH("Mat [id] does not exist!")
		cached_mat = new(4)
		matlist_cache[id] = cached_mat

		cached_mat[MOLES] = 0
		cached_mat[ARCHIVE] = 0
		cached_mat[MAT_META] = meta_mat_info[id]
		cached_mat[MAT_DATA] = new/list()
	else
		cached_mat = matlist_cache[id]
	//Copy() it because only GAS_META is static
	return cached_mat.Copy()

/datum/material
	var/list/mats
	var/temperature
	var/tmp/temperature_archived
	var/volume
	var/last_share
	var/atom/my_atom
	var/updating = 0

/datum/material/New(vol = 0)
	..()
	mats = new
	temperature = 0
	temperature_archived = 0
	volume = vol
	priority = 1 // higher is slower.
	request_update()


//listmos procs

	//assert(id) - used to guarantee that the mat list for this id exists.
	//Must be used before adding to a mat. May be used before reading from a mat.
/datum/material/proc/assert(id)
	var/cached_mats = mats
	if(cached_mats[id])
		return
	cached_mats[id] = matlist(id)

	//assert_many(args) - shorthand for calling assert() once for each type.
/datum/material/proc/assert_many()
	for(var/id in args)
		assert(id)

	//add(gas_id) - similar to assert(), but does not check for an existing
		//mat list for this id. This can clobber existing mats.
	//Used instead of assert() when you know the mat does not exist. Faster than assert().
/datum/material/proc/add(id)
	mats[id] = matlist(id)

	//add_many(args) - shorthand for calling add() once for each gas_type.
/datum/material/proc/add_many()
	for(var/id in args)
		add(id)

	//garbage_collect() - removes any mat list which is empty.
	//If called with a list as an argument, only removes gas lists with IDs from that list.
	//Must be used after subtracting from a mat. Must be used after assert()
		//if assert() was called only to read from the mat.
	//By removing empty mats, processing speed is increased.
/datum/material/proc/garbage_collect(list/tocheck)
	var/list/cached_mats = mats
	for(var/id in (tocheck || cached_mats))
		if(cached_mats[id][MOLES] <= 0 && cached_mats[id][ARCHIVE] <= 0)
			if(cached_mats[id][MAT_DATA])
				qdel(cached_mats[id][MAT_DATA])
			cached_mats -= id

	//PV = nRT
/datum/material/proc/heat_capacity() //joules per kelvin
	var/list/cached_mats = mats
	. = 0
	for(var/id in cached_mats)
		. += cached_mats[id][MOLES] * cached_mats[id][MAT_META][META_MAT_SPECIFIC_HEAT]

/datum/material/proc/heat_capacity_archived() //joules per kelvin
	var/list/cached_mats = mats
	. = 0
	for(var/id in cached_mats)
		. += cached_mats[id][ARCHIVE] * cached_mats[id][MAT_META][META_MAT_SPECIFIC_HEAT]

// Can use state to only get moles of materials with matching states.
/datum/material/proc/total_moles(state = ALL_MATS) //moles
	var/list/cached_mats = mats
	. = 0
	for(var/id in cached_mats)
		if(state & cached_mats[id][MAT_META][META_MAT_STATE])
			. += cached_mats[id][MOLES]

/datum/material/proc/return_pressure() //kilopascals
	var/vol = (volume - return_volume(FINITE_MATS))
	if(vol > 0) // to prevent division by zero
		return total_moles(GASEOUS_MATS) * R_IDEAL_GAS_EQUATION * temperature / vol
	return 0

/datum/material/proc/return_temperature() //kelvins
	return temperature

/datum/material/proc/return_volume(state = ALL_MATS) //units
	if(state & GAS || state & PLASMA)
		return max(0, volume)
	else
		return max(0, total_moles(state) * 10)

/datum/material/proc/thermal_energy() //joules
	return temperature * heat_capacity()

// Returns the color and alpha of chems inside. list("#color", alpha)
/datum/material/proc/return_color(state = ALL_MATS)
	var/list/cached_mats = mats
	var/list/colors = new/list()
	var/alpha = 0
	var/part = 0
	for(var/id in cached_mats)
		if(state & cached_mats[id][MAT_META][META_MAT_STATE])
			part += cached_mats[id][MOLES]
			colors[cached_mats[id][MAT_META][META_MAT_COLOR]] += cached_mats[id][MAT_META][META_MAT_ALPHA]/255 * cached_mats[id][MOLES]
			alpha += cached_mats[id][MAT_META][META_MAT_ALPHA] * cached_mats[id][MOLES]
	. = list(mix_colors_from_list(colors), alpha/part)
	qdel(colors)

// Adjust the thermal energy of the mixture by a specified amount (negative values subtract). I would prefer that you use this instead of setting the temperature directly.
/datum/material/proc/adjust_thermal_energy(amount = 0, update = TRUE)
	if(amount == 0)
		return
	temperature = Clamp(thermal_energy() + amount / max(MINIMUM_HEAT_CAPACITY, heat_capacity()), TCMB, INFINITY)
	if(update)
		request_update()

// Adjust the contents of the mixture.
// id: ID of the material being adjusted.
// amount: amount of the material being adjusted. Negative amounts subtract.
// temp: temperature of the material being adjusted. Set to 0 or null to assume temperature. (WARNING: this will create or destroy thermal energy.)
// update: whether this material should update afterwards. Set to false if you are updating manually.
/datum/material/proc/adjust_one(id, amount = 0, temp = T20C, update = TRUE)
	if(!id || amount == 0)
		return
	assert(id)
	var/cached_mats = mats
	max(cached_mats[id][MOLES] += amount, 0)
	if(temp && amount) // Adjusts thermal energy when adding if temp is greater than 0
		adjust_thermal_energy(cached_mats[id][MAT_META][META_MAT_SPECIFIC_HEAT] * amount * temp)
	else if(!amount) // Automatically adjusts thermal energy on subtract.
		adjust_thermal_energy(cached_mats[id][MAT_META][META_MAT_SPECIFIC_HEAT] * amount * temperature)
	if(update)
		request_update()
	else
		garbage_collect(list(id))

// Shorthand for adjust_moles with more than one id to be adjusted.
// instead of id, amount, use list(id = amount, id2 = amount2) for each item being adjusted.
/datum/material/proc/adjust_many(list/amount, temp = T20C, update = TRUE)
	for(var/id in amount)
		adjust_one(id, amount[id], temp, 0)
	if(update)
		request_update()

// Remove a proportional amount of moles from the mixture, and return the results.
// You can set state to only remove certain materials. (used with atmos machines)/
// Set return_after to FALSE if you aren't interested in the removed materials.
/datum/material/proc/remove_moles(amount = 0, state =  ALL_MATS, return_after = TRUE, update = TRUE)
	if(!amount || !state)
		return
	var/total = total_moles(state)
	if(!total)
		return
	var/cached_mats = mats
	var/part = Clamp(amount / total, 0, 1)

	if(!return_after) // If you don't want the returned amount, this is a bit faster.
		for(var/id in cached_mats)
			if(!(state & cached_mats[id][MAT_META][META_MAT_STATE]))
				continue
			adjust_one(id, -cached_mats[id][MOLES] * part, update = FALSE)
	else
		var/list/removed = new/list()
		for(var/id in cached_mats)
			if(!(state & cached_mats[id][MAT_META][META_MAT_STATE]))
				continue
			removed[id] = cached_mats[id][MOLES] * part
			adjust_one(id, -cached_mats[id][MOLES] * part, update = FALSE)
		if(removed)
			. = removed
		else
			qdel(removed)
	if(update)
		request_update()

// Same as above, but remove a proportional amount of units from the mixture instead of moles.
/datum/material/proc/remove_volume(amount = 0, state = ALL_MATS, return_after = TRUE, update = TRUE)
	if(!amount || !state)
		return
	var/part = Clamp(amount / return_volume(state), 0, 1)
	var/cached_mats = mats
	var/gas_part
	if(state & GASEOUS_MATS)
		gas_part = (return_pressure() * part) / (temperature * R_IDEAL_GAS_EQUATION)
	if(!return_after)
		for(var/id in cached_mats)
			if(!(state & cached_mats[id][MAT_META][META_MAT_STATE]))
				continue
			if(GASEOUS_MATS & cached_mats[id][MAT_META][META_MAT_STATE])
				adjust_one(id, -cached_mats[id][MOLES] * gas_part, update = FALSE)
			else
				adjust_one(id, -cached_mats[id][MOLES] * part, update = FALSE)
	else
		var/list/removed = new/list()
		for(var/id in cached_mats)
			if(!(state & cached_mats[id][MAT_META][META_MAT_STATE]))
				continue
			if(GASEOUS_MATS & cached_mats[id][MAT_META][META_MAT_STATE])
				removed[id] = cached_mats[id][MOLES] * gas_part
				adjust_one(id, -cached_mats[id][MOLES] * gas_part, update = FALSE)
			else
				removed[id] = cached_mats[id][MOLES] * part
				adjust_one(id, -cached_mats[id][MOLES] * part, update = FALSE)
		if(removed)
			. = removed
		else
			qdel(removed)
	if(update)
		request_update()

/datum/material/proc/remove_all(state = ALL_MATS, return_after = TRUE, update = TRUE)
	if(!state)
		return
	var/cached_mats = mats
	if(!return_after)
		for(var/id in cached_mats)
			if(!(state & cached_mats[id][MAT_META][META_MAT_STATE]))
				continue
			adjust_one(id, -cached_mats[id][MOLES], update = FALSE)
	else
		var/list/removed = new/list()
		for(var/id in cached_mats)
			if(!(state & cached_mats[id][MAT_META][META_MAT_STATE]))
				continue
			removed[id] = cached_mats[id][MOLES]
			adjust_one(id, -cached_mats[id][MOLES], update = FALSE)
		if(removed)
			. = removed
		else
			qdel(removed)
	if(update)
		request_update()

// Gets the material with the most moles.
/datum/material/proc/get_master_mat(state = ALL_MATS)
	var/master
	var/max_moles = 0
	var/cached_mats = mats
	for(var/id in cached_mats)
		if(cached_mats[id][MOLES] > max_moles && state & cached_mats[id][MAT_META][META_MAT_STATE])
			max_moles = cached_mats[id][MOLES]
			master = id
	return master

/datum/material/proc/request_update()
	if(updating)
		return
	updating = TRUE
	// START_PROCESSING(SSmaterials, src) // nullbear

/datum/material/process()
	updating = FALSE
	react()

// Check for potential reactions.
/datum/material/proc/react()
	if(flags & MAT_NOREACT)
		return
	garbage_collect()
	var/reaction_occured = 0
	var/cached_mats = mats

	for(var/id in cached_mats)
		finding_reactions:
			for(var/reaction in reactions_list[id])
				if(!reaction || cached_mats[id][MAT_DATA][REACTIONS][reaction])
					continue finding_reactions

				var/datum/reaction/R = reaction
				var/total_reqs = R.reqs.len
				var/total_match = 0
				var/req_temp = R.req_temp
				var/cold_req = R.cold_req

				if(cold_req && temperature > req_temp || !cold_req && temperature < req_temp)
					continue finding_reactions

				for(var/B in R.reqs)
					if(cached_mats[B][MOLES] < R.reqs[B])
						break
					total_match++

				if(total_match != total_reqs)
					continue finding_reactions

				if(R.spec_reqs(src)) // All the optimized recipe checking is done. This recipe is PROBABLY a match. Do the hard checks.
					if(R.react(src)) // All looks well. Did it finish reacting?
						reaction_occured = 1 // Sign up for another update. Just in case.

	if(reaction_occured)
		request_update()

/datum/material/proc/archive()
	var/list/cached_mats = mats

	temperature_archived = temperature
	for(var/id in cached_mats)
		cached_mats[id][ARCHIVE] = cached_mats[id][MOLES]