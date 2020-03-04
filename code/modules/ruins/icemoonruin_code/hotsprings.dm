GLOBAL_LIST_EMPTY(cursed_minds)

/turf/open/water/cursed_spring
	baseturfs = /turf/open/water/cursed_spring
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/water/cursed_spring/Entered(atom/movable/thing, atom/oldLoc)
	. = ..()
	if(isliving(thing))
		var/mob/living/L = thing
		if(!L.client)
			return
		if(L.mind in GLOB.cursed_minds)
			return
		GLOB.cursed_minds += L.mind
		L.unequip_everything()
		var/random_choice = pick("Mob", "Life")
		switch(random_choice)
			if("Mob")
				L = wabbajack(L, "animal")
				var/turf/T = find_safe_turf()
				L.forceMove(T)
				to_chat(L, "<span class='notice'>You blink and find yourself in [get_area_name(T)].</span>")
			if("Life")
				var/mob/living/carbon/human/H = wabbajack(L, "humanoid")
				randomize_human(H)
				var/random_race = GLOB.species_list[pick(GLOB.roundstart_races)]
				H.set_species(random_race)
				var/list/valid_jobs = list()
				for(var/random_job in subtypesof(/datum/job))
					var/datum/job/J = new random_job()
					if(J.total_positions == 1 || J.spawn_positions == 1)
						continue
					if(J.minimal_player_age > 0)
						continue
					if(J.faction != "Station")
						continue
					if(J.title in GLOB.command_positions)
						continue
					valid_jobs |= J
					qdel(J)
				var/datum/job/J = pick(valid_jobs)
				J.equip(H, FALSE, TRUE, TRUE)
				SSjob.SendToLateJoin(H)
