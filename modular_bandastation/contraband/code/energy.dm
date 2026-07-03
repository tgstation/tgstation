/obj/item/melee/energy/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/melee/energy/sword/nullrod/Initialize(mapload)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

