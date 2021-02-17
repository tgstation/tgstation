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
	if(!holder || !reaction) //sanity check
		stack_trace("A new [type] was set up, with incorrect/null input vars!")
		to_delete = TRUE
		return
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
	return ..()

/*
* Check to make sure our input vars are sensible - truncated version of check_reagent_properties()
*
* (as the setup in holder.dm checks for that already - this is a way to reduce calculations on New())
* Don't call this unless you know what you're doing, this is an internal proc
*/
/datum/equilibrium/proc/check_inital_conditions()
	//Make sure we have the right multipler for on_reaction()
	for(var/single_reagent in reaction.required_reagents)
		multiplier = min(multiplier, round((holder.get_reagent_amount(single_reagent) / reaction.required_reagents[single_reagent]), CHEMICAL_QUANTISATION_LEVEL))
	if(multiplier == INFINITY)
		return FALSE
	//Consider purity gating too? - probably not, purity is hard to determine
	//To prevent reactions outside of the pH window from starting.
	if(!((holder.ph >= (reaction.optimal_ph_min - reaction.determin_ph_range)) && (holder.ph <= (reaction.optimal_ph_max + reaction.determin_ph_range))))
		return FALSE
	return TRUE

/*
* Check to make sure our input vars are sensible - is the holder overheated? does it have the required reagents? Does it have the required calalysts?
*
* If you're adding more checks for reactions, this is the proc to edit
* otherwise, generally, don't call this directed except internally
*/
/datum/equilibrium/proc/check_reagent_properties()
	//Have we exploded from on_reaction?
	if(!holder.my_atom || holder.reagent_list.len == 0)
		return FALSE
	if(!holder)
		stack_trace("an equilibrium is missing it's holder.")
		return FALSE
	if(!reaction)
		stack_trace("an equilibrium is missing it's reaction.")
		return FALSE

	//set up catalyst checks
	var/total_matching_catalysts = 0
	//Reagents check should be handled in the calculate_yield() from multiplier

	//If the product/reactants are too impure
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		//this is done this way to reduce processing compared to holder.has_reagent(P)
		for(var/datum/reagent/catalyst as anything in reaction.required_catalysts)
			if(catalyst == reagent.type)
				total_matching_catalysts++
		if(istype(reagent, /datum/reagent/catalyst_agent))
			var/datum/reagent/catalyst_agent/catalyst_agent = reagent
			if(reagent.volume >= catalyst_agent.min_volume)
				catalyst_agent.consider_catalyst(src)

	if(!(total_matching_catalysts == reaction.required_catalysts.len))
		return FALSE

	//All good!
	return TRUE

/*
* Calculates how much we're aiming to create
*
* Specifically calcuates multiplier, product_ratio, step_target_vol
* Also checks to see if these numbers are sane, returns a TRUE/FALSE
* Generally an internal proc
*/
/datum/equilibrium/proc/calculate_yield()
	if(!reaction)
		stack_trace("Tried to calculate an equlibrium for reaction [reaction.type], but there was no reaction set for the datum")
		return FALSE

	multiplier = INFINITY
	for(var/reagent in reaction.required_reagents)
		multiplier = min(multiplier, round((holder.get_reagent_amount(reagent) / reaction.required_reagents[reagent]), CHEMICAL_QUANTISATION_LEVEL))

	if(!length(reaction.results)) //Incase of no reagent product
		product_ratio = 1
		step_target_vol = INFINITY
		for(var/reagent in reaction.required_reagents)
			step_target_vol = min(step_target_vol, multiplier * reaction.required_reagents[reagent])
		if(step_target_vol == 0 || multiplier == 0)
			return FALSE
		//Sanity Check
		if(step_target_vol == INFINITY || multiplier == INFINITY) //I don't see how this can happen, but I'm not bold enough to let infinities roll around for free
			to_delete = TRUE
			CRASH("Tried to calculate target vol for [reaction.type] with no products, but could not find required reagents for the reaction. If it got here, something is really broken with the recipe.")
		return TRUE

	product_ratio = 0
	step_target_vol = 0
	var/true_reacted_vol //Because volumes can be lost mid reactions
	for(var/product in reaction.results)
		step_target_vol += (reaction.results[product]*multiplier)
		product_ratio += reaction.results[product]
		true_reacted_vol += holder.get_reagent_amount(product)
	if(step_target_vol == 0 || multiplier == INFINITY)
		return FALSE
	target_vol = step_target_vol + true_reacted_vol
	reacted_vol = true_reacted_vol
	return TRUE

