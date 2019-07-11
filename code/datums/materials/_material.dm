/*! Material datum

Simple datum which is instanced once per type and is used for every object of said material. It has a variety of variables that define behavior. Subtyping from this makes it easier to create your own materials. 

*/


/datum/material
	var/name = "material"
	var/desc = "its..stuff."
	//Var that's mostly used by science machines to identify specific materials, should most likely be phased out at some point
	var/id = "mat"
	///Base color of the material, is used for greyscale. Item isn't changed in color if this is null.
	var/color
	///Base alpha of the material, is used for greyscale icons.
	var/alpha
	///Materials "Traits". its a map of key = category | Value = Bool. Used to define what it can be used for.gold
	var/list/categories = list()
	///The type of sheet this material creates. This should be replaced as soon as possible by greyscale sheets.
	var/sheet_type = null
	///The type of coin this material spawns. This should be replaced as soon as possible by greyscale coins.
	var/coin_type = null
	///Icon state override for walls, appeases the WJohn.
	var/wall_override
	///Icon state override for floors, appeases the WJohn.
	var/floor_override
	///This is a modifier for both force and integrity, and resembles the strength of the material
	var/strength = 1

///This proc is called when the material is added to an object. mapload exists mostly to prevent the removal of mapped in variables.
/datum/material/proc/on_applied(atom/source, amount, mapload = FALSE)
	source.desc += "<br><u>It is made out of [name]</u>."
	if(!mapload) //Prevent changing mapload icons, to keep colored toolboxes their looks.
		if(color) //Do we have a custom color?
			source.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		if(alpha)
			source.alpha = alpha

	if(istype(source, /obj)) //objs
		on_applied_obj(source, amount, mapload)
	return

///This proc is called when the material is added to an item specifically.
/datum/material/proc/on_applied_obj(var/obj/o, amount, mapload)
	if(!mapload)
		o.max_integrity = o.max_integrity *= strength
		o.obj_integrity = o.max_integrity
		o.force = o.force *= strength
		o.throwforce = o.throwforce *= strength