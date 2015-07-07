
/obj/item/honey_frame
	name = "honey frame"
	desc = "a scaffold for bees to build honeycomb on"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "honeyframe"
	var/honeycomb_capacity = 10 //10 Honeycomb per frame by default, researchable frames maybe?


/obj/item/honey_frame/New()
	pixel_x = rand(8,-8)
	pixel_y = rand(8,-8)