/turf/closed/wall/window_frame
	name = "window frame"
	desc = "A frame section to place a window on top.."
	icon = 'icons/turf/walls/windowframe_normal.dmi'
	icon_state = "windowframe_normal-0"
	base_icon_state = "windowframe_normal"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOWS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOWS)
	opacity = FALSE
	density = TRUE
	blocks_air = FALSE
	flags_1 = RAD_NO_CONTAMINATE_1
	rad_insulation = null
	frill_icon = null
	///Bitflag to hold state on what other objects we have
	var/window_state = NONE
	///Icon used by grilles for this window frame
	var/grille_icon = 'icons/turf/walls/window_grille.dmi'
	///Icon state used by grilles for this window frame
	var/grille_icon_state = "window_grille"
	///Icon used by windows for this window frame
	var/window_icon = 'icons/turf/walls/window-normal.dmi'
	///Icon state used by windows for this window frame
	var/window_icon_state = "window-normal"


/turf/closed/wall/window_frame/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	update_icon()

///delightfully devilous seymour
/turf/closed/wall/window_frame/set_smoothed_icon_state(new_junction)
	. = ..()
	update_icon()

/turf/closed/wall/window_frame/update_overlays()
	. = ..()
	if(window_state & WINDOW_FRAME_WITH_GRILLES)
		. += mutable_appearance(grille_icon, "[grille_icon_state]-[smoothing_junction]")
	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		. += mutable_appearance(window_icon, "[window_icon_state]-[smoothing_junction]")

/turf/closed/wall/window_frame/grille
	window_state = WINDOW_FRAME_WITH_GRILLES

/turf/closed/wall/window_frame/grille_and_window
	window_state = WINDOW_FRAME_WITH_GRILLES | WINDOW_FRAME_WITH_WINDOW
