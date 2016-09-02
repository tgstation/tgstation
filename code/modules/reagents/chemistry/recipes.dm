/datum/chemical_reaction
	var/name = null
	var/id = null
	var/list/results = new/list()
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/secondary = 0 // set to nonzero if secondary reaction
	var/no_mob_react = 0 //Determines if a chemical reaction can occur inside a mob

	var/required_temp = 0
	var/is_cold_recipe = 0 // Set to 1 if you want the recipe to only react when it's BELOW the required temp.
	var/mix_message = "The solution begins to bubble." //The message shown to nearby people upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg' //The sound played upon mixing, if applicable

// Used to check special requirements of the recipe. Such as slime core uses and required containers.
/datum/chemical_reaction/proc/special_reqs(datum/reagents/holder)
	if(!istype(holder))
		return 0

// Called when the recipe is made.
/datum/chemical_reaction/proc/react(datum/reagents/holder)
	if(!istype(holder))
		return 0

// Consume the required_reagents. Used by most recipes.
/datum/chemical_reaction/proc/consume_reagents(datum/reagents/holder, multiplier = 1)
	if(!istype(holder) || !multiplier)
		return 0
	for(var/reagent in required_reagents)
		holder.adjust_volume(reagent, -required_reagents[reagent]*multiplier)

// Create the results.
/datum/chemical_reaction/proc/create_reagents(datum/reagents/holder, multiplier = 1, temperature = 293)
	if(!istype(holder) || !multiplier)
		return 0
	for(var/reagent in results)
		holder.adjust_volume(reagent, results[reagent]*multiplier)

// Get the multiplier for maximum possible reactions based on required reagents. Set ratio_mode to false to force full_integers only.
/datum/chemical_reaction/proc/get_multiplier(datum/reagents/holder, ratio_mode = TRUE)
	if(!istype(holder))
		return 0
	var/list/multipliers = new/list()
	for(var/R in required_reagents)
		var/available = holder.get_reagent_amount(R)
		var/needs = required_reagents[R]
		if(isnull(needs)) // More quality of life! If the recipe calls for 1 part, you don't need to explicitly type " = 1
			needs = 1
		if(available >= needs)
			if(needs == 0) // It's a 'perfect' catalyst, and needs only be present. Skip division by zero.
				continue
			multipliers += available/needs
		else
			return 0
	if(ratio_mode)
		return min(multipliers)
	else
		return round(min(multipliers))

// The basic reaction code. Used by old recipes.
/datum/chemical_reaction/proc/simple_react(datum/reagents/holder, multiplier = 1)
	if(!istype(holder) || !multiplier)
		return 0
	consume_reagents(holder, multiplier)
	create_reagents(holder, multiplier)

// Outputs a feedback message, and plays a sound. Override the defaults with mix_message = "message" or mix_sound = 'sound/path'. Alternatively you can set either argument to null.
/datum/chemical_reaction/proc/simple_feedback(datum/reagents/holder, mix_message = "The solution begins to bubble.", mix_sound = 'sound/effects/bubbles.ogg')
	if(!istype(holder) || istype(holder.my_atom, /mob)) // No bubbling mobs
		return 0
	var/list/seen = viewers(4, get_turf(holder.my_atom))
	if(mix_sound)
		playsound(get_turf(holder.my_atom), mix_sound, 80, 1)
	if(mix_message)
		for(var/mob/M in seen)
			M << "<span class='notice'>\icon[holder.my_atom] [mix_message]</span>"

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.

var/list/chemical_mob_spawn_meancritters = list() // list of possible hostile mobs
var/list/chemical_mob_spawn_nicecritters = list() // and possible friendly mobs
/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_faction = "chemicalsummon")
	if(holder && holder.my_atom)
		if (chemical_mob_spawn_meancritters.len <= 0 || chemical_mob_spawn_nicecritters.len <= 0)
			for (var/T in typesof(/mob/living/simple_animal))
				var/mob/living/simple_animal/SA = T
				switch(initial(SA.gold_core_spawnable))
					if(1)
						chemical_mob_spawn_meancritters += T
					if(2)
						chemical_mob_spawn_nicecritters += T
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/area/my_area = get_area(T)
		var/message = "A [reaction_name] reaction has occured in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>)"
		message += " (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [key_name_admin(M)](<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</A>)"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_eyes()
		for(var/i = 1, i <= amount_to_spawn, i++)
			var/chosen
			if (reaction_name == "Friendly Gold Slime")
				chosen = pick(chemical_mob_spawn_nicecritters)
			else
				chosen = pick(chemical_mob_spawn_meancritters)
			var/mob/living/simple_animal/C = new chosen
			C.faction |= mob_faction
			C.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(C, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/proc/goonchem_vortex(turf/T, setting_type, range)
	for(var/atom/movable/X in orange(range, T))
		if(istype(X, /obj/effect))
			continue
		if(!X.anchored)
			var/distance = get_dist(X, T)
			var/moving_power = max(range - distance, 1)
			if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
				if(setting_type)
					var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
					X.throw_at_fast(throw_target, moving_power, 1)
				else
					X.throw_at_fast(T, moving_power, 1)
			else
				spawn(0) //so everything moves at the same time.
					if(setting_type)
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_away(X, T))
								break
					else
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_towards(X, T))
								break
