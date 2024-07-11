/obj/item/trash/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_TRASH_ITEM, INNATE_TRAIT)
