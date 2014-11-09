/* Diffrent misc types of sheets
 * Contains:
 *		Metal
 *		Plasteel
 *		Wood
 *		Cloth
 *		Cardboard
 */

/*
 * Metal
 */
var/global/list/datum/stack_recipe/metal_recipes = list ( \
	new/datum/stack_recipe("stool", /obj/structure/stool, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("chair", /obj/structure/stool/bed/chair, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bed", /obj/structure/stool/bed, 2, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe_list("office chairs",list( \
		new/datum/stack_recipe("dark office chair",  /obj/structure/stool/bed/chair/office/dark, 5, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("light office chair", /obj/structure/stool/bed/chair/office/light, 5, one_per_turf = 1, on_floor = 1), \
		), 5), \
	new/datum/stack_recipe_list("comfy chairs", list( \
		new/datum/stack_recipe("beige comfy chair", /obj/structure/stool/bed/chair/comfy/beige, 2, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("black comfy chair", /obj/structure/stool/bed/chair/comfy/black, 2, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("brown comfy chair", /obj/structure/stool/bed/chair/comfy/brown, 2, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("lime comfy chair",  /obj/structure/stool/bed/chair/comfy/lime,  2, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("teal comfy chair",  /obj/structure/stool/bed/chair/comfy/teal,  2, one_per_turf = 1, on_floor = 1), \
		), 2), \
	null, \
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts, 2), \
	new/datum/stack_recipe("rack parts", /obj/item/weapon/rack_parts), \
	new/datum/stack_recipe("closet", /obj/structure/closet, 2, time = 15, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("canister", /obj/machinery/portable_atmospherics/canister, 10, time = 15, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 20), \
	new/datum/stack_recipe("metal rod", /obj/item/stack/rods, 1, 2, 60), \
	null, \
	new/datum/stack_recipe("computer frame", /obj/structure/computerframe, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("wall girders", /obj/structure/girder, 2, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("machine frame",/obj/machinery/constructable_frame/machine_frame, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("turret frame", /obj/machinery/porta_turret_construct, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("iv drip",      /obj/machinery/iv_drip,                            2, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("meat spike",   /obj/structure/kitchenspike,                       2, time = 25, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe_list("airlock assemblies", list( \
		new/datum/stack_recipe("standard airlock assembly",      /obj/structure/door_assembly,                            4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("command airlock assembly",       /obj/structure/door_assembly/door_assembly_com,          4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("security airlock assembly",      /obj/structure/door_assembly/door_assembly_sec,          4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("engineering airlock assembly",   /obj/structure/door_assembly/door_assembly_eng,          4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("mining airlock assembly",        /obj/structure/door_assembly/door_assembly_min,          4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("atmospherics airlock assembly",  /obj/structure/door_assembly/door_assembly_atmo,         4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("research airlock assembly",      /obj/structure/door_assembly/door_assembly_research,     4, time = 50, one_per_turf = 1, on_floor = 1), \
/*		new/datum/stack_recipe("science airlock assembly",       /obj/structure/door_assembly/door_assembly_science,      4, time = 50, one_per_turf = 1, on_floor = 1), \ */
		new/datum/stack_recipe("medical airlock assembly",       /obj/structure/door_assembly/door_assembly_med,          4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("maintenance airlock assembly",   /obj/structure/door_assembly/door_assembly_mai,          4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("external airlock assembly",      /obj/structure/door_assembly/door_assembly_ext,          4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("freezer airlock assembly",       /obj/structure/door_assembly/door_assembly_fre,          4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("airtight hatch assembly",        /obj/structure/door_assembly/door_assembly_hatch,        4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("maintenance hatch assembly",     /obj/structure/door_assembly/door_assembly_mhatch,       4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 4, time = 50, one_per_turf = 1, on_floor = 1), \
/*		new/datum/stack_recipe("multi-tile airlock assembly",    /obj/structure/door_assembly/multi_tile,                 4, time = 50, one_per_turf = 1, on_floor = 1), \ */
		), 4), \
	null, \
	new/datum/stack_recipe("embedded controller frame",          /obj/item/airlock_controller_frame,                      1, time = 50, one_per_turf = 0, on_floor = 1), \
	new/datum/stack_recipe("access button frame",                /obj/item/access_button_frame,                           1, time = 50, one_per_turf = 0, on_floor = 1), \
	new/datum/stack_recipe("airlock sensor frame",               /obj/item/airlock_sensor_frame,                           1, time = 50, one_per_turf = 0, on_floor = 1), \
	null, \
	new/datum/stack_recipe("grenade casing", /obj/item/weapon/grenade/chem_grenade), \
	new/datum/stack_recipe("light fixture frame", /obj/item/light_fixture_frame, 2), \
	new/datum/stack_recipe("small light fixture frame", /obj/item/light_fixture_frame/small, 1), \
	null, \
	new/datum/stack_recipe("apc frame", /obj/item/apc_frame, 2), \
	new/datum/stack_recipe("air alarm frame", /obj/item/alarm_frame, 2), \
	new/datum/stack_recipe("fire alarm frame", /obj/item/firealarm_frame, 2), \
	null, \
	new/datum/stack_recipe("iron door", /obj/structure/mineral_door/iron, 20, one_per_turf = 1, on_floor = 1), \
)

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out off metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	m_amt = 3750
	w_type = RECYK_METAL
	throwforce = 14.0
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "materials=1"
	melt_temperature = MELTPOINT_STEEL

/obj/item/stack/sheet/metal/recycle(var/datum/materials/rec)
	rec.addAmount("iron",1*amount)
	return 1

// Diet metal.
/obj/item/stack/sheet/metal/cyborg
	m_amt = 0

/obj/item/stack/sheet/metal/New(var/loc, var/amount=null)
	recipes = metal_recipes
	return ..()


/*
 * Plasteel
 */
var/global/list/datum/stack_recipe/plasteel_recipes = list ( \
	new/datum/stack_recipe("AI core", /obj/structure/AIcore, 4, time = 50, one_per_turf = 1), \
	new/datum/stack_recipe("Metal crate", /obj/structure/closet/crate, 10, time = 50, one_per_turf = 1), \
	new/datum/stack_recipe("RUST fuel assembly port frame", /obj/item/rust_fuel_assembly_port_frame, 12, time = 50, one_per_turf = 1), \
	new/datum/stack_recipe("RUST fuel compressor frame", /obj/item/rust_fuel_compressor_frame, 12, time = 50, one_per_turf = 1), \
	)

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-plasteel"
	m_amt = 3750 // Was 7500, which doesn't make any fucking sense
	perunit = 2875 //average of plasma and metal
	throwforce = 15.0
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "materials=2"
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL+500

/obj/item/stack/sheet/plasteel/New(var/loc, var/amount=null)
		recipes = plasteel_recipes
		return ..()

/obj/item/stack/sheet/plasteel/recycle(var/datum/materials/rec)
	rec.addAmount("plasma",1*amount)
	rec.addAmount("iron",1*amount)
	return 1

/*
 * Wood
 */
var/global/list/datum/stack_recipe/wood_recipes = list ( \
	new/datum/stack_recipe("wooden sandals", /obj/item/clothing/shoes/sandal, 1), \
	new/datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20), \
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts/wood, 2), \
	new/datum/stack_recipe("wooden chair", /obj/structure/stool/bed/chair/wood/normal, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("barricade kit", /obj/item/weapon/barricade_kit, 5), \
	new/datum/stack_recipe("bookcase", /obj/structure/bookcase, 5, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 20, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("apiary", /obj/item/apiary, 10, time = 25, one_per_turf = 0, on_floor = 0), \
	)

/obj/item/stack/sheet/wood
	name = "wooden planks"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	origin_tech = "materials=1;biotech=1"
	autoignition_temperature=AUTOIGNITION_WOOD

/obj/item/stack/sheet/wood/cultify()
	return

/obj/item/stack/sheet/wood/New(var/loc, var/amount=null)
	recipes = wood_recipes
	return ..()

/*
 * Cloth
 */
/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "This roll of cloth is made from only the finest chemicals and bunny rabbits."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = "materials=2"

/*
 * Cardboard
 */
var/global/list/datum/stack_recipe/cardboard_recipes = list ( \
	new/datum/stack_recipe("box", /obj/item/weapon/storage/box), \
	new/datum/stack_recipe("large box", /obj/item/weapon/storage/box/large, 4), \
	new/datum/stack_recipe("light tubes", /obj/item/weapon/storage/box/lights/tubes), \
	new/datum/stack_recipe("light bulbs", /obj/item/weapon/storage/box/lights/bulbs), \
	new/datum/stack_recipe("mouse traps", /obj/item/weapon/storage/box/mousetraps), \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg), \
	new/datum/stack_recipe("pizza box", /obj/item/pizzabox), \
	new/datum/stack_recipe("folder", /obj/item/weapon/folder), \
)

/obj/item/stack/sheet/cardboard	//BubbleWrap
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	flags = FPRINT | TABLEPASS
	origin_tech = "materials=1"

/obj/item/stack/sheet/cardboard/New(var/loc, var/amount=null)
		recipes = cardboard_recipes
		return ..()

/*
 * /vg/ charcoal
 */
var/global/list/datum/stack_recipe/charcoal_recipes = list ()

/obj/item/stack/sheet/charcoal	//N3X15
	name = "charcoal"
	desc = "Yum."
	singular_name = "charcoal sheet"
	icon_state = "sheet-charcoal"
	flags = FPRINT | TABLEPASS
	origin_tech = "materials=1"
	autoignition_temperature=AUTOIGNITION_WOOD

/obj/item/stack/sheet/charcoal/New(var/loc, var/amount=null)
		recipes = charcoal_recipes
		return ..()
