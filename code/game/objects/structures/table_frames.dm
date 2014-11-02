/* Table Frames
 * Contains:
 *		Frames
 *		Wooden Frames
 *		Reinforced Frames
 */


/*
 * Normal Frames
 */

/obj/structure/table_frame
	name = "table frame"
	desc = "Four metal legs with four framing rods for a table. You could easily pass through this."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table_frame"
	density = 0
	anchored = 0
	layer = 2.8

/obj/structure/table_frame/attackby()

/*
 * Wooden Frames
 */

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"

 /*
 * Reinforced Frames
 */

/obj/structure/table_frame/reinforced
	name = "reinforced table frame"
	desc = "Four metal legs with four framing rods for a table. They seem especially reinforced."
	icon_state = "reinforced_frame"
	density = 1
	anchored = 1
	throwpass = 1