///Contains all turf lighting
/atom/movable/screen/plane_master/turf_lighting
	name = "Turf Lighting"
	documentation = "Contains all lighting drawn to turfs. Not so complex, draws directly onto the lighting plate."
	plane = LIGHTING_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_LIGHTING)
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	critical = PLANE_CRITICAL_DISPLAY

/// This will not work through multiz, because of a byond bug with BLEND_MULTIPLY
/// Bug report is up, waiting on a fix
/atom/movable/screen/plane_master/o_light_visual
	name = "Overlight light visual"
	documentation = "Holds overlay lighting objects, or the sort of lighting that's a well, overlay stuck to something.\
		<br>Exists because lighting updating is really slow, and movement needs to feel smooth.\
		<br>We draw to the game plane, and mask out space for ourselves on the lighting plane so any color we have has the chance to display."
	plane = O_LIGHTING_VISUAL_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_target = O_LIGHTING_VISUAL_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY
	critical = PLANE_CRITICAL_DISPLAY

/atom/movable/screen/plane_master/above_lighting
	name = "Above lighting"
	plane = ABOVE_LIGHTING_PLANE
	documentation = "Anything on the game plane that needs a space to draw on that will be above the lighting plane.\
		<br>Mostly little alerts and effects, also sometimes contains things that are meant to look as if they glow."

/**
 * Handles emissive overlays and emissive blockers.
 */
/atom/movable/screen/plane_master/emissive
	name = "Emissive"
	documentation = "Holds things that will be used to mask the lighting plane later on. Masked by the Emissive Mask plane to ensure we don't emiss out under a wall.\
		<br>Relayed onto the Emissive render plane to do the actual masking of lighting, since we need to be transformed and other emissive stuff needs to be transformed too.\
		<br>Don't want to double scale now."
	plane = EMISSIVE_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list(EMISSIVE_RENDER_PLATE)
	critical = PLANE_CRITICAL_DISPLAY
