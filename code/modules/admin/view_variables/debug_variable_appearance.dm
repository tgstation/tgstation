/* 	< OH MY GOD. Can't you just make "/image/proc/foo()" instead of making these? >
 * 		/appearance is a hardcoded byond type, and it is very internal type.
 *		Its type is actually /image, but it isn't truly /image. We defined it as "/appearance"
 * 		new procs to /image will only work to actual /image references, but...
 * 		/appearance references are not capable of executing procs, because these are not real /image
 * 		This is why these global procs exist. Welcome to the curse.
 */
#define ADD_UNUSED_VAR(varlist, thing, varname) if(NAMEOF(##thing, ##varname)) ##varlist += #varname
#define RESULT_VARIABLE_NOT_FOUND "_switch_result_variable_not_found"

/// An alias datum that allows us to access and view the variables of an appearance by keeping certain known, yet undocumented, variables that we can access and read in a datum for debugging purposes.
/// Kindly do not use this outside of a debugging context.
/image/appearance
	parent_type = /atom/movable // This is necessary to access the variables on compile-time.

	// var/override // Sad point. We can't steal byond internal variable name
#ifdef OPENDREAM
	// opendream doens't support mouse_drop_zone yet. Remove this once OD supports it.
	var/mouse_drop_zone
#endif

/image/appearance/New(loc, ...)
	. = ..()
	CRASH("something tried to use '/image/appearance', but this isn't actual type we use. Do not fucking do this.")

/// Makes a var list of /appearance type actually uses. This will be only called once.
/proc/build_virtual_appearance_vars()
	var/list/used_variables = list("vis_flags") // manual listing.
	. = used_variables
	var/list/unused_var_names = list()

	var/image/appearance/nameof_reference // We don't copy vars from this.
	pass(nameof_reference) // compiler complains unused variable
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, appearance) // it only does self-reference
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, x) // xyz are always 0
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, y)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, z)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, weak_reference) // it's not a good idea to make a weak_ref on this, and this won't have it
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, vars) // inherited from /image, but /appearance hasn't this

	// Even if these vars are essential for image, these only exists in an actual type
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, filter_data)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, realized_overlays)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, realized_underlays)

	// we have no reason to show these, right?
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, _active_timers)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, _datum_components)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, _listen_lookup)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, _signal_procs)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, __auxtools_weakref_id)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, _status_traits)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, cooldowns)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, datum_flags)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, verbs)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, gc_destroyed)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, harddel_deets_dumped)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, open_uis)
	ADD_UNUSED_VAR(unused_var_names, nameof_reference, tgui_shared_states)

	var/image/dummy_image = image(null, null) // actual type we'll copy variable names
	for(var/each in dummy_image.vars) // try to inherit var list from /image
		if(each in unused_var_names)
			continue
		used_variables += each
	del(dummy_image)
	dummy_image = null

	return used_variables

/// debug_variable() proc but made for /appearance type specifically
/proc/debug_variable_appearance(var_name, appearance)
	var/value
	try
		value = locate_appearance_variable(var_name, appearance)
	catch
		return "<li style='backgroundColor:white'>(READ ONLY) <font color='blue'>[var_name] = (untrackable)</font></li>"
	if(value == RESULT_VARIABLE_NOT_FOUND)
		return "<li style='backgroundColor:white'>(READ ONLY) [var_name] <font color='blue'>(Undefined var name in switch)</font></li>"
	return "<li style='backgroundColor:white'>(READ ONLY) [var_name] = [_debug_variable_value(var_name, value, 0, appearance, sanitize = TRUE, display_flags = NONE)]</li>"