/*
* Deals with lag - allows a reaction to speed up to 3x from delta_time
* "Charged" time (time_deficit) discharges by incrementing reactions by doubling them
* If delta_time is greater than 1.5, then we save the extra time for the next ticks
*
* Arguments:
* * delta_time - the time between the last proc in world.time
*/
/datum/equilibrium/proc/deal_with_time(delta_time)
	if(delta_time > 1)
		time_deficit += delta_time - 1
		delta_time = 1 //Lets make sure reactions aren't super speedy and blow people up from a big lag spike
	else if (time_deficit)
		if(time_deficit < 0.25)
			delta_time += time_deficit
			time_deficit = 0
		else
			delta_time += 0.25
			time_deficit -= 0.25
	return delta_time

/*
* Main method of checking for explosive - or failed states
* Checks overheated() and overly_impure() of a reaction
* This was moved from the start, to the end - after a reaction, so post reaction temperature changes aren't ignored.
* overheated() is first - so double explosions can't happen (i.e. explosions that blow up the holder)
*/
/datum/equilibrium/proc/check_fail_states()
	//Are we overheated?
	if(reaction.is_cold_recipe)
		if(holder.chem_temp < reaction.overheat_temp) //This is before the process - this is here so that overly_impure and overheated() share the same code location (and therefore vars) for calls.
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] overheated reaction steps")
			reaction.overheated(holder, src)
	else
		if(holder.chem_temp > reaction.overheat_temp)
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] overheated reaction steps")
			reaction.overheated(holder, src)

	//is our product too impure?
	for(var/product in reaction.results)
		var/datum/reagent/reagent = holder.has_reagent(product)
		if(!reagent) //might be missing from overheat exploding
			continue
		if (reagent.purity < reaction.purity_min)//If purity is below the min, call the proc
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] overly impure reaction steps")
			reaction.overly_impure(holder, src)

	//did we explode?
	if(!holder.my_atom || holder.reagent_list.len == 0)
		return FALSE
	return TRUE

