/obj/item/clothing/shoes/wheelys
	name = "Wheely-Heels"
	desc = "Uses patented retractable wheel technology. Never sacrifice speed for style - not that this provides much of either." //Thanks Fel
	worn_icon_state = "wheelys"
	greyscale_colors = "#545454#ffffff"
	icon_state = "sneakers"
	greyscale_config = /datum/greyscale_config/sneakers_wheelys
	inhand_icon_state = "wheelys"
	worn_icon = 'icons/mob/large-worn-icons/64x64/feet.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64
	clothing_flags = LARGE_WORN_ICON
	actions_types = list(/datum/action/item_action/wheelys)
	///False means wheels are not popped out
	var/wheelToggle = FALSE
	///The vehicle associated with the shoes
	var/obj/vehicle/ridden/scooter/skateboard/wheelys/wheels = /obj/vehicle/ridden/scooter/skateboard/wheelys

/obj/item/clothing/shoes/wheelys/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	wheels = new wheels(null)
	wheels.link_shoes(src)

/obj/item/clothing/shoes/wheelys/ui_action_click(mob/user, action)
	if(!isliving(user))
		return
	if(!istype(user.get_item_by_slot(ITEM_SLOT_FEET), /obj/item/clothing/shoes/wheelys))
		to_chat(user, span_warning("You must be wearing the wheely-heels to use them!"))
		return
	if(!(wheels.is_occupant(user)))
		wheelToggle = FALSE
	if(wheelToggle)
		wheels.unbuckle_mob(user)
		wheelToggle = FALSE
		return
	wheels.forceMove(get_turf(user))
	wheels.buckle_mob(user)
	wheelToggle = TRUE

/obj/item/clothing/shoes/wheelys/dropped(mob/user)
	if(wheelToggle)
		wheels.unbuckle_mob(user)
		wheelToggle = FALSE
	..()

/obj/item/clothing/shoes/wheelys/proc/toggle_wheels(status)
	if (status)
		worn_icon_state = "[initial(worn_icon_state)]-on"
	else
		worn_icon_state = "[initial(worn_icon_state)]"
	playsound(src, 'sound/weapons/tap.ogg', 10, TRUE)
	update_appearance()

/obj/item/clothing/shoes/wheelys/Destroy()
	QDEL_NULL(wheels)
	. = ..()

/obj/item/clothing/shoes/wheelys/rollerskates
	name = "roller skates"
	desc = "An EightO brand pair of roller skates. The wheels are retractable, though're quite bulky to walk in."
	icon_state = "rollerskates"
	greyscale_colors = null
	greyscale_config = null
	worn_icon_state = "rollerskates"
	slowdown = SHOES_SLOWDOWN+1
	wheels = /obj/vehicle/ridden/scooter/skateboard/wheelys/rollerskates
	custom_premium_price = PAYCHECK_EASY * 5
	custom_price = PAYCHECK_EASY * 5

/obj/item/clothing/shoes/wheelys/skishoes
	name = "ski shoes"
	desc = "A pair of shoes equipped with foldable skis! Very handy to move in snowy environments unimpeded."
	icon_state = "skishoes"
	greyscale_colors = null
	greyscale_config = null
	worn_icon_state = "skishoes"
	slowdown = SHOES_SLOWDOWN+1
	wheels = /obj/vehicle/ridden/scooter/skateboard/wheelys/skishoes
	custom_premium_price = PAYCHECK_EASY * 1.6
	custom_price = PAYCHECK_EASY * 1.6
