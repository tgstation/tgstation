///unique items that spawn at the mook village
/obj/structure/ore_container/material_stand
	name = "material stand"
	desc = "Is everyone free to use this thing?"
	icon = 'icons/mob/simple/jungle/mook.dmi'
	icon_state = "material_stand"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	bound_width = 64
	bound_height = 64

///put ore icons on the counter!
/obj/structure/ore_container/material_stand/update_overlays()
	. = ..()
	for(var/obj/item/stack/ore/ore_item in contents)
		var/image/ore_icon = image(icon = initial(ore_item.icon), icon_state = initial(ore_item.icon_state), layer = LOW_ITEM_LAYER)
		ore_icon.transform = ore_icon.transform.Scale(0.6, 0.6)
		ore_icon.pixel_x = rand(9, 17)
		ore_icon.pixel_y = rand(2, 4)
		. += ore_icon

/obj/effect/landmark/mook_village
	name = "mook village landmark"
	icon_state = "x"
