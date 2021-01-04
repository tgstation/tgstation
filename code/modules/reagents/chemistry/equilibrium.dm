/*
An object/datum to contain the vars for each of the reactions currently ongoing in a holder/reagents datum
This way all information is kept within one accessable object
equilibrium is a unique name as reaction is already too close to chemical_reaction
This is set up this way to reduce holder.dm bloat as well as reduce confusing list overhead
The crux of the fermimechanics are handled here
*/
/datum/equilibrium
    var/datum/chemical_reaction/reaction //The chemical reaction that is presently being processed
    var/datum/reagents/holder //The location the processing is taking place
    var/targetVol //The target volume the reaction is headed towards.
    var/reactedVol = 0 //How much of the reaction has been made so far.
    var/cachedVolIncrement = 0 //if the pH and the temperature are the same, then increment the amount produced per step by the same amount
    var/toDelete = FALSE //If we're done with this reaction so that holder can clear it

/datum/equilibrium/New(datum/chemical_reaction/Cr, datum/reagents/R)
    reaction = Cr
    holder = R
    CalculateYield()

/datum/equilibrium/proc/CalculateYield()
    if(toDelete)
        return
    if(!reaction)
        debug_admins("Tried to calculate an equlibrium, but there was no reaction set for the datum")
    if(!CanReact())
        return
    if(reaction.instantReaction)
        InstantReaction()

//The handler for a reaction that instantly reacts
//Doesn't MAKE the result here, just sets the Yield and the increment
//After setup the holder will process and complete the reaction - so for the end user it appears instant
/datum/equilibrium/proc/InstantReaction()
    var/list/cached_required_reagents = selected_reaction.required_reagents
    var/list/cached_results = selected_reaction.results
    var/list/multiplier = INFINITY
    for(var/B in cached_required_reagents)
        multiplier = min(multiplier, round(get_reagent_amount(B) / cached_required_reagents[B]))

    for(var/B in cached_required_reagents)
        remove_reagent(B, (multiplier * cached_required_reagents[B]), safety = 1)

    for(var/P in selected_reaction.results)
        multiplier = max(multiplier, 1) //this shouldn't happen ...
        SSblackbox.record_feedback("tally", "chemical_reaction", cached_results[P]*multiplier, P)
        add_reagent(P, cached_results[P]*multiplier, null, chem_temp)

/datum/equilibrium/proc/CanReact()
    if(holder.chem_temp > reaction.fExplodeTemp)
        SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[reaction.name] explosion"))
        reaction.Overheated(holder, src)
        return FALSE
    if(holder.chem_temp >= reaction.OptimalTempMin) //This check is done before in holder, BUT this is here to ensure if it dips under it'll stop
        return FALSE //Not hot enough
    if(! ((holder.pH >= (reaction.OptimalpHMin - reaction.ReactpHLim)) && (holder.pH <= (reaction.OptimalpHMax + reaction.ReactpHLim)) ))//To prevent pointless reactions
        return FALSE
