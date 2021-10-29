//////////////////////
//		Walls		//
//////////////////////

/turf/closed/indestructible/dungeon
	name = "stone wall"
	desc = "Cold stone walls. It's like a dungeon."
	icon = 'modular_skyrat/modules/mapping/icons/unique/dungeon.dmi'
	icon_state = "wall"
	base_icon_state = "wall"
	explosion_block = INFINITY

/turf/closed/indestructible/dungeon/corner
	icon_state = "wall-corner"
	base_icon_state = "wall-corner"

//////////////////////
//       Turfs       //
//////////////////////

/turf/open/floor/plating/cobblestone
	gender = PLURAL
	name = "cobblestone"
	desc = "Cobbled stone that makes a permanent pathway. A bit old-fashioned."
	icon = 'modular_skyrat/modules/mapping/icons/unique/dungeon.dmi'
	icon_state = "cobble"
	planetary_atmos = FALSE

/turf/open/floor/plating/cobblestone/planet
	baseturfs = /turf/open/floor/plating/dirt/planet
	planetary_atmos = TRUE

/turf/open/floor/plating/cobblestone/dungeon
	icon_state = "cobble-dungeon"
	baseturfs = /turf/open/floor/plating/cobblestone/dungeon
	planetary_atmos = FALSE

// This one has a rocky texture to it.
/turf/open/floor/plating/cobblestone/sparse
	icon_state = "cobble_sparse"
	baseturfs = /turf/open/floor/plating/cobblestone/sparse

/turf/open/floor/plating/cobblestone/sparse/planet
	icon_state = "cobble_sparse"
	baseturfs = /turf/open/floor/plating/cobblestone/sparse/planet
	planetary_atmos = TRUE

//////////////////////
//    Fake Walls    //
//////////////////////

/obj/structure/dungeon
	name = "stone wall with a hole in it!"
	desc = "A hole in the wall! It's small."
	icon = 'modular_skyrat/modules/mapping/icons/unique/dungeon.dmi'
	icon_state = "wall-hole"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/dungeon/doorway
	name = "doorway"
	desc = "A doorway fashioned into a stone wall. It's a tight fit."
	icon = 'modular_skyrat/modules/mapping/icons/unique/dungeon.dmi'
	icon_state = "wall-doorway"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/railing/stone/Initialize()
	.=..()
	if(dir == 2)
		layer = ABOVE_MOB_LAYER
	else
		return

/obj/structure/railing/stone
	name = "stone wall"
	desc = "Cobbled stone wall. This is pretty strong."
	icon = 'modular_skyrat/modules/mapping/icons/unique/dungeon.dmi'
	icon_state = "cobble-wall"
	max_integrity = 100
	density = TRUE
	anchored = TRUE
	climbable = TRUE

/obj/structure/railing/stone/attackby(obj/item/wrench, mob/living/user, params)
	to_chat(user, "<span class='notice'>You frown as you realise this wall is in fact made of stone, and cannot be uprooted from the ground and dragged along with a mere wrench.</span>")
	return

/obj/structure/railing/stone/left
	icon_state = "cobble-wall-left"
	density = FALSE
	climbable = FALSE

/obj/structure/railing/stone/right
	icon_state = "cobble-wall-right"
	density = FALSE
	climbable = FALSE

/obj/structure/mineral_door/dungeon
	name = "wooden door"
	desc = "A small wooden door. It probably still opens, but it's kind of small."
	icon = 'modular_skyrat/modules/mapping/icons/unique/dungeon.dmi'
	icon_state = "wall-door"
	openSound = 'sound/effects/doorcreaky.ogg'
	closeSound = 'sound/effects/doorcreaky.ogg'
	sheetType = /obj/item/stack/sheet/mineral/wood
	max_integrity = 100

/obj/machinery/button/dungeon
	name = "stone brick"
	desc = "A brick that's stuck out of the wall. Huh."
	icon = 'modular_skyrat/modules/mapping/icons/unique/dungeon.dmi'
	icon_state = "doorctrl"
	power_channel = AREA_USAGE_ENVIRON
	use_power = NO_POWER_USE
	idle_power_usage = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/button/dungeon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, "<span class='notice'>You prod around the rim of the bricks and try and jam it in. Looks like it isn't coming out this way.</span>")
		return
// Let's not open the maintenance panel of a stone brick.
