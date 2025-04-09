/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"

	It can also be used for color filters, since some effects (using non-RGB space matrices)
	are impossible to achieve with just the color variable
*/

/atom
	/**
	 * used to store the different colors on an atom
	 *
	 * its inherent color, the colored paint applied on it, special color effect etc...
	 */
	var/list/atom_colours
	/// Currently used color filter - cached because its applied to all of our overlays because BYOND is horrific
	var/list/cached_color_filter

///Adds an instance of colour_type to the atom's atom_colours list
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	var/color_type = ATOM_COLOR_TYPE_NORMAL
	if (islist(coloration))
		var/list/color_matrix = coloration
		if (color_matrix["type"] == "color")
			color_type = ATOM_COLOR_TYPE_FILTER
	atom_colours[colour_priority] = list(coloration, color_type)
	update_atom_colour()

///Removes an instance of colour_type from the atom's atom_colours list
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		return
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority])
		if (atom_colours[colour_priority][ATOM_COLOR_TYPE_INDEX] == ATOM_COLOR_TYPE_NORMAL)
			if (atom_colours[colour_priority][ATOM_COLOR_VALUE_INDEX] != coloration)
				return //if we don't have the expected color (for a specific priority) to remove, do nothing
		else
			if (!islist(coloration) || !compare_list(coloration, atom_colours[colour_priority][ATOM_COLOR_VALUE_INDEX]["color"]))
				return
	atom_colours[colour_priority] = null
	update_atom_colour()

/**
 * Checks if this atom has the passed color
 * Can optionally be supplied with a range of priorities, IE only checking "washable" or above
 */
/atom/proc/is_atom_colour(looking_for_color, min_priority_index = 1, max_priority_index = COLOUR_PRIORITY_AMOUNT)
	// make sure uppertext hex strings don't mess with LOWER_TEXT hex strings
	if (!islist(looking_for_color))
		looking_for_color = LOWER_TEXT(looking_for_color)

	if(!LAZYLEN(atom_colours))
		// no atom colors list has been set up, just check the color var
		if (!islist(color))
			return LOWER_TEXT(color) == looking_for_color
		if (!islist(looking_for_color))
			return FALSE
		return compare_list(color, looking_for_color)

	for(var/i in min_priority_index to max_priority_index)
		if (!atom_colours[i])
			continue

		if (!islist(looking_for_color))
			if (islist(atom_colours[i][ATOM_COLOR_VALUE_INDEX]))
				continue

			if (LOWER_TEXT(atom_colours[i][ATOM_COLOR_VALUE_INDEX]) == looking_for_color)
				return TRUE

			continue

		var/compared_matrix = atom_colours[i][ATOM_COLOR_VALUE_INDEX]
		if (atom_colours[i][ATOM_COLOR_TYPE_INDEX] == ATOM_COLOR_TYPE_FILTER)
			compared_matrix = atom_colours[i][ATOM_COLOR_VALUE_INDEX]["color"]

		if (compare_list(looking_for_color, compared_matrix))
			return TRUE

	return FALSE

///Resets the atom's color to null, and then sets it to the highest priority colour available
/atom/proc/update_atom_colour()
	var/old_filter = cached_color_filter
	var/old_color = color
	color = null
	cached_color_filter = null
	remove_filter(ATOM_PRIORITY_COLOR_FILTER)
	REMOVE_KEEP_TOGETHER(src, ATOM_COLOR_TRAIT)

	if (!atom_colours)
		if (!(SEND_SIGNAL(src, COMSIG_ATOM_COLOR_UPDATED, old_color || old_filter) & COMPONENT_CANCEL_COLOR_APPEARANCE_UPDATE) && old_filter)
			update_appearance()
		return

	for (var/list/checked_color in atom_colours)
		if (checked_color[ATOM_COLOR_TYPE_INDEX] == ATOM_COLOR_TYPE_FILTER)
			add_filter(ATOM_PRIORITY_COLOR_FILTER, ATOM_PRIORITY_COLOR_FILTER_PRIORITY, checked_color[ATOM_COLOR_VALUE_INDEX])
			cached_color_filter = checked_color[ATOM_COLOR_VALUE_INDEX]
			break

		if (length(checked_color[ATOM_COLOR_VALUE_INDEX]))
			color = checked_color[ATOM_COLOR_VALUE_INDEX]
			break

	ADD_KEEP_TOGETHER(src, ATOM_COLOR_TRAIT)
	if (!(SEND_SIGNAL(src, COMSIG_ATOM_COLOR_UPDATED, old_color != color || old_filter != cached_color_filter) & COMPONENT_CANCEL_COLOR_APPEARANCE_UPDATE) && cached_color_filter != old_filter)
		update_appearance()

/// Same as update_atom_color, but simplifies overlay coloring
/atom/proc/color_atom_overlay(mutable_appearance/overlay)
	overlay.color = color
	if (!cached_color_filter)
		return overlay
	return filter_appearance_recursive(overlay, cached_color_filter)
