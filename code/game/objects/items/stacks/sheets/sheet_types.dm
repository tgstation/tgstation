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
	desc = "Sheets made out of metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL)
	w_type = RECYK_METAL
	throwforce = 14.0
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = "materials=1"
	melt_temperature = MELTPOINT_STEEL

/obj/item/stack/sheet/metal/resetVariables()
	return ..("recipes", "pixel_x", "pixel_y")

/obj/item/stack/sheet/metal/ex_act(severity)
	switch(severity)
		if(1.0)
			returnToPool(src)
			return
		if(2.0)
			if (prob(50))
				returnToPool(src)
				return
		if(3.0)
			if (prob(5))
				returnToPool(src)
				return
		else
	return

/obj/item/stack/sheet/metal/blob_act()
	returnToPool(src)

/obj/item/stack/sheet/metal/singularity_act()
	returnToPool(src)
	return 2

// Diet metal.
/obj/item/stack/sheet/metal/cyborg
	starting_materials = null

/obj/item/stack/sheet/metal/New(var/loc, var/amount=null)
	recipes = metal_recipes
	return ..()

/*
 * Plasteel
 */
/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-plasteel"
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL, MAT_PLASMA = CC_PER_SHEET_MISC) // Was 7500, which doesn't make any fucking sense
	perunit = 2875 //average of plasma and metal
	throwforce = 15.0
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = "materials=2"
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL+500

/obj/item/stack/sheet/plasteel/New(var/loc, var/amount=null)
		recipes = plasteel_recipes
		return ..()

/*
 * Wood
 */
/obj/item/stack/sheet/wood
	name = "wooden planks"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	origin_tech = "materials=1;biotech=1"
	autoignition_temperature=AUTOIGNITION_WOOD
	sheettype = "wood"
	w_type = RECYK_WOOD

/obj/item/stack/sheet/wood/afterattack(atom/Target, mob/user, adjacent, params)
	..()
	if(adjacent)
		if(isturf(Target) || istype(Target, /obj/structure/lattice))
			var/turf/T = get_turf(Target)
			if(T.canBuildLattice(src))
				if(src.use(1))
					to_chat(user, "<span class='notice'>Constructing some foundations ...</span>")
					playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
					new /obj/structure/lattice/wood(T)

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
/obj/item/stack/sheet/cardboard	//BubbleWrap
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	flags = FPRINT
	origin_tech = "materials=1"
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

/obj/item/stack/sheet/cardboard/New(var/loc, var/amount=null)
		recipes = cardboard_recipes
		return ..()

/obj/item/stack/sheet/cardboard/recycle(var/datum/materials/rec)
	rec.addAmount(MAT_CARDBOARD, amount)
	return 1

/*
 * /vg/ charcoal
 */
var/global/list/datum/stack_recipe/charcoal_recipes = list ()

/obj/item/stack/sheet/charcoal	//N3X15
	name = "charcoal"
	desc = "Yum."
	singular_name = "charcoal sheet"
	icon_state = "sheet-charcoal"
	flags = FPRINT
	origin_tech = "materials=1"
	autoignition_temperature=AUTOIGNITION_WOOD

/obj/item/stack/sheet/charcoal/New(var/loc, var/amount=null)
		recipes = charcoal_recipes
		return ..()
