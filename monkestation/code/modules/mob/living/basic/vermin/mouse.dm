/obj/item/food/deadmouse/Initialize(mapload, mob/living/basic/mouse/dead_critter)
	. = ..()
	ADD_TRAIT(src, TRAIT_TRASH_ITEM, INNATE_TRAIT)
