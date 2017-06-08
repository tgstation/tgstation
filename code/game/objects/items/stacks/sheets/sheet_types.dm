/* Diffrent misc types of sheets
 * Contains:
 * Metal
 * Plasteel
 * Wood
 * Cloth
 * Plastic
 * Cardboard
 * Runed Metal (cult)
 * Brass (clockwork cult)
 */

/*
 * Metal
 */
GLOBAL_LIST_INIT(metal_recipes, list ( \
	new/datum/stack_recipe("stool", /obj/structure/chair/stool, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bar stool", /obj/structure/chair/stool/bar, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("chair", /obj/structure/chair, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("swivel chair", /obj/structure/chair/office/dark, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("comfy chair", /obj/structure/chair/comfy/beige, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bed", /obj/structure/bed, 2, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("rack parts", /obj/item/weapon/rack_parts), \
	new/datum/stack_recipe("closet", /obj/structure/closet, 2, time = 15, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("canister", /obj/machinery/portable_atmospherics/canister, 10, time = 15, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 20), \
	new/datum/stack_recipe("metal rod", /obj/item/stack/rods, 1, 2, 60), \
	null, \
	new/datum/stack_recipe("wall girders", /obj/structure/girder, 2, time = 40, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("computer frame", /obj/structure/frame/computer, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("modular console", /obj/machinery/modular_computer/console/buildable/, 10, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("machine frame", /obj/structure/frame/machine, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("airlock assembly", /obj/structure/door_assembly, 4, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("firelock frame", /obj/structure/firelock_frame, 3, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("turret frame", /obj/machinery/porta_turret_construct, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("meatspike frame", /obj/structure/kitchenspike_frame, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("reflector frame", /obj/structure/reflector, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("grenade casing", /obj/item/weapon/grenade/chem_grenade), \
	new/datum/stack_recipe("light fixture frame", /obj/item/wallframe/light_fixture, 2), \
	new/datum/stack_recipe("small light fixture frame", /obj/item/wallframe/light_fixture/small, 1), \
	null, \
	new/datum/stack_recipe("apc frame", /obj/item/wallframe/apc, 2), \
	new/datum/stack_recipe("air alarm frame", /obj/item/wallframe/airalarm, 2), \
	new/datum/stack_recipe("fire alarm frame", /obj/item/wallframe/firealarm, 2), \
	new/datum/stack_recipe("extinguisher cabinet frame", /obj/item/wallframe/extinguisher_cabinet, 2), \
	new/datum/stack_recipe("button frame", /obj/item/wallframe/button, 1), \
	null, \
	new/datum/stack_recipe("iron door", /obj/structure/mineral_door/iron, 20, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("floodlight frame", /obj/structure/floodlight_frame, 5, one_per_turf = 1, on_floor = 1), \
))

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out of metal."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)
	throwforce = 10
	flags = CONDUCT
	origin_tech = "materials=1"
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/metal

/obj/item/stack/sheet/metal/ratvar_act()
	new /obj/item/stack/tile/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/metal/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/sheet/metal/fifty
	amount = 50

/obj/item/stack/sheet/metal/twenty
	amount = 20

/obj/item/stack/sheet/metal/five
	amount = 5

/obj/item/stack/sheet/metal/cyborg
	materials = list()
	is_cyborg = 1
	cost = 500

/obj/item/stack/sheet/metal/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.metal_recipes
	return ..()

/*
 * Plasteel
 */
GLOBAL_LIST_INIT(plasteel_recipes, list ( \
	new/datum/stack_recipe("AI core", /obj/structure/AIcore, 4, time = 50, one_per_turf = 1), \
	new/datum/stack_recipe("bomb assembly", /obj/machinery/syndicatebomb/empty, 10, time = 50), \
))

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	materials = list(MAT_METAL=2000, MAT_PLASMA=2000)
	throwforce = 10
	flags = CONDUCT
	origin_tech = "materials=2"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 80)
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/plasteel

/obj/item/stack/sheet/plasteel/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.plasteel_recipes
	return ..()

/obj/item/stack/sheet/plasteel/twenty
	amount = 20

/obj/item/stack/sheet/plasteel/fifty
	amount = 50

/*
 * Wood
 */
GLOBAL_LIST_INIT(wood_recipes, list ( \
	new/datum/stack_recipe("wooden sandals", /obj/item/clothing/shoes/sandal, 1), \
	new/datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20), \
	new/datum/stack_recipe("wood table frame", /obj/structure/table_frame/wood, 2, time = 10), \
	new/datum/stack_recipe("rifle stock", /obj/item/weaponcrafting/stock, 10, time = 40), \
	new/datum/stack_recipe("rolling pin", /obj/item/weapon/kitchen/rollingpin, 2, time = 30), \
	new/datum/stack_recipe("wooden chair", /obj/structure/chair/wood/, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("winged wooden chair", /obj/structure/chair/wood/wings, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 20, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("book case", /obj/structure/bookcase, 4, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("drying rack", /obj/machinery/smartfridge/drying_rack, 10, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("dog bed", /obj/structure/bed/dogbed, 10, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("picture frame", /obj/item/wallframe/picture, 1, time = 10),\
	new/datum/stack_recipe("display case chassis", /obj/structure/displaycase_chassis, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("wooden buckler", /obj/item/weapon/shield/riot/buckler, 20, time = 40), \
	new/datum/stack_recipe("apiary", /obj/structure/beebox, 40, time = 50),\
	new/datum/stack_recipe("tiki mask", /obj/item/clothing/mask/gas/tiki_mask, 2), \
	new/datum/stack_recipe("honey frame", /obj/item/honey_frame, 5, time = 10),\
	new/datum/stack_recipe("ore box", /obj/structure/ore_box, 4, time = 50, one_per_turf = 1, on_floor = 1),\
	new/datum/stack_recipe("wooden crate", /obj/structure/closet/crate/wooden, 6, time = 50, one_per_turf = 1, on_floor = 1),\
	new/datum/stack_recipe("baseball bat", /obj/item/weapon/melee/baseball_bat, 5, time = 15),\
	))

/obj/item/stack/sheet/mineral/wood
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	icon = 'icons/obj/items.dmi'
	origin_tech = "materials=1;biotech=1"
	sheettype = "wood"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 0)
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/mineral/wood
	novariants = TRUE

/obj/item/stack/sheet/mineral/wood/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.wood_recipes
	return ..()

/obj/item/stack/sheet/mineral/wood/fifty
	amount = 50

/*
 * Cloth
 */
GLOBAL_LIST_INIT(cloth_recipes, list ( \
	new/datum/stack_recipe("grey jumpsuit", /obj/item/clothing/under/color/grey, 3), \
	new/datum/stack_recipe("black shoes", /obj/item/clothing/shoes/sneakers/black, 2), \
	null, \
	new/datum/stack_recipe("backpack", /obj/item/weapon/storage/backpack, 4), \
	new/datum/stack_recipe("dufflebag", /obj/item/weapon/storage/backpack/dufflebag, 6), \
	null, \
	new/datum/stack_recipe("plant bag", /obj/item/weapon/storage/bag/plants, 4), \
	new/datum/stack_recipe("book bag", /obj/item/weapon/storage/bag/books, 4), \
	new/datum/stack_recipe("mining satchel", /obj/item/weapon/storage/bag/ore, 4), \
	new/datum/stack_recipe("chemistry bag", /obj/item/weapon/storage/bag/chemistry, 4), \
	new/datum/stack_recipe("bio bag", /obj/item/weapon/storage/bag/bio, 4), \
	null, \
	new/datum/stack_recipe("improvised gauze", /obj/item/stack/medical/gauze/improvised, 1, 2, 6), \
	new/datum/stack_recipe("rag", /obj/item/weapon/reagent_containers/glass/rag, 1), \
	new/datum/stack_recipe("bedsheet", /obj/item/weapon/bedsheet, 3), \
	new/datum/stack_recipe("empty sandbag", /obj/item/weapon/emptysandbag, 4), \
	null, \
	new/datum/stack_recipe("fingerless gloves", /obj/item/clothing/gloves/fingerless, 1), \
	new/datum/stack_recipe("black gloves", /obj/item/clothing/gloves/color/black, 3), \
	null, \
	new/datum/stack_recipe("blindfold", /obj/item/clothing/glasses/sunglasses/blindfold, 2), \
	))

/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "Is it cotton? Linen? Denim? Burlap? Canvas? You can't tell."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = "materials=2"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cloth

/obj/item/stack/sheet/cloth/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.cloth_recipes
	return ..()

/obj/item/stack/sheet/cloth/ten
	amount = 10

/*
 * Cardboard
 */
GLOBAL_LIST_INIT(cardboard_recipes, list ( \
	new/datum/stack_recipe("box", /obj/item/weapon/storage/box), \
	new/datum/stack_recipe("light tubes", /obj/item/weapon/storage/box/lights/tubes), \
	new/datum/stack_recipe("light bulbs", /obj/item/weapon/storage/box/lights/bulbs), \
	new/datum/stack_recipe("mouse traps", /obj/item/weapon/storage/box/mousetraps), \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg), \
	new/datum/stack_recipe("pizza box", /obj/item/pizzabox), \
	new/datum/stack_recipe("folder", /obj/item/weapon/folder), \
	new/datum/stack_recipe("large box", /obj/structure/closet/cardboard, 4), \
	new/datum/stack_recipe("cardboard cutout", /obj/item/cardboard_cutout, 5), \
))

/obj/item/stack/sheet/cardboard	//BubbleWrap //it's cardboard you fuck
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	origin_tech = "materials=1"
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/cardboard
	novariants = TRUE

/obj/item/stack/sheet/cardboard/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.cardboard_recipes
	return ..()

/obj/item/stack/sheet/cardboard/fifty
	amount = 50

/*
 * Runed Metal
 */

GLOBAL_LIST_INIT(runed_metal_recipes, list ( \
	new/datum/stack_recipe("runed door", /obj/machinery/door/airlock/cult, 1, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("runed girder", /obj/structure/girder/cult, 1, time = 50, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("pylon", /obj/structure/destructible/cult/pylon, 4, time = 40, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("forge", /obj/structure/destructible/cult/forge, 3, time = 40, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("archives", /obj/structure/destructible/cult/tome, 3, time = 40, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("altar", /obj/structure/destructible/cult/talisman, 3, time = 40, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/runed_metal
	name = "runed metal"
	desc = "Sheets of cold metal with shifting inscriptions writ upon them."
	singular_name = "runed metal sheet"
	icon_state = "sheet-runed"
	icon = 'icons/obj/items.dmi'
	sheettype = "runed"
	merge_type = /obj/item/stack/sheet/runed_metal
	novariants = TRUE

/obj/item/stack/sheet/runed_metal/ratvar_act()
	new /obj/item/stack/tile/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/runed_metal/attack_self(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>Only one with forbidden knowledge could hope to work this metal...</span>")
		return
	return ..()

/obj/item/stack/sheet/runed_metal/attack(atom/target, mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>Only one with forbidden knowledge could hope to work this metal...</span>")
		return
	..()

/obj/item/stack/sheet/runed_metal/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.runed_metal_recipes
	return ..()

/obj/item/stack/sheet/runed_metal/fifty
	amount = 50

/obj/item/stack/sheet/runed_metal/five
	amount = 5

/*
 * Brass
 */
GLOBAL_LIST_INIT(brass_recipes, list ( \
	new/datum/stack_recipe("wall gear", /obj/structure/destructible/clockwork/wall_gear, 3, time = 30, one_per_turf = TRUE, on_floor = TRUE), \
	null,
	new/datum/stack_recipe("pinion airlock", /obj/machinery/door/airlock/clockwork, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("brass pinion airlock", /obj/machinery/door/airlock/clockwork/brass, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("brass windoor", /obj/machinery/door/window/clockwork, 2, time = 30, on_floor = TRUE, window_checks = TRUE), \
	null,
	new/datum/stack_recipe("directional brass window", /obj/structure/window/reinforced/clockwork/unanchored, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile brass window", /obj/structure/window/reinforced/clockwork/fulltile/unanchored, 2, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("brass table frame", /obj/structure/table_frame/brass, 1, time = 5, one_per_turf = TRUE, on_floor = TRUE) \
))

/obj/item/stack/tile/brass
	name = "brass"
	desc = "Sheets made out of brass."
	singular_name = "brass sheet"
	icon_state = "sheet-brass"
	icon = 'icons/obj/items.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	throwforce = 10
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	turf_type = /turf/open/floor/clockwork
	novariants = FALSE

/obj/item/stack/tile/brass/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/tile/brass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.brass_recipes
	. = ..()
	pixel_x = 0
	pixel_y = 0

/obj/item/stack/sheet/lessergem
	name = "lesser gems"
	desc = "Rare kind of gems which are only gained by blood sacrifice to minor deities. They are needed in crafting powerful objects."
	singular_name = "lesser gem"
	icon_state = "sheet-lessergem"
	origin_tech = "materials=4"
	novariants = TRUE


/obj/item/stack/sheet/greatergem
	name = "greater gems"
	desc = "Rare kind of gems which are only gained by blood sacrifice to minor deities. They are needed in crafting powerful objects."
	singular_name = "greater gem"
	icon_state = "sheet-greatergem"
	origin_tech = "materials=7"
	novariants = TRUE

	/*
 * Bones
 */
/obj/item/stack/sheet/bone
	name = "bones"
	icon = 'icons/obj/mining.dmi'
	icon_state = "bone"
	singular_name = "bone"
	desc = "Someone's been drinking their milk."
	force = 7
	throwforce = 5
	max_amount = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=2;biotech=2"

GLOBAL_LIST_INIT(plastic_recipes, list(
	new /datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 5, one_per_turf = 1, on_floor = 1, time = 40), \
	new /datum/stack_recipe("water bottle", /obj/item/weapon/reagent_containers/glass/beaker/waterbottle/empty), \
	new /datum/stack_recipe("large water bottle", /obj/item/weapon/reagent_containers/glass/beaker/waterbottle/large/empty,3), \
	new /datum/stack_recipe("wet floor sign", /obj/item/weapon/caution, 2)))

/obj/item/stack/sheet/plastic
	name = "plastic"
	desc = "Compress dinosaur over millions of years, then refine, split and mold, and voila! You have plastic."
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	throwforce = 7
	origin_tech = "materials=1"
	origin_tech = "materials=1;biotech=1"
	merge_type = /obj/item/stack/sheet/plastic

/obj/item/stack/sheet/plastic/fifty
	amount = 50

/obj/item/stack/sheet/plastic/five
	amount = 5

/obj/item/stack/sheet/plastic/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.plastic_recipes
	. = ..()
