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

/turf/closed/wall/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(wall_trim)
		if(istype(attacking_item, /obj/item/airlock_painter/decal))
			var/obj/item/airlock_painter/decal/new_painter = attacking_item
			if(user.istate & ISTATE_SECONDARY)
				if(new_painter.stored_custom_color)
					change_trim_color(new_painter.stored_custom_color)
			else
				if(new_painter.stored_custom_color)
					change_paint_color(new_painter.stored_custom_color)

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
	update_appearance()

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
