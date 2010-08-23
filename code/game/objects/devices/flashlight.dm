#define FLASHLIGHT_LUM 4

/obj/item/device/flashlight/attack_self(mob/user)
	on = !on
	icon_state = "flight[on]"

	if(on)
		user.sd_SetLuminosity(user.luminosity + FLASHLIGHT_LUM)
	else
		user.sd_SetLuminosity(user.luminosity - FLASHLIGHT_LUM)


/obj/item/device/flashlight/pickup(mob/user)
	if(on)
		src.sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + FLASHLIGHT_LUM)



/obj/item/device/flashlight/dropped(mob/user)
	if(on)
		user.sd_SetLuminosity(user.luminosity - FLASHLIGHT_LUM)
		src.sd_SetLuminosity(FLASHLIGHT_LUM)

/obj/item/clothing/head/helmet/hardhat/attack_self(mob/user)
	on = !on
	icon_state = "hardhat[on]"
	item_state = "hardhat[on]"

	if(on)
		user.sd_SetLuminosity(user.luminosity + FLASHLIGHT_LUM)
	else
		user.sd_SetLuminosity(user.luminosity - FLASHLIGHT_LUM)

/obj/item/clothing/head/helmet/hardhat/pickup(mob/user)
	if(on)
		src.sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + FLASHLIGHT_LUM)



/obj/item/clothing/head/helmet/hardhat/dropped(mob/user)
	if(on)
		user.sd_SetLuminosity(user.luminosity - FLASHLIGHT_LUM)
		src.sd_SetLuminosity(FLASHLIGHT_LUM)