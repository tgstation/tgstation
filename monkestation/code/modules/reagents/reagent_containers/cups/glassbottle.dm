/obj/item/broken_bottle/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_TRASH_ITEM, INNATE_TRAIT)
