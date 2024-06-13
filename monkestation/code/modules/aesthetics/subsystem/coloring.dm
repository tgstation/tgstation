
SUBSYSTEM_DEF(station_coloring)
	name = "Station Coloring"
	init_order = INIT_ORDER_ICON_COLORING // before SSicon_smooth
	flags = SS_NO_FIRE
	///do we bother with wall trims?
	var/wall_trims = FALSE
	//RED (Only sec stuff honestly)
	var/list/red = list("#d0294c", "#d6292f", "#d62f29", "#d63a29")
	//BAR
	var/list/bar = list("#3790aa", "#5ca9c1", "#5cb092", "#4daf9b", "#4a9bdf", "#30cedf", "#c7804a", "#b0cedf")
	//PURPLE (RnD + Research outpost)
	var/list/purple = list("#674dba", "#6b43bc", "#864ec5", "#8d40c3")
	//BROWN (Mining + Cargo)
	var/list/brown = list("#826627", "#825327", "#a9682b", "#a9542b")
	//GREEN (Virology and Hydro areas)
	var/list/green = list("#50b47c", "#59b25d", "#46955a", "#4ba17b")
	//BLUE (Some of Medbay areas)
	var/list/blue = list("#336f92", "#5d99bc", "#3f87ae", "#6eabce", "#307199")
	//ORANGE (engineering)
	var/list/orange = list("#f3a852", "#f39d3a", "#c47010", "#f08913", "#fc8600")

/datum/controller/subsystem/station_coloring/Initialize()
	var/list/color_palette = list(
		pick(red)          = typesof(/area/station/security),
		pick(purple)       = typesof(/area/station/science),
		pick(green)        = list(/area/station/medical/virology) + typesof(/area/station/service) - /area/station/service/bar,
		pick(blue)         = typesof(/area/station/medical),
		pick(bar)          = list(/area/station/service/bar),
		pick(brown)		   = typesof(/area/station/cargo) + typesof(/area/mine),
		COLOR_WHITE        = typesof(/area/shuttle),
		COLOR_WHITE        = typesof(/area/centcom),
		pick(orange)	   = typesof(/area/station/engineering),
	)

	for(var/color in color_palette)
		color_area_objects(color_palette[color], color)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/station_coloring/proc/color_area_objects(list/possible_areas, color) // paint in areas
	for(var/type in possible_areas)
		for(var/obj/structure/window/W in GLOB.areas_by_type[type]) // for in area is slow by refs, but we have a time while in lobby so just to-do-sometime
			W.change_color(color)
		if(wall_trims)
			for(var/turf/closed/wall/wall in GLOB.areas_by_type[type])
				if(wall.wall_trim)
					wall.change_trim_color(color)

/datum/controller/subsystem/station_coloring/proc/get_default_color()
	var/static/default_color = pick(list("#1a356e", "#305a6d", "#164f41"))

	return default_color

/datum/controller/subsystem/station_coloring/proc/recolor_areas()
	var/list/color_palette = list(
		pick(red)          = typesof(/area/station/security),
		pick(purple)       = typesof(/area/station/science),
		pick(green)        = list(/area/station/medical/virology,
		                        /area/station/service/hydroponics),
		pick(blue)         = typesof(/area/station/medical),
		pick(bar)          = list(/area/station/service/bar),
		pick(brown)		   = typesof(/area/station/cargo) + typesof(/area/mine),
		COLOR_WHITE        = typesof(/area/shuttle),
		COLOR_WHITE        = typesof(/area/centcom),
	)

	for(var/color in color_palette)
		color_area_objects(color_palette[color], color)
