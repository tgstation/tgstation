/**
 * #Chemical Reaction
 *
 * Datum that makes the magic between reagents happen.
 *
 * Chemical reactions is a class that is instantiated and stored in a global list 'chemical_reactions_list'
 */
/datum/chemical_reaction
	///Results of the chemical reactions
	var/list/results = new/list()
	///Required chemicals that are USED in the reaction
	var/list/required_reagents = new/list()
	///Required chemicals that must be present in the container but are not USED.
	var/list/required_catalysts = new/list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	/// the exact container path required for the reaction to happen
	var/required_container
	/// an integer required for the reaction to happen
	var/required_other = 0

	///Determines if a chemical reaction can occur inside a mob
	var/mob_react = TRUE

	///The message shown to nearby people upon mixing, if applicable
	var/mix_message = "The solution begins to bubble."
	///The sound played upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg'

	/// Set to TRUE if you want the recipe to only react when it's BELOW the required temp.
	var/is_cold_recipe = FALSE
	///FermiChem! - See fermi_readme.md
	///Required temperature for the reaction to begin, for fermimechanics it defines the lower area of bell curve for determining heat based rate reactions, aka the minimum
	var/required_temp = 100
	/// Upper end for above (i.e. the end of the curve section defined by temp_exponent_factor)
	var/optimal_temp = 500
	/// Temperature at which reaction explodes - If any reaction is this hot, it explodes!
	var/overheat_temp = 900
	/// Lowest value of pH determining pH a 1 value for pH based rate reactions (Plateu phase)
	var/optimal_ph_min = 5
	/// Higest value for above
	var/optimal_ph_max = 9
	/// How far out pH wil react, giving impurity place (Exponential phase)
	var/determin_ph_range = 4
	/// How sharp the temperature exponential curve is (to the power of value)
	var/temp_exponent_factor = 2
	/// How sharp the pH exponential curve is (to the power of value)
	var/ph_exponent_factor = 2
	/// How much the temperature will change (with no intervention) (i.e. for 30u made the temperature will increase by 100, same with 300u. The final temp will always be start + this value, with the exception con beakers with different specific heats)
	var/thermic_constant = 50
	/// pH change per 1u reaction
	var/H_ion_release = 0.01
	/// Optimal/max rate possible if all conditions are perfect
	var/rate_up_lim = 30
	/// If purity is below 0.15, it calls OverlyImpure() too. Set to 0 to disable this.
	var/purity_min = 0.15
	/// bitflags for clear conversions; REACTION_CLEAR_IMPURE, REACTION_CLEAR_INVERSE, REACTION_CLEAR_RETAIN, REACTION_INSTANT
	var/reaction_flags = NONE

/datum/chemical_reaction/New()
	. = ..()
	SSticker.OnRoundstart(CALLBACK(src,.proc/update_info))

/**
 * Updates information during the roundstart
 *
 * This proc is mainly used by explosives but can be used anywhere else
 * You should generally use the special reactions in [/datum/chemical_reaction/randomized]
 * But for simple variable edits, like changing the temperature or adding/subtracting required reagents it is better to use this.
 */
/datum/chemical_reaction/proc/update_info()
	return

///REACTION PROCS

/**
 * Shit that happens on reaction
 * Only procs at the START of a reaction
 * use reaction_step() for each step of a reaction
 * or reaction_end() when the reaction stops
 * If reaction_flags & REACTION_INSTANT then this is the only proc that is called.
 *
 * Proc where the additional magic happens.
 * You dont want to handle mob spawning in this since there is a dedicated proc for that.client
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * created_volume - volume created when this is mixed. look at 'var/list/results'.
 */
