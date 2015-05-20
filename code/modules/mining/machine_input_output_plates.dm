/**********************Input and output plates**************************/

/obj/machinery/mineral/input
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	name = "Input area"
	density = 0
	anchored = 1.0
	New()
		icon_state = "blank"

/obj/machinery/mineral/output
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	name = "Output area"
	density = 0
	anchored = 1.0
	New()
		icon_state = "blank"

/obj/machinery/mineral
	var/input_dir = NORTH
	var/output_dir = SOUTH

/obj/machinery/mineral/proc/unload_mineral(var/atom/movable/S)
	S.loc = loc
	var/turf/T = get_step(src,output_dir)
	if(T)
		S.loc = T