	//Regular (engineering) hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	item_color = "engineering" //Determines used sprites: hardsuit[on]-[color] and hardsuit[on]-[color]2 (lying down sprite)
	action_button_name = "Toggle Helmet Light"

/obj/item/clothing/head/helmet/space/hardsuit/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
		return
	on = !on
	icon_state = "hardsuit[on]-[item_color]"
//	item_state = "hardsuit[on]-[item_color]"
	user.update_inv_head()	//so our mob-overlays update

	if(on)	user.AddLuminosity(brightness_on)
	else	user.AddLuminosity(-brightness_on)

/obj/item/clothing/head/helmet/space/hardsuit/pickup(mob/user)
	if(on)
		user.AddLuminosity(brightness_on)
//		user.UpdateLuminosity()
		SetLuminosity(0)

/obj/item/clothing/head/helmet/space/hardsuit/dropped(mob/user)
	if(on)
		user.AddLuminosity(-brightness_on)
//		user.UpdateLuminosity()
		SetLuminosity(brightness_on)

/obj/item/clothing/suit/space/hardsuit
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	slowdown = 2
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/device/t_scanner, /obj/item/weapon/rcd)


	//Atmospherics
/obj/item/clothing/head/helmet/space/hardsuit/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding."
	icon_state = "hardsuit0-atmospherics"
	item_state = "atmo_helm"
	item_color = "atmospherics"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/atmos
	name = "atmospherics hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has thermal shielding."
	icon_state = "hardsuit-atmospherics"
	item_state = "atmo_hardsuit"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT


	//Chief Engineer's hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "hardsuit0-white"
	item_state = "ce_helm"
	item_color = "white"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/elite
	icon_state = "hardsuit-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT


	//Mining hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating for wildlife encounters."
	icon_state = "hardsuit0-mining"
	item_state = "mining_helm"
	item_color = "mining"
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)

/obj/item/clothing/suit/space/hardsuit/mining
	icon_state = "hardsuit-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating for wildlife encounters."
	item_state = "mining_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/storage/bag/ore,/obj/item/weapon/pickaxe)



	//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	on = 1
	action_button_name = "Toggle Helmet Mode"

/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_icon()
	icon_state = "hardsuit[on]-[item_color]"

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot toggle your helmet while in this [user.loc]" //To prevent some lighting anomalities.
		return
	on = !on
	if(on)
		user << "<span class='notice'>You switch your helmet to travel mode.</span>"
		name = "blood-red hardsuit helmet"
		desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
		flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE | THICKMATERIAL
		flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
		cold_protection = HEAD
		user.AddLuminosity(brightness_on)
	else
		user << "<span class='notice'>You switch your helmet to combat mode.</span>"
		name = "blood-red hardsuit helmet (combat)"
		desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
		flags = BLOCKHAIR
		flags_inv = HIDEEARS
		cold_protection = null
		user.AddLuminosity(-brightness_on)

	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	user.update_inv_head()

/obj/item/clothing/suit/space/hardsuit/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	slowdown = 1
	w_class = 3
	var/on = 1
	action_button_name = "Toggle Hardsuit Mode"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword/saber,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank/emergency_oxygen)

/obj/item/clothing/suit/space/hardsuit/syndi/update_icon()
	icon_state = "hardsuit[on]-[item_color]"

/obj/item/clothing/suit/space/hardsuit/syndi/attack_self(mob/user)
	on = !on
	if(on)
		user << "<span class='notice'>You switch your hardsuit to travel mode.</span>"
		name = "blood-red hardsuit helmet"
		desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
		slowdown = 1
		flags = STOPSPRESSUREDMAGE | THICKMATERIAL
		flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
		cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	else
		user << "<span class='notice'>You switch your hardsuit to combat mode.</span>"
		name = "blood-red hardsuit helmet (combat)"
		desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
		slowdown = 0
		flags = BLOCKHAIR
		flags_inv = null
		cold_protection = null

	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	user.update_inv_wear_suit()
	user.update_inv_w_uniform()

	//Wizard hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "hardsuit0-wiz"
	item_state = "wiz_helm"
	item_color = "wiz"
	unacidable = 1 //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 40, bullet = 20, laser = 20, energy = 20, bomb = 35, bio = 100, rad = 50)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1

/obj/item/clothing/suit/space/hardsuit/wizard
	icon_state = "hardsuit-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	slowdown = 1
	w_class = 3
	unacidable = 1
	armor = list(melee = 40, bullet = 20, laser = 20, energy = 20, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/teleportation_scroll,/obj/item/weapon/tank/emergency_oxygen)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	unacidable = 1


	//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort."
	icon_state = "hardsuit0-medical"
	item_state = "medical_helm"
	item_color = "medical"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50)

/obj/item/clothing/suit/space/hardsuit/medical
	icon_state = "hardsuit-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Built with lightweight materials for easier movement."
	item_state = "medical_hardsuit"
	slowdown = 1
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50)


	//Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	item_color = "sec"
	armor = list(melee = 30, bullet = 15, laser = 30,energy = 10, bomb = 10, bio = 100, rad = 50)

/obj/item/clothing/suit/space/hardsuit/security
	icon_state = "hardsuit-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen, /obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs)
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 10, bio = 100, rad = 50)
