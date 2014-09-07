	//Regular (engineering) hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	allowed = list(/obj/item/device/flashlight)
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	item_color = "engineering" //Determines used sprites: hardsuit[on]-[color] and hardsuit[on]-[color]2 (lying down sprite)
	action_button_name = "Toggle Helmet Light"

	attack_self(mob/user)
		if(!isturf(user.loc))
			user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
			return
		on = !on
		icon_state = "hardsuit[on]-[item_color]"
//		item_state = "hardsuit[on]-[item_color]"
		user.update_inv_head()	//so our mob-overlays update

		if(on)	user.AddLuminosity(brightness_on)
		else	user.AddLuminosity(-brightness_on)

	pickup(mob/user)
		if(on)
			user.AddLuminosity(brightness_on)
//			user.UpdateLuminosity()
			SetLuminosity(0)

	dropped(mob/user)
		if(on)
			user.AddLuminosity(-brightness_on)
//			user.UpdateLuminosity()
			SetLuminosity(brightness_on)

/obj/item/clothing/suit/space/hardsuit
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	slowdown = 2
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/t_scanner, /obj/item/weapon/rcd)
	//RIG health monitor code and vars(think dead space) -PJB3005
	var/healthmonitored = 1//not all hardsuits have sprites that support the monitors, this enabled/disables it to prevent lag
	var/healthstates = list(
	"hardsuit-engineering",
	"hardsuit-engineering1",
	"hardsuit-engineering2",//icon_states for the harsuits with their health states, from full to sub-stages to crit to dead
	"hardsuit-engineering3",
	"hardsuit-engineering4",
	"hardsuit-engineering5"
	)


/obj/item/clothing/suit/space/hardsuit/New()
	..()
	processing_objects.Add(src)
//processing list for health monitor updates (i know i could use life() or whatever it is(if it even is here) on /TG/, i'm just not good enough at coding
/obj/item/clothing/suit/space/hardsuit/Del()
	..()
	processing_objects.Remove(src)
/obj/item/clothing/suit/space/hardsuit/proc/updatehealthmonitor()
	var/mob/living/carbon/human/M = loc//only way to get the wearer into a var that i know of -PJ
	var/monitor_oldstate
	if(healthmonitored)
		if(!istype(M)) return//only do the rest if it's a human wearing it, not if it's a floor/suit storage unit/locker/etc, dont want to spam proc crashes
		if(M.health >= 100){monitor_oldstate = icon_state;icon_state =  healthstates[1]}
		else if(M.health >= 75){monitor_oldstate = icon_state;icon_state =  healthstates[2]}
		else if(M.health >= 30){monitor_oldstate = icon_state;icon_state =  healthstates[3]}
		else if(M.health > 0){monitor_oldstate = icon_state;icon_state =  healthstates[4]}//this code's inneficient, uses icons instead of overlays in seperate files, as such; lot's of clutter in the .DMIs, patch this up if you want -PJ
		else if(M.health > -200){monitor_oldstate = icon_state;icon_state =  healthstates[5]}
		else {monitor_oldstate = icon_state;icon_state =  healthstates[6]}//can't be any other state, AKA dead
		if(monitor_oldstate != icon_state)M.regenerate_icons()

/obj/item/clothing/suit/space/hardsuit/process()//actually UPDATE the thing
	updatehealthmonitor()

	//Atmospherics
/obj/item/clothing/head/helmet/space/hardsuit/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding."
	icon_state = "hardsuit0-atmospherics"
	item_state = "atmo_helm"
	item_color = "atmospherics"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/atmos
	name = "atmospherics hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has thermal shielding."
	icon_state = "hardsuit-atmospherics"
	item_state = "atmo_hardsuit"
	healthstates = list(
	"hardsuit-atmospherics",
	"hardsuit-atmospherics1",
	"hardsuit-atmospherics2",
	"hardsuit-atmospherics3",
	"hardsuit-atmospherics4",
	"hardsuit-atmospherics5",
	)
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT


	//Chief Engineer's hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "hardsuit0-white"
	item_state = "ce_helm"
	item_color = "white"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/elite
	icon_state = "hardsuit-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	healthstates = list(
	"hardsuit-white",
	"hardsuit-white1",
	"hardsuit-white2",
	"hardsuit-white3",
	"hardsuit-white4",
	"hardsuit-white5",
	)

	//Mining hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "hardsuit0-mining"
	item_state = "mining_helm"
	item_color = "mining"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)

/obj/item/clothing/suit/space/hardsuit/mining
	icon_state = "hardsuit-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	item_state = "mining_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/weapon/pickaxe)
	healthstates = list(
	"hardsuit-mining",
	"hardsuit-mining1",
	"hardsuit-mining2",
	"hardsuit-mining3",
	"hardsuit-mining4",
	"hardsuit-mining5",
	)


	//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced helmet designed for work in special operations. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)

/obj/item/clothing/suit/space/hardsuit/syndi
	icon_state = "hardsuit-syndi"
	name = "blood-red hardsuit"
	desc = "An advanced suit that protects against injuries during special operations. Property of Gorlex Marauders."
	item_state = "syndie_hardsuit"
	slowdown = 1
	w_class = 3
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen)
	healthstates = list(
	"hardsuit-syndi",
	"hardsuit-syndi1",
	"hardsuit-syndi2",
	"hardsuit-syndi3",
	"hardsuit-syndi4",
	"hardsuit-syndi5",
	)

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
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT

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
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	healthstates = list(
	"hardsuit-wiz",
	"hardsuit-wiz1",
	"hardsuit-wiz2",
	"hardsuit-wiz3",
	"hardsuit-wiz4",
	"hardsuit-wiz5",
	)

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
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50)
	healthstates = list(
	"hardsuit-medical",
	"hardsuit-medical1",
	"hardsuit-medical2",
	"hardsuit-medical3",
	"hardsuit-medical4",
	"hardsuit-medical5",
	)


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
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank, /obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs)
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 10, bio = 100, rad = 50)
	healthmonitored = 0//sprite doesn't have a health meter