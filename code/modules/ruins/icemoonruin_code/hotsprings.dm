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
		var/random_choice = pick("Mob", "Appearance")
		switch(random_choice)
			if("Mob")
				L = wabbajack(L, "animal")
				var/turf/T = find_safe_turf()
				L.forceMove(T)
				to_chat(L, "<span class='notice'>You feel somehow... different?</span>")
				to_chat(L, "<span class='notice'>You blink and find yourself in [get_area_name(T)].</span>")
			if("Appearance")
				var/mob/living/carbon/human/H = wabbajack(L, "humanoid")
				randomize_human(H)
				var/list/all_species = list()
				for(var/stype in subtypesof(/datum/species))
					var/datum/species/S = stype
					if(initial(S.changesource_flags) & RACE_SWAP)
						all_species += stype
				var/random_race = pick(all_species)
				H.set_species(random_race)
				H.dna.unique_enzymes = H.dna.generate_unique_enzymes()
				var/turf/T = find_safe_turf()
				H.forceMove(T)
				to_chat(H, "<span class='notice'>You feel somehow... different?</span>")
				to_chat(H, "<span class='notice'>You blink and find yourself in [get_area_name(T)].</span>")
