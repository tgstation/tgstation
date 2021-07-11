/// Updates the combat mode vignette depending on the mob's current combat mode state
/mob/living/proc/update_combat_mode_vignette()
	if (!client?.prefs?.toggle_combat_mode_vignette)
		return

	if (isnull(combat_mode_vignette_corners))
		if (!combat_mode)
			return

		combat_mode_vignette_corners = create_combat_mode_vignette_corners()

	// We set icon state rather than disabling the UI so the animation resets
	// Note that this only works because the icon state isn't set to "loop", but instead just
	// to a really high number.
	for (var/atom/movable/screen/combat_mode_vignette_corner/corner as anything in combat_mode_vignette_corners)
		if (combat_mode)
			corner.icon_state = initial(corner.icon_state)
		else
			corner.icon_state = ""

	client?.screen |= combat_mode_vignette_corners

/// Creates the corners for the combat mode vignette
/proc/create_combat_mode_vignette_corners()
	var/list/corners = list()

	var/atom/movable/screen/top_left_corner = new /atom/movable/screen/combat_mode_vignette_corner
	top_left_corner.screen_loc = "WEST,CENTER"
	corners += top_left_corner

	var/atom/movable/screen/top_right_corner = new /atom/movable/screen/combat_mode_vignette_corner
	top_right_corner.transform = top_right_corner.transform.Scale(-1, 1)
	top_right_corner.screen_loc = "CENTER,CENTER"
	corners += top_right_corner

	var/atom/movable/screen/bottom_left_corner = new /atom/movable/screen/combat_mode_vignette_corner
	bottom_left_corner.transform = bottom_left_corner.transform.Scale(1, -1)
	bottom_left_corner.screen_loc = "WEST,SOUTH"
	corners += bottom_left_corner

	var/atom/movable/screen/bottom_right_corner = new /atom/movable/screen/combat_mode_vignette_corner
	bottom_right_corner.transform = bottom_right_corner.transform.Scale(-1, -1)
	bottom_right_corner.screen_loc = "CENTER,SOUTH"
	corners += bottom_right_corner

	return corners

/// A corner for the combat mode vignette
/atom/movable/screen/combat_mode_vignette_corner
	icon = 'icons/hud/combat_mode.dmi'
	icon_state = "corner"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 150
	plane = FULLSCREEN_PLANE
	layer = COMBAT_MODE_VIGNETTE_LAYER
