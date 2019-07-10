/datum/material
	var/name = "material"
	var/desc = "its..stuff."
	var/id = "mat"
	var/color // hex value goes here
	var/list/categories = list() //Materials "Traits". its a map of key = category | Value = Bool
	var/sheet_type = null //This should be replaced as soon as possible by greyscale sheets.
	var/coin_type = null//This should be replaced as soon as possible by greyscale coins.
	var/wall_override //Icon state override for walls, appeases the WJohn.
	var/floor_override //Icon state override for floors, appeases the WJohn.


/datum/material/proc/on_applied(atom/source, amount, should_color = TRUE) //What happens to the object that has this material?
	source.desc += "<br><u>It is made out of [name]</u>."
	if(should_color && color) //Do we have a custom color?
		source.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
	return
