GLOBAL_LIST_EMPTY(cursed_minds)

/turf/open/water/cursed_spring
	baseturfs = /turf/open/water/cursed_spring
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/water/cursed_spring/Entered(atom/movable/thing, atom/oldLoc)
	. = ..()
	if(!isliving(thing))
		return
	var/mob/living/L = thing
	if(!L.client)
		return
	if(L.mind in GLOB.cursed_minds)
		return
	GLOB.cursed_minds += L.mind
	var/random_choice = pick("Mob", "Appearance")
	switch(random_choice)
		if("Mob")
			L = wabbajack(L, "animal")
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
			L = H
		var/turf/T = find_safe_turf()
		L.forceMove(T)
		to_chat(H, "<span class='notice'>You blink and find yourself in [get_area_name(T)].</span>")
