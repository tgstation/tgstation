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
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 3
	throw_range = 5
	origin_tech = "materials=1"
	sheettype = "sandstone"
	material = new/datum/material/sandstone()

/obj/item/stack/sheet/mineral/sandstone/New(var/loc, var/amount=null)
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Diamond
 */
/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	singular_name = "diamond"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_range = 3
	origin_tech = "materials=6"
	sheettype = "diamond"
	material = new/datum/material/diamond()

/obj/item/stack/sheet/mineral/diamond/New(var/loc, var/amount=null)
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Uranium
 */
/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	icon_state = "sheet-uranium"
	singular_name = "uranium sheet"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=5"
	sheettype = "uranium"
	material = new/datum/material/uranium()

/obj/item/stack/sheet/mineral/uranium/New(var/loc, var/amount=null)
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Plasma
 */
/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
	singular_name = "plasma sheet"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "plasmatech=2;materials=2"
	sheettype = "plasma"
	material = new/datum/material/plasma()

/obj/item/stack/sheet/mineral/plasma/New(var/loc, var/amount=null)
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Gold
 */
/obj/item/stack/sheet/mineral/gold
	name = "gold"
	icon_state = "sheet-gold"
	singular_name = "gold bar"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"
	sheettype = "gold"
	material = new/datum/material/gold()

/obj/item/stack/sheet/mineral/gold/New(var/loc, var/amount=null)
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Silver
 */
/obj/item/stack/sheet/mineral/silver
	name = "silver"
	icon_state = "sheet-silver"
	singular_name = "silver bar"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=3"
	sheettype = "silver"
	material = new/datum/material/silver()


/obj/item/stack/sheet/mineral/silver/New(var/loc, var/amount=null)
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Clown
 */
/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	icon_state = "sheet-clown"
	singular_name = "bananium sheet"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"
	sheettype = "clown"
	material = new/datum/material/bananium()

/obj/item/stack/sheet/mineral/bananium/New(var/loc, var/amount=null)
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()


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