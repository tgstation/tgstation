/obj/item/clothing/shoes/wheelys
	name = "Wheely-Heels"
	desc = "Uses patented retractable wheel technology. Never sacrifice speed for style - not that this provides much of either." //Thanks Fel
	icon_state = "sneakers"
	worn_icon_state = "wheelys"
	inhand_icon_state = "sneakers_back"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_wheelys
	greyscale_config_inhand_left = /datum/greyscale_config/sneakers/inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/sneakers/inhand_right
	worn_icon = 'icons/mob/large-worn-icons/64x64/feet.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64
	clothing_flags = parent_type::clothing_flags | LARGE_WORN_ICON
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
		balloon_alert(user, "must be worn!")
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
	playsound(src, 'sound/items/weapons/tap.ogg', 10, TRUE)
	update_appearance()

/obj/item/clothing/shoes/wheelys/Destroy()
	QDEL_NULL(wheels)
	. = ..()

/obj/item/clothing/shoes/wheelys/rollerskates
	name = "roller skates"
	desc = "An EightO brand pair of roller skates. The wheels are retractable, though're quite bulky to walk in."
	icon_state = "rollerskates"
	inhand_icon_state = null
	greyscale_colors = null
	greyscale_config = null
	worn_icon_state = "rollerskates"
	slowdown = SHOES_SLOWDOWN+1
	wheels = /obj/vehicle/ridden/scooter/skateboard/wheelys/rollerskates
	custom_premium_price = PAYCHECK_CREW * 5
	custom_price = PAYCHECK_CREW * 5

/obj/item/clothing/shoes/wheelys/skishoes
	name = "ski shoes"
	desc = "A pair of shoes equipped with foldable skis! Very handy to move in snowy environments unimpeded."
	icon_state = "skishoes"
	inhand_icon_state = null
	greyscale_colors = null
	greyscale_config = null
	worn_icon_state = "skishoes"
	slowdown = SHOES_SLOWDOWN+1
	wheels = /obj/vehicle/ridden/scooter/skateboard/wheelys/skishoes
	custom_premium_price = PAYCHECK_CREW * 1.6
	custom_price = PAYCHECK_CREW * 1.6
