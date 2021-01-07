/*
An object/datum to contain the vars for each of the reactions currently ongoing in a holder/reagents datum
This way all information is kept within one accessable object
equilibrium is a unique name as reaction is already too close to chemical_reaction
This is set up this way to reduce holder.dm bloat as well as reduce confusing list overhead
The crux of the fermimechanics are handled here
Instant reactions AREN'T handled here. See holder.dm
*/
/datum/equilibrium
	var/datum/chemical_reaction/reaction //The chemical reaction that is presently being processed
	var/datum/reagents/holder //The location the processing is taking place
	var/multiplier = INFINITY
	var/targetVol = INFINITY//The target volume the reaction is headed towards.
	var/reactedVol = 0 //How much of the reaction has been made so far. Mostly used for subprocs
	var/toDelete = FALSE //If we're done with this reaction so that holder can clear it

/datum/equilibrium/New(datum/chemical_reaction/Cr, datum/reagents/R)
	reaction = Cr
	holder = R
	if(!check_inital_conditions()) //If we're outside of the scope of the reaction vars
		toDelete = TRUE
		return
	if(!calculate_yield()) //maybe remove
		toDelete = TRUE
		return
	debug_world("Trying to call on_reaction for [Cr.type]")
	reaction.on_reaction(holder, multiplier) 
	SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] attempts")

//Check to make sure our input vars are sensible - truncated version of check_conditions (as the setup in holder.dm checks for that already)
/datum/equilibrium/proc/check_inital_conditions()
	if(holder.chem_temp > reaction.overheatTemp)//This is here so grenades can be made
		SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] overheats")
		reaction.overheated(holder, src)//Though the proc will likely have to be created to be an explosion.

	if(!reaction.is_cold_recipe)
		if(holder.chem_temp < reaction.required_temp) //This check is done before in holder, BUT this is here to ensure if it dips under it'll stop
			debug_world("[reaction.type] Failed initial temp checks")
			return FALSE //Not hot enough
	else
		if(holder.chem_temp > reaction.required_temp)
			debug_world("[reaction.type] Failed initial cold temp checks")
			return FALSE //Not cold enough
			
	if(! ((holder.pH >= (reaction.OptimalpHMin - reaction.ReactpHLim)) && (holder.pH <= (reaction.OptimalpHMax + reaction.ReactpHLim)) ))//To prevent pointless reactions
		debug_world("[reaction.type] Failed initial pH checks")
		return FALSE
	return TRUE

//Check to make sure our input vars are sensible - temp, pH, catalyst and explosion
/datum/equilibrium/proc/check_conditions()
	//Have we exploded?
	if(!holder.my_atom || holder.reagent_list.len == 0)
		debug_world("fermiEnd due to the atom/reagents no longer existing.")
		return FALSE
	//Are we overheated?
	if(holder.chem_temp > reaction.overheatTemp)
		debug_world("[reaction.type] Overheated")
		SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] overheated reaction steps")
		reaction.overheated(holder, src)

	//set up catalyst checks
	var/total_matching_catalysts = 0
	var/total_matching_reagents = 0

	//If the product/reactants are too impure
	for(var/datum/reagent/R in holder.reagent_list)
		if (R.purity < reaction.PurityMin)//If purity is below the min, call the proc
			SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[reaction.type] overly impure reaction steps")
			reaction.overly_impure(holder, src)
		//this is done this way to reduce processing compared to holder.has_reagent(P)
		for(var/P in reaction.required_catalysts)
			var/datum/reagent/R0 = P
			if(R0 == R.type)
				total_matching_catalysts++

		for(var/B in reaction.required_reagents)
			var/datum/reagent/R0 = B
			if(R0 == R.type) // required_reagents = list(/datum/reagent/consumable/sugar = 1) /datum/reagent/consumable/sugar
				total_matching_reagents++
	
	if(!(total_matching_reagents == reaction.required_reagents.len))
		debug_world("[reaction.type] Failed reagent checks")
		return FALSE

	if(!(total_matching_catalysts == reaction.required_catalysts.len))
		debug_world("[reaction.type] Failed catalyst checks")
		return FALSE

	/* moved to main handler
	//If we're too cold
	if(!reaction.is_cold_recipe)
		if(holder.chem_temp < reaction.required_temp) //This check is done before in holder, BUT this is here to ensure if it dips under it'll stop
			debug_world("[reaction.type] Failed initial temp checks")
			return FALSE //Not hot enough
	else //or too hot
		if(holder.chem_temp > reaction.required_temp)
			debug_world("[reaction.type] Failed initial cold temp checks")
			return FALSE //Not cold enough
	*/

	//Ensure we're within pH bounds - Disables reactions outside of the pH range
	//if(! ((holder.pH >= (reaction.OptimalpHMin - reaction.ReactpHLim)) && (holder.pH <= (reaction.OptimalpHMax + reaction.ReactpHLim)) )) //This could potentially be removed to reduce overhead
		//debug_world("[reaction.type] Failed pH checks")
		//return FALSE
	
	//All good!
	return TRUE

