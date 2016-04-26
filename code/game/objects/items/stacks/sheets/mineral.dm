/*
Mineral Sheets
	Contains:
		- Sandstone
		- Brick
		- Diamond
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Clown
		- Plastic
	Others:
		- Adamantine
		- Mythril
		- Enriched Uranium
*/

/obj/item/stack/sheet/mineral
	w_type = RECYK_METAL
	var/recyck_mat

/obj/item/stack/sheet/mineral/recycle(var/datum/materials/rec)
	if(!recyck_mat)
		return 0

	rec.addAmount(recyck_mat, amount)
	. = 1

/*
 * Sandstone
 */
/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone bricks"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 4
	throw_range = 5
	origin_tech = "materials=1"
	sheettype = "sandstone"
	melt_temperature = MELTPOINT_GLASS
	recyck_mat = MAT_GLASS

var/global/list/datum/stack_recipe/sandstone_recipes = list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/portable_atmospherics/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/machinery/door/mineral/sandstone, 10, one_per_turf = 1, on_floor = 1), \
/*	new/datum/stack_recipe("sandstone wall", ???), \
		new/datum/stack_recipe("sandstone floor", ???),\ */
	)

/obj/item/stack/sheet/mineral/sandstone/New(var/loc, var/amount=null)
	recipes = sandstone_recipes
	..()

/*
 * Brick
 */
/obj/item/stack/sheet/mineral/brick
	name ="brick"
	singular_name = "brick"
	icon_state = "sheet-brick"
	force = 5.0
	throwforce = 5
	throw_range = 3
	throw_speed = 3
	w_class = 3.0
	melt_temperature = 2473.15
	sheettype = "brick"

/*
 * Diamond
 */
/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	singular_name = "diamond sheet"
	icon_state = "sheet-diamond"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_range = 3
	origin_tech = "materials=6"
	perunit = 1750
	sheettype = "diamond"
	melt_temperature = 3820 // In a vacuum, but fuck dat
	recyck_mat = MAT_DIAMOND

