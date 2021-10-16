/obj/structure/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	resistance_flags |= INDESTRUCTIBLE
	flags_1 |= NODECONSTRUCT_1

/obj/machinery/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	resistance_flags |= INDESTRUCTIBLE
	flags_1 |= NODECONSTRUCT_1

/turf
	explosion_block = 50

/turf/rust_heretic_act()
	return

/turf/acid_act(acidpwr, acid_volume, acid_id)
	return FALSE

/turf/Melt()
	to_be_destroyed = FALSE
	return src

/turf/singularity_act()
	return