/// manually locate a variable through string value.
/// appearance type needs a manual var referencing because it doesn't have "vars" variable internally.
/// There's no way doing this in a fancier way.
/proc/locate_appearance_variable(var_name, image/appearance/appearance) // WARN: /image/appearance is a mocking type, not real one
	switch(var_name) // Welcome to this curse
		// appearance doesn't have "vars" variable.
		// This means you need to target a variable manually through this way.

		// appearance vars in DM document
		if(NAMEOF(appearance, alpha))
			return appearance.alpha
		if(NAMEOF(appearance, appearance_flags))
			return appearance.appearance_flags
		if(NAMEOF(appearance, blend_mode))
			return appearance.blend_mode
		if(NAMEOF(appearance, color))
			return appearance.color
		if(NAMEOF(appearance, desc))
			return appearance.desc
		if(NAMEOF(appearance, gender))
			return appearance.gender
		if(NAMEOF(appearance, icon))
			return appearance.icon
		if(NAMEOF(appearance, icon_state))
			return appearance.icon_state
		if(NAMEOF(appearance, invisibility))
			return appearance.invisibility
		if(NAMEOF(appearance, infra_luminosity))
			return appearance.infra_luminosity
		if(NAMEOF(appearance, filters))
			return appearance.filters
		if(NAMEOF(appearance, layer))
			return appearance.layer
		if(NAMEOF(appearance, luminosity))
			return appearance.luminosity
		if(NAMEOF(appearance, maptext))
			return appearance.maptext
		if(NAMEOF(appearance, maptext_width))
			return appearance.maptext_width
		if(NAMEOF(appearance, maptext_height))
			return appearance.maptext_height
		if(NAMEOF(appearance, maptext_x))
			return appearance.maptext_x
		if(NAMEOF(appearance, maptext_y))
			return appearance.maptext_y
		if(NAMEOF(appearance, mouse_over_pointer))
			return appearance.mouse_over_pointer
		if(NAMEOF(appearance, mouse_drag_pointer))
			return appearance.mouse_drag_pointer
		if(NAMEOF(appearance, mouse_drop_pointer))
			return appearance.mouse_drop_pointer
		if(NAMEOF(appearance, mouse_drop_zone))
			return appearance:mouse_drop_zone
		if(NAMEOF(appearance, mouse_opacity))
			return appearance.mouse_opacity
		if(NAMEOF(appearance, name))
			return appearance.name
		if(NAMEOF(appearance, opacity))
			return appearance.opacity
		if(NAMEOF(appearance, overlays))
			return appearance.overlays
		if("override") // only /image has this. mocking type can't steal byond internal var name
			var/image/image_appearance = appearance
			return image_appearance.override
		if(NAMEOF(appearance, pixel_x))
			return appearance.pixel_x
		if(NAMEOF(appearance, pixel_y))
			return appearance.pixel_y
		if(NAMEOF(appearance, pixel_w))
			return appearance.pixel_w
		if(NAMEOF(appearance, pixel_z))
			return appearance.pixel_z
		if(NAMEOF(appearance, plane))
			return appearance.plane
		if(NAMEOF(appearance, render_source))
			return appearance.render_source
		if(NAMEOF(appearance, render_target))
			return appearance.render_target
		if(NAMEOF(appearance, suffix))
			return appearance.suffix
		if(NAMEOF(appearance, text))
			return appearance.text
		if(NAMEOF(appearance, transform))
			return appearance.transform
		if(NAMEOF(appearance, underlays))
			return appearance.underlays

		if(NAMEOF(appearance, parent_type))
			return appearance.parent_type
		if(NAMEOF(appearance, type))
			return /image/appearance // don't fool people

		// These are not documented ones but trackable values. Maybe we'd want these.
		if(NAMEOF(appearance, animate_movement))
			return appearance.animate_movement
		if(NAMEOF(appearance, dir))
			return appearance.dir
		if(NAMEOF(appearance, glide_size))
			return appearance.glide_size
		if("pixel_step_size")
			return "" //atom_appearance.pixel_step_size
			// DM compiler complains this

		// I am not sure if these will be ever detected, but I made a connection just in case.
		if(NAMEOF(appearance, contents)) // It's not a thing, but I don't believe how DM will change /appearance in future.
			return appearance.contents
		if(NAMEOF(appearance, loc)) // same reason above
			return appearance.loc
		if(NAMEOF(appearance, vis_contents)) // same reason above
			return appearance.vis_contents
		if(NAMEOF(appearance, vis_flags)) // DM document says /appearance has this, but it throws error
			return appearance.vis_flags

		// we wouldn't need these, but let's these trackable anyway...
		if(NAMEOF(appearance, density))
			return appearance.density
		if(NAMEOF(appearance, screen_loc))
			return appearance.screen_loc
		if(NAMEOF(appearance, verbs))
			return appearance.verbs
		if(NAMEOF(appearance, tag))
			return appearance.tag
	return RESULT_VARIABLE_NOT_FOUND

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
	// Don't add any vv option carelessly unless you have a good reason to add one for /appearance.
	// /appearance type shouldn't allow general options. Even "Mark Datum" is a questionable behaviour here.
	VV_DROPDOWN_OPTION_APPEARANCE(thing, "", "---")
	VV_DROPDOWN_OPTION_APPEARANCE(thing, VV_HK_EXPOSE, "Show VV To Player") // only legit option
	return .

#undef ADD_UNUSED_VAR
#undef RESULT_VARIABLE_NOT_FOUND
