/*
 * Recipe datum
 * For the actual crafting that uses these datums, see stack.dm
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = 0
	var/on_floor = 0
	var/start_unanchored = 0
	New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0, start_unanchored = 0)
		src.title = title
		src.result_type = result_type
		src.req_amount = req_amount
		src.res_amount = res_amount
		src.max_res_amount = max_res_amount
		src.time = time
		src.one_per_turf = one_per_turf
		src.on_floor = on_floor
		src.start_unanchored = start_unanchored

/datum/stack_recipe/proc/can_build_here(var/mob/usr, var/turf/T)
	if(one_per_turf && locate(result_type) in T)
		to_chat(usr, "<span class='warning'>There is another [title] here!</span>")
		return 0
	if(on_floor && (istype(T, /turf/space)))
		to_chat(usr, "<span class='warning'>\The [title] must be constructed on solid floor!</span>")
		return 0
	return 1

/datum/stack_recipe/proc/finish_building(var/mob/usr, var/obj/item/stack/S, var/R) //This will be called after the recipe is done building, useful for doing something to the result if you want.
	return

//Recipe list datum
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null
	var/req_amount = 1
	New(title, recipes, req_amount = 1)
		src.title = title
		src.recipes = recipes
		src.req_amount = req_amount

/* =====================================================================
							METAL RECIPES
===================================================================== */
/datum/stack_recipe/chair/can_build_here(var/mob/usr, var/turf/T)
	if(one_per_turf)
		for(var/atom/movable/AM in T)
			if(istype(AM, /obj/structure/bed/chair/vehicle)) //Bandaid to allow people in vehicles (and wheelchairs) build chairs
				continue
			else if(istype(AM, /obj/structure/bed/chair))
				to_chat(usr, "<span class='warning'>There is already a chair here!</span>")
				return 0
	if(on_floor && (istype(T, /turf/space)))
		to_chat(usr, "<span class='warning'>\The [title] must be constructed on solid floor!</span>")
		return 0
	return 1

/datum/stack_recipe/conveyor_frame/can_build_here(var/mob/usr, var/turf/T)
	if(one_per_turf)
		for(var/atom/movable/AM in T)
			if(is_type_in_list(AM, list(/obj/machinery/conveyor_assembly, /obj/machinery/conveyor)))
				to_chat(usr, "<span class='warning'>There is already a conveyor belt here!</span>")
				return 0
	if(on_floor && (istype(T, /turf/space)))
		to_chat(usr, "<span class='warning'>\The [title] must be constructed on solid floor!</span>")
		return 0
	return 1

