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
	///Tagging vars
	///A bitflag var for tagging reagents for the reagent loopup functon
	var/reaction_tags = NONE

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
/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
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
/datum/chemical_reaction/proc/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, delta_ph, step_reaction_vol)
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
/datum/chemical_reaction/proc/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	//failed_chem handler
	var/cached_temp = holder.chem_temp
	for(var/id in results)
		var/datum/reagent/reagent = holder.has_reagent(id)
		if(!reagent)
			continue
		//Split like this so it's easier for people to edit this function in a child
		reaction_clear_check(reagent, holder)
	holder.chem_temp = cached_temp

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
		var/cached_purity = reagent.purity
		if((reaction_flags & REACTION_CLEAR_INVERSE) && reagent.inverse_chem)
			if(reagent.inverse_chem_val > reagent.purity)
				holder.remove_reagent(reagent.type, cached_volume, FALSE)
				holder.add_reagent(reagent.inverse_chem, cached_volume, FALSE, added_purity = 1-cached_purity)
				return

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
 * * step_volume_added - how much product (across all products) was added for this single step
 */
/datum/chemical_reaction/proc/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	for(var/id in results)
		var/datum/reagent/reagent = holder.get_reagent(id)
		if(!reagent)
			return
		reagent.volume = round((reagent.volume*0.98), 0.01) //Slowly lower yield per tick

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
 * * step_volume_added - how much product (across all products) was added for this single step
 */
/datum/chemical_reaction/proc/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
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
			var/mob/living/spawned_mob
			if(random)
				spawned_mob = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				spawned_mob = new mob_class(get_turf(holder.my_atom))//Spawn our specific mob_class
			spawned_mob.faction |= mob_faction
			if(prob(50))
				for(var/j in 1 to rand(1, 3))
					step(spawned_mob, pick(NORTH,SOUTH,EAST,WEST))

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

/*
 * The same method that pyrotechnic reagents used before
 * Now instead of defining the var as part of the reaction - any recipe can call it and define their own method
 * WILL REMOVE ALL REAGENTS
 *
 * arguments:
 * * holder - the reagents datum that it is being used on
 * * created_volume - the volume of reacting elements
 * * modifier - a flat additive numeric to the size of the explosion - set this if you want a minimum range
 * * strengthdiv - the divisional factor of the explosion, a larger number means a smaller range - This is the part that modifies an explosion's range with volume (i.e. it divides it by this number)
 */
/datum/chemical_reaction/proc/default_explode(datum/reagents/holder, created_volume, modifier = 0, strengthdiv = 10)
	var/power = modifier + round(created_volume/strengthdiv, 1)
	if(power > 0)
		var/turf/T = get_turf(holder.my_atom)
		var/inside_msg
		if(ismob(holder.my_atom))
			var/mob/M = holder.my_atom
			inside_msg = " inside [ADMIN_LOOKUPFLW(M)]"
		var/lastkey = holder.my_atom.fingerprintslast //This can runtime (null.fingerprintslast) - due to plumbing?
		var/touch_msg = "N/A"
		if(lastkey)
			var/mob/toucher = get_mob_by_key(lastkey)
			touch_msg = "[ADMIN_LOOKUPFLW(toucher)]"
		if(!istype(holder.my_atom, /obj/machinery/plumbing)) //excludes standard plumbing equipment from spamming admins with this shit
			message_admins("Reagent explosion reaction occurred at [ADMIN_VERBOSEJMP(T)][inside_msg]. Last Fingerprint: [touch_msg].")
		log_game("Reagent explosion reaction occurred at [AREACOORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"]." )
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(power , T, 0, 0)
		e.start(holder.my_atom)
	holder.clear_reagents()

/*
 *Creates a flash effect only - less expensive than explode()
 *
 * *Arguments
 * * range - the radius around the holder's atom that is flashed
 * * length - how long it lasts in ds
 */
