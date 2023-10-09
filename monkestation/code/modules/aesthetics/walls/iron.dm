/turf/closed/wall
	icon = 'monkestation/icons/turf/walls/wall.dmi'
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	smooth_adapters = SMOOTH_ADAPTERS_WALLS_FOR_WALLS
	var/wall_trim = 'monkestation/icons/turf/walls/wall_trim.dmi'
	var/trim_color
	var/list/managed_wall_trim = list()
	var/list/managed_wall_paint = list()
	var/paint_color

/turf/closed/wall/proc/change_trim_color(color)
	trim_color = color
	update_appearance()

/turf/closed/wall/proc/change_paint_color(color)
	paint_color = color
	update_appearance()

/turf/closed/wall/update_appearance()
	. = ..()
	if(wall_trim)
		cut_overlay(managed_wall_trim)
		managed_wall_trim = list()
		var/image/new_trim = image("icon" = wall_trim, "icon_state" = icon_state, "layer" = src.layer + 0.02)
		new_trim.color = trim_color
		managed_wall_trim += new_trim
		add_overlay(managed_wall_trim)
	if(paint_color)
		cut_overlay(managed_wall_paint)
		managed_wall_paint = list()
		var/image/new_trim = image("icon" = icon, "icon_state" = icon_state, "layer" = src.layer + 0.01)
		new_trim.color = paint_color
		managed_wall_paint += new_trim
		add_overlay(managed_wall_paint)

/turf/closed/wall/smooth_icon()
	. = ..()
	if(wall_trim)
		cut_overlay(managed_wall_trim)
		managed_wall_trim = list()
		var/image/new_trim = image("icon" = wall_trim, "icon_state" = icon_state, "layer" = src.layer + 0.02)
		new_trim.color = trim_color
		managed_wall_trim += new_trim
		add_overlay(managed_wall_trim)
	if(paint_color)
		cut_overlay(managed_wall_paint)
		managed_wall_paint = list()
		var/image/new_trim = image("icon" = icon, "icon_state" = icon_state, "layer" = src.layer + 0.01)
		new_trim.color = paint_color
		managed_wall_paint += new_trim
		add_overlay(managed_wall_paint)

/turf/closed/wall/r_wall
	icon = 'monkestation/icons/turf/walls/reinforced_wall.dmi'
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	wall_trim = 'monkestation/icons/turf/walls/reinforced_wall_trim.dmi'

/obj/structure/falsewall
	icon = 'monkestation/icons/turf/walls/wall.dmi'
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	///pulled from the wall
	var/wall_trim = 'monkestation/icons/turf/walls/wall_trim.dmi'
	var/trim_color

/obj/structure/falsewall/reinforced
	icon = 'monkestation/icons/turf/walls/reinforced_wall.dmi'
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
	///pulled from the wall
	wall_trim = 'monkestation/icons/turf/walls/reinforced_wall_trim.dmi'


/turf/closed/indestructible/riveted
	icon = 'monkestation/icons/turf/walls/reinforced_wall.dmi'
	base_icon_state = "reinforced_wall"
	icon_state = "reinforced_wall-0"
	smoothing_groups = SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
