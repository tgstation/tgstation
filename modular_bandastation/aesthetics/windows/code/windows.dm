#define WINDOW_COLOR "#99BBFF"
#define PLASMA_WINDOW_COLOR "#C800FF"
#define TINTED_WINDOW_COLOR "#5A6E82"
#define EDGE_OVERLAY_COLOR "#4f4f4f"

// MARK: Windows
/obj/structure/window
	icon = 'modular_bandastation/aesthetics/windows/icons/directional.dmi'
	icon_state = "window"
	color = WINDOW_COLOR
	layer = ABOVE_WINDOW_LAYER + 0.05
	/// Used to define what file the edging sprite is contained within
	var/edge_overlay_file
	/// Used to define the color of the edging
	var/edge_overlay_color = EDGE_OVERLAY_COLOR
	/// Tracks the edging appearence sprite
	var/mutable_appearance/edge_overlay

/obj/structure/window/update_overlays(updates=ALL)
	. = ..()
	if(!edge_overlay_file)
		return
	edge_overlay = mutable_appearance(edge_overlay_file, "edge-[smoothing_junction]", layer + 0.01, appearance_flags = RESET_COLOR | KEEP_APART)
	edge_overlay.color = edge_overlay_color
	. += edge_overlay

/obj/structure/window/reinforced
	icon_state = "r_window"

/obj/structure/window/reinforced/tinted
	icon_state = "r_window"
	color = TINTED_WINDOW_COLOR

/obj/structure/window/reinforced/tinted/frosted
	icon_state = "r_window"

/obj/structure/window/reinforced/tinted/Initialize(mapload, direct)
	. = ..()
	flags_1 |= UNPAINTABLE_1

/obj/structure/window/plasma
	icon_state = "window"
	color = PLASMA_WINDOW_COLOR

/obj/structure/window/plasma/Initialize(mapload, direct)
	. = ..()
	flags_1 |= UNPAINTABLE_1

/obj/structure/window/reinforced/plasma
	icon_state = "r_window"
	color = PLASMA_WINDOW_COLOR

/obj/structure/window/reinforced/plasma/Initialize(mapload, direct)
	. = ..()
	flags_1 |= UNPAINTABLE_1

// Delete colors
/obj/structure/window/bronze
	color = null

/obj/structure/window/paperframe
	color = null

/obj/structure/window/reinforced/shuttle
	color = null

/obj/structure/window/reinforced/survival_pod
	color = null

/obj/structure/window/reinforced/plasma/plastitanium
	color = null

/**
 * Рамки окон но как отдельный объект.
 * НЕ ИСПОЛЬЗОВАТЬ!!!
 *
 * Только для рендера карт.
 */
/obj/structure/window/fulltile/frame
	name = "DONT USE THIS"
	icon = 'icons/bandastation/windows/window_edges.dmi'
	icon_state = "edge-0"
	base_icon_state = "edge"
	color = EDGE_OVERLAY_COLOR

/obj/structure/window/reinforced/fulltile/frame
	name = "DONT USE THIS"
	icon = 'icons/bandastation/windows/reinforced_window_edges.dmi'
	icon_state = "edge-0"
	base_icon_state = "edge"
	color = EDGE_OVERLAY_COLOR

/obj/structure/window/fulltile
	icon = 'icons/bandastation/windows/window.dmi'
	edge_overlay_file = 'icons/bandastation/windows/window_edges.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	color = WINDOW_COLOR

/obj/structure/window/reinforced/fulltile
	icon = 'icons/bandastation/windows/reinforced_window.dmi'
	edge_overlay_file = 'icons/bandastation/windows/reinforced_window_edges.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	color = WINDOW_COLOR

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'icons/bandastation/windows/reinforced_window.dmi'
	edge_overlay_file = 'icons/bandastation/windows/reinforced_window_edges.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	flags_1 = UNPAINTABLE_1
	color = TINTED_WINDOW_COLOR

/obj/structure/window/plasma/fulltile
	icon = 'icons/bandastation/windows/window.dmi'
	edge_overlay_file = 'icons/bandastation/windows/window_edges.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	flags_1 = UNPAINTABLE_1
	color = PLASMA_WINDOW_COLOR

