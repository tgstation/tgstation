/obj/effect/mapping/atmos_helper
	name = "Atmos Helper"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "atmos_helper_1"
	var/layer = PIPING_LAYER_DEFAULT
	var/pipe_color =
	var/pipe_type = /obj/machinery/atmospherics/pipe

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
		var/list/targets = list()
		for(var/i in GLOB.cardinals)
			var/turf/T = get_step(src, i)
			for(var/obj/effect/mapping/pipe_helper/PH in T)

