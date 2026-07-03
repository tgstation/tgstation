/mob/living/basic/headslug/Initialize(mapload)
	. = ..()
	pass_flags = PASSMOB|PASSTABLE
	ADD_TRAIT(src, TRAIT_UNDENSE, INNATE_TRAIT)

