//Gun crafting parts til they can be moved elsewhere

// PARTS //

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "A prototype modular receiver and trigger assembly for a firearm."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "receiver"

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 6)
	icon = 'icons/obj/improvised.dmi'
	icon_state = "riflestock"

/obj/item/weaponcrafting/slide
	name = "pistol slide"
	desc = "A striker-fired pistol slide with mounting brackets for safeties, decockers and other advanced gun features."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "slide"

/obj/item/weaponcrafting/magspring
	name = "magazine spring"
	desc = "A magazine spring intended as a spare part for old firearms."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "magspring"
