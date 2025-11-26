/datum/chemical_reaction/reagent_explosion/gay_potassium_explosion
	required_reagents = list(/datum/reagent/medicine/gaywater = 1, /datum/reagent/potassium = 1)
	strengthdiv = 15 // a bit weaker than normal potassium explosion

/datum/chemical_reaction/reagent_explosion/gay_potassium_explosion/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/turf/center = get_turf(holder.my_atom)
	var/range = created_volume/6
	var/include_flags = INCLUDE_HELD|INCLUDE_ACCESSORIES|INCLUDE_POCKETS

	for (var/turf/T in RANGE_TURFS(range, center))
		T.add_atom_colour("#ff99fc",WASHABLE_COLOUR_PRIORITY)

		for (var/mob/living/M in T)
			playsound(M, SFX_GAY, 100, FALSE)
			M.reagents.add_reagent(/datum/reagent/medicine/gaywater, 25)

			for (var/obj/item/gayitem in M.get_equipped_items(include_flags))
				gayitem.add_atom_colour("#ff99fc", WASHABLE_COLOUR_PRIORITY)

		for (var/obj/gaything in T)
			gaything.add_atom_colour("#ff99fc", WASHABLE_COLOUR_PRIORITY)

	default_explode(holder, created_volume, modifier, strengthdiv, FALSE)
