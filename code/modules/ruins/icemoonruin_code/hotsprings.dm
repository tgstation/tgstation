GLOBAL_LIST_EMPTY(cursed_minds)

/turf/open/water/cursed_spring
	baseturfs = /turf/open/water/cursed_spring
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	var/list/banned_mob_types = list(/mob/living/simple_animal/hostile/carp/ranged,
										 /mob/living/simple_animal/hostile/carp/ranged/chaos,
										 /mob/living/simple_animal/hostile/megafauna/dragon/lesser,
										 /mob/living/simple_animal/hostile/poison/giant_spider,
										 /mob/living/simple_animal/hostile/poison/giant_spider/hunter)


/turf/open/water/cursed_spring/Entered(atom/movable/thing, atom/oldLoc)
	. = ..()
	if(isliving(thing))
		var/mob/living/L = thing
		if(!L.client)
			return
		if(L.mind in GLOB.cursed_minds)
			return
		GLOB.cursed_minds += L.mind
		var/picked_effect = pickweight(list("Appearance" = 4, "Mob" = 2))
		switch(picked_effect)
			if("Appearance")
				L = wabbajack(L, "humanoid")
				randomize_human(L)
			if("Mob")
				L = wabbajack(L, "animal")
				while(is_type_in_typecache(L, banned_mob_types)) // no
					L = wabbajack(L, "animal")
				var/turf/T = find_safe_turf()
				L.forceMove(T)
				to_chat(L, "<span class='notice'>You blink and find yourself in [get_area_name(T)].</span>")


/proc/genderswap(mob/living/L)
	if(!istype(L) || L.stat == DEAD || L.notransform || (GODMODE & L.status_flags))
		return
	if(!L.gender || !(L.gender in list(MALE, FEMALE)))
		return
		if(L.gender == MALE)
			L.gender = FEMALE
			to_chat(L, "<span class='notice'>Man, you feel like a woman!</span>")
		else
			L.gender = MALE
			to_chat(L, "<span class='notice'>Whoa man, you feel like a man!</span>")
			L.update_body()
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.update_mutations_overlay()
			C.dna.update_ui_block(DNA_GENDER_BLOCK)