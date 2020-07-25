
/obj/item/honey_frame
	name = "honey frame"
	desc = "A scaffold for bees to build honeycomb on."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "honey_frame"
	var/honeycomb_capacity = 10 //10 Honeycomb per frame by default, researchable frames perhaps?


/obj/item/honey_frame/Initialize()
	. = ..()
	if(loc)
		forceMove(loc, rand(8,-8), rand(8,-8))
