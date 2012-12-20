/obj/item/clothing/head/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	flags = FPRINT | TABLEPASS
	item_state = "hardhat0_yellow"
	brightness_on = 4 //luminosity when on
	light_on = 0
	color = "yellow" //Determines used sprites: hardhat[on]_[color] and hardhat[on]_[color]2 (lying down sprite)
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 10, bomb = 20, bio = 10, rad = 20)
	flags_inv = 0
	icon_action_button = "action_hardhat"

	attack_self(mob/user)
		if(!isturf(user.loc))
			user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
			return
		light_on = !light_on
		icon_state = "hardhat[light_on]_[color]"
		item_state = "hardhat[light_on]_[color]"

		if((light_on) && (user.luminosity < brightness_on))
			user.SetLuminosity(brightness_on)
		else
			user.SetLuminosity(search_light(user, src))

	pickup(mob/user)
		if(light_on)
			if (user.luminosity < brightness_on)
				user.SetLuminosity(brightness_on)
//			user.UpdateLuminosity()	//TODO: Carn
			SetLuminosity(0)

	dropped(mob/user)
		if(light_on)
			if ((layer <= 3) || (loc != user.loc))
				user.SetLuminosity(search_light(user, src))
				SetLuminosity(brightness_on)
	//			user.UpdateLuminosity()

	equipped(mob/user, slot)
		if(light_on)
			if (user.luminosity < brightness_on)
				user.SetLuminosity(brightness_on)
//			user.UpdateLuminosity()	//TODO: Carn
			SetLuminosity(0)


/obj/item/clothing/head/hardhat/orange
	icon_state = "hardhat0_orange"
	item_state = "hardhat0_orange"
	color = "orange"

/obj/item/clothing/head/hardhat/red
	icon_state = "hardhat0_red"
	item_state = "hardhat0_red"
	color = "red"
	name = "firefighter helmet"
	flags = FPRINT | TABLEPASS | STOPSPRESSUREDMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECITON_TEMPERATURE

/obj/item/clothing/head/hardhat/white
	icon_state = "hardhat0_white"
	item_state = "hardhat0_white"
	color = "white"
	flags = FPRINT | TABLEPASS | STOPSPRESSUREDMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECITON_TEMPERATURE

/obj/item/clothing/head/hardhat/dblue
	icon_state = "hardhat0_dblue"
	item_state = "hardhat0_dblue"
	color = "dblue"