/datum/chemical_reaction/proc/explode_flash(datum/reagents/holder, datum/equilibrium/equilibrium, range = 2, length = 25)
	var/turf/location = get_turf(holder.my_atom)
	for(var/mob/living/living_mob in viewers(range, location))
		living_mob.flash_act(length = length)
	holder.my_atom.visible_message("The [holder.my_atom] suddenly lets out a bright flash!")

/*
 *Deafens those in range causing ear damage and muting sound
 *
 * Arguments
 * * power - How much damage is applied to the ear organ (I believe?)
 * * stun - How long the mob is stunned for
 * * range - the radius around the holder's atom that is banged
 */
/datum/chemical_reaction/proc/explode_deafen(datum/reagents/holder, datum/equilibrium/equilibrium, power = 3, stun = 20, range = 2)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, TRUE)
	for(var/mob/living/carbon/carbon_mob in get_hearers_in_view(range, location))
		carbon_mob.soundbang_act(1, stun, power)

//Spews out the inverse of the chems in the beaker of the products/reactants only
/datum/chemical_reaction/proc/explode_invert_smoke(datum/reagents/holder, datum/equilibrium/equilibrium, force_range = 0, clear_products = TRUE, clear_reactants = TRUE, accept_impure = TRUE)
	var/datum/reagents/invert_reagents = new (2100, NO_REACT)//I think the biggest size we can get is 2100?
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new()
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
	if(!force_range)
		force_range = (sum_volume/6) + 3
	if(invert_reagents.reagent_list)
		smoke.set_up(force_range, holder = holder.my_atom, location = holder.my_atom, carry = invert_reagents)
		smoke.start(log = TRUE)
	holder.my_atom.audible_message("The [holder.my_atom] suddenly explodes, launching the aerosolized reagents into the air!")
	if(clear_reactants)
		clear_reactants(holder)
	if(clear_products)
		clear_products(holder)

//Spews out the corrisponding reactions reagents  (products/required) of the beaker in a smokecloud. Doesn't spew catalysts
/datum/chemical_reaction/proc/explode_smoke(datum/reagents/holder, datum/equilibrium/equilibrium, force_range = 0, clear_products = TRUE, clear_reactants = TRUE)
	var/datum/reagents/reagents = new/datum/reagents(2100, NO_REACT)//Lets be safe first
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new()
	reagents.my_atom = holder.my_atom //fingerprint
	var/sum_volume = 0
	for (var/datum/reagent/reagent as anything in holder.reagent_list)
		if((reagent.type in required_reagents) || (reagent.type in results))
			reagents.add_reagent(reagent.type, reagent.volume, added_purity = reagent.purity, no_react = TRUE)
			holder.remove_reagent(reagent.type, reagent.volume)
	if(!force_range)
		force_range = (sum_volume/6) + 3
	if(reagents.reagent_list)
		smoke.set_up(force_range, holder = holder.my_atom, location = holder.my_atom, carry = reagents)
		smoke.start(log = TRUE)
	holder.my_atom.audible_message("The [holder.my_atom] suddenly explodes, launching the aerosolized reagents into the air!")
	if(clear_reactants)
		clear_reactants(holder)
	if(clear_products)
		clear_products(holder)

//Pushes everything out, and damages mobs with 10 brute damage.
/datum/chemical_reaction/proc/explode_shockwave(datum/reagents/holder, datum/equilibrium/equilibrium, range = 3, damage = 5, sound_and_text = TRUE, implosion = FALSE)
	var/turf/this_turf = get_turf(holder.my_atom)
	if(sound_and_text)
		holder.my_atom.audible_message("The [holder.my_atom] suddenly explodes, sending a shockwave rippling through the air!")
		playsound(this_turf, 'sound/chemistry/shockwave_explosion.ogg', 80, TRUE)
	//Modified goonvortex
	for(var/atom/movable/movey as anything in orange(range, this_turf))
		if(!istype(movey, /atom/movable))
			continue
		if(isliving(movey) && damage)
			var/mob/living/live = movey
			live.apply_damage(damage)//Since this can be called multiple times
		if(movey.anchored)
			continue
		if(iseffect(movey) || iscameramob(movey) || isdead(movey))
			continue
		if(implosion)
			var/distance = get_dist(movey, this_turf)
			var/moving_power = max(4 - distance, 1)
			var/turf/target = get_turf(holder.my_atom)
			movey.throw_at(target, moving_power, 1)
		else
			var/distance = get_dist(movey, this_turf)
			var/moving_power = max(3 - distance, 1)//Make sure we're thrown out of range of the next one
			var/atom/throw_target = get_edge_target_turf(movey, get_dir(movey, get_step_away(movey, this_turf)))
			movey.throw_at(throw_target, moving_power, 1)