/datum/chemical_reaction/proc/on_reaction(datum/equilibrium/reaction, datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.

/**
 * Stuff that occurs in the middle of a reaction
 * Only procs DURING a reaction
 * If reaction_flags & REACTION_INSTANT then this isn't called
 * returning END_REACTION will END the reaction
 *
 * Arguments:
 * * reaction - the equilibrium reaction holder that is reaction is processed within - use this to edit delta_t and delta
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * created_volume - volume created per step
 * * added_purity - how pure the created volume is per step
 *
 * Outputs:
 * * returning END_REACTION will end the associated reaction - flagging it for deletion and preventing any reaction in that timestep from happening. Make sure to set the vars in the holder to one that can't start it from starting up again.
 */
/datum/chemical_reaction/proc/reaction_step(datum/equilibrium/reaction, datum/reagents/holder, delta_t, delta_ph, step_reaction_vol)
	return

/**
 * Stuff that occurs at the end of a reaction. This will proc if the beaker is forced to stop and start again (say for sudden temperature changes).
 * Only procs at the END of reaction
 * If reaction_flags & REACTION_INSTANT then this isn't called
 * if reaction_flags REACTION_CLEAR_IMPURE then the impurity chem is handled here, producing the result in the beaker instead of in a mob
 * Likewise for REACTION_CLEAR_INVERSE the inverse chem is produced at the end of the reaction in the beaker
 * You should be calling ..() if you're writing a child function of this proc otherwise purity methods won't work correctly
 *
 * Proc where the additional magic happens.
 * You dont want to handle mob spawning in this since there is a dedicated proc for that.client
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * react_volume - volume created across the whole reaction
 */
/datum/chemical_reaction/proc/reaction_finish(datum/reagents/holder, react_vol)
	//failed_chem handler
	var/cached_temp = holder.chem_temp
	for(var/id in results)
		var/datum/reagent/reagent = holder.has_reagent(id)
		if(!reagent)
			continue
		//Split like this so it's easier for people to edit this function in a child
		convert_into_failed(reagent, holder)
		reaction_clear_check(reagent, holder)
	holder.chem_temp = cached_temp

/**
 * Converts a reagent into the type specified by the failed_chem var of the input reagent
 *
 * Arguments:
 * * reagent - the target reagent to convert
 */
/datum/chemical_reaction/proc/convert_into_failed(datum/reagent/reagent, datum/reagents/holder)
	if(reagent.purity < purity_min)
		var/cached_volume = reagent.volume
		holder.remove_reagent(reagent.type, cached_volume, FALSE)
		holder.add_reagent(reagent.failed_chem, cached_volume, FALSE, added_purity = 1)
		SSblackbox.record_feedback("tally", "chemical_reaction", 1, "[type] failed reactions")

/**
 * REACTION_CLEAR handler
 * If the reaction has the REACTION_CLEAR flag, then it will split using purity methods in the beaker instead
 *
 * Arguments:
 * * reagent - the target reagent to convert
 */
/datum/chemical_reaction/proc/reaction_clear_check(datum/reagent/reagent, datum/reagents/holder)
	if(!reagent)//Failures can delete R
		return
	if(reaction_flags & (REACTION_CLEAR_IMPURE | REACTION_CLEAR_INVERSE))
		if(reagent.purity == 1)
			return

		var/cached_volume = reagent.volume
		if((reaction_flags & REACTION_CLEAR_INVERSE) && reagent.inverse_chem)
			if(reagent.inverse_chem_val > reagent.purity)
				holder.remove_reagent(reagent.type, cached_volume, FALSE)
				holder.add_reagent(reagent.inverse_chem, cached_volume, FALSE, added_purity = 1)

		if((reaction_flags & REACTION_CLEAR_IMPURE) && reagent.impure_chem)
			var/impureVol = cached_volume * (1 - reagent.purity)
			holder.remove_reagent(reagent.type, (impureVol), FALSE)
			holder.add_reagent(reagent.impure_chem, impureVol, FALSE, added_purity = 1)
			reagent.creation_purity = reagent.purity
			reagent.purity = 1

/**
 * Occurs when a reation is overheated (i.e. past it's overheatTemp)
 * Will be called every tick in the reaction that it is overheated
 * If you want this to be a once only proc (i.e. the reaction is stopped after) set reaction.toDelete = TRUE
 * The above is useful if you're writing an explosion
 * By default the parent proc will reduce the final yield slightly. If you don't want that don't add ..()
 *
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * equilibrium - the equilibrium datum that contains the equilibrium reaction properties and methods
 */
/datum/chemical_reaction/proc/overheated(datum/reagents/holder, datum/equilibrium/equilibrium)
	for(var/id in results)
		var/datum/reagent/reagent = holder.get_reagent(id)
		if(!reagent)
			return
		reagent.volume =  round((reagent.volume*0.98), 0.01) //Slowly lower yield per tick

/**
 * Occurs when a reation is too impure (i.e. it's below purity_min)
 * Will be called every tick in the reaction that it is too impure
 * If you want this to be a once only proc (i.e. the reaction is stopped after) set reaction.toDelete = TRUE
 * The above is useful if you're writing an explosion
 * By default the parent proc will reduce the purity of all reagents involved in the reaction in the beaker slightly. If you don't want that don't add ..()
 *
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * equilibrium - the equilibrium datum that contains the equilibrium reaction properties and methods
 */
/datum/chemical_reaction/proc/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium)
	var/affected_list = results + required_reagents
	for(var/_reagent in affected_list)
		var/datum/reagent/reagent = holder.get_reagent(_reagent)
		if(!reagent)
			continue
		reagent.purity = clamp((reagent.purity-0.01), 0, 1) //slowly reduce purity of reagents

