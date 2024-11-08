/obj/structure/closet/crate/freezer/surplus_limbs
	name = "prosthetic limbs freezer"
	desc = "A crate containing an assortment of robust prosthetic limbs."

/obj/structure/closet/crate/freezer/surplus_limbs/PopulateContents()
	. = ..()
	new /obj/item/bodypart/arm/left/robot/android(src)
	new /obj/item/bodypart/arm/left/robot/android(src)
	new /obj/item/bodypart/arm/right/robot/android(src)
	new /obj/item/bodypart/arm/right/robot/android(src)
	new /obj/item/bodypart/leg/left/robot/android(src)
	new /obj/item/bodypart/leg/left/robot/android(src)
	new /obj/item/bodypart/leg/right/robot/android(src)
	new /obj/item/bodypart/leg/right/robot/android(src)
