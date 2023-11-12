//it's a coding warcrime but it works

/obj/item/clothing/gloves/cargo_gauntlet/Initialize()
	. = ..()
	QDEL_NULL(clothing_traits)

/obj/item/clothing/gloves/color/yellow/Initialize()
	. = ..()
	QDEL_NULL(clothing_traits)
