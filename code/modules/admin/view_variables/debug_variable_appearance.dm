/* 	< OH MY GOD. Can't you just make "/image/proc/foo()" instead of making these? >
 * 		/appearance is a hardcoded byond type, and it is very internal type.
 *		Its type is actually /image, but it isn't truly /image. We defined it as "/appearance"
 * 		new procs to /image will only work to actual /image references, but...
 * 		/appearance references are not capable of executing procs, because these are not real /image
 * 		This is why these global procs exist. Welcome to the curse.
 */
/// Makes a var list of /appearance type actually uses. This will be only called once.
/proc/build_virtual_appearance_vars()
	. = list("vis_flags") // manual listing.
	var/list/unused_var_names = list(
		"appearance", // it only does self-reference
		"x","y","z", // these are always 0
		"weak_reference", // it's not a good idea to make a weak_ref on this, and this won't have it
		"vars", // inherited from /image, but /appearance hasn't this

		// Even if these vars are essential for image, these only exists in an actual type
		"filter_data", 
		"realized_overlays",
		"realized_underlays",
				
		// we have no reason to show these, right?
		"_active_timers",
		"_datum_components",
		"_listen_lookup",
		"_signal_procs",
		"__auxtools_weakref_id",
		"_status_traits",
		"cooldowns",
		"datum_flags",
		"visibility",
		"verbs",
		"gc_destroyed",
		"harddel_deets_dumped",
		"open_uis",
		"tgui_shared_states"
		)
	var/image/dummy_image = image(null, null)
	for(var/each in dummy_image.vars) // try to inherit var list from /image
		if(each in unused_var_names)
			continue
		. += each
	del(dummy_image)
	dummy_image = null

/// appearance type needs a manual var referencing because it doesn't have "vars" variable internally.
/// There's no way doing this in a fancier way.
/proc/debug_variable_appearance(var_name, appearance)
	var/value
	try
		switch(var_name) // Welcome to this curse
			// appearance doesn't have "vars" variable.
			// This means you need to target a variable manually through this way.

			// appearance vars in DM document
			if("alpha")
				value = appearance:alpha
			if("appearance_flags")
				value = appearance:appearance_flags
			if("blend_mode")
				value = appearance:blend_mode
			if("color")
				value = appearance:color
			if("desc")
				value = appearance:desc
			if("gender")
				value = appearance:gender
			if("icon")
				value = appearance:icon
			if("icon_state")
				value = appearance:icon_state
			if("invisibility")
				value = appearance:invisibility
			if("infra_luminosity")
				value = appearance:infra_luminosity
			if("filters")
				value = appearance:filters
			if("layer")
				value = appearance:layer
			if("luminosity")
				value = appearance:luminosity
			if("maptext")
				value = appearance:maptext
			if("maptext_width")
				value = appearance:maptext_width
			if("maptext_height")
				value = appearance:maptext_height
			if("maptext_x")
				value = appearance:maptext_x
			if("maptext_y")
				value = appearance:maptext_y
			if("mouse_over_pointer")
				value = appearance:mouse_over_pointer
			if("mouse_drag_pointer")
				value = appearance:mouse_drag_pointer
			if("mouse_drop_pointer")
				value = appearance:mouse_drop_pointer
			if("mouse_drop_zone")
				value = appearance:mouse_drop_zone
			if("mouse_opacity")
				value = appearance:mouse_opacity
			if("name")
				value = appearance:name
			if("opacity")
				value = appearance:opacity
			if("overlays")
				value = appearance:overlays
			if("override")
				value = appearance:override
			if("pixel_x")
				value = appearance:pixel_x
			if("pixel_y")
				value = appearance:pixel_y
			if("pixel_w")
				value = appearance:pixel_w
			if("pixel_z")
				value = appearance:pixel_z
			if("plane")
				value = appearance:plane
			if("render_source")
				value = appearance:render_source
			if("render_target")
				value = appearance:render_target
			if("suffix")
				value = appearance:suffix
			if("text")
				value = appearance:text
			if("transform")
				value = appearance:transform
			if("underlays")
				value = appearance:underlays

			if("parent_type")
				value = appearance:parent_type
			if("type")
				value = "/appearance (as [appearance:type])" // don't fool people

			// These are not documented ones but trackable values. Maybe we'd want these.
			if("animate_movement")
				value = appearance:animate_movement
			if("dir")
				value = appearance:dir
			if("glide_size")
				value = appearance:glide_size
			if("pixel_step_size")
				value = "" //atom_appearance:pixel_step_size
				// DM compiler complains this

			// I am not sure if these will be ever detected, but I made a connection just in case.
			if("contents")
				value = appearance:contents
			if("vis_contents")
				value = appearance:vis_contents
			if("vis_flags") // DM document says /appearance has this, but it throws error
				value = appearance:vis_flags
			if("loc")
				value = appearance:loc

			// we wouldn't need these, but let's these trackable anyway...
			if("density")
				value = appearance:density
			if("screen_loc")
				value = appearance:screen_loc
			if("verbs")
				value = appearance:verbs
			if("tag")
				value = appearance:tag

			else
				return "<li style='backgroundColor:white'>(READ ONLY) [var_name] <font color='blue'>(Undefined var name in switch)</font></li>"
	catch
		return "<li style='backgroundColor:white'>(READ ONLY) <font color='blue'>[var_name] = (untrackable)</font></li>"
	return "<li style='backgroundColor:white'>(READ ONLY) [var_name] = [_debug_variable_value(var_name, value, 0, appearance, sanitize = TRUE, display_flags = NONE)]</li>"

/// Shows a header name on top when you investigate an appearance
/proc/vv_get_header_appearance(image/thing)
	. = list()
	var/icon_name = "<b>[thing.icon || "null"]</b><br/>"
	. += replacetext(icon_name, "icons/obj", "") // shortens the name. We know the path already.
	if(thing.icon)
		. += thing.icon_state ? "\"[thing.icon_state]\"" : "(icon_state = null)"

/image/vv_get_header() // it should redirect to global proc version because /appearance can't call a proc, unless we want dupe code here
	return vv_get_header_appearance(src)

/// Makes a format name for shortened vv name.
/proc/get_appearance_vv_summary_name(image/thing)
	var/icon_file_name = thing.icon ? splittext("[thing.icon]", "/") : "null"
	if(islist(icon_file_name))
		icon_file_name = length(icon_file_name) ? icon_file_name[length(icon_file_name)] : "null"
	if(thing.icon_state)
		return "[icon_file_name]:[thing.icon_state]"
	else
		return "[icon_file_name]"

/proc/vv_get_dropdown_appearance(image/thing)
	. = list()
	// unless you have a good reason to add a vv option for /appearance,
	// /appearance type shouldn't alloow any vv option. Even "Mark Datum" is a questionable behaviour here.
	VV_DROPDOWN_OPTION_APPEARANCE(thing, "", "---")
	VV_DROPDOWN_OPTION_APPEARANCE(thing, "", "VV option not allowed")
