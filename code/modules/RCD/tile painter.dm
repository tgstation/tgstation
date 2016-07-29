/obj/item/device/rcd/tile_painter
	name				= "tile painter"
	desc				= "A device used to paint floors in various colours and fashions."

	icon_state			= "rpd" //placeholder art, someone please sprite it

	starting_materials	= list(MAT_IRON = 75000, MAT_GLASS = 37500)

	origin_tech			= "engineering=2;materials=1"

	sparky				= 0

	schematics = list(/datum/rcd_schematic/clear_decals)

/obj/item/device/rcd/tile_painter/New()
	schematics += typesof(/datum/rcd_schematic/tile)
	. = ..()