var/global/list/datum/stack_recipe/diamond_recipes = list ( \
	new/datum/stack_recipe("diamond floor tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20), \
	new/datum/stack_recipe("diamond door", /obj/machinery/door/mineral/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/diamond/New(var/loc, var/amount=null)
	recipes = diamond_recipes
	..()

/*
 * Uranium
 */
/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	singular_name = "uranium sheet"
	icon_state = "sheet-uranium"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 2000
	sheettype = "uranium"
	melt_temperature = 1132+T0C
	recyck_mat = MAT_URANIUM

var/global/list/datum/stack_recipe/uranium_recipes = list ( \
	new/datum/stack_recipe("uranium floor tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	new/datum/stack_recipe("uranium door", /obj/machinery/door/mineral/uranium, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/uranium/New(var/loc, var/amount=null)
	recipes = uranium_recipes
	..()

/*
 * Plasma
 */
/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	singular_name = "plasma sheet"
	icon_state = "sheet-plasma"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "plasmatech=2;materials=2"
	perunit = 2000
	sheettype = "plasma"
	melt_temperature = MELTPOINT_STEEL + 500
	recyck_mat = MAT_PLASMA

var/global/list/datum/stack_recipe/plasma_recipes = list ( \
	new/datum/stack_recipe("plasma floor tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	new/datum/stack_recipe("plasma door", /obj/machinery/door/mineral/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/plasma/New(var/loc, var/amount=null)
	recipes = plasma_recipes

	..()

/obj/item/stack/sheet/mineral/plastic
	name = "plastic"
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=3"
	perunit = 2000
	melt_temperature = MELTPOINT_PLASTIC
	sheettype = "plastic"
	recyck_mat = MAT_PLASTIC

var/global/list/datum/stack_recipe/plastic_recipes = list ( \
	new/datum/stack_recipe("plastic floor tile", /obj/item/stack/tile/mineral/plastic, 1, 4, 20), \
	new/datum/stack_recipe("plastic crate", /obj/structure/closet/pcrate, 10, one_per_turf = 1, on_floor = 1, one_per_turf = 1), \
	new/datum/stack_recipe("plastic ashtray", /obj/item/ashtray/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic fork", /obj/item/weapon/kitchen/utensil/fork/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic spoon", /obj/item/weapon/kitchen/utensil/spoon/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic knife", /obj/item/weapon/kitchen/utensil/knife/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic bag", /obj/item/weapon/storage/bag/plasticbag, 3, on_floor = 1), \
	new/datum/stack_recipe("blood bag", /obj/item/weapon/reagent_containers/blood/empty, 3, on_floor = 1), \
	new/datum/stack_recipe("plastic coat", /obj/item/clothing/suit/raincoat, 5), \
	new/datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 10, one_per_turf = 1, on_floor = 1, start_unanchored = 1), \
	new/datum/stack_recipe("water-cooler", /obj/structure/reagent_dispensers/water_cooler, 4, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/plastic/New(var/loc, var/amount=null)
	recipes = plastic_recipes
	..()

/*
 * Gold
 */
/obj/item/stack/sheet/mineral/gold
	name = "gold"
	singular_name = "gold sheet"
	icon_state = "sheet-gold"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000
	melt_temperature = 1064+T0C
	sheettype = "gold"
	recyck_mat = MAT_GOLD

var/global/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("golden floor tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	new/datum/stack_recipe("golden door", /obj/machinery/door/mineral/gold, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/gold/New(var/loc, var/amount=null)
	recipes = gold_recipes
	..()

/*
 * Phazon
 */
var/global/list/datum/stack_recipe/phazon_recipes = list( \
	new/datum/stack_recipe("phazon floor tile", /obj/item/stack/tile/mineral/phazon, 1, 4, 20), \
	)

/obj/item/stack/sheet/mineral/phazon
	name = "phazon"
	singular_name = "phazon sheet"
	desc = "Holy christ what is this?"
	icon_state = "sheet-phazon"
	item_state = "sheet-phazon"
	sheettype = "phazon"
	perunit = 1500
	melt_temperature = MELTPOINT_PLASTIC
	throwforce = 15.0
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = "materials=9"
	recyck_mat = MAT_PHAZON

/obj/item/stack/sheet/mineral/phazon/New(var/loc, var/amount=null)
		recipes = phazon_recipes
		return ..()

/*
 * Silver
 */
/obj/item/stack/sheet/mineral/silver
	name = "silver"
	singular_name = "silver sheet"
	icon_state = "sheet-silver"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=3"
	perunit = 2000
	sheettype = "silver"
	recyck_mat = MAT_SILVER

var/global/list/datum/stack_recipe/silver_recipes = list ( \
	new/datum/stack_recipe("silver floor tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	new/datum/stack_recipe("silver door", /obj/machinery/door/mineral/silver, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/silver/New(var/loc, var/amount=null)
	recipes = silver_recipes
	..()

/*
 * Clown
 */
/obj/item/stack/sheet/mineral/clown
	name = "bananium"
	singular_name = "bananium sheet"
	icon_state = "sheet-clown"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000
	sheettype = "clown"
	recyck_mat = MAT_CLOWN

var/global/list/datum/stack_recipe/clown_recipes = list ( \
	new/datum/stack_recipe("bananium floor tile", /obj/item/stack/tile/mineral/clown, 1, 4, 20), \
	)

/obj/item/stack/sheet/mineral/clown/New(var/loc, var/amount=null)
	recipes = clown_recipes
	..()

/****************************** Others ****************************/

/*
 * Enriched Uranium
 */
/obj/item/stack/sheet/mineral/enruranium
	name = "enriched uranium"
	icon_state = "sheet-enruranium"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 1000

/*
 * Adamantine
 */
/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	icon_state = "sheet-adamantine"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000

/*
 * Mythril
 */
/obj/item/stack/sheet/mineral/mythril
	name = "mythril"
	icon_state = "sheet-mythril"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000

/*
/obj/item/stack/sheet/mineral/pharosium
	name = "pharosium"
	icon_state = "sheet-pharosium"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750

/obj/item/stack/sheet/mineral/char
	name = "char"
	icon_state = "sheet-char"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/claretine
	name = "claretine"
	icon_state = "sheet-claretine"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/cobryl
	name = "cobryl"
	icon_state = "sheet-cobryl"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/bohrum
	name = "bohrum"
	icon_state = "sheet-bohrum"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/syreline
	name = "syreline"
	icon_state = "sheet-syreline"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/erebite
	name = "erebite"
	icon_state = "sheet-erebite"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/cerenkite
	name = "cerenkite"
	icon_state = "sheet-cerenkite"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/cytine
	name = "cytine"
	icon_state = "sheet-cytine"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/uqill
	name = "uqill"
	icon_state = "sheet-uqill"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/telecrystal
	name = "telecrystal"
	icon_state = "sheet-telecrystal"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/mauxite
	name = "mauxite"
	icon_state = "sheet-mauxite"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/molitz
	name = "molitz"
	icon_state = "sheet-molitz"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750
*/
