

/turf/closed/wall/shuttle
	name = "wall"
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	smooth = SMOOTH_FALSE

/turf/closed/wall/shuttle/copyTurf(turf/T)
	. = ..()
	T.transform = transform

/turf/closed/wall/shuttle/survival
	name = "pod wall"
	desc = "An easily-compressable wall used for temporary shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/closed/wall/shuttle/survival, /obj/machinery/door/airlock/survival_pod, /obj/structure/window/shuttle/survival_pod, /obj/structure/shuttle/engine)

/turf/closed/wall/shuttle/survival/nodiagonal
	smooth = SMOOTH_MORE

/turf/closed/wall/shuttle/survival/pod
	canSmoothWith = list(/turf/closed/wall/shuttle/survival, /obj/machinery/door/airlock, /obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/shuttle, /obj/structure/shuttle/engine)


/turf/closed/wall/shuttle/syndie
	icon_state = "wall3"
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium

/turf/closed/wall/shuttle/smooth
	name = "wall"
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle"
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/closed/wall/shuttle/smooth, /obj/structure/window/shuttle, /obj/structure/shuttle, /obj/machinery/door/airlock/glass, /obj/machinery/door/airlock/shuttle)

/turf/closed/wall/shuttle/smooth/nodiagonal
	smooth = SMOOTH_MORE
	icon_state = "shuttle_nd"

/turf/closed/wall/shuttle/smooth/overspace
	icon_state = "overspace"
	fixed_underlay = list("space"=1)

//sub-type to be used for interior shuttle walls
//won't get an underlay of the destination turf on shuttle move
/turf/closed/wall/shuttle/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	T.transform = transform
	return T

