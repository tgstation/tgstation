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
    if(reaction.RateUpLim > targetVol) //A catch all check incase I miss some reactions
        holder.instant_react(reaction)
        toDelete = TRUE
        //This is done at the end
        SEND_SIGNAL(holder, COMSIG_REAGENTS_REACTED, 1)
        holder.update_total()
        return
    Cr.on_reaction(holder, targetVol)  //(datum/reagents/holder, created_volume)
    SSblackbox.record_feedback("tally", "chemical_starts", 1, "[reaction.type] attempts")

//Check to make sure our input vars are sensible - truncated version of check_conditions (as the setup in holder.dm checks for that already)
/datum/equilibrium/proc/check_inital_conditions()
    if(holder.chem_temp > reaction.overheatTemp)//This is here so grenades can be made
        SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[reaction.type] overheats"))
        reaction.overheated(holder, src)//Though the proc will likely have to be created to be an explosion.
    if(holder.chem_temp < reaction.required_temp) //This check is done before in holder, BUT this is here to ensure if it dips under it'll stop
        debug_world("[reaction.type] Failed initial temp checks")
        return FALSE //Not hot enough
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
        SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[reaction.type] overheats"))
        reaction.overheated(holder, src)

    //set up catalyst checks
    var/catalystCheck = TRUE
    var/total_matching_reagents = 0
    if(reaction.required_catalysts.len)
        catalystCheck = FALSE

    //If the product/reactants are too impure
    for(var/datum/reagent/R in holder.reagent_list)
        if (R.purity < reaction.PurityMin)//If purity is below the min, call the proc
            SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[reaction.type] overly impure reactions"))
            reaction.overly_impure(holder, src)
        //this is done this way to reduce processing compared to holder.has_reagent(P)
        if(!catalystCheck)
            for(var/datum/reagent/P in reaction.required_catalysts)
                if(P.type == R.type)
                    catalystCheck = TRUE

        for(var/datum/reagent/B in reaction.required_reagents)
            if(B.type == R.type)
                total_matching_reagents++
    
    if(!total_matching_reagents == reaction.required_reagents.len)
        debug_world("[reaction.type] Failed reagent checks")
        return FALSE

    if(!catalystCheck)
        debug_world("[reaction.type] Failed catalyst checks")
        return FALSE

    //If we're too cold
    if(holder.chem_temp < reaction.required_temp) 
        debug_world("[reaction.type] Failed temp checks")
        return FALSE 
    //Ensure we're within pH bounds
    if(! ((holder.pH >= (reaction.OptimalpHMin - reaction.ReactpHLim)) && (holder.pH <= (reaction.OptimalpHMax + reaction.ReactpHLim)) )) //This could potentially be removed to reduce overhead
        debug_world("[reaction.type] Failed pH checks")
        return FALSE
    
    //All good!
    return TRUE

//Calculates how much we're aiming to create
/datum/equilibrium/proc/calculate_yield()
    if(toDelete)
        return FALSE
    if(!reaction)
        debug_world("Tried to calculate an equlibrium for reaction [reaction.type], but there was no reaction set for the datum")
    multiplier = INFINITY
    for(var/B in reaction.required_reagents)
        multiplier = min(multiplier, round((holder.get_reagent_amount(B) / reaction.required_reagents[B]), CHEMICAL_QUANTISATION_LEVEL))
    for(var/P in reaction.results)
        targetVol = (reaction.results[P]*multiplier)
    if(GLOB.Debug2)
        debug_world("(Fermichem) reaction [reaction.type] has a target volume of: [targetVol] with a multipler of [multiplier]")
    if(targetVol == 0)
        debug_world("[reaction.type] Failed volume calculation checks [multiplier] | [targetVol]")
        return FALSE
    return TRUE

//Main reaction processor
//Increments reaction by a timestep
/datum/equilibrium/proc/react_timestep()
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
    //This should never proc:
    else
        WARNING("[holder.my_atom] | [reaction.type] attempted to determine FermiChem pH for '[reaction.type]' which broke for some reason! ([usr])")

    //Calculate DeltaT (Deviation of T from optimal)
    if (cached_temp < reaction.OptimalTempMax && cached_temp >= reaction.required_temp)
        deltaT = (((cached_temp - reaction.required_temp)**reaction.CurveSharpT)/((reaction.OptimalTempMax - reaction.required_temp)**reaction.CurveSharpT))
    else if (cached_temp >= reaction.OptimalTempMax)
        deltaT = 1
    else
        deltaT = 0

    purity = (deltapH)//set purity equal to pH offset

    //Then adjust purity of result with reagent purity.
    purity *= reactant_purity(reaction)


    var/removeChemAmmount //remove factor
    var/addChemAmmount //add factor
    var/TotalStep = 0 //total added
    //Calculate how much product to make and how much reactant to remove factors..
    for(var/P in reaction.results)
        addChemAmmount = reaction.RateUpLim*deltaT
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
        holder.add_reagent(P, (addChemAmmount), null, cached_temp, purity, calculate_reactions = FALSE) //Calculate reactions only recalculates if a NEW reagent is added
        SSblackbox.record_feedback("tally", "fermi_chem", addChemAmmount, P)
        TotalStep += addChemAmmount//for multiple products - presently it doesn't work for multiple, but the code just needs a lil tweak when it works to do so (make targetVol in the calculate yield equal to all of the products, and make the vol check add totalStep)
    

    //remove reactants
    for(var/B in reaction.required_reagents)
        holder.remove_reagent(B, (removeChemAmmount * reaction.required_reagents[B]), safety = 1, ignore_pH = TRUE)

    SSblackbox.record_feedback("tally", "chemical_steps", addChemAmmount, reaction.type)//log
        
    reaction.reaction_step(src, addChemAmmount, purity)//proc that calls when step is done

    //Apply pH changes and thermal output of reaction to beaker
    holder.chem_temp = round(cached_temp + (reaction.ThermicConstant * addChemAmmount))
    holder.pH += (reaction.HIonRelease * addChemAmmount)
    //keep track of the current reacted amount
    reactedVol = reactedVol + addChemAmmount

    //conditions are updated at the start - so if you go over at the last tick, you should be safe.
    /*
    if(round(reactedVol, CHEMICAL_VOLUME_MINIMUM) >= round(targetVol, CHEMICAL_VOLUME_MINIMUM))
        debug_world("fermiEnd due to volumes: React:[round(reactedVol, CHEMICAL_VOLUME_MINIMUM)] vs Target:[round(targetVol, CHEMICAL_VOLUME_MINIMUM)]")
        toDelete = TRUE	   
        */

    //Give a chance of sounds
    if (prob(20))
        holder.my_atom.visible_message("<span class='notice'>[icon2html(holder.my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [reaction.mix_message]</span>")
        if(reaction.mix_sound)
            playsound(get_turf(holder.my_atom), reaction.mix_sound, 80, TRUE)

    //Make sure things are limited
    holder.pH = clamp(holder.pH, 0, 14)
    holder.update_total(FALSE)//do NOT recalculate reactions
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
        CRASH("No reactants found mid reaction for [C.type], how it got here is beyond me. Beaker: [holder.my_atom]")
    return cachedPurity/i


