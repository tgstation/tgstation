/*
* #/datum/equilibrium
*
* A dynamic reaction object that processes the reaction that it is set within it. Relies on a reagents holder to call and operate the functions.
*
* An object/datum to contain the vars for each of the reactions currently ongoing in a holder/reagents datum
* This way all information is kept within one accessable object
* equilibrium is a unique name as reaction is already too close to chemical_reaction
* This is set up this way to reduce holder.dm bloat as well as reduce confusing list overhead
* The crux of the fermimechanics are handled here
* Instant reactions AREN'T handled here. See holder.dm
*/
/datum/equilibrium
	///The chemical reaction that is presently being processed
	var/datum/chemical_reaction/reaction
	///The location/reagents datum the processing is taking place
	var/datum/reagents/holder
	///How much product we can make multiplied by the input recipe's products/required_reagents numerical values
	var/multiplier = INFINITY
	///The sum total of each of the product's numerical's values. This is so the addition/deletion is kept at the right values for multiple product reactions
	var/product_ratio = 0
	///The total possible that this reaction can make presently - used for gui outputs
	var/target_vol = 0
	///The target volume the reaction is headed towards. This is updated every tick, so isn't the total value for the reaction, it's just a way to ensure we can't make more than is possible.
	var/step_target_vol = INFINITY
	///How much of the reaction has been made so far. Mostly used for subprocs, but it keeps track across the whole reaction and is added to every step.
	var/reacted_vol = 0
	///What our last delta_ph was
	var/reaction_quality = 1
	///If we're done with this reaction so that holder can clear it.
	var/to_delete = FALSE
	///Result vars, private - do not edit unless in reaction_step()
	///How much we're adding
	var/delta_t
	///How pure our step is
	var/delta_ph
	///Modifiers from catalysts, do not use negative numbers.
	///I should write a better handiler for modifying these
	///Speed mod
	var/speed_mod = 1
	///pH mod
	var/h_ion_mod = 1
	///Temp mod
	var/thermic_mod = 1
	///Allow us to deal with lag by "charging" up our reactions to react faster over a period - this means that the reaction doesn't suddenly mass react - which can cause explosions
	var/time_deficit
	///Used to store specific data needed for a reaction, usually used to keep track of things between explosion calls. CANNOT be used as a part of chemical_recipe - those vars are static lookup tables.
	var/data = list()

/*
* Creates and sets up a new equlibrium object
*
* Arguments:
* * input_reaction - the chemical_reaction datum that will be processed
* * input_holder - the reagents datum that the output will be put into
*/
/datum/equilibrium/New(datum/chemical_reaction/input_reaction, datum/reagents/input_holder)
	reaction = input_reaction
	holder = input_holder
	if(!check_inital_conditions()) //If we're outside of the scope of the reaction vars
		to_delete = TRUE
		return
	if(!length(reaction.results)) //Come back to and revise the affected reactions in the next PR, this is a placeholder fix.
		holder.instant_react(reaction) //Even if this check fails, there's a backup - look inside of calculate_yield()
		to_delete = TRUE
		return
	LAZYADD(holder.reaction_list, src)
	SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] attempts")


/datum/equilibrium/Destroy()
	if(reacted_vol < target_vol) //We did NOT finish from reagents - so we can restart this reaction given property changes in the beaker. (i.e. if it stops due to low temp, this will allow it to fast restart when heated up again)
		LAZYADD(holder.failed_but_capable_reactions, reaction) //Consider replacing check with calculate_yield()
	LAZYREMOVE(holder.reaction_list, src)
	holder = null
	reaction = null
	to_delete = TRUE
	return ..()

/*
* Check to make sure our input vars are sensible - truncated version of check_reagent_properties()
*
* (as the setup in holder.dm checks for that already - this is a way to reduce calculations on New())
* Don't call this unless you know what you're doing, this is an internal proc
*/
/datum/equilibrium/proc/check_inital_conditions()
	PRIVATE_PROC(TRUE)

	if(QDELETED(holder))
		stack_trace("an equilibrium is missing its holder.")
		return FALSE
	if(QDELETED(reaction))
		stack_trace("an equilibrium is missing its reaction.")
		return FALSE
	if(!length(reaction.required_reagents))
		stack_trace("an equilibrium is missing required reagents.")
		return FALSE

	//Make sure we have the right multipler for on_reaction()
	for(var/datum/reagent/single_reagent as anything in reaction.required_reagents)
		multiplier = min(multiplier, holder.get_reagent_amount(single_reagent) / reaction.required_reagents[single_reagent])
	multiplier = round(multiplier, CHEMICAL_QUANTISATION_LEVEL)
	if(!multiplier) //we have no more or very little reagents left
		return FALSE

	//To prevent reactions outside of the pH window from starting.
	if(holder.ph < (reaction.optimal_ph_min - reaction.determin_ph_range) || holder.ph > (reaction.optimal_ph_max + reaction.determin_ph_range))
		return FALSE

	//All checks pass. cache the product ratio
	if(length(reaction.results))
		product_ratio = 0
		for(var/datum/reagent/product as anything in reaction.results)
			product_ratio += reaction.results[product]
	else
		product_ratio = 1
	return TRUE

