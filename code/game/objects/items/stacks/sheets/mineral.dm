/*
Mineral Sheets
	Contains:
		- Sandstone
		- Diamond
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Clown
	Others:
		- Adamantine
		- Mythril
		- Enriched Uranium
*/

/*
 * Sandstone
 */

/obj/item/stack/sheet/mineral
	icon = 'icons/obj/mining.dmi'

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "Some bricks made of compacted sand, ideal for construction."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 3
	throw_range = 5
	origin_tech = "materials=1"
	sheettype = "sandstone"

var/global/list/datum/stack_recipe/sandstone_recipes = list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Assistant Statue", /obj/structure/statue/sandstone/assistant, 5, one_per_turf = 1, on_floor = 1), \
/*	new/datum/stack_recipe("sandstone wall", ???), \
		new/datum/stack_recipe("sandstone floor", ???),\ */
	)

/obj/item/stack/sheet/mineral/sandstone/New(var/loc, var/amount=null)
	recipes = sandstone_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Diamond
 */
/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	desc = "A very tough form of carbon. Prized in adornments and some construction."
	icon_state = "sheet-diamond"
	singular_name = "diamond"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_range = 3
	origin_tech = "materials=6"
	sheettype = "diamond"

var/global/list/datum/stack_recipe/diamond_recipes = list ( \
	new/datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("diamond tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20),  \
	new/datum/stack_recipe("Captain Statue", /obj/structure/statue/diamond/captain, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Hologram Statue", /obj/structure/statue/diamond/ai1, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Core Statue", /obj/structure/statue/diamond/ai2, 5, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/diamond/New(var/loc, var/amount=null)
	recipes = diamond_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Uranium
 */
/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	desc = "A radioactive element commonly used in exosuit construction."
	icon_state = "sheet-uranium"
	singular_name = "uranium sheet"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=5"
	sheettype = "uranium"

var/global/list/datum/stack_recipe/uranium_recipes = list ( \
	new/datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("uranium tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	new/datum/stack_recipe("Nuke Statue", /obj/structure/statue/uranium/nuke, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Engineer Statue", /obj/structure/statue/uranium/eng, 5, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/uranium/New(var/loc, var/amount=null)
	recipes = uranium_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Plasma
 */
/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	desc = "Plasma. Very toxic, very flammable, and very mysterious. Nanotrasen is currently researching potential uses for this substance."
	icon_state = "sheet-plasma"
	singular_name = "plasma sheet"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "plasmatech=2;materials=2"
	sheettype = "plasma"

var/global/list/datum/stack_recipe/plasma_recipes = list ( \
	new/datum/stack_recipe("plasma door", /obj/structure/mineral_door/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plasma tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	new/datum/stack_recipe("Scientist Statue", /obj/structure/statue/plasma/scientist, 5, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/plasma/New(var/loc, var/amount=null)
	recipes = plasma_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Gold
 */
/obj/item/stack/sheet/mineral/gold
	name = "gold"
	desc = "A precious metal used commonly in electronics and circuits."
	icon_state = "sheet-gold"
	singular_name = "gold bar"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"
	sheettype = "gold"

var/global/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("gold tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	new/datum/stack_recipe("HoS Statue", /obj/structure/statue/gold/hos, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("HoP Statue", /obj/structure/statue/gold/hop, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("CE Statue", /obj/structure/statue/gold/ce, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("RD Statue", /obj/structure/statue/gold/rd, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("CMO Statue", /obj/structure/statue/gold/cmo, 5, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/gold/New(var/loc, var/amount=null)
	recipes = gold_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Silver
 */
/obj/item/stack/sheet/mineral/silver
	name = "silver"
	desc = "A semi-precious metal used in science for electronics."
	icon_state = "sheet-silver"
	singular_name = "silver bar"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=3"
	sheettype = "silver"

var/global/list/datum/stack_recipe/silver_recipes = list ( \
	new/datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("silver tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	new/datum/stack_recipe("Med Officer Statue", /obj/structure/statue/silver/md, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Janitor Statue", /obj/structure/statue/silver/janitor, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Officer Statue", /obj/structure/statue/silver/sec, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Borg Statue", /obj/structure/statue/silver/secborg, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Med Borg Statue", /obj/structure/statue/silver/medborg, 5, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/silver/New(var/loc, var/amount=null)
	recipes = silver_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Clown
 */
/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	desc = "A strange metal that gains its toughness from sodium chloride."
	icon_state = "sheet-clown"
	singular_name = "bananium sheet"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"
	sheettype = "clown"

var/global/list/datum/stack_recipe/clown_recipes = list ( \
	new/datum/stack_recipe("bananium tile", /obj/item/stack/tile/mineral/bananium, 1, 4, 20), \
	new/datum/stack_recipe("Clown Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/bananium/New(var/loc, var/amount=null)
	recipes = clown_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Mythril
 */

/obj/item/stack/sheet/mineral/mythril
	name = "mythril bars"
	desc = "Mythril. It's an extremely tough metal when shaped, but otherwise soft and malleable even at room temperature."
	icon_state = "sheet-mythril"
	singular_name = "mythril bar"
	force = 5
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"
	sheettype = "mythril"

var/global/list/datum/stack_recipe/mythril_recipes = list(\
	new/datum/stack_recipe("mythril wrench", /obj/item/weapon/wrench/mythril, 1, 0, 1), \
	new/datum/stack_recipe("mythril crowbar", /obj/item/weapon/crowbar/mythril, 1, 0, 1), \
	new/datum/stack_recipe("mythril screwdriver", /obj/item/weapon/screwdriver/mythril, 1, 0, 1), \
	new/datum/stack_recipe("mythril wirecutters", /obj/item/weapon/wirecutters/mythril, 1, 0, 1), \
	new/datum/stack_recipe("mythril hardsuit plates", /obj/item/asteroid/goliath_hide/mythrilPlates, 10, 0, 1), \
	)

/obj/item/stack/sheet/mineral/mythril/New(var/loc, var/amount=null)
	recipes = mythril_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

//Tools creatable by mythril
/obj/item/weapon/wrench/mythril
	name = "mythril wrench"
	desc = "A lump of shapen mythril vaguely resembling a wrench."
	force = 7
	icon = 'icons/obj/mining.dmi'
	icon_state = "mythrilWrench"
	item_state = "wrench"

/obj/item/weapon/crowbar/mythril
	name = "mythril crowbar"
	desc = "A hook-shaped rod of shapen mythril that looks like a cane."
	force = 7
	icon = 'icons/obj/mining.dmi'
	icon_state = "mythrilCrowbar"

/obj/item/weapon/screwdriver/mythril
	name = "mythril screwdriver"
	desc = "A chunk of shapen mythril that looks like a very misshapen screwdriver."
	force = 7
	icon = 'icons/obj/mining.dmi'
	icon_state = "mythrilScrewdriver"

/obj/item/weapon/screwdriver/mythril/New()
	..()
	icon_state = "[initial(icon_state)]"

/obj/item/weapon/wirecutters/mythril
	name = "mythril wirecutters"
	desc = "A pair of wirecutters made of shapen mythril. Resemblance is only cursory."
	force = 7
	icon = 'icons/obj/mining.dmi'
	icon_state = "mythrilWirecutters"

/obj/item/weapon/wirecutters/mythril/New()
	..()
	icon_state = "[initial(icon_state)]"


/****************************** Others ****************************/

/*
 * Enriched Uranium
 */
/obj/item/stack/sheet/mineral/enruranium
	name = "enriched uranium"
	icon_state = "sheet-enruranium"
	singular_name = "enriched uranium sheet"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=5"

/*
 * Adamantine
 */
/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	icon_state = "sheet-adamantine"
	singular_name = "adamantine sheet"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"

/*
 * Mythril
 */
/obj/item/stack/sheet/mineral/mythril
	name = "mythril"
	icon_state = "sheet-mythril"
	singular_name = "mythril sheet"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"