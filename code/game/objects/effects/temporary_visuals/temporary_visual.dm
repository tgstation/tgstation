//temporary visual effects
/obj/effect/overlay/temp
	icon_state = "nothing"
	anchored = 1
	layer = ABOVE_MOB_LAYER
	mouse_opacity = 0
	var/duration = 10 //in deciseconds
	var/randomdir = TRUE
	var/timerid

/obj/effect/overlay/temp/Initialize()
	. = ..()
	if(randomdir)
		setDir(pick(GLOB.cardinal))

	timerid = QDEL_IN(src, duration)

/obj/effect/overlay/temp/Destroy()
	. = ..()
	deltimer(timerid)

/obj/effect/overlay/temp/singularity_act()
	return

/obj/effect/overlay/temp/singularity_pull()
	return

/obj/effect/overlay/temp/ex_act()
	return

/obj/effect/overlay/temp/dir_setting
	randomdir = FALSE

/obj/effect/overlay/temp/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		setDir(set_dir)
	. = ..()