/*
* Main reaction processor - Increments the reaction by a timestep
*
* First checks the holder to make sure it can continue
* Then calculates the purity and volume produced.TRUE
* Then adds/removes reagents
* Then alters the holder pH and temperature, and calls reaction_step
* Arguments:
* * delta_time - the time displacement between the last call and the current, 1 is a standard step
* * purity_modifier - how much to modify the step's purity by (0 - 1)
*/
/datum/equilibrium/proc/react_timestep(delta_time, purity_modifier = 1)
	if(to_delete)
		//This occurs when it explodes
		return FALSE
	if(!check_reagent_properties()) //this is first because it'll call explosions first
		to_delete = TRUE
		return
	if(!calculate_yield())//So that this can detect if we're missing reagents
		to_delete = TRUE
		return
	delta_time = deal_with_time(delta_time)

	delta_t = 0 //how far off optimal temp we care
	delta_ph = 0 //How far off the pH we are
	var/cached_ph = holder.ph
	var/cached_temp = holder.chem_temp
	var/purity = 1 //purity of the current step

	//Begin checks
	//Calculate DeltapH (Deviation of pH from optimal)
	//Within mid range
	if (cached_ph >= reaction.optimal_ph_min  && cached_ph <= reaction.optimal_ph_max)
		delta_ph = 1 //100% purity for this step
	//Lower range
	else if (cached_ph < reaction.optimal_ph_min) //If we're outside of the optimal lower bound
		if (cached_ph < (reaction.optimal_ph_min - reaction.determin_ph_range)) //If we're outside of the deterministic bound
			delta_ph = 0 //0% purity
		else //We're in the deterministic phase
			delta_ph = (((cached_ph - (reaction.optimal_ph_min - reaction.determin_ph_range))**reaction.ph_exponent_factor)/((reaction.determin_ph_range**reaction.ph_exponent_factor))) //main pH calculation
	//Upper range
	else if (cached_ph > reaction.optimal_ph_max) //If we're above of the optimal lower bound
		if (cached_ph > (reaction.optimal_ph_max + reaction.determin_ph_range))  //If we're outside of the deterministic bound
			delta_ph = 0 //0% purity
		else  //We're in the deterministic phase
			delta_ph = (((- cached_ph + (reaction.optimal_ph_max + reaction.determin_ph_range))**reaction.ph_exponent_factor)/(reaction.determin_ph_range**reaction.ph_exponent_factor))//Reverse - to + to prevent math operation failures.

	//This should never proc, but it's a catch incase someone puts in incorrect values
	else
		stack_trace("[holder.my_atom] attempted to determine FermiChem pH for '[reaction.type]' which had an invalid pH of [cached_ph] for set recipie pH vars. It's likely the recipe vars are wrong.")

	//Calculate DeltaT (Deviation of T from optimal)
	if(!reaction.is_cold_recipe)
		if (cached_temp < reaction.optimal_temp && cached_temp >= reaction.required_temp)
			delta_t = (((cached_temp - reaction.required_temp)**reaction.temp_exponent_factor)/((reaction.optimal_temp - reaction.required_temp)**reaction.temp_exponent_factor))
		else if (cached_temp >= reaction.optimal_temp)
			delta_t = 1
		else //too hot
			delta_t = 0
			to_delete = TRUE
			return
	else
		if (cached_temp > reaction.optimal_temp && cached_temp <= reaction.required_temp)
			delta_t = (((cached_temp - reaction.required_temp)**reaction.temp_exponent_factor)/((reaction.optimal_temp - reaction.required_temp)**reaction.temp_exponent_factor))
		else if (cached_temp <= reaction.optimal_temp)
			delta_t = 1
		else //Too cold
			delta_t = 0
			to_delete = TRUE
			return

	//Call any special reaction steps BEFORE addition
	if(reaction.reaction_step(src, holder, delta_t, delta_ph, step_target_vol) == END_REACTION)
		to_delete = TRUE
		return

	//Catalyst modifier
	delta_t *= speed_mod

	purity = delta_ph//set purity equal to pH offset

	//Then adjust purity of result with beaker reagent purity.
	purity *= reactant_purity(reaction)

	//Then adjust it from the input modifier
	purity *= purity_modifier

	//Now we calculate how much to add - this is normalised to the rate up limiter
	var/delta_chem_factor = (reaction.rate_up_lim*delta_t)*delta_time//add/remove factor
	var/total_step_added = 0
	//keep limited
	if(delta_chem_factor > step_target_vol)
		delta_chem_factor = step_target_vol
	else if (delta_chem_factor < CHEMICAL_VOLUME_MINIMUM)
		delta_chem_factor = CHEMICAL_VOLUME_MINIMUM
	//Normalise to multiproducts
	delta_chem_factor /= product_ratio
	//delta_chem_factor = round(delta_chem_factor, CHEMICAL_QUANTISATION_LEVEL) // Might not be needed - left here incase testmerge shows that it does. Remove before full commit.

	//Calculate how much product to make and how much reactant to remove factors..
	for(var/reagent in reaction.required_reagents)
		holder.remove_reagent(reagent, (delta_chem_factor * reaction.required_reagents[reagent]), safety = TRUE)
		//Apply pH changes
		holder.adjust_specific_reagent_ph(reagent, (delta_chem_factor * reaction.required_reagents[reagent])*(reaction.H_ion_release*h_ion_mod))

	var/step_add
	for(var/product in reaction.results)
		//create the products
		step_add = delta_chem_factor * reaction.results[product]
		holder.add_reagent(product, step_add, null, cached_temp, purity, override_base_ph = TRUE)
		//Apply pH changes
		holder.adjust_specific_reagent_ph(product, step_add*reaction.H_ion_release)
		reacted_vol += step_add
		total_step_added += step_add

	#ifdef REAGENTS_TESTING //Kept in so that people who want to write fermireactions can contact me with this log so I can help them
	if(GLOB.Debug2) //I want my spans for my sanity
		message_admins("<span class='green'>Reaction step active for:[reaction.type]</spans>")
		message_admins("<span class='notice'>|Reaction conditions| Temp: [holder.chem_temp], pH: [holder.ph], reactions: [length(holder.reaction_list)], awaiting reactions: [length(holder.failed_but_capable_reactions)], no. reagents:[length(holder.reagent_list)], no. prev reagents: [length(holder.previous_reagent_list)]<spans>")
		message_admins("<span class='warning'>Reaction vars: PreReacted:[reacted_vol] of [step_target_vol] of total [target_vol]. delta_t [delta_t], multiplier [multiplier], delta_chem_factor [delta_chem_factor] Pfactor [product_ratio], purity of [purity] from a delta_ph of [delta_ph]. DeltaTime: [delta_time]")
	#endif

	//Apply thermal output of reaction to beaker
	if(reaction.reaction_flags & REACTION_HEAT_ARBITARY)
		holder.chem_temp += (reaction.thermic_constant* total_step_added*thermic_mod) //old method - for every bit added, the whole temperature is adjusted
	else //Standard mechanics
		var/heat_energy = reaction.thermic_constant * total_step_added * thermic_mod * SPECIFIC_HEAT_DEFAULT
		holder.adjust_thermal_energy(heat_energy, 0, 10000) //heat is relative to the beaker conditions

	//Give a chance of sounds
	if(prob(5))
		holder.my_atom.audible_message("<span class='notice'>[icon2html(holder.my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [reaction.mix_message]</span>")
		if(reaction.mix_sound)
			playsound(get_turf(holder.my_atom), reaction.mix_sound, 80, TRUE)

	//Used for UI output
	reaction_quality = purity

	//post reaction checks
	if(!(check_fail_states()))
		to_delete = TRUE

	//end reactions faster so plumbing is faster
	if((step_add >= step_target_vol) && (length(holder.reaction_list == 1)))//length is so that plumbing is faster - but it doesn't disable competitive reactions. Basically, competitive reactions will likely reach their step target at the start, so this will disable that. We want to avoid that. But equally, we do want to full stop a holder from reacting asap so plumbing isn't waiting an tick to resolve.
		to_delete = TRUE

	holder.update_total()//do NOT recalculate reactions


/*
* Calculates the total sum normalised purity of ALL reagents in a holder
*
* Currently calculates it irrespective of required reagents at the start, but this should be changed if this is powergamed to required reagents
* It's not currently because overly_impure affects all reagents
*/
/datum/equilibrium/proc/reactant_purity(datum/chemical_reaction/C)
	var/list/cached_reagents = holder.reagent_list
	var/i = 0
	var/cached_purity
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if (reagent in cached_reagents)
			cached_purity += reagent.purity
			i++
	if(!i)//I've never seen it get here with 0, but in case - it gets here when it blows up from overheat
		stack_trace("No reactants found mid reaction for [C.type]. Beaker: [holder.my_atom]")
		return 0 //we exploded and cleared reagents - but lets not kill the process
	return cached_purity/i

///Panic stop a reaction - cleanup should be handled by the next timestep
/datum/equilibrium/proc/force_clear_reactive_agents()
	for(var/reagent in reaction.required_reagents)
		holder.remove_reagent(reagent, (multiplier * reaction.required_reagents[reagent]), safety = 1)