/obj/structure/window/reinforced/plasma/fulltile
	icon = 'icons/bandastation/windows/reinforced_window.dmi'
	edge_overlay_file = 'icons/bandastation/windows/reinforced_window_edges.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	flags_1 = UNPAINTABLE_1
	color = PLASMA_WINDOW_COLOR

/obj/structure/window/reinforced/fulltile/ice
	edge_overlay_file = null

// MARK: Spawners
/obj/effect/spawner/structure/window
	icon = 'modular_bandastation/aesthetics/windows/icons/spawners.dmi'

/obj/effect/spawner/structure/window
	spawn_list = MAP_SWITCH(list(/obj/structure/grille, /obj/structure/window/fulltile), list(/obj/structure/grille, /obj/structure/window/fulltile, /obj/structure/window/fulltile/frame))

/obj/effect/spawner/structure/window/reinforced
	spawn_list = MAP_SWITCH(list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile), list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/fulltile/frame))

/obj/effect/spawner/structure/window/reinforced/tinted
	spawn_list = MAP_SWITCH(list(/obj/structure/grille, /obj/structure/window/reinforced/tinted/fulltile), list(/obj/structure/grille, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/reinforced/fulltile/frame))

/obj/effect/spawner/structure/window/plasma
	spawn_list = MAP_SWITCH(list(/obj/structure/grille, /obj/structure/window/plasma/fulltile), list(/obj/structure/grille, /obj/structure/window/plasma/fulltile, /obj/structure/window/fulltile/frame))

/obj/effect/spawner/structure/window/reinforced/plasma
	spawn_list = MAP_SWITCH(list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/fulltile), list(/obj/structure/grille, /obj/structure/window/reinforced/plasma/fulltile, /obj/structure/window/reinforced/fulltile/frame))

/obj/effect/spawner/structure/window/reinforced/indestructible
	spawn_list = MAP_SWITCH(list(/obj/structure/grille/indestructible, /obj/structure/window/reinforced/fulltile/indestructible), list(/obj/structure/grille/indestructible, /obj/structure/window/reinforced/fulltile/indestructible, /obj/structure/window/reinforced/fulltile/frame))

// Override to original
/obj/effect/spawner/structure/window/bronze
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/hollow
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/ice
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/survival_pod
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/reinforced/shuttle
	icon = 'icons/obj/structures_spawners.dmi'

/obj/effect/spawner/structure/window/reinforced/plasma/plastitanium
	icon = 'icons/obj/structures_spawners.dmi'

// MARK: Indestructible windows
/turf/closed/indestructible/fakeglass
	icon = 'icons/bandastation/windows/reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	color = WINDOW_COLOR
	/// Used to define what file the edging sprite is contained within
	var/edge_overlay_file = 'icons/bandastation/windows/reinforced_window_edges.dmi'
	/// Tracks the edging appearence sprite
	var/mutable_appearance/edge_overlay

/turf/closed/indestructible/fakeglass/smooth_icon()
	..()
	update_icon(UPDATE_OVERLAYS)

/turf/closed/indestructible/fakeglass/update_icon_state()
	. = ..()
	if(smoothing_flags & SMOOTH_BITMASK)
		QUEUE_SMOOTH(src)

/turf/closed/indestructible/fakeglass/update_overlays()
	. = ..()
	if(!edge_overlay_file)
		return
	edge_overlay = mutable_appearance(edge_overlay_file, "edge-[smoothing_junction]", layer + 0.1, appearance_flags = RESET_COLOR | KEEP_APART)
	. += edge_overlay

/turf/closed/indestructible/fakeglass/plasma
	flags_1 = UNPAINTABLE_1
	color = PLASMA_WINDOW_COLOR

/turf/closed/indestructible/fakeglass/unreinforced
	icon = 'icons/bandastation/windows/window.dmi'
	edge_overlay_file = 'icons/bandastation/windows/window_edges.dmi'
	icon_state = "window-0"
	base_icon_state = "window"

/turf/closed/indestructible/fakeglass/unreinforced/plasma
	flags_1 = UNPAINTABLE_1
	color = PLASMA_WINDOW_COLOR
