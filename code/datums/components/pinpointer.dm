/datum/component/pinpointer
	/// Distance thresholds for arrow colours.
	var/green_range = 5
	var/yellow_range = 10
	var/orange_range = 15

	/// How long the arrow remains visible.
	var/arrow_duration = 1.5 SECONDS

/datum/component/pinpointer/Initialize()
	. = ..()

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

/atom/movable/screen/pinpointer_arrow
	icon = 'icons/effects/96x96.dmi'
	icon_state = "multitool_arrow"
	pixel_x = -32
	pixel_y = -32
	screen_loc = around_player

/atom/movable/screen/pinpointer_arrow/Destroy()
	var/datum/hud/our_hud = hud
	. = ..()

	if(!QDELETED(our_hud))
		INVOKE_ASYNC(our_hud, TYPE_PROC_REF(/datum/hud, show_hud), our_hud.hud_version)

/datum/component/pinpointer/proc/get_arrow_color(distance)
	if(distance <= green_range)
		return COLOR_GREEN
	else if(distance <= yellow_range)
		return COLOR_YELLOW
	else if(distance <= orange_range)
		return COLOR_ORANGE
	else
		return COLOR_RED

/// Displays a directional arrow pointing towards the target.
/datum/component/pinpointer/proc/point_to(mob/user, atom/target)
	if(!user || !target || QDELETED(target))
		return

	var/distance = get_dist(parent, target)

	if(!distance)
		return 0

	var/angle = get_angle(user, target)
	var/datum/hud/user_hud = user.hud_used

	if(!user_hud)
		return distance

	var/atom/movable/screen/pinpointer_arrow/arrow = user_hud.add_screen_object(
		/atom/movable/screen/pinpointer_arrow,
		HUD_MULTITOOL_ARROW,
		HUD_GROUP_INFO,
		update_screen = TRUE,
	)

	arrow.color = get_arrow_color(distance)
	arrow.transform = matrix(angle, MATRIX_ROTATE)

	QDEL_IN(arrow, arrow_duration)

	return distance