/**
 * Magical mob spawning when chemicals react
 *
 * Your go to proc when you want to create new mobs from chemicals. please dont use on_reaction.
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * amount_to_spawn - how much /mob to spawn
 * * reaction_name - what is the name of this reaction. be creative, the world is your oyster after all!
 * * mob_class - determines if the mob will be friendly, neutral or hostile
 * * mob_faction - used in determining targets, mobs from the same faction won't harm eachother.
 * * random - creates random mobs. self explanatory.
 */
/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = "chemicalsummon", random = TRUE)
	if(holder?.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/message = "Mobs have been spawned in [ADMIN_VERBOSEJMP(T)] by a [reaction_name] reaction."
		message += " (<A HREF='?_src_=vars;Vars=[REF(A)]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [ADMIN_LOOKUPFLW(M)]"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)
		log_game("[reaction_name] chemical mob spawn reaction occuring at [AREACOORD(T)] carried by [key_name(M)] with last fingerprint [A.fingerprintslast? A.fingerprintslast : "N/A"]")

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, TRUE)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_act()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/simple_animal/S
			if(random)
				S = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				S = new mob_class(get_turf(holder.my_atom))//Spawn our specific mob_class
			S.faction |= mob_faction
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(S, pick(NORTH,SOUTH,EAST,WEST))

/**
 * Magical move-wooney that happens sometimes.
 *
 * Simulates a vortex that moves nearby movable atoms towards or away from the turf T.
 * Range also determines the strength of the effect. High values cause nearby objects to be thrown.
 * Arguments:
 * * T - turf where it happens
 * * setting_type - does it suck or does it blow?
 * * range - range.
 */
/proc/goonchem_vortex(turf/T, setting_type, range)
	for(var/atom/movable/X in orange(range, T))
		if(X.anchored)
			continue
		if(iseffect(X) || iscameramob(X) || isdead(X))
			continue
		var/distance = get_dist(X, T)
		var/moving_power = max(range - distance, 1)
		if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
			if(setting_type)
				var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
				X.throw_at(throw_target, moving_power, 1)
			else
				X.throw_at(T, moving_power, 1)
		else
			if(setting_type)
				if(step_away(X, T) && moving_power > 1) //Can happen twice at most. So this is fine.
					addtimer(CALLBACK(GLOBAL_PROC, .proc/_step_away, X, T), 2)
			else
				if(step_towards(X, T) && moving_power > 1)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/_step_towards, X, T), 2)

//////////////////Generic explosions/failures////////////////////
// It is HIGHLY, HIGHLY recomended that you consume all/a good volume of the reagents/products in an explosion - because it will just keep going forever until the reaction stops
//If you have competitive reactions - it's a good idea to consume ALL reagents in a beaker (or product+reactant), otherwise it'll swing back with the deficit and blow up again


//Spews out the inverse of the chems in the beaker of the products/reactants only
/datum/chemical_reaction/proc/explode_invert_smoke(datum/reagents/holder, datum/equilibrium/equilibrium, clear_products = TRUE, clear_reactants = TRUE)
	var/datum/reagents/invert_reagents = new (2100, NO_REACT)//I think the biggest size we can get is 2100?
	var/datum/effect_system/smoke_spread/chem/smoke = new()
	var/sum_volume = 0
	invert_reagents.my_atom = holder.my_atom //Give the gas a fingerprint
	for(var/datum/reagent/reagent as anything in holder.reagent_list) //make gas for reagents, has to be done this way, otherwise it never stops Exploding
		if(!(reagent.type in required_reagents) || !(reagent.type in results))
			continue
		if(reagent.inverse_chem)
			invert_reagents.add_reagent(reagent.inverse_chem, reagent.volume, no_react = TRUE)
			holder.remove_reagent(reagent.type, reagent.volume)
			continue
		invert_reagents.add_reagent(reagent.type, reagent.volume, added_purity = reagent.purity, no_react = TRUE)
		sum_volume += reagent.volume
		holder.remove_reagent(reagent.type, reagent.volume)
	if(invert_reagents.reagent_list)
		smoke.set_up(invert_reagents, (sum_volume/5), holder.my_atom)
		smoke.start()
	holder.my_atom.audible_message("The [holder.my_atom] suddenly explodes, launching the aerosolized reagents into the air!")
	if(clear_reactants)
		clear_reactants(holder)
	if(clear_products)
		clear_products(holder)

