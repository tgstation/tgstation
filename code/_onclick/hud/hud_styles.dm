GLOBAL_LIST_INIT_TYPED(available_hud_styles, /datum/hud_style, generate_available_hud_styles())
GLOBAL_DATUM(default_hud_style, /datum/hud_style)

/// The base for separate HUDs
/datum/hud_style
	/// The name of the UI style, to show in menus
	var/name

	/// The background color, if this HUD should use greyscaling
	var/background_color

	/// The accent color, if this HUD should use greyscaling
	var/accent_color

	/// The base icon, if this HUD should NOT use greyscaling
	var/base_icon

	var/cached_hud_icon
	var/cached_hud_icon_colors

/// Returns an icon for the left hand, for preferences menu
/datum/hud_style/proc/hand_icon(suffix)
	return icon(hud_icon(), "hand_[suffix]")

/// Returns the greyscale_color for this HUD style, if this is greyscale
/datum/hud_style/proc/greyscale_colors()
	if (!isnull(base_icon))
		CRASH("greyscale_colors() should only be called on greyscale HUDs")

	return "[background_color][accent_color]"

/// Returns the icon to use for this HUD.
/// Guaranteed to return the same result with the same greyscale_colors, such that hud_icon() == hud_icon().
/datum/hud_style/proc/hud_icon()
	if (!isnull(base_icon))
		return base_icon

	var/new_colors = greyscale_colors()
	if (cached_hud_icon_colors == new_colors)
		return cached_hud_icon

	cached_hud_icon = SSgreyscale.GetColoredIconByType(/datum/greyscale_config/hud, greyscale_colors())
	cached_hud_icon_colors = new_colors
	return cached_hud_icon

/proc/generate_available_hud_styles()
	var/list/available_hud_styles = list()

	for (var/datum/hud_style/hud_style as anything in subtypesof(/datum/hud_style))
		available_hud_styles[initial(hud_style.name)] = new hud_style

	// Doing this instead of a define so that it's a compile error if midnight is gone
	var/datum/hud_style/midnight/midnight = /datum/hud_style/midnight
	GLOB.default_hud_style = available_hud_styles[initial(midnight.name)]

	return available_hud_styles

/datum/hud_style/midnight
	name = "Midnight"
	background_color = "#2B2B33"
	accent_color = "#6d91ac"

/datum/hud_style/plasmafire
	name = "Plasmafire"
	background_color = "#21213D"
	accent_color = "#ffb61a"

/datum/hud_style/slimecore
	name = "Slimecore"
	background_color = "#2B3834"
	accent_color = "#44984E"

/datum/hud_style/operative
	name = "Operative"
	background_color = "#3D2127"
	accent_color = "#9C1E1B"

/datum/hud_style/clockwork
	name = "Clockwork"
	background_color = "#896B19"
	accent_color = "#f14f34"

/datum/hud_style/glass
	name = "Glass"
	base_icon = 'icons/hud/screen_glass.dmi'

/datum/hud_style/trasenknox
	name = "Trasen-Knox"
	base_icon = 'icons/hud/screen_trasenknox.dmi'

/datum/hud_style/retro
	name = "Retro"
	base_icon = 'icons/hud/screen_retro.dmi'
