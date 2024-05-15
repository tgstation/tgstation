/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"
*/

/atom
	/**
	 * used to store the different colors on an atom
	 *
	 * its inherent color, the colored paint applied on it, special color effect etc...
	 */
	var/list/atom_colours

///Adds an instance of colour_type to the atom's atom_colours list
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()


///Removes an instance of colour_type from the atom's atom_colours list
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		return
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()

/**
 * Checks if this atom has the passed color
 * Can optionally be supplied with a range of priorities, IE only checking "washable" or above
 */
/atom/proc/is_atom_colour(looking_for_color, min_priority_index = 1, max_priority_index = COLOUR_PRIORITY_AMOUNT)
	// make sure uppertext hex strings don't mess with LOWER_TEXT hex strings
	looking_for_color = LOWER_TEXT(looking_for_color)

	if(!LAZYLEN(atom_colours))
		// no atom colors list has been set up, just check the color var
		return LOWER_TEXT(color) == looking_for_color

	for(var/i in min_priority_index to max_priority_index)
		if(LOWER_TEXT(atom_colours[i]) == looking_for_color)
			return TRUE

	return FALSE

///Resets the atom's color to null, and then sets it to the highest priority colour available
/atom/proc/update_atom_colour()
	color = null
	if(!atom_colours)
		return
	for(var/checked_color in atom_colours)
		if(islist(checked_color))
			var/list/color_list = checked_color
			if(color_list.len)
				color = color_list
				return
		else if(checked_color)
			color = checked_color
			return