//Calculates how much we're aiming to create
/datum/equilibrium/proc/calculate_yield()
	if(toDelete)
		return FALSE
	if(!reaction)
		WARNING("Tried to calculate an equlibrium for reaction [reaction.type], but there was no reaction set for the datum")
		return FALSE
	multiplier = INFINITY
	for(var/B in reaction.required_reagents)
		multiplier = min(multiplier, round((holder.get_reagent_amount(B) / reaction.required_reagents[B]), CHEMICAL_QUANTISATION_LEVEL))
	for(var/P in reaction.results)
		targetVol = (reaction.results[P]*multiplier)
	debug_world("(Fermichem) reaction [reaction.type] has a target volume of: [targetVol] with a multipler of [multiplier]")
	if(targetVol == 0)
		debug_world("[reaction.type] Failed volume calculation checks [multiplier] | [targetVol]")
		return FALSE
	return TRUE

//Main reaction processor
//Increments reaction by a timestep
/datum/equilibrium/proc/react_timestep(delta_time)
	var/deltaT = 0
	var/deltapH = 0 //How far off the pH we are
	var/cached_pH = holder.pH
	var/cached_temp = holder.chem_temp
	var/stepChemAmmount = 0
	if(!check_conditions())
		toDelete = TRUE
		return
	if(!calculate_yield())
		toDelete = TRUE
		return

	//get purity from combined beaker reactant purities HERE.
	var/purity = 1

	//Begin checks
	//For now, purity is handled elsewhere (on add)
	//Calculate DeltapH (Deviation of pH from optimal)
	//Lower range
	if (cached_pH < reaction.OptimalpHMin)
		if (cached_pH < (reaction.OptimalpHMin - reaction.ReactpHLim))
			deltapH = 0
			//If outside pH range, 0
		else
			deltapH = (((cached_pH - (reaction.OptimalpHMin - reaction.ReactpHLim))**reaction.CurveSharppH)/((reaction.ReactpHLim**reaction.CurveSharppH))) //main pH calculation
	//Upper range
	else if (cached_pH > reaction.OptimalpHMax)
		if (cached_pH > (reaction.OptimalpHMax + reaction.ReactpHLim))
			deltapH = 0
			//If outside pH range, 0
		else
			deltapH = (((- cached_pH + (reaction.OptimalpHMax + reaction.ReactpHLim))**reaction.CurveSharppH)/(reaction.ReactpHLim**reaction.CurveSharppH))//Reverse - to + to prevent math operation failures.
	//Within mid range
	else if (cached_pH >= reaction.OptimalpHMin  && cached_pH <= reaction.OptimalpHMax)
		deltapH = 1
	//This should never proc, but it's a catch incase someone puts in incorrect values
	else
		WARNING("[holder.my_atom] attempted to determine FermiChem pH for '[reaction.type]' which had an invalid pH of [cached_pH] for set recipie pH vars. It's likely the recipe vars are wrong.")

	//Calculate DeltaT (Deviation of T from optimal)
	if(!reaction.is_cold_recipe)
		if (cached_temp < reaction.OptimalTempMax && cached_temp >= reaction.required_temp)
			deltaT = (((cached_temp - reaction.required_temp)**reaction.CurveSharpT)/((reaction.OptimalTempMax - reaction.required_temp)**reaction.CurveSharpT))
		else if (cached_temp >= reaction.OptimalTempMax)
			deltaT = 1
		else
			debug_world("[reaction.type] Failed temp checks")
			deltaT = 0
			toDelete = TRUE
			return
	else
		if (cached_temp > reaction.OptimalTempMax && cached_temp <= reaction.required_temp)
			deltaT = (((cached_temp - reaction.required_temp)**reaction.CurveSharpT)/((reaction.OptimalTempMax - reaction.required_temp)**reaction.CurveSharpT))
		else if (cached_temp <= reaction.OptimalTempMax)
			deltaT = 1
		else
			debug_world("[reaction.type] Failed cold temp checks")
			deltaT = 0
			toDelete = TRUE
			return

	purity = (deltapH)//set purity equal to pH offset

	//Then adjust purity of result with reagent purity.
	purity *= reactant_purity(reaction)


	var/removeChemAmmount //remove factor
	var/addChemAmmount //add factor
	var/TotalStep = 0 //total added
	//Calculate how much product to make and how much reactant to remove factors..
	for(var/P in reaction.results)
		addChemAmmount = (reaction.RateUpLim*deltaT)*delta_time
		if(addChemAmmount > targetVol)
			addChemAmmount = targetVol
		else if (addChemAmmount < CHEMICAL_VOLUME_MINIMUM)
			addChemAmmount = CHEMICAL_VOLUME_MINIMUM
		removeChemAmmount = (addChemAmmount/reaction.results[P])
		//keep limited.
		addChemAmmount = round(addChemAmmount, CHEMICAL_QUANTISATION_LEVEL)
		removeChemAmmount = round(removeChemAmmount, CHEMICAL_QUANTISATION_LEVEL)
		debug_world("Reaction vars: PreReacted:[reactedVol] of [targetVol]. deltaT [deltaT], multiplier [multiplier], Step [stepChemAmmount], uncapped Step [deltaT*(multiplier*reaction.results[P])], addChemAmmount [addChemAmmount], removeFactor [removeChemAmmount] Pfactor [reaction.results[P]], adding [addChemAmmount]")
		//create the products
		holder.add_reagent(P, (addChemAmmount), null, cached_temp, purity, ignore_pH = TRUE) //Calculate reactions only recalculates if a NEW reagent is added
		TotalStep += addChemAmmount//for multiple products - presently it doesn't work for multiple, but the code just needs a lil tweak when it works to do so (make targetVol in the calculate yield equal to all of the products, and make the vol check add totalStep)
	
	//remove reactants
	for(var/B in reaction.required_reagents)
		holder.remove_reagent(B, (removeChemAmmount * reaction.required_reagents[B]), safety = 1, ignore_pH = TRUE)
		
	//Apply pH changes and thermal output of reaction to beaker
	holder.chem_temp = round(cached_temp + (reaction.ThermicConstant * addChemAmmount))
	holder.pH += (reaction.HIonRelease * addChemAmmount)
	//keep track of the current reacted amount
	reactedVol = reactedVol + addChemAmmount

	reaction.reaction_step(src, addChemAmmount, purity)//proc that calls when step is done

	//Give a chance of sounds
	if (prob(20))
		holder.my_atom.visible_message("<span class='notice'>[icon2html(holder.my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [reaction.mix_message]</span>")
		if(reaction.mix_sound)
			playsound(get_turf(holder.my_atom), reaction.mix_sound, 80, TRUE)

	//Make sure things are limited
	holder.pH = clamp(holder.pH, 0, 14)
	holder.update_total()//do NOT recalculate reactions
	return

//Currently calculates it irrespective of required reagents at the start
/datum/equilibrium/proc/reactant_purity(var/datum/chemical_reaction/C)
	var/list/cached_reagents = holder.reagent_list
	var/i = 0
	var/cachedPurity
	for(var/datum/reagent/R in holder.reagent_list)
		if (R in cached_reagents)
			cachedPurity += R.purity
			i++
	if(!i)//I've never seen it get here with 0, but in case
		CRASH("No reactants found mid reaction for [C.type]. Beaker: [holder.my_atom]")
	return cachedPurity/i