//Spews out the corrisponding reactions reagents  (products/required) of the beaker in a smokecloud. Doesn't spew catalysts
/datum/chemical_reaction/proc/explode_smoke(datum/reagents/holder, datum/equilibrium/equilibrium, clear_products = TRUE, clear_reactants = TRUE)
	var/datum/reagents/reagents = new/datum/reagents(2100, NO_REACT)//Lets be safe first
	var/datum/effect_system/smoke_spread/chem/smoke = new()
	reagents.my_atom = holder.my_atom //fingerprint
	var/sum_volume = 0
	for (var/datum/reagent/reagent as anything in holder.reagent_list)
		if((reagent.type in required_reagents) || (reagent.type in results))
			reagents.add_reagent(reagent.type, reagent.volume, added_purity = reagent.purity, no_react = TRUE)
			holder.remove_reagent(reagent.type, reagent.volume)
	if(reagents.reagent_list)
		smoke.set_up(reagents, (sum_volume/5), holder.my_atom)
		smoke.start()
	holder.my_atom.audible_message("The [holder.my_atom] suddenly explodes, launching the aerosolized reagents into the air!")
	if(clear_reactants)
		clear_reactants(holder)
	if(clear_products)
		clear_products(holder)

//Pushes everything out, and damages mobs with 10 brute damage.
/datum/chemical_reaction/proc/explode_shockwave(datum/reagents/holder, datum/equilibrium/equilibrium)
	var/turf/this_turf = get_turf(holder.my_atom)
	holder.my_atom.audible_message("The [holder.my_atom] suddenly explodes, sending a shockwave rippling through the air!")
	playsound(this_turf, 'sound/chemistry/shockwave_explosion.ogg', 80, TRUE)
	//Modified goonvortex
	for(var/atom/movable/movey in orange(3, this_turf))
		if(isliving(movey))
			var/mob/living/live = movey
			live.apply_damage(5)//Since this can be called multiple times
		if(movey.anchored)
			continue
		if(iseffect(movey) || iscameramob(movey) || isdead(movey))
			continue
		var/distance = get_dist(movey, this_turf)
		var/moving_power = max(4 - distance, 1)//Make sure we're thrown out of range of the next one
		var/atom/throw_target = get_edge_target_turf(movey, get_dir(movey, get_step_away(movey, this_turf)))
		movey.throw_at(throw_target, moving_power, 1)


//Creates a ring of fire in a set range around the beaker location
/datum/chemical_reaction/proc/explode_fire(datum/reagents/holder, datum/equilibrium/equilibrium, range)
	explosion(holder.my_atom, 0, 0, 0, 0, flame_range = 3)
	holder.my_atom.audible_message("The [holder.my_atom] suddenly errupts in flames!")

//Clears the beaker of the reagents only
/datum/chemical_reaction/proc/clear_reactants(datum/reagents/holder, volume = null)
	if(!holder)
		return FALSE
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if(!(reagent.type in required_reagents))
			continue
		if(!volume)
			holder.remove_reagent(reagent.type, reagent.volume)
		else
			holder.remove_reagent(reagent.type, volume)

//Clears the beaker of the product only
/datum/chemical_reaction/proc/clear_products(datum/reagents/holder, volume = null)
	if(!holder)
		return FALSE
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if(!(reagent.type in results))
			continue
		if(!volume)
			holder.remove_reagent(reagent.type, reagent.volume)
		else
			holder.remove_reagent(reagent.type, volume)

//Clears the beaker of ALL reagents inside
/datum/chemical_reaction/proc/clear_reagents(datum/reagents/holder, volume = null)
	if(!holder)
		return FALSE
	holder.remove_all(volume)
