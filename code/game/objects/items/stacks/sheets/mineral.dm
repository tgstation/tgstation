/*
Mineral Sheets
	Contains:
		- Sandstone
		- Sandbags
		- Diamond
		- Snow
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Clown
		- Titanium
		- Plastitanium
	Others:
		- Adamantine
		- Mythril
		- Enriched Uranium
		- Abductor
*/

/obj/item/stack/sheet/mineral
	icon = 'icons/obj/mining.dmi'

/obj/item/stack/sheet/mineral/Initialize(mapload)
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)
	. = ..()

/*
 * Sandstone
 */

GLOBAL_LIST_INIT(sandstone_recipes, list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("aesthetic volcanic floor tile", /obj/item/stack/tile/basalt, 2, 2, 4, 20), \
	new/datum/stack_recipe("Assistant Statue", /obj/structure/statue/sandstone/assistant, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Breakdown into sand", /obj/item/weapon/ore/glass, 1, one_per_turf = 0, on_floor = 1) \
	))

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 3
	throw_range = 5
	origin_tech = "materials=1"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	sheettype = "sandstone"

/obj/item/stack/sheet/mineral/sandstone/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.sandstone_recipes
	. = ..()

/obj/item/stack/sheet/mineral/sandstone/thirty
	amount = 30

/*
 * Sandbags
 */

/obj/item/stack/sheet/mineral/sandbags
	name = "sandbags"
	icon = 'icons/obj/items.dmi'
	icon_state = "sandbags"
	singular_name = "sandbag"
	layer = LOW_ITEM_LAYER
	origin_tech = "materials=2"
	novariants = TRUE

GLOBAL_LIST_INIT(sandbag_recipes, list ( \
	new/datum/stack_recipe("sandbags", /obj/structure/barricade/sandbags, 1, time = 25, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/sandbags/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.sandbag_recipes
	. = ..()

/obj/item/weapon/emptysandbag
	name = "empty sandbag"
	desc = "A bag to be filled with sand."
	icon = 'icons/obj/items.dmi'
	icon_state = "sandbag"
	w_class = WEIGHT_CLASS_TINY

/obj/item/weapon/emptysandbag/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/weapon/ore/glass))
		to_chat(user, "<span class='notice'>You fill the sandbag.</span>")
		var/obj/item/stack/sheet/mineral/sandbags/I = new /obj/item/stack/sheet/mineral/sandbags
		qdel(src)
		user.put_in_hands(I)
		qdel(W)
	else
		return ..()

/*
 * Diamond
 */
/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	singular_name = "diamond"
	origin_tech = "materials=6"
	sheettype = "diamond"
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)
	novariants = TRUE

GLOBAL_LIST_INIT(diamond_recipes, list ( \
	new/datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("diamond tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20),  \
	new/datum/stack_recipe("Captain Statue", /obj/structure/statue/diamond/captain, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Hologram Statue", /obj/structure/statue/diamond/ai1, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Core Statue", /obj/structure/statue/diamond/ai2, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/diamond/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.diamond_recipes
	. = ..()

/*
 * Uranium
 */
/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	icon_state = "sheet-uranium"
	singular_name = "uranium sheet"
	origin_tech = "materials=5"
	sheettype = "uranium"
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)
	novariants = TRUE

GLOBAL_LIST_INIT(uranium_recipes, list ( \
	new/datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("uranium tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	new/datum/stack_recipe("Nuke Statue", /obj/structure/statue/uranium/nuke, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Engineer Statue", /obj/structure/statue/uranium/eng, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/uranium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.uranium_recipes
	. = ..()

/*
 * Plasma
 */
/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
	singular_name = "plasma sheet"
	origin_tech = "plasmatech=2;materials=2"
	sheettype = "plasma"
	resistance_flags = FLAMMABLE
	max_integrity = 100
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)

GLOBAL_LIST_INIT(plasma_recipes, list ( \
	new/datum/stack_recipe("plasma door", /obj/structure/mineral_door/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plasma tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	new/datum/stack_recipe("Scientist Statue", /obj/structure/statue/plasma/scientist, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/plasma/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.plasma_recipes
	. = ..()

/obj/item/stack/sheet/mineral/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		var/turf/T = get_turf(src)
		message_admins("Plasma sheets ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(T)]",0,1)
		log_game("Plasma sheets ignited by [key_name(user)] in [COORD(T)]")
		fire_act(W.is_hot())
	else
		return ..()

/obj/item/stack/sheet/mineral/plasma/fire_act(exposed_temperature, exposed_volume)
	atmos_spawn_air("plasma=[amount*10];TEMP=[exposed_temperature]")
	qdel(src)

/*
 * Gold
 */
/obj/item/stack/sheet/mineral/gold
	name = "gold"
	icon_state = "sheet-gold"
	singular_name = "gold bar"
	origin_tech = "materials=4"
	sheettype = "gold"
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)

GLOBAL_LIST_INIT(gold_recipes, list ( \
	new/datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("gold tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	new/datum/stack_recipe("HoS Statue", /obj/structure/statue/gold/hos, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("HoP Statue", /obj/structure/statue/gold/hop, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("CE Statue", /obj/structure/statue/gold/ce, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("RD Statue", /obj/structure/statue/gold/rd, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Simple Crown", /obj/item/clothing/head/crown, 5), \
	new/datum/stack_recipe("CMO Statue", /obj/structure/statue/gold/cmo, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/gold/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.gold_recipes
	. = ..()

/*
 * Silver
 */
/obj/item/stack/sheet/mineral/silver
	name = "silver"
	icon_state = "sheet-silver"
	singular_name = "silver bar"
	origin_tech = "materials=4"
	sheettype = "silver"
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)

GLOBAL_LIST_INIT(silver_recipes, list ( \
	new/datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("silver tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	new/datum/stack_recipe("Med Officer Statue", /obj/structure/statue/silver/md, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Janitor Statue", /obj/structure/statue/silver/janitor, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Officer Statue", /obj/structure/statue/silver/sec, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Borg Statue", /obj/structure/statue/silver/secborg, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Med Borg Statue", /obj/structure/statue/silver/medborg, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/silver/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.silver_recipes
	. = ..()

/*
 * Clown
 */
/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	icon_state = "sheet-clown"
	singular_name = "bananium sheet"
	origin_tech = "materials=4"
	sheettype = "clown"
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)
	novariants = TRUE

GLOBAL_LIST_INIT(clown_recipes, list ( \
	new/datum/stack_recipe("bananium tile", /obj/item/stack/tile/mineral/bananium, 1, 4, 20), \
	new/datum/stack_recipe("Clown Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/bananium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.clown_recipes
	. = ..()

/*
 * Titanium
 */
/obj/item/stack/sheet/mineral/titanium
	name = "titanium"
	icon_state = "sheet-titanium"
	singular_name = "titanium sheet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"
	sheettype = "titanium"
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT)

GLOBAL_LIST_INIT(titanium_recipes, list ( \
	new/datum/stack_recipe("titanium tile", /obj/item/stack/tile/mineral/titanium, 1, 4, 20), \
	))

/obj/item/stack/sheet/mineral/titanium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.titanium_recipes
	. = ..()


/*
 * Plastitanium
 */
/obj/item/stack/sheet/mineral/plastitanium
	name = "plastitanium"
	icon_state = "sheet-plastitanium"
	singular_name = "plastitanium sheet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"
	sheettype = "plastitanium"
	materials = list(MAT_TITANIUM=2000, MAT_PLASMA=2000)

GLOBAL_LIST_INIT(plastitanium_recipes, list ( \
	new/datum/stack_recipe("plas-titanium tile", /obj/item/stack/tile/mineral/plastitanium, 1, 4, 20), \
	))

/obj/item/stack/sheet/mineral/plastitanium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.plastitanium_recipes
	. = ..()


/*
 * Snow
 */
/obj/item/stack/sheet/mineral/snow
	name = "snow"
	icon_state = "sheet-snow"
	singular_name = "snow block"
	force = 1
	throwforce = 2
	origin_tech = "materials=1"

GLOBAL_LIST_INIT(snow_recipes, list ( \
	new/datum/stack_recipe("Snow Wall",/turf/closed/wall/mineral/snow, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Snowman", /obj/structure/statue/snow/snowman, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Snowball", /obj/item/toy/snowball, 1), \
	))

/obj/item/stack/sheet/mineral/snow/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.snow_recipes
	. = ..()

/****************************** Others ****************************/

/*
 * Enriched Uranium
 */
/obj/item/stack/sheet/mineral/enruranium
	name = "enriched uranium"
	icon_state = "sheet-enruranium"
	singular_name = "enriched uranium sheet"
	origin_tech = "materials=6"
	materials = list(MAT_URANIUM=3000)

/*
 * Adamantine
 */
GLOBAL_LIST_INIT(adamantine_recipes, list(
	new /datum/stack_recipe("incomplete servant golem shell", /obj/item/golem_shell/servant, req_amount=1, res_amount=1),
	))

/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	icon_state = "sheet-adamantine"
	singular_name = "adamantine sheet"
	origin_tech = "materials=4"

/obj/item/stack/sheet/mineral/adamantine/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.adamantine_recipes
	. = ..()

/*
 * Mythril
 */
/obj/item/stack/sheet/mineral/mythril
	name = "mythril"
	icon_state = "sheet-mythril"
	singular_name = "mythril sheet"
	origin_tech = "materials=4"
	novariants = TRUE

/*
 * Alien Alloy
 */
/obj/item/stack/sheet/mineral/abductor
	name = "alien alloy"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "sheet-abductor"
	singular_name = "alien alloy sheet"
	origin_tech = "materials=6;abductor=1"
	sheettype = "abductor"

GLOBAL_LIST_INIT(abductor_recipes, list ( \
/*	new/datum/stack_recipe("alien chair", /obj/structure/chair, one_per_turf = 1, on_floor = 1), \ */
	new/datum/stack_recipe("alien bed", /obj/structure/bed/abductor, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien locker", /obj/structure/closet/abductor, 2, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien table frame", /obj/structure/table_frame/abductor, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien airlock assembly", /obj/structure/door_assembly/door_assembly_abductor, 4, time = 20, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("alien floor tile", /obj/item/stack/tile/mineral/abductor, 1, 4, 20), \
/*	null, \
	new/datum/stack_recipe("Abductor Agent Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Abductor Sciencist Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1)*/
	))

/obj/item/stack/sheet/mineral/abductor/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.abductor_recipes
	. = ..()
