/obj/item/clothing/head/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"//Could stand to be renamed
	item_state = "hardhat0_pumpkin"
	color = "pumpkin"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | HEADCOVERSMOUTH | BLOCKHAIR
	see_face = 0.0
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	var/brightness_on = 2 //luminosity when on
	var/on = 0

	attack_self(mob/user)
		if(!isturf(user.loc))
			user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
			return
		on = !on
		icon_state = "hardhat[on]_[color]"
		item_state = "hardhat[on]_[color]"

		if(on)
			user.total_luminosity += brightness_on
		else
			user.total_luminosity -= brightness_on

	pickup(mob/user)
		if(on)
			user.total_luminosity += brightness_on
			user.UpdateLuminosity()
			src.sd_SetLuminosity(0)

	dropped(mob/user)
		if(on)
			user.total_luminosity -= brightness_on
			user.UpdateLuminosity()
			src.sd_SetLuminosity(brightness_on)