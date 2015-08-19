///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/result_amount = 0
	var/secondary = 0 // set to nonzero if secondary reaction
	var/mob_react = 0 //Determines if a chemical reaction can occur inside a mob

	var/required_temp = 0
	var/mix_message = "The solution begins to bubble."

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.


/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_faction = "chemicalsummon")
	if(holder && holder.my_atom)
		var/list/meancritters = list(/mob/living/simple_animal/hostile/blob/blobspore, // list of possible hostile mobs
									/mob/living/simple_animal/hostile/blob/blobbernaut,
									/mob/living/simple_animal/hostile/carp/ranged/chaos,
									/mob/living/simple_animal/hostile/carp/ranged,
									/mob/living/simple_animal/hostile/carp/megacarp,
									/mob/living/simple_animal/hostile/carp/eyeball,
									/mob/living/simple_animal/hostile/carp,
									/mob/living/simple_animal/hostile/alien/drone,
									/mob/living/simple_animal/hostile/alien/sentinel,
									/mob/living/simple_animal/hostile/alien/queen,
									/mob/living/simple_animal/hostile/alien,
									/mob/living/simple_animal/hostile/bear/Hudson,
									/mob/living/simple_animal/hostile/bear,
									/mob/living/simple_animal/hostile/poison/bees,
									/mob/living/simple_animal/hostile/poison/giant_spider/nurse,
									/mob/living/simple_animal/hostile/poison/giant_spider/hunter,
									/mob/living/simple_animal/hostile/poison/giant_spider,
									/mob/living/simple_animal/hostile/creature,
									/mob/living/simple_animal/hostile/faithless,
									/mob/living/simple_animal/hostile/headcrab,
									/mob/living/simple_animal/hostile/hivebot/range,
									/mob/living/simple_animal/hostile/hivebot/rapid,
									/mob/living/simple_animal/hostile/hivebot/strong,
									/mob/living/simple_animal/hostile/hivebot,
									/mob/living/simple_animal/hostile/killertomato,
									/mob/living/simple_animal/hostile/mimic/crate,
									/mob/living/simple_animal/hostile/mimic,
									/mob/living/simple_animal/hostile/statue,
									/mob/living/simple_animal/hostile/viscerator,
									/mob/living/simple_animal/hostile/tree/festivus,
									/mob/living/simple_animal/hostile/tree)

		var/list/nicecritters = list(/mob/living/simple_animal/crab,
									/mob/living/simple_animal/mouse,
									/mob/living/simple_animal/lizard,
									/mob/living/simple_animal/parrot,
									/mob/living/simple_animal/butterfly,
									/mob/living/simple_animal/cow,
									/mob/living/simple_animal/chicken) // and possible friendly mobs
		nicecritters += typesof(/mob/living/simple_animal/pet) - /mob/living/simple_animal/pet
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
			if (reaction_name == "Friendly Gold Slime")
				var/chosen = pick(nicecritters)
				var/mob/living/simple_animal/C = new chosen
				C.faction |= mob_faction
				C.loc = get_turf(holder.my_atom)
				if(prob(50))
					for(var/j = 1, j <= rand(1, 3), j++)
						step(C, pick(NORTH,SOUTH,EAST,WEST))
			else
				var/chosen = pick(meancritters)
				var/mob/living/simple_animal/hostile/C = new chosen
				C.faction |= mob_faction
				C.loc = get_turf(holder.my_atom)
				if(prob(50))
					for(var/j = 1, j <= rand(1, 3), j++)
						step(C, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/proc/goonchem_vortex(turf/simulated/T, setting_type, range)
	for(var/atom/movable/X in orange(range, T))
		if(istype(X, /obj/effect))
			continue
		if(!X.anchored)
			var/distance = get_dist(X, T)
			var/moving_power = max(range - distance, 1)
			spawn(0) //so everything moves at the same time.
				if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
					if(setting_type)
						var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
						X.throw_at(throw_target, moving_power, 1)
					else
						X.throw_at(T, moving_power, 1)
				else
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
