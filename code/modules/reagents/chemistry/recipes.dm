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
	///Required temperature for the reaction to begin
	var/required_temp = 0
	/// Set to TRUE if you want the recipe to only react when it's BELOW the required temp.
	var/is_cold_recipe = FALSE
	///The message shown to nearby people upon mixing, if applicable
	var/mix_message = "The solution begins to bubble."
	///The sound played upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg'

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

/**
  * Shit that happens on reaction
  *
  * Proc where the additional magic happens.
  * You dont want to handle mob spawning in this since there is a dedicated proc for that.client
  * Arguments:
  * * holder - the datum that holds this reagent, be it a beaker or anything else
  * * created_volume - volume created when this is mixed. look at 'var/list/results'.
  */
/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.

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