/**
 * Check to make sure our input vars are sensible
 * 1) Is our atom in which this reaction is occuring still intact?
 * 2) Do we still have reagents to react with
 * 3) Do we have the required catalysts?
 * If you're adding more checks for reactions, this is the proc to edit
 * otherwise, generally, don't call this directed except internally
 */
/datum/equilibrium/proc/check_reagent_properties()
	PRIVATE_PROC(TRUE)

	//Have we exploded from on_reaction or did we run out of reagents?
	if(QDELETED(holder.my_atom) || !holder.reagent_list.len)
		return FALSE

	//Check for catalysts
	var/total_matching_catalysts = 0
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		//this is done this way to reduce processing compared to holder.has_reagent(P)
		for(var/datum/reagent/catalyst as anything in reaction.required_catalysts)
			if(catalyst == reagent.type)
				total_matching_catalysts++
		if(istype(reagent, /datum/reagent/catalyst_agent))
			var/datum/reagent/catalyst_agent/catalyst_agent = reagent
			if(reagent.volume >= catalyst_agent.min_volume)
				catalyst_agent.consider_catalyst(src)

	//Our present catalysts should match with our required catalyts
	return total_matching_catalysts == reaction.required_catalysts.len

/*
* Calculates how much we're aiming to create
*
* Specifically calcuates multiplier, product_ratio, step_target_vol
* Also checks to see if these numbers are sane, returns a TRUE/FALSE
* Generally an internal proc
*/
/datum/equilibrium/proc/calculate_yield()
	PRIVATE_PROC(TRUE)

	multiplier = INFINITY
	for(var/datum/reagent/reagent as anything in reaction.required_reagents)
		multiplier = min(multiplier, holder.get_reagent_amount(reagent) / reaction.required_reagents[reagent])
	multiplier = round(multiplier, CHEMICAL_QUANTISATION_LEVEL)
	if(!multiplier) //we have no more or very little reagents left
		return FALSE

	//Incase of no reagent product
	if(!length(reaction.results))
		step_target_vol = INFINITY
		for(var/datum/reagent/reagent as anything in reaction.required_reagents)
			step_target_vol = min(step_target_vol, multiplier * reaction.required_reagents[reagent])
		return TRUE

	//If we have reagent products
	step_target_vol = 0
	reacted_vol = 0 //Because volumes can be lost mid reactions
	for(var/datum/reagent/product as anything in reaction.results)
		step_target_vol += multiplier * reaction.results[product]
		reacted_vol += holder.get_reagent_amount(product)
	target_vol = reacted_vol + step_target_vol
	return TRUE

/*
* Main method of checking for explosive - or failed states
* Checks overheated() and overly_impure() of a reaction
* This was moved from the start, to the end - after a reaction, so post reaction temperature changes aren't ignored.
* overheated() is first - so double explosions can't happen (i.e. explosions that blow up the holder)
* step_volume_added is how much product (across all products) was added for this single step
*/
/datum/equilibrium/proc/check_fail_states(step_volume_added)
	PRIVATE_PROC(TRUE)

	//Are we overheated?
	if(reaction.is_cold_recipe)
		if(holder.chem_temp < reaction.overheat_temp && reaction.overheat_temp != NO_OVERHEAT) //This is before the process - this is here so that overly_impure and overheated() share the same code location (and therefore vars) for calls.
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] overheated reaction steps")
			reaction.overheated(holder, src, step_volume_added)
	else
		if(holder.chem_temp > reaction.overheat_temp)
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] overheated reaction steps")
			reaction.overheated(holder, src, step_volume_added)

	//is our product too impure?
	for(var/datum/reagent/product as anything in reaction.results)
		var/datum/reagent/reagent = holder.has_reagent(product)
		if(!reagent) //might be missing from overheat exploding
			continue
		if (reagent.purity < reaction.purity_min)//If purity is below the min, call the proc
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] overly impure reaction steps")
			reaction.overly_impure(holder, src, step_volume_added)

	//did we explode or run out of reagents?
	return !QDELETED(holder.my_atom) && holder.reagent_list.len

