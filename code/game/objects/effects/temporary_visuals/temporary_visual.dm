///temporary visual effects
/obj/effect/temp_visual
	icon_state = "nothing"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///time, in deciseconds, that this object will exist
	var/duration = 10
	///if true, will pick a random direction when created.
	var/randomdir = TRUE
	///id of the deletion timer
	var/timerid

/obj/effect/temp_visual/Initialize()
	. = ..()
	if(randomdir)
		setDir(pick(GLOB.cardinals))

	timerid = QDEL_IN(src, duration)

/obj/effect/temp_visual/Destroy()
	. = ..()
	deltimer(timerid)

/obj/effect/temp_visual/singularity_act()
	return

/obj/effect/temp_visual/singularity_pull()
	return

/obj/effect/temp_visual/dir_setting
	randomdir = FALSE

/obj/effect/temp_visual/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		setDir(set_dir)
	. = ..()