////////BEGIN FIRE BASED EXPLOSIONS

//Calls the default explosion subsystem handiler to explode with fire (random firespots and noise)
/datum/chemical_reaction/proc/explode_fire(datum/reagents/holder, datum/equilibrium/equilibrium, range = 3)
	explosion(holder.my_atom, flame_range = range, explosion_cause = src)
	holder.my_atom.audible_message("The [holder.my_atom] suddenly errupts in flames!")

//Creates a ring of fire in a set range around the beaker location
/datum/chemical_reaction/proc/explode_fire_vortex(datum/reagents/holder, datum/equilibrium/equilibrium, x_offset = 1, y_offset = 1, reverse = FALSE, id = "f_vortex", )
	var/increment = reverse ? -1 : 1
	if(isnull(equilibrium.data["[id]_tar"]))
		equilibrium.data = list("[id]_x" = x_offset, "[id]_y" = y_offset, "[id]_tar" = "[id]_y")//tar is the current movement direction the cyclone is moving in
	if(equilibrium.data["[id]_tar"] == "[id]_x")
		if(equilibrium.data["[id]_x"] >= x_offset)
			equilibrium.data["[id]_tar"] = "[id]_y"
			equilibrium.data["[id]_y"] += increment
		else if(equilibrium.data["[id]_x"] <= -x_offset)
			equilibrium.data["[id]_tar"] = "[id]_y"
			equilibrium.data["[id]_y"] -= increment
		else
			if(equilibrium.data["[id]_y"] < 0)
				equilibrium.data["[id]_x"] += increment
			else if(equilibrium.data["[id]_y"] > 0)
				equilibrium.data["[id]_x"] -= increment

	else if (equilibrium.data["[id]_tar"] == "[id]_y")
		if(equilibrium.data["[id]_y"] >= y_offset)
			equilibrium.data["[id]_tar"] = "[id]_x"
			equilibrium.data["[id]_x"] -= increment
		else if(equilibrium.data["[id]_y"] <= -y_offset)
			equilibrium.data["[id]_tar"] = "[id]_x"
			equilibrium.data["[id]_x"] += increment
		else
			if(equilibrium.data["[id]_x"] < 0)
				equilibrium.data["[id]_y"] -= increment
			else if(equilibrium.data["[id]_x"] > 0)
				equilibrium.data["[id]_y"] += increment
	var/turf/holder_turf = get_turf(holder.my_atom)
	var/turf/target = locate(holder_turf.x + equilibrium.data["[id]_x"], holder_turf.y + equilibrium.data["[id]_y"], holder_turf.z)
	new /obj/effect/hotspot(target)
	debug_world("X: [equilibrium.data["[id]_x"]], Y: [equilibrium.data["[id]_x"]]")

/*
 * Creates a square of fire in a fire_range radius,
 * fire_range = 0 will be on the exact spot of the holder,
 * fire_range = 1 or more will be additional tiles around the holder. Every tile will be heated this way.
 * How clf3 works, you know!
 */
/datum/chemical_reaction/proc/explode_fire_square(datum/reagents/holder, datum/equilibrium/equilibrium, fire_range = 1)
	var/turf/location = get_turf(holder.my_atom)
	if(fire_range == 0)
		new /obj/effect/hotspot(location)
		return
	for(var/turf/turf as anything in RANGE_TURFS(fire_range, location))
		new /obj/effect/hotspot(turf)

