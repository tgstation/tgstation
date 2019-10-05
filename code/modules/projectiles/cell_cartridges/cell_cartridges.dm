//Boxes of ammo
/obj/item/cell_cartridge
	name = "cell cartridge"
	desc = "A cartridge for holding power cells; typically used with energy weapons."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "cell_cartridge"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	materials = list(/datum/material/plastic = 5000, /datum/material/glass = 1000, /datum/material/gold = 1000)
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7

	///What type of power cell the cartridge has by default
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell
	var/can_load = FALSE //if false, cannot load or unload cells.
	var/can_charge = TRUE //if calse, cannot recharge in a recharger
	var/charge_sections = 4 //Number of charge sections for visualization of remaining charge.
	var/old_ratio = 0 // stores the cell's previous charge ratio to see if it needs an updated icon

	///sound when inserting cell
	var/load_sound = 'sound/weapons/gun/general/magazine_insert_full.ogg'
	///sound when inserting an empty magazine
	var/load_empty_sound = "buzz-sigh.ogg"
	///volume of loading sound
	var/load_sound_volume = 40
	///whether loading sound should vary
	var/load_sound_vary = TRUE

	///Sound of ejecting a magazine
	var/eject_sound = 'sound/weapons/gun/general/magazine_remove_full.ogg'
	///sound of ejecting an empty magazine
	var/eject_empty_sound = 'sound/weapons/gun/general/magazine_remove_empty.ogg'
	///volume of ejecting a magazine
	var/eject_sound_volume = 40
	///whether eject sound should vary
	var/eject_sound_vary = TRUE

/obj/item/cell_cartridge/Initialize()
	. = ..()
	if(cell_type && !cell)
		cell = new cell_type(src)

	update_icon()

/obj/item/cell_cartridge/examine(mob/user)
	. = ..()
	if(cell)
		. += "It has a cell loaded. The charge meter reads [round(cell.percent() )]%."
	else
		. += "It has no cell loaded."

/obj/item/cell_cartridge/get_cell()
	return cell

/obj/item/cell_cartridge/update_icon(force_update, mob/user)
	if(QDELETED(src))
		return
	..()
	var/ratio = 0
	if(cell)
		ratio = CEILING(CLAMP(cell.charge / cell.maxcharge, 0, 1) * charge_sections, 1)
	if(ratio == old_ratio && !force_update)
		return
	old_ratio = ratio
	cut_overlays()
	add_overlay("[icon_state]_charge[ratio]")


/obj/item/cell_cartridge/attack_hand(mob/user)
	if(!can_load) //Only relevant for cartridges that can unload their cell
		to_chat(user, "<span class='warning'>[src] cannot unload its cell!</span>")
		return ..()
	if(loc == user && user.is_holding(src) && cell)
		eject_cell(user)
		return
	return ..()


/obj/item/cell_cartridge/attackby(obj/item/W, mob/user, params)
	var/obj/item/stock_parts/cell/C
	if(istype(W, /obj/item/stock_parts/cell))
		C = W
		if(!can_load)
			to_chat(user, "<span class='warning'>[src] cannot accept other cells.</span>")
			return ..()

		if(cell && C) //Where we remove the cell.
			eject_cell(user, TRUE, TRUE) //Remove the cell, then replace it.
			return

		if(!cell && C)
			load_cell(user, C)

	else
		return ..()


/obj/item/cell_cartridge/proc/eject_cell(mob/user, display_message = TRUE, replace_cell = FALSE)
	if(!cell) //Sanity check
		return
	var/obj/item/stock_parts/cell/C = cell
	C.forceMove(drop_location())
	user.put_in_hands(C)
	C.update_icon()
	if(cell.charge)
		playsound(src, load_sound, load_sound_volume, load_sound_vary)
	else
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	cell = null
	if(display_message)
		to_chat(user, "<span class='warning'>You pull [C] out of \the [src].</span>")
	update_icon(TRUE, user)


/obj/item/cell_cartridge/proc/load_cell(mob/user, obj/item/stock_parts/cell/C)
	if(!C) //Sanity check
		return
	if(!user.transferItemToLoc(C, src))
		return
	cell = C
	playsound(src, load_sound, load_sound_volume, load_sound_vary)
	to_chat(user, "<span class='warning'>You install [C] in [src].</span>")
	update_icon(TRUE, user)
	return TRUE


/obj/item/cell_cartridge/dead //For those produced at autolathes
	cell_type = /obj/item/stock_parts/cell/empty