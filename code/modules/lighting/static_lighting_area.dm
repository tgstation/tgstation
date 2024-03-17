/// List of plane offset + 1 -> object to display to use
/// Fills with offsets as they are generated
/// Holds a list of objects that represent starlight. The idea is to render_source them
/// So modifying starlight requires touching only one place (NOTE: this doesn't work for the area overlays)
/// In order to modify them you need to use set_starlight. Areas don't work with render sources it looks like
GLOBAL_LIST_INIT_TYPED(starlight_objects, /obj, list(starlight_object(0)))
/obj/starlight_appearance
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	layer = LIGHTING_PRIMARY_LAYER
	blend_mode = BLEND_ADD
	screen_loc = "1,1"

/proc/starlight_object(offset)
	var/obj/starlight_appearance/glow = new()
	SET_PLANE_W_SCALAR(glow, LIGHTING_PLANE, offset)
	glow.layer = LIGHTING_PRIMARY_LAYER
	glow.blend_mode = BLEND_ADD
	glow.color = GLOB.starlight_color
	glow.render_target = SPACE_OVERLAY_RENDER_TARGET(offset)
	return glow

/// List of plane offset + 1 -> mutable appearance to use
/// Fills with offsets as they are generated
/// They mirror their appearance from the starlight objects, which lets us save
/// time updating them
GLOBAL_LIST_INIT_TYPED(starlight_overlays, /obj, list(starlight_overlay(0)))

/proc/starlight_overlay(offset)
	var/mutable_appearance/glow = new /mutable_appearance()
	SET_PLANE_W_SCALAR(glow, LIGHTING_PLANE, offset)
	glow.layer = LIGHTING_PRIMARY_LAYER
	glow.blend_mode = BLEND_ADD
	glow.render_source = SPACE_OVERLAY_RENDER_TARGET(offset)
	return glow

/area
	///Whether this area allows static lighting and thus loads the lighting objects
	var/static_lighting = TRUE

//Non static lighting areas.
//Any lighting area that wont support static lights.
//These areas will NOT have corners generated.

///regenerates lighting objects for turfs in this area, primary use is VV changes
/area/proc/create_area_lighting_objects()
	for(var/turf/T in src)
		if(T.space_lit)
			continue
		T.lighting_build_overlay()
		CHECK_TICK

///Removes lighting objects from turfs in this area if we have them, primary use is VV changes
/area/proc/remove_area_lighting_objects()
	for(var/turf/T in src)
		if(T.space_lit)
			continue
		T.lighting_clear_overlay()
		CHECK_TICK
