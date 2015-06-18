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

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out of metal."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	m_amt = MINERAL_MATERIAL_AMOUNT
	throwforce = 10.0
	flags = CONDUCT
	origin_tech = "materials=1"
	material = new/datum/material/iron()

/obj/item/stack/sheet/metal/cyborg
	m_amt = 0
	is_cyborg = 1
	cost = 500


/*
 * Plasteel
 */

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	m_amt = 6000
	throwforce = 10.0
	flags = CONDUCT
	origin_tech = "materials=2"
	material = new/datum/material/plasteel()

/*
 * Wood
 */

/obj/item/stack/sheet/mineral/wood
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	icon = 'icons/obj/items.dmi'
	origin_tech = "materials=1;biotech=1"
	sheettype = "wood"
	material = new/datum/material/wood()

/*
 * Cloth
 */
/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "This roll of cloth is made from only the finest chemicals and bunny rabbits."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = "materials=2"
	material = new/datum/material/cloth()
/*
 * Cardboard
 */

/obj/item/stack/sheet/cardboard	//BubbleWrap
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	origin_tech = "materials=1"
	material = new/datum/material/cardboard()