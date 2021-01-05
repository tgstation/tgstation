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
    var/targetVol //The target volume the reaction is headed towards.
    var/reactedVol = 0 //How much of the reaction has been made so far.
    var/toDelete = FALSE //If we're done with this reaction so that holder can clear it

/datum/equilibrium/New(datum/chemical_reaction/Cr, datum/reagents/R)
    reaction = Cr
    holder = R
    if(!check_inital_conditions()) //If we're outside of the scope of the reaction vars
        toDelete = TRUE
        return
    calculate_yield() //maybe remove
    if(toDelete)
        return
    Cr.on_reaction(holder, holder.my_atom, multiplier)

//Check to make sure our input vars are sensible - truncated version of check_conditions (as the setup in holder.dm checks for that already)
/datum/equilibrium/proc/check_inital_conditions()
    if(holder.chem_temp > reaction.overheatTemp)//This is here so grenades can be made
        SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[reaction.type] overheats"))
        reaction.overheated(holder, src)//Though the proc will likely have to be created to be an explosion.
    if(holder.chem_temp >= reaction.required_temp) //This check is done before in holder, BUT this is here to ensure if it dips under it'll stop
        return FALSE //Not hot enough
    if(! ((holder.pH >= (reaction.required_temp - reaction.ReactpHLim)) && (holder.pH <= (reaction.OptimalpHMax + reaction.ReactpHLim)) ))//To prevent pointless reactions
        return FALSE

//Check to make sure our input vars are sensible - temp, pH, catalyst and explosion
/datum/equilibrium/proc/check_conditions()
    //Have we exploded?
    if(!holder.my_atom || holder.reagent_list.len == 0)
        if(GLOB.Debug2)
            debug_world("fermiEnd due to the atom/reagents no longer existing.")
            qdel(src)
        return FALSE
    //Are we overheated?
    if(holder.chem_temp > reaction.overheatTemp)
        SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[reaction.type] overheats"))
        reaction.overheated(holder, src)
    //If the product/reactants are too impure
    for(var/datum/reagent/R in holder.reagent_list)
        if (R.purity < reaction.PurityMin)//If purity is below the min, call the proc
            SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[reaction.type] overly impure reactions"))
            reaction.overly_impure(holder, src)
    //If we're too cold
    if(holder.chem_temp >= reaction.required_temp) 
        return FALSE 
    //Ensure we're within pH bounds
    if(! ((holder.pH >= (reaction.required_temp - reaction.ReactpHLim)) && (holder.pH <= (reaction.OptimalpHMax + reaction.ReactpHLim)) ))
        return FALSE
    //Do have have our catalyst?
    if(reaction.required_catalysts) 
        for(var/P in reaction.required_catalysts)
            if(!holder.has_reagent(P))
                return FALSE
    //All good!
    return TRUE

//Calculates how much we're aiming to create
/datum/equilibrium/proc/calculate_yield()
    if(toDelete)
        return
    if(!reaction)
        debug_world("Tried to calculate an equlibrium for reaction [reaction.type], but there was no reaction set for the datum")
    if(!targetVol)//Somehow the code gets here with a targetvol
        for(var/B in reaction.required_reagents)
            multiplier = min(multiplier, round((holder.get_reagent_amount(B) / reaction.required_reagents[B]), 0.0001))
        for(var/P in reaction.results)
            targetVol = reaction.results[P]*multiplier
        if(GLOB.Debug2)
            debug_world("(Fermichem) reaction [reaction.type] has a target volume of: [targetVol]")
    if(targetVol == 0)
        toDelete = TRUE

//Main reaction processor
//Increments reaction by a timestep
/datum/equilibrium/proc/react_timestep()
    var/deltaT = 0
    var/deltapH = 0 //How far off the pH we are
    var/cached_pH = holder.pH
    var/cached_temp = holder.chem_temp
    var/stepChemAmmount = 0
    check_conditions()
    calculate_yield()
    if(toDelete == TRUE) //if either checks are 0
        return

    //get purity from combined beaker reactant purities HERE.
    var/purity = 1

    //Begin checks
    //For now, purity is handled elsewhere (on add)
    //Calculate DeltapH (Deviation of pH from optimal)
    //Lower range
    if (cached_pH < reaction.required_temp)
        if (cached_pH < (reaction.required_temp - reaction.ReactpHLim))
            deltapH = 0
            //If outside pH range, 0
        else
            deltapH = (((cached_pH - (reaction.required_temp - reaction.ReactpHLim))**reaction.CurveSharppH)/((reaction.ReactpHLim**reaction.CurveSharppH))) //main pH calculation
    //Upper range
    else if (cached_pH > reaction.OptimalpHMax)
        if (cached_pH > (reaction.OptimalpHMax + reaction.ReactpHLim))
            deltapH = 0
            //If outside pH range, 0
        else
            deltapH = (((- cached_pH + (reaction.OptimalpHMax + reaction.ReactpHLim))**reaction.CurveSharppH)/(reaction.ReactpHLim**reaction.CurveSharppH))//Reverse - to + to prevent math operation failures.
    //Within mid range
    else if (cached_pH >= reaction.required_temp  && cached_pH <= reaction.OptimalpHMax)
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
    //Calculate how much product to make and how much reactant to remove factors..
    for(var/P in reaction.results)
        stepChemAmmount = (multiplier*reaction.results[P])
        if (stepChemAmmount > reaction.RateUpLim)
            stepChemAmmount = reaction.RateUpLim
        addChemAmmount = deltaT * stepChemAmmount
        if (addChemAmmount >= (targetVol - reactedVol))
            addChemAmmount = (targetVol - reactedVol)
        if (addChemAmmount < CHEMICAL_VOLUME_MINIMUM)
            addChemAmmount = CHEMICAL_VOLUME_MINIMUM
        removeChemAmmount = (addChemAmmount/reaction.results[P])
        //keep limited.
        addChemAmmount = round(addChemAmmount, CHEMICAL_VOLUME_MINIMUM)
        removeChemAmmount = round(removeChemAmmount, CHEMICAL_VOLUME_MINIMUM)
        if(GLOB.Debug2)
            debug_world("Reaction vars: PreReacted: <span class='danger'>[reactedVol] of [targetVol].</span> deltaT [deltaT], <span class='velvet'>multiplier [multiplier]</span>, Step [stepChemAmmount], uncapped Step [deltaT*(multiplier*reaction.results[P])], addChemAmmount [addChemAmmount], removeFactor [removeChemAmmount] Pfactor [reaction.results[P]], adding [addChemAmmount]")

    //remove reactants
    for(var/B in reaction.required_reagents)
        holder.remove_reagent(B, (removeChemAmmount * reaction.required_reagents[B]), safety = 1, ignore_pH = TRUE)

    //add product
    var/TotalStep = 0
    for(var/P in reaction.results)
        SSblackbox.record_feedback("tally", "chemical_reaction", addChemAmmount, P)//log
        SSblackbox.record_feedback("tally", "fermi_chem", addChemAmmount, P)
        holder.add_reagent(P, (addChemAmmount), null, cached_temp, purity, calculate_reactions = FALSE) //Calculate reactions only recalculates if a NEW reagent is added
        TotalStep += addChemAmmount//for multiple products
        //Above should reduce yield based on holder purity.
        
    reaction.reaction_step(src, addChemAmmount, purity)//proc that calls when step is done

    //Apply pH changes and thermal output of reaction to beaker
    holder.chem_temp = round(cached_temp + (reaction.ThermicConstant * addChemAmmount))
    holder.pH += (reaction.HIonRelease * addChemAmmount)
    //keep track of the current reacted amount
    reactedVol = reactedVol + addChemAmmount

    //conditions are updated at the start - so if you go over at the last tick, you should be safe.
    if(round(reactedVol, CHEMICAL_VOLUME_MINIMUM) == round(targetVol, CHEMICAL_VOLUME_MINIMUM))
        if(GLOB.Debug2)
            debug_world("fermiEnd due to volumes: React:[round(reactedVol, CHEMICAL_VOLUME_MINIMUM)] vs Target:[round(targetVol, CHEMICAL_VOLUME_MINIMUM)]")
        toDelete = TRUE	   

    //Give a chance of sounds
    if (prob(20))
        holder.my_atom.visible_message("<span class='notice'>[icon2html(holder.my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [reaction.mix_message]</span>")
        if(reaction.mix_sound)
            playsound(get_turf(holder.my_atom), reaction.mix_sound, 80, TRUE)

    //Make sure things are limited
    holder.pH = clamp(holder.pH, 0, 14)
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