///////////END FIRE BASED EXPLOSIONS

/*
* Freezes in a circle around the holder location
* Arguments:
* * temp - the temperature to set the air to
* * radius - the range of the effect
* * freeze_duration - how long the icey spots remain for
* * snowball_chance - the chance to spawn a snowball on a turf
*/
/datum/chemical_reaction/proc/freeze_radius(datum/reagents/holder, datum/equilibrium/equilibrium, temp, radius = 2, freeze_duration = 50 SECONDS, snowball_chance = 0)
	for(var/any_turf in circle_range_turfs(center = get_turf(holder.my_atom), radius = radius))
		if(!istype(any_turf, /turf/open))
			continue
		var/turf/open/open_turf = any_turf
		open_turf.MakeSlippery(TURF_WET_PERMAFROST, freeze_duration, freeze_duration, freeze_duration)
		open_turf.temperature = temp
		if(prob(snowball_chance))
			new /obj/item/toy/snowball(open_turf)

///Clears the beaker of the reagents only
///if volume is not set, it will remove all of the reactant
/datum/chemical_reaction/proc/clear_reactants(datum/reagents/holder, volume = 1000)
	if(!holder)
		return FALSE
	for(var/reagent in required_reagents)
		holder.remove_reagent(reagent, volume)

///Clears the beaker of the product only
/datum/chemical_reaction/proc/clear_products(datum/reagents/holder, volume = 1000)
	if(!holder)
		return FALSE
	for(var/reagent in results)
		holder.remove_reagent(reagent, volume)


///Clears the beaker of ALL reagents inside
/datum/chemical_reaction/proc/clear_reagents(datum/reagents/holder, volume = 1000)
	if(!holder)
		return FALSE
	if(!volume)
		volume = holder.total_volume
	holder.remove_all(volume)

/*
* "Attacks" all mobs within range with a specified reagent
* Will be blocked if they're wearing proper protective equipment unless disabled
* Arguments
* * reagent - the reagent typepath that will be added
* * vol - how much will be added
* * range - the range that this will affect mobs for
* * ignore_mask - if masks block the effect, making this true will affect someone regardless
* * ignore_eyes - if glasses block the effect, making this true will affect someone regardless
*/
/datum/chemical_reaction/proc/explode_attack_chem(datum/reagents/holder, datum/equilibrium/equilibrium, reagent, vol, range = 3, ignore_mask = FALSE, ignore_eyes = FALSE)
	if(istype(reagent, /datum/reagent))
		var/datum/reagent/temp_reagent = reagent
		reagent = temp_reagent.type
	for(var/mob/living/carbon/target in orange(range, get_turf(holder.my_atom)))
		if(target.has_smoke_protection() && !ignore_mask)
			continue
		if(target.get_eye_protection() && !ignore_eyes)
			continue
		to_chat(target, "The [holder.my_atom.name] launches some of [holder.p_their()] contents at you!")
		target.reagents.add_reagent(reagent, vol)


/*
* Applys a cooldown to the reaction
* Returns false if time is below required, true if it's above required
* Time is kept in eqilibrium data
*
* Arguments:
* * seconds - the amount of time in server seconds to delay between true returns, will ceiling to the nearest 0.25
* * id - a string phrase so that multiple cooldowns can be applied if needed
* * initial_delay - The number of seconds of delay to add on creation
*/
/datum/chemical_reaction/proc/off_cooldown(datum/reagents/holder, datum/equilibrium/equilibrium, seconds = 1, id = "default", initial_delay = 0)
	id = "[id]_cooldown"
	if(isnull(equilibrium.data[id]))
		equilibrium.data[id] = 0
		if(initial_delay)
			equilibrium.data[id] += initial_delay
			return FALSE
		return TRUE//first time we know we can go
	equilibrium.data[id] += equilibrium.time_deficit ? 0.5 : 0.25 //sync to lag compensator
	if(equilibrium.data[id] >= seconds)
		equilibrium.data[id] = 0
		return TRUE
	return FALSE
