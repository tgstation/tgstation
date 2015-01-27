

/obj/machinery/mirror/beamsplitter
	name = "beamsplitter"
	desc = "Uses a half-silvered plasma-glass mirror to split beams in two directions."
	mirror_state = "splitter"
	icon_state = "splitter" // For alignment when mapping
	nsplits = 2

/obj/machinery/mirror/beamsplitter/New()
	..()
	component_parts = list(
		new /obj/item/stack/sheet/glass/plasmarglass(src,5),
	)

/obj/machinery/mirror/beamsplitter/get_deflections(var/in_dir)
	// Splits like a real beam-splitter:
	//     |
	// >>==/-- (NORTH, SOUTH)
	//
	// >>==\-- (EAST, WEST)
	//     |
	// Can probably do this mathematically, but I'm too goddamn tired.

	if(dir in list(EAST, WEST)) // \\ orientation
		switch(in_dir)
			if(NORTH) return list(SOUTH, EAST)
			if(SOUTH) return list(NORTH, WEST)
			if(EAST)  return list(NORTH, WEST)
			if(WEST)  return list(SOUTH, EAST)
	else
		switch(in_dir) // / orientation
			if(NORTH) return list(SOUTH, WEST)
			if(SOUTH) return list(NORTH, EAST)
			if(EAST)  return list(SOUTH, WEST)
			if(WEST)  return list(NORTH, EAST)