var/global/list/datum/stack_recipe/metal_recipes = list (
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 20),
	new/datum/stack_recipe("metal rod",  /obj/item/stack/rods,          1, 2, 60),
	null,
	new/datum/stack_recipe("computer frame", /obj/structure/computerframe,                      5, time = 25, one_per_turf = 1			    ),
	new/datum/stack_recipe("wall girders",   /obj/structure/girder,                             2, time = 50, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("machine frame",  /obj/machinery/constructable_frame/machine_frame,  5, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("mirror frame",   /obj/structure/mirror_frame,                       5, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("turret frame",   /obj/machinery/porta_turret_construct,             5, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe/conveyor_frame("conveyor frame", /obj/machinery/conveyor_assembly,   5, time = 25, one_per_turf = 1, on_floor = 1),
	null,
	new/datum/stack_recipe_list("chairs and beds",list(
		new/datum/stack_recipe/chair("dark office chair",  /obj/structure/bed/chair/office/dark,  5, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("light office chair", /obj/structure/bed/chair/office/light, 5, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("beige comfy chair",  /obj/structure/bed/chair/comfy/beige,  2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("black comfy chair",  /obj/structure/bed/chair/comfy/black,  2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("brown comfy chair",  /obj/structure/bed/chair/comfy/brown,  2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("lime comfy chair",   /obj/structure/bed/chair/comfy/lime,   2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("teal comfy chair",   /obj/structure/bed/chair/comfy/teal,   2, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe/chair("stool",              /obj/item/weapon/stool												   ),
		new/datum/stack_recipe/chair("bar stool",          /obj/item/weapon/stool/bar                                              ),
		new/datum/stack_recipe/chair("chair",              /obj/structure/bed/chair,                 one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("bed",                      /obj/structure/bed,                    2, one_per_turf = 1, on_floor = 1),
		)),
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts,                           2                                ),
	new/datum/stack_recipe("rack parts",  /obj/item/weapon/rack_parts                                                              ),
	new/datum/stack_recipe("closet",      /obj/structure/closet,                                  2, one_per_turf = 1, time = 15   ),
	null,
	new/datum/stack_recipe_list("airlock assemblies", list(
		new/datum/stack_recipe("standard airlock assembly",      /obj/structure/door_assembly,                            4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("command airlock assembly",       /obj/structure/door_assembly/door_assembly_com,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("security airlock assembly",      /obj/structure/door_assembly/door_assembly_sec,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("engineering airlock assembly",   /obj/structure/door_assembly/door_assembly_eng,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("mining airlock assembly",        /obj/structure/door_assembly/door_assembly_min,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("atmospherics airlock assembly",  /obj/structure/door_assembly/door_assembly_atmo,         4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("research airlock assembly",      /obj/structure/door_assembly/door_assembly_research,     4, time = 50, one_per_turf = 1, on_floor = 1),
/*		new/datum/stack_recipe("science airlock assembly",       /obj/structure/door_assembly/door_assembly_science,      4, time = 50, one_per_turf = 1, on_floor = 1), */
		new/datum/stack_recipe("medical airlock assembly",       /obj/structure/door_assembly/door_assembly_med,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("maintenance airlock assembly",   /obj/structure/door_assembly/door_assembly_mai,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("external airlock assembly",      /obj/structure/door_assembly/door_assembly_ext,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("freezer airlock assembly",       /obj/structure/door_assembly/door_assembly_fre,          4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("airtight hatch assembly",        /obj/structure/door_assembly/door_assembly_hatch,        4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("maintenance hatch assembly",     /obj/structure/door_assembly/door_assembly_mhatch,       4, time = 50, one_per_turf = 1, on_floor = 1),
		new/datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 4, time = 50, one_per_turf = 1, on_floor = 1),
/*		new/datum/stack_recipe("multi-tile airlock assembly",    /obj/structure/door_assembly/multi_tile,                 4, time = 50, one_per_turf = 1, on_floor = 1), */
		), 4),
	null,
	new/datum/stack_recipe("canister",        /obj/machinery/portable_atmospherics/canister, 10, time = 15, one_per_turf = 1			  ),
	new/datum/stack_recipe("iv drip",         /obj/machinery/iv_drip,                         2, time = 25, one_per_turf = 1			  ),
	new/datum/stack_recipe("meat spike",      /obj/structure/kitchenspike,                    2, time = 25, one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("grenade casing",  /obj/item/weapon/grenade/chem_grenade                                                       ),
	new/datum/stack_recipe("desk bell shell", /obj/item/device/deskbell_assembly,             2                                           ),
	null,
	new/datum/stack_recipe_list("mounted frames", list(
		new/datum/stack_recipe("apc frame",                 /obj/item/mounted/frame/apc_frame,            2                                           ),
		new/datum/stack_recipe("air alarm frame",           /obj/item/mounted/frame/alarm_frame,          2                                           ),
		new/datum/stack_recipe("fire alarm frame",          /obj/item/mounted/frame/firealarm,            2                                           ),
		new/datum/stack_recipe("lightswitch frame",         /obj/item/mounted/frame/light_switch,         2                                           ),
		new/datum/stack_recipe("intercom frame",            /obj/item/mounted/frame/intercom,             2                                           ),
		new/datum/stack_recipe("sound system frame",		/obj/item/mounted/frame/soundsystem,		  2											  ),
		new/datum/stack_recipe("nanomed frame",             /obj/item/mounted/frame/wallmed,              3, time = 25, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("light fixture frame",       /obj/item/mounted/frame/light_fixture,        2                                           ),
		new/datum/stack_recipe("small light fixture frame", /obj/item/mounted/frame/light_fixture/small,  1                                           ),
		new/datum/stack_recipe("embedded controller frame", /obj/item/mounted/frame/airlock_controller,   1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("access button frame",       /obj/item/mounted/frame/access_button,        1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("airlock sensor frame",      /obj/item/mounted/frame/airlock_sensor,       1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("mass driver button frame",  /obj/item/mounted/frame/driver_button,        1, time = 50, one_per_turf = 0, on_floor = 1),
		new/datum/stack_recipe("lantern hook",              /obj/item/mounted/frame/hanging_lantern_hook, 1, time = 25, one_per_turf = 0, on_floor = 0),
		)),
	null,
	new/datum/stack_recipe("iron door", /obj/machinery/door/mineral/iron, 					20, 			one_per_turf = 1, on_floor = 1),
	new/datum/stack_recipe("stove", /obj/machinery/space_heater/campfire/stove, 			5, time = 25, 	one_per_turf = 1, on_floor = 1),
	)

/* ========================================================================
							PLASTEEL RECIPES
======================================================================== */
var/global/list/datum/stack_recipe/plasteel_recipes = list (
	new/datum/stack_recipe("AI core",						/obj/structure/AIcore,								4,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Metal crate",					/obj/structure/closet/crate,						10,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Cage",							/obj/structure/cage,								6,  time = 100, one_per_turf = 1				),
	new/datum/stack_recipe("RUST fuel assembly port frame",	/obj/item/mounted/frame/rust_fuel_assembly_port,	12,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("RUST fuel compressor frame",	/obj/item/mounted/frame/rust_fuel_compressor,		12,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Mass Driver frame",				/obj/machinery/mass_driver_frame,					3,	time = 50,	one_per_turf = 1				),
	new/datum/stack_recipe("Tank dispenser",				/obj/structure/dispenser/empty,						2,	time = 10,	one_per_turf = 1				),
	new/datum/stack_recipe("Fireaxe cabinet",				/obj/item/mounted/frame/fireaxe_cabinet_frame,		2,	time = 50									),
	null,
	new/datum/stack_recipe("Vault Door assembly",			/obj/structure/door_assembly/door_assembly_vault,	8,	time = 50,	one_per_turf = 1,	on_floor = 1),
	)

/* ====================================================================
							WOOD RECIPES
==================================================================== */
var/global/list/datum/stack_recipe/wood_recipes = list (
	new/datum/stack_recipe("wooden sandals",	/obj/item/clothing/shoes/sandal																),
	new/datum/stack_recipe("wood floor tile",	/obj/item/stack/tile/wood,				1,4,20												),
	new/datum/stack_recipe("table parts",		/obj/item/weapon/table_parts/wood,		2													),
	new/datum/stack_recipe("wooden chair",		/obj/structure/bed/chair/wood/normal,	3,		time = 10,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("barricade kit",		/obj/item/weapon/barricade_kit,			5													),
	new/datum/stack_recipe("bookcase",			/obj/structure/bookcase,				5,		time = 50,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("wooden door",		/obj/machinery/door/mineral/wood,		10,		time = 20,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("coffin",			/obj/structure/closet/coffin,			5,		time = 15,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("apiary",			/obj/item/apiary,						10,		time = 25,	one_per_turf = 0,	on_floor = 0),
	new/datum/stack_recipe("bowl",				/obj/item/trash/bowl,					1													),
	new/datum/stack_recipe("notice board",		/obj/structure/noticeboard,				2,		time = 15,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("blank canvas",		/obj/item/mounted/frame/painting/blank,	2,		time = 15									),
	new/datum/stack_recipe("campfire",			/obj/machinery/space_heater/campfire,	4,		time = 35,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("spit",				/obj/machinery/cooking/grill/spit,		1,		time = 10,	one_per_turf = 1,	on_floor = 1),
	new/datum/stack_recipe("wall girders",		/obj/structure/girder/wood,				2, 		time = 50, 	one_per_turf = 1, 	on_floor = 1),
	new/datum/stack_recipe("boomerang",			/obj/item/weapon/boomerang,				6,		time = 50),
	new/datum/stack_recipe("buckler",			/obj/item/weapon/shield/riot/buckler,	5,		time = 50),
	)

/* =========================================================================
							CARDBOARD RECIPES
========================================================================= */
var/global/list/datum/stack_recipe/cardboard_recipes = list (
	new/datum/stack_recipe("box",				/obj/item/weapon/storage/box							),
	new/datum/stack_recipe("large box",			/obj/item/weapon/storage/box/large,					4	),
	new/datum/stack_recipe("light tubes box",	/obj/item/weapon/storage/box/lights/tubes				),
	new/datum/stack_recipe("light bulbs box",	/obj/item/weapon/storage/box/lights/bulbs				),
	new/datum/stack_recipe("mouse traps box",	/obj/item/weapon/storage/box/mousetraps					),
	new/datum/stack_recipe("candle box",		/obj/item/weapon/storage/fancy/candle_box/empty			),
	new/datum/stack_recipe("crayon box",		/obj/item/weapon/storage/fancy/crayons/empty			),
	new/datum/stack_recipe("cardborg suit",		/obj/item/clothing/suit/cardborg,					3	),
	new/datum/stack_recipe("cardborg helmet",	/obj/item/clothing/head/cardborg						),
	new/datum/stack_recipe("pizza box",			/obj/item/pizzabox										),
	new/datum/stack_recipe("folder",			/obj/item/weapon/folder									),
	new/datum/stack_recipe("flare box",			/obj/item/weapon/storage/fancy/flares/empty				),
	new/datum/stack_recipe("donut box",			/obj/item/weapon/storage/fancy/donut_box/empty			),
	new/datum/stack_recipe("eggbox",			/obj/item/weapon/storage/fancy/egg_box/empty			),
	new/datum/stack_recipe("paper bin",			/obj/item/weapon/paper_bin/empty						),
	)
