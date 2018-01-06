/turf/open/floor/plating/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/stack/tile/mineral/reagent))
		var/obj/item/stack/tile/mineral/reagent/F = C
		var/turf/open/floor/mineral/reagent/FT = ChangeTurf(F.turf_type)
		var/paths = subtypesof(/datum/reagent)
		for(var/path in paths)
			var/datum/reagent/RR = new path
			if(RR.id == F.reagent_type.id)
				FT.reagent_type = RR
				FT.name ="[F.reagent_type] floor"
				FT.desc = "Floor tiles made of [F.reagent_type]"
				FT.add_atom_colour(F.reagent_type.color, FIXED_COLOUR_PRIORITY)
				break
			else
				qdel(RR)

		if(!F.use(1))
			return
	..()