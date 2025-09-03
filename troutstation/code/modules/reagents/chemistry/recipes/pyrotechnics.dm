/datum/chemical_reaction/reagent_explosion/gay_potassium_explosion
	required_reagents = list(/datum/reagent/medicine/gaywater = 1, /datum/reagent/potassium = 1)
	strengthdiv = 15 // a bit weaker than normal potassium explosion

/datum/chemical_reaction/reagent_explosion/gay_potassium_explosion/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/center = get_turf(holder.my_atom)
	var/range = created_volume/5
	for(var/turf/T in RANGE_TURFS(range, center))
		T.add_filter("gay_explosion_pink", 10, color_matrix_filter(COLOR_FADED_PINK))
		for(var/mob/living/M in T)
			playsound(M, 'troutstation/sound/misc/gay.ogg', 100, FALSE)
			M.reagents.add_reagent(/datum/reagent/medicine/gaywater, 25)
	default_explode(holder, created_volume, modifier, strengthdiv, FALSE)
