/obj/item/pickaxe/bismuth
	name = "bismuth pick"

/obj/item/pickaxe/bismuth/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/gem/weapon/bismuthpick
	name = "Shapeshift Pickaxe"
	desc = "A tool used to mine materials, or shatter gems"
	weapon_type = /obj/item/pickaxe/bismuth