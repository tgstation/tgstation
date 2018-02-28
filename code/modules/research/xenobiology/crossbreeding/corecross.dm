//////////////////////////////////////////////
//////////     SLIME CROSSBREEDS    //////////
//////////////////////////////////////////////
// A system of combining two extract types. //
// Performed by feeding a slime 20 of an    //
// extract color.                           //
//////////////////////////////////////////////
/*==========================================*\
To add a crossbreed:
	The file name is automatically selected
	by the crossbreeding effect, which uses
	the format slimecross/[modifier]/[color].

	If a crossbreed doesn't exist, don't
	worry. If no file is found at that
	location, it will simple display that
	the crossbreed was too unstable.

	As a result, do not feel the need to
	try to add all of the crossbred
	effects at once, if you're here and
	trying to make a new slime type. Just
	get your slimetype in the codebase and
	get around to the crossbreeds eventually!
\*==========================================*/

/obj/item/slimecross //The base type for crossbred extracts. Mostly here for posterity, and to set base case things.
	name = "crossbred slime extract"
	desc = "An extremely potent slime extract, formed through crossbreeding."
	var/colour = "null"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6

/obj/item/slimecross/Initialize()
	..()
	name = colour + " " + name

/obj/item/slimecross/beaker //To be used as a result for extract reactions that make chemicals.
	name = "result extract"
	desc = "You shouldn't see this."
	container_type = INJECTABLE | DRAWABLE
