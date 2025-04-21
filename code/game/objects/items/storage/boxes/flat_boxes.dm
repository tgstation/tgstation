/obj/item/storage/box/flat
	name = "flat box"
	desc = "A cardboard box folded in a manner that is optimal for concealment, rather than for stowing your belongings."
	icon_state = "flat"
	illustration = null
	storage_type = /datum/storage/box/flat

/obj/item/storage/box/flat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER, use_anchor = TRUE, tilt_tile = TRUE)

/obj/item/storage/box/proc/flatten_box()
	if(istype(loc, /obj/item/storage) || type != /obj/item/storage/box || contents.len)
		return

	var/obj/flat_box = new /obj/item/storage/box/flat(drop_location())
	playsound(src, 'sound/items/handling/materials/cardboard_drop.ogg', 50, TRUE)

	flat_box.pixel_x = pixel_x
	flat_box.pixel_y = pixel_y

	qdel(src)
