/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	flags = HEADCOVERSEYES | HEADBANGPROTECT
	item_state = "helmet"
	armor = list(melee = 50, bullet = 15, laser = 50,energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|HEADBANGPROTECT
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	strip_delay = 80
	action_button_name = "Toggle Helmet Visor"
	visor_flags = HEADCOVERSEYES|HEADCOVERSMOUTH
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE

/obj/item/clothing/head/helmet/riot/attack_self()
	if(usr.canmove && !usr.stat && !usr.restrained())
		if(up)
			up = !up
			flags |= (visor_flags)
			flags_inv |= (visor_flags_inv)
			icon_state = initial(icon_state)
			usr << "You pull \the [src] down."
			usr.update_inv_head(0)
		else
			up = !up
			flags &= ~(visor_flags)
			flags_inv &= ~(visor_flags_inv)
			icon_state = "[initial(icon_state)]up"
			usr << "You push \the [src] up."
			usr.update_inv_head(0)

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "An extremely robust, space-worthy helmet with the Nanotrasen logo emblazoned on the top."
	icon_state = "swat"
	item_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80

/obj/item/clothing/head/helmet/bulletproof
	name = "tactical helmet"
	desc = "An advanced helmet designed to protect against traditional projectile weaponry and explosives."
	icon_state = "bulletproof"
	armor = list(melee = 25, bullet = 60, laser = 25, energy = 10, bomb = 40, bio = 0, rad = 0)
	strip_delay = 70

/obj/item/clothing/head/helmet/swat/syndicate
	name = "blood-red helmet"
	desc = "An extremely robust, space-worthy helmet that lacks a visor to allow for goggle usage underneath. Property of Gorlex Marauders."
	icon_state = "helmetsyndi"
	item_state = "helmet"

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	flags = HEADCOVERSEYES
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"
	strip_delay = 100

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = HEADCOVERSEYES|BLOCKHAIR
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

obj/item/clothing/head/helmet/redtaghelm
	name = "red laser tag helmet"
	desc = "They have chosen their own end."
	icon_state = "redtaghelm"
	flags = HEADCOVERSEYES
	item_state = "redtaghelm"
	armor = list(melee = 30, bullet = 10, laser = 20,energy = 10, bomb = 20, bio = 0, rad = 0)
	// Offer about the same protection as a hardhat.
	flags_inv = HIDEEARS|HIDEEYES

obj/item/clothing/head/helmet/bluetaghelm
	name = "blue laser tag helmet"
	desc = "They'll need more men."
	icon_state = "bluetaghelm"
	flags = HEADCOVERSEYES
	item_state = "bluetaghelm"
	armor = list(melee = 30, bullet = 10, laser = 20,energy = 10, bomb = 20, bio = 0, rad = 0)
	// Offer about the same protection as a hardhat.
	flags_inv = HIDEEARS|HIDEEYES
