//Contains all weather overlays
/atom/movable/screen/plane_master/weather_overlay
	name = "weather overlay master"
	plane = WEATHER_OVERLAY_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = WEATHER_RENDER_TARGET
	render_relay_planes = list() //Used as alpha filter for weather_effect fullscreen
	allows_offsetting = FALSE
	critical = PLANE_CRITICAL_DISPLAY


/atom/movable/screen/plane_master/weather_overlay/eclipse
	name = "weather overlay master eclipse z"
	plane = WEATHER_OVERLAY_PLANE_ECLIPSE
	render_target = WEATHER_ECLIPSE_RENDER_TARGET

/atom/movable/screen/plane_master/weather_overlay/check_outside_bounds()
	return FALSE

//Contains the weather effect itself
/atom/movable/screen/plane_master/weather_effect
	name = "weather effect plane master"
	plane = WEATHER_EFFECT_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_planes = list(RENDER_PLANE_GAME)
	allows_offsetting = FALSE
	critical = PLANE_CRITICAL_DISPLAY
	var/z_type = "Default"

/atom/movable/screen/plane_master/weather_effect/Initialize()
	. = ..()
	//filters += filter(type="alpha", render_source=WEATHER_RENDER_TARGET)
	if(SSoutdoor_effects.enabled)
		SSoutdoor_effects.weather_planes_need_vis |= src

/atom/movable/screen/plane_master/weather_effect/Destroy()
	. = ..()
	SSoutdoor_effects.weather_planes_need_vis -= src

/atom/movable/screen/plane_master/weather_effect/check_outside_bounds()
	return FALSE

/atom/movable/screen/plane_master/weather_effect/misc
	name = "weather effect misc plane master"
	plane = WEATHER_EFFECT_PLANE_MISC
	z_type = "Misc"

/atom/movable/screen/plane_master/weather_effect/eclipse
	name = "weather effect eclipse plane master"
	plane = WEATHER_EFFECT_PLANE_ECLIPSE
	z_type = "Eclipse"

//Contains all sunlight overlays
/atom/movable/screen/plane_master/sunlight
	name = "sunlight plane master"
	plane = SUNLIGHTING_PLANE
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = SUNLIGHTING_RENDER_TARGET
	render_relay_planes = list()  //Used as layer filter for sunlight fullscreen
	critical = PLANE_CRITICAL_DISPLAY