/*
* Deals with lag - allows a reaction to speed up to 3x from seconds_per_tick
* "Charged" time (time_deficit) discharges by incrementing reactions by doubling them
* If seconds_per_tick is greater than 1.5, then we save the extra time for the next ticks
*
* Arguments:
* * seconds_per_tick - the time between the last proc in world.time
*/
/datum/equilibrium/proc/deal_with_time(seconds_per_tick)
	PRIVATE_PROC(TRUE)

	if(seconds_per_tick > 1)
		time_deficit += seconds_per_tick - 1
		seconds_per_tick = 1 //Lets make sure reactions aren't super speedy and blow people up from a big lag spike
	else if (time_deficit)
		if(time_deficit < 0.25)
			seconds_per_tick += time_deficit
			time_deficit = 0
		else
			seconds_per_tick += 0.25
			time_deficit -= 0.25
	return seconds_per_tick

/*
* Main reaction processor - Increments the reaction by a timestep
*
* First checks the holder to make sure it can continue
* Then calculates the purity and volume produced.TRUE
* Then adds/removes reagents
* Then alters the holder pH and temperature, and calls reaction_step
* Arguments:
* * seconds_per_tick - the time displacement between the last call and the current, 1 is a standard step
* * purity_modifier - how much to modify the step's purity by (0 - 1)
*/
/datum/equilibrium/proc/react_timestep(seconds_per_tick, purity_modifier = 1)
	if(to_delete) //Sanity incase we try to complete a failed reaction
		return FALSE
	if(!check_reagent_properties()) //this is first because it'll call explosions first
		to_delete = TRUE
		return
	if(!calculate_yield())//So that this can detect if we're missing reagents
		to_delete = TRUE
		return
	seconds_per_tick = deal_with_time(seconds_per_tick)

	delta_t = 0 //how far off optimal temp we care
	delta_ph = 0 //How far off the pH we are
	var/cached_ph = holder.ph
	var/cached_temp = holder.chem_temp
	var/purity = 1 //purity of the current step

	//Begin checks
	//Calculate DeltapH (Deviation of pH from optimal)
	//Within mid range
	var/acceptable_ph
	if (cached_ph >= reaction.optimal_ph_min  && cached_ph <= reaction.optimal_ph_max)
		delta_ph = 1 //100% purity for this step
	//Lower range
	else if (cached_ph < reaction.optimal_ph_min) //If we're outside of the optimal lower bound
		acceptable_ph = reaction.optimal_ph_min - reaction.determin_ph_range
		if (cached_ph < acceptable_ph) //If we're outside of the deterministic bound
			delta_ph = 0 //0% purity
		else //We're in the deterministic phase
			delta_ph = ((cached_ph - acceptable_ph) / reaction.determin_ph_range) ** reaction.ph_exponent_factor
	//Upper range
	else if (cached_ph > reaction.optimal_ph_max) //If we're above of the optimal lower bound
		acceptable_ph = reaction.optimal_ph_max + reaction.determin_ph_range
		if (cached_ph > acceptable_ph)  //If we're outside of the deterministic bound
			delta_ph = 0 //0% purity
		else  //We're in the deterministic phase
			delta_ph = ((acceptable_ph - cached_ph) / reaction.determin_ph_range) ** reaction.ph_exponent_factor

	//Calculate DeltaT (Deviation of T from optimal)
	if(!reaction.is_cold_recipe)
		if (cached_temp < reaction.optimal_temp && cached_temp >= reaction.required_temp)
			delta_t = ((cached_temp - reaction.required_temp) / (reaction.optimal_temp - reaction.required_temp)) ** reaction.temp_exponent_factor
		else if (cached_temp >= reaction.optimal_temp)
			delta_t = 1
		else //too hot
			delta_t = 0
			to_delete = TRUE
			return
	else
		if (cached_temp > reaction.optimal_temp && cached_temp <= reaction.required_temp)
			delta_t = ((reaction.required_temp - cached_temp) / (reaction.required_temp - reaction.optimal_temp)) ** reaction.temp_exponent_factor
		else if (cached_temp <= reaction.optimal_temp)
			delta_t = 1
		else //Too cold
			delta_t = 0
			to_delete = TRUE
			return

	//Call any special reaction steps BEFORE addition
	if(reaction.reaction_step(holder, src, delta_t, delta_ph, step_target_vol) == END_REACTION)
		to_delete = TRUE
		return

	//Catalyst modifier
	delta_t *= speed_mod

	//set purity equal to pH offset
	purity = delta_ph

	//Then adjust purity of result with beaker reagent purity.
	purity *= holder.get_average_purity()

	//Then adjust it from the input modifier
	purity *= purity_modifier

	//Now we calculate how much to add - this is normalised to the rate up limiter
	var/delta_chem_factor = reaction.rate_up_lim * delta_t * seconds_per_tick//add/remove factor
	//keep limited
	if(delta_chem_factor > step_target_vol)
		delta_chem_factor = step_target_vol
	//Normalise to multiproducts
	delta_chem_factor = round(delta_chem_factor / product_ratio, CHEMICAL_VOLUME_ROUNDING)
	if(delta_chem_factor <= 0)
		to_delete = TRUE
		return

	//Calculate how much product to make and how much reactant to remove factors..
	var/required_amount
	var/pH_adjust
	for(var/datum/reagent/requirement as anything in reaction.required_reagents)
		required_amount = reaction.required_reagents[requirement]
		if(!holder.remove_reagent(requirement, delta_chem_factor * required_amount))
			to_delete = TRUE
			return
		//Apply pH changes
		if(reaction.reaction_flags & REACTION_PH_VOL_CONSTANT)
			pH_adjust = ((delta_chem_factor * required_amount) / target_vol) * (reaction.H_ion_release * h_ion_mod)
		else //Default adds pH independant of volume
			pH_adjust = (delta_chem_factor * required_amount) * (reaction.H_ion_release * h_ion_mod)
		holder.adjust_specific_reagent_ph(requirement, pH_adjust)

	var/step_add
	var/total_step_added = 0
	for(var/datum/reagent/product as anything in reaction.results)
		//create the products
		step_add = holder.add_reagent(product, delta_chem_factor * reaction.results[product], null, cached_temp, purity, override_base_ph = TRUE)
		if(!step_add)
			to_delete = TRUE
			return

		//Apply pH changes
		if(reaction.reaction_flags & REACTION_PH_VOL_CONSTANT)
			pH_adjust = (step_add / target_vol) * (reaction.H_ion_release * h_ion_mod)
		else
			pH_adjust = step_add * (reaction.H_ion_release * h_ion_mod)
		holder.adjust_specific_reagent_ph(product, pH_adjust)

		//record amounts created
		reacted_vol += step_add
		total_step_added += step_add

	#ifdef REAGENTS_TESTING //Kept in so that people who want to write fermireactions can contact me with this log so I can help them
	if(GLOB.Debug2) //I want my spans for my sanity
		message_admins("<span class='green'>Reaction step active for:[reaction.type]</span>")
		message_admins("<span class='notice'>|Reaction conditions| Temp: [holder.chem_temp], pH: [holder.ph], reactions: [length(holder.reaction_list)], awaiting reactions: [length(holder.failed_but_capable_reactions)], no. reagents:[length(holder.reagent_list)], no. prev reagents: [length(holder.previous_reagent_list)]</span>")
		message_admins("<span class='warning'>Reaction vars: PreReacted:[reacted_vol] of [step_target_vol] of total [target_vol]. delta_t [delta_t], multiplier [multiplier], delta_chem_factor [delta_chem_factor] Pfactor [product_ratio], purity of [purity] from a delta_ph of [delta_ph]. DeltaTime: [seconds_per_tick]</span>")
	#endif

	//Apply thermal output of reaction to beaker
	var/heat_energy = reaction.thermic_constant * total_step_added * thermic_mod
	if(reaction.reaction_flags & REACTION_HEAT_ARBITARY) //old method - for every bit added, the whole temperature is adjusted
		holder.set_temperature(clamp(holder.chem_temp + heat_energy, 0, CHEMICAL_MAXIMUM_TEMPERATURE))
	else //Standard mechanics - heat is relative to the beaker conditions
		holder.adjust_thermal_energy(heat_energy * SPECIFIC_HEAT_DEFAULT, 0, CHEMICAL_MAXIMUM_TEMPERATURE)

	//Give a chance of sounds
	if(prob(5))
		holder.my_atom.audible_message(span_notice("[icon2html(holder.my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [reaction.mix_message]"))
		if(reaction.mix_sound)
			playsound(get_turf(holder.my_atom), reaction.mix_sound, 80, TRUE)

	//Used for UI output
	reaction_quality = purity

	//post reaction checks
	if(!check_fail_states(total_step_added))
		to_delete = TRUE
		return

	//If the volume of reagents created(total_step_added) >= volume of reagents still to be created(step_target_vol) then end
	//i.e. we have created all the reagents needed for this reaction
	//This is only accurate when a single reaction is present and we don't have multiple reactions where
	//reaction B consumes the products formed from reaction A(which can happen in add_reagent() as it also triggers handle_reactions() which can consume the reagent just added)
	//because total_step_added will be higher than the actual volume that was created leading to the reaction ending early
	//and yielding less products than intended
	if(total_step_added >= step_target_vol && length(holder.reaction_list) == 1)
		to_delete = TRUE
