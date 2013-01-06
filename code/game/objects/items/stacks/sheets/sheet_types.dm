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
	new/datum/stack_recipe("swivel chair", /obj/structure/stool/bed/chair/office/dark, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("comfy chair", /obj/structure/stool/bed/chair/comfy/beige, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bed", /obj/structure/stool/bed, 2, one_per_turf = 1, on_floor = 1), \
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
	new/datum/stack_recipe("airlock assembly", /obj/structure/door_assembly, 4, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("machine frame", /obj/machinery/constructable_frame/machine_frame, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("turret frame", /obj/machinery/porta_turret_construct, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("apc frame", /obj/item/apc_frame, 2), \
	new/datum/stack_recipe("grenade casing", /obj/item/weapon/grenade/chem_grenade), \
	new/datum/stack_recipe("light fixture frame", /obj/item/light_fixture_frame, 2), \
	new/datum/stack_recipe("small light fixture frame", /obj/item/light_fixture_frame/small, 1), \
	null, \
	new/datum/stack_recipe("iron door", /obj/structure/mineral_door/iron, 20, one_per_turf = 1, on_floor = 1), \
)

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out off metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	m_amt = 3750
	throwforce = 14.0
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "materials=1"

/obj/item/stack/sheet/metal/cyborg
	name = "metal"
	desc = "Sheets made out off metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	m_amt = 0
	throwforce = 14.0
	flags = FPRINT | TABLEPASS | CONDUCT

/obj/item/stack/sheet/metal/New(var/loc, var/amount=null)
	recipes = metal_recipes
	return ..()


/*
 * Plasteel
 */
var/global/list/datum/stack_recipe/plasteel_recipes = list ( \
	new/datum/stack_recipe("AI core", /obj/structure/AIcore, 4, time = 50, one_per_turf = 1), \
	)

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	m_amt = 7500
	throwforce = 15.0
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "materials=2"

/obj/item/stack/sheet/plasteel/New(var/loc, var/amount=null)
		recipes = plasteel_recipes
		return ..()

/*
 * Wood
 */
var/global/list/datum/stack_recipe/wood_recipes = list ( \
	new/datum/stack_recipe("wooden sandals", /obj/item/clothing/shoes/sandal, 1), \
	new/datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20), \
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts/wood, 2), \
	new/datum/stack_recipe("wooden chair", /obj/structure/stool/bed/chair/wood/normal, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 20, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 15, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/wood
	name = "wooden planks"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	origin_tech = "materials=1;biotech=1"

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
	new/datum/stack_recipe("light tubes", /obj/item/weapon/storage/lightbox/tubes), \
	new/datum/stack_recipe("light bulbs", /obj/item/weapon/storage/lightbox/bulbs), \
	new/datum/stack_recipe("mouse traps", /obj/item/weapon/storage/mousetraps), \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg), \
	new/datum/stack_recipe("pizza box", /obj/item/pizzabox), \
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