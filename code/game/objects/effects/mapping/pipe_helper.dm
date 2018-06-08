/obj/effect/mapping/atmos_helper
	name = "Atmos Helper"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "atmos_helper_1"
	var/pipe_layer = PIPING_LAYER_DEFAULT
	var/pipe_color =

/obj/effect/mapping/pipe_helper/Initialize(mapload)
	if(!isturf(loc))
		return INITIALIZE_HINT_QDEL
	for(var/obj/effect/mapping/pipe_helper/PH in loc)
		if(WH == src)
			continue
		if(WH.layer == layer)
			qdel(WH)
			if(mapload)
				stack_trace("Extraneous pipe helper with the same layer erased at [COORD(src)].")
			return INITIALIZE_HINT_QDEL
	if(!mapload)			//adminspawn
		if(!GLOB.Debug2)
			to_chat(usr, "<span class='boldwarning'>Sorry, but piping helpers do not support adminspawning as of yet.</span>")
			return INITIALIZE_HINT_QDEL
	else
		var/list/target_helpers = list()
		var/list/target_atmos = list()
		for(var/i in GLOB.cardinals)
			var/turf/T = get_step(src, i)
			for(var/obj/effect/mapping/pipe_helper/PH in T)
				target_helpers[PH] = i
			for(var/obj/machinery/atmospherics/A in T)
				if(!(A.GetInitDirs() & get_dir(A, src)))
					continue
				if(!(A.pipe_flags & PIPING_ALL_LAYER) && (A.pipe_layer != pipe_layer))
					continue
				target_atmos[A] = i

