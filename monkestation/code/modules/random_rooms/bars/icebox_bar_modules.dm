////////////////
//ABDUCTOR BAR//
////////////////
/turf/closed/wall/mineral/abductor/fake
	desc = "A wall with cheap immitation alien alloy plating."
	sheet_type = /obj/item/stack/sheet/iron

/turf/open/floor/mineral/fake_abductor
	name = "alien floor"
	icon_state = "alienpod1"
	floor_tile = /obj/item/stack/tile/mineral/fake_abductor
	icons = list("alienpod1", "alienpod2", "alienpod3", "alienpod4", "alienpod5", "alienpod6", "alienpod7", "alienpod8", "alienpod9")
	custom_materials = list(/datum/material/iron = 500)

/turf/open/floor/mineral/fake_abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/obj/item/stack/tile/mineral/fake_abductor
	name = "\"alien\" floor tile"
	singular_name = "alien floor tile"
	desc = "A tile made out of cheap immitation alien alloy."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "tile_abductor"
	inhand_icon_state = "tile-abductor"
	mats_per_unit = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*0.25)
	turf_type = /turf/open/floor/mineral/fake_abductor
	mineralType = "iron"
	merge_type = /obj/item/stack/tile/mineral/abductor

/obj/structure/table/fake_abductor
	name = "\"alien\" table"
	desc = "Moderately advanced flat surface technology at work!"
	icon = 'icons/obj/smooth_structures/alien_table.dmi'
	icon_state = "alien_table-0"
	base_icon_state = "alien_table"
	buildstack = /obj/item/stack/sheet/iron //unsure if this will mess with stuff
	framestack = /obj/item/stack/sheet/iron
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_TABLES
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_TABLES

/obj/item/scalpel/fake_alien
	name = "immitation alien scalpel"
	desc = "It's a gleaming sharp knife made out of silvery-green metal... \
			Or at least it looks like it."
	icon = 'icons/obj/abductor.dmi'

/obj/item/hemostat/fake_alien
	name = "immitation alien hemostat"
	desc = "You've never seen this before... \
			Besides in that one ad."
	icon = 'icons/obj/abductor.dmi'

/obj/item/retractor/fake_alien
	name = "immitation alien retractor"
	desc = "You're not sure if you want the veil pulled back... \
			On second thought it already has been."
	icon = 'icons/obj/abductor.dmi'

/obj/item/circular_saw/fake_alien
	name = "immitation alien saw"
	desc = "Do the aliens also lose this, and need to find an alien hatchet? \
			Looks cheaply made."
	icon = 'icons/obj/abductor.dmi'
	force = 13 //this one is less good for combat
	wound_bonus = 10

/obj/item/surgicaldrill/fake_alien
	name = "immitation alien drill"
	desc = "Maybe alien surgeons have finally found a use for the drill... \
			Making it cost more then your rent."
	icon = 'icons/obj/abductor.dmi'

/obj/item/cautery/fake_alien
	name = "immitation alien cautery"
	desc = "Why would bloodless aliens have a tool to stop bleeding? \
			Unless..."
	icon = 'icons/obj/abductor.dmi'

/obj/machinery/chem_dispenser/drinks/fake_abductor
	name = "odd looking soda dispenser"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "chem_dispenser"
	base_icon_state = "chem_dispenser"

/obj/machinery/chem_dispenser/drinks/beer/fake_abductor
	name = "odd looking booze dispenser"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "dispenser"
	base_icon_state = "dispenser"
	pixel_x = 0
	pixel_y = 0

/obj/machinery/door/airlock/fake_abductor
	name = "\"alien\" airlock"
	desc = "With humanity's current technological level, it could take years to hack this advanced airlock... or maybe we should give a screwdriver a try?"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_public
	note_overlay_file = 'icons/obj/doors/airlocks/external/overlays.dmi'

/obj/structure/closet/abductor/fake
	name = "\"alien\" locker"
	desc = "Contains the secrets of the bar."
	material_drop = /obj/item/stack/sheet/iron

/obj/structure/showcase/abductor_console
	name = "\"alien\" console"
	desc = "Used for, something. You're not sure what."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "console"

///////////////
//ARCADE BAR//
///////////////

/obj/machinery/computer/arcade/amputation/bar
	circuit = /obj/item/circuitboard/computer/arcade/amputation/bar
	works_with_slimes = FALSE

/obj/item/circuitboard/computer/arcade/amputation/bar
	build_path = /obj/machinery/computer/arcade/amputation/bar

//SM BAR
/area/station/engineering/supermatter/icebox_bar
	name = "Bar Supermatter"

/area/station/engineering/supermatter/room/icebox_bar
	name = "Bar Supermatter Chamber"
