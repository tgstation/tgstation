/**
 * Protects washable decal elements and washable color layers on floor tiles from being washed.
 */
/obj/item/paint_sealer
	name = "paint sealer"
	desc = "Permamentally seals paint and other designs on floor tiles."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint_sealer"
	inhand_icon_state = "paint_sprayer"
	worn_icon_state = "painter"
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/effects/spray3.ogg'
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)

	/// The power cell powering the tool
	var/obj/item/stock_parts/cell/power_cell
	/// How much is costs to fire the paint sealer
	var/cost_to_fire = 10

/obj/item/paint_sealer/Initialize(mapload)
	. = ..()

	power_cell = new /obj/item/stock_parts/cell()

/obj/item/paint_sealer/examine(mob/user)
	. = ..()
	. += span_notice("You see a note: <i>Not guarenteed to seal spray paint.</i>")

	if(!power_cell)
		. += span_notice("It doesn't have a power cell installed.")
		return

	. += span_notice("You can remove the power cell with <b>Alt+Click</b>.")
	. += span_notice("The charge meter reads [power_cell.percent()]%.")

/obj/item/paint_sealer/afterattack(atom/target, mob/user, proximity)
	. = ..()

	// Power check
	if(!power_cell?.use(cost_to_fire))
		playsound(loc, 'sound/effects/pop.ogg', 50, TRUE)
		return

	// Shoot sealent blip
	user.changeNext_move(CLICK_CD_RANGE*2)
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	playsound(loc, 'sound/weapons/emitter2.ogg', 30, TRUE, -6)
	new /obj/effect/temp_visual/paint_sealer_blip(get_turf(src), get_turf(target))

/obj/item/paint_sealer/AltClick(mob/user)
	. = ..()
	if(!power_cell)
		return

	// Remove power cell.
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	power_cell.forceMove(user.drop_location())
	user.put_in_hands(power_cell)
	to_chat(user, span_notice("You remove [power_cell] from [src]."))
	power_cell = null

/obj/item/paint_sealer/attackby(obj/item/item, mob/user)
	if(!istype(item, /obj/item/stock_parts/cell))
		return ..()

	if(power_cell)
		to_chat(user, span_warning("[src] already contains \a [power_cell]!"))
		return

	// Add power cell.
	if(!user.transferItemToLoc(item, src))
		return

	to_chat(user, span_notice("You install [item] into [src]."))
	power_cell = item
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
