
/obj/item/honey_frame
	name = "honey frame"
	desc = "A scaffold for bees to build honeycomb on."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "honey_frame"
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 5)
	var/honeycomb_capacity = 10 //10 Honeycomb per frame by default, researchable frames perhaps?


/obj/item/honey_frame/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(8, -8)
	pixel_y = base_pixel_y + rand(8, -8)
