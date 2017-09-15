/datum/reagent/proc/FINISHONMOBLIFE(mob/living/M)
	current_cycle++
	M.reagents.remove_reagent(src.id, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.
	return TRUE

/datum/reagent/proc/reaction_turf(turf/T, volume)
	if(!istype(T))
		return
	if(isspaceturf(T))
		return
	if(volume * 0.25 < 1)
		return
	for(var/obj/effect/decal/cleanable/chempile/c in T.contents)//handles merging existing chempiles
		c.reagents.add_reagent("[src.id]", volume * 0.25)
		var/mixcolor = mix_color_from_reagents(c.reagents.reagent_list)
		c.add_atom_colour(mixcolor, FIXED_COLOUR_PRIORITY)
		if(c.reagents.total_volume < 5 & REAGENT_NOREACT)
			c.reagents.set_reacting(TRUE)
		return TRUE

	var/obj/effect/decal/cleanable/chempile/C = new /obj/effect/decal/cleanable/chempile(T)//otherwise makes a new one
	C.reagents.add_reagent("[src.id]", volume * 0.25)
	var/mixcolor = mix_color_from_reagents(C.reagents.reagent_list)
	C.add_atom_colour(mixcolor, FIXED_COLOUR_PRIORITY)
	return