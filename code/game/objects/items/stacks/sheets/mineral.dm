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

/obj/item/stack/sheet/mineral
	w_type=RECYK_METAL

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

var/global/list/datum/stack_recipe/sandstone_recipes = list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, one_per_turf = 1, on_floor = 1), \
/*	new/datum/stack_recipe("sandstone wall", ???), \
		new/datum/stack_recipe("sandstone floor", ???),\ */
	)

/obj/item/stack/sheet/mineral/sandstone/New(var/loc, var/amount=null)
	recipes = sandstone_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/sandstone/recycle(var/datum/materials/rec)
	rec.addAmount("glass",1*amount)
	return 1
/*
 * Diamond
 */
/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_range = 3
	origin_tech = "materials=6"
	perunit = 3750
	sheettype = "diamond"

var/global/list/datum/stack_recipe/diamond_recipes = list ( \
	new/datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/diamond/New(var/loc, var/amount=null)
	recipes = diamond_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/diamond/recycle(var/datum/materials/rec)
	rec.addAmount("diamond",1*amount)
	return 1

/*
 * Uranium
 */
/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	icon_state = "sheet-uranium"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 2000
	sheettype = "uranium"

var/global/list/datum/stack_recipe/uranium_recipes = list ( \
	new/datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/uranium/New(var/loc, var/amount=null)
	recipes = uranium_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/uranium/recycle(var/datum/materials/rec)
	rec.addAmount("uranium",1*amount)
	return 1

/*
 * Plasma
 */
/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "plasmatech=2;materials=2"
	perunit = 2000
	sheettype = "plasma"

var/global/list/datum/stack_recipe/plasma_recipes = list ( \
	new/datum/stack_recipe("plasma door", /obj/structure/mineral_door/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/plasma/New(var/loc, var/amount=null)
	recipes = plasma_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/plasma/recycle(var/datum/materials/rec)
	rec.addAmount("plasma",1*amount)
	return 1

/obj/item/stack/sheet/mineral/plastic
	name = "Plastic"
	icon_state = "sheet-plastic"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=3"
	perunit = 2000
	sheettype = "plastic"

var/global/list/datum/stack_recipe/plastic_recipes = list ( \
	new/datum/stack_recipe("plastic crate", /obj/structure/closet/pcrate, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plastic ashtray", /obj/item/ashtray/plastic, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plastic fork", /obj/item/weapon/kitchen/utensil/pfork, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic spoon", /obj/item/weapon/kitchen/utensil/pspoon, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic knife", /obj/item/weapon/kitchen/utensil/pknife, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic bag", /obj/item/weapon/storage/bag/plasticbag, 3, on_floor = 1), \
	new/datum/stack_recipe("blood bag", /obj/item/weapon/reagent_containers/blood, 3, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/plastic/New(var/loc, var/amount=null)
	recipes = plastic_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/plastic/recycle(var/datum/materials/rec)
	rec.addAmount("plastic",1*amount)
	return 0

/*
 * Gold
 */
/obj/item/stack/sheet/mineral/gold
	name = "gold"
	icon_state = "sheet-gold"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000
	sheettype = "gold"

var/global/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/gold/New(var/loc, var/amount=null)
	recipes = gold_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/gold/recycle(var/datum/materials/rec)
	rec.addAmount("gold",1*amount)
	return 1


/*
 * Phazon
 */
var/global/list/datum/stack_recipe/phazon_recipes = list()

/obj/item/stack/sheet/mineral/phazon
	name = "phazon"
	singular_name = "phazon sheet"
	desc = "Holy christ what is this?"
	icon_state = "sheet-phazon"
	item_state = "sheet-phazon"
	m_amt = 7500
	w_type = RECYK_METAL
	throwforce = 15.0
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "materials=9"

/obj/item/stack/sheet/mineral/phazon/New(var/loc, var/amount=null)
		recipes = phazon_recipes
		return ..()

/obj/item/stack/sheet/mineral/phazon/recycle(var/datum/materials/rec)
	rec.addAmount("phazon",1*amount)
	return 1

/*
 * Silver
 */
/obj/item/stack/sheet/mineral/silver
	name = "silver"
	icon_state = "sheet-silver"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=3"
	perunit = 2000
	sheettype = "silver"

var/global/list/datum/stack_recipe/silver_recipes = list ( \
	new/datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/silver/New(var/loc, var/amount=null)
	recipes = silver_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/silver/recycle(var/datum/materials/rec)
	rec.addAmount("silver",1*amount)
	return 1

/*
 * Clown
 */
/obj/item/stack/sheet/mineral/clown
	name = "bananium"
	icon_state = "sheet-clown"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000
	sheettype = "clown"

/obj/item/stack/sheet/mineral/clown/New(var/loc, var/amount=null)
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/clown/recycle(var/datum/materials/rec)
	rec.addAmount("clown",1*amount)
	return 1


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

