/obj/item/clothing/head/helmet/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	flags = FPRINT | TABLEPASS | SUITSPACE
	item_state = "hardhat0_yellow"
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	color = "yellow" //Determines used sprites: hardhat[on]_[color] and hardhat[on]_[color]2 (lying down sprite)
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 10, bomb = 20, bio = 10, rad = 20)
	flags_inv = 0

/obj/item/clothing/head/helmet/hardhat/orange
	icon_state = "hardhat0_orange"
	item_state = "hardhat0_orange"
	color = "orange"

/obj/item/clothing/head/helmet/hardhat/red
	icon_state = "hardhat0_red"
	item_state = "hardhat0_red"
	color = "red"
	name = "firefighter helmet"
	flags = FPRINT | TABLEPASS | SUITSPACE | STOPSPRESSUREDMAGE

/obj/item/clothing/head/helmet/hardhat/white
	icon_state = "hardhat0_white"
	item_state = "hardhat0_white"
	color = "white"
	flags = FPRINT | TABLEPASS | SUITSPACE | STOPSPRESSUREDMAGE

/obj/item/clothing/head/helmet/hardhat/dblue
	icon_state = "hardhat0_dblue"
	item_state = "hardhat0_dblue"
	color = "dblue"

/obj/item/clothing/head/helmet/hardhat/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"
	item_state = "hardhat0_pumpkin"
	flags = FPRINT | TABLEPASS | HEADCOVERSEYES | HEADCOVERSMOUTH | BLOCKHAIR
	brightness_on = 3
	see_face = 0.0
	color = "pumpkin"
	armor = list(melee = 5, bullet = 0, laser = 5,energy = 5, bomb = 5, bio = 0, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES