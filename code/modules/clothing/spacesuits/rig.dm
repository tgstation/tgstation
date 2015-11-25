//Regular rig suits
/obj/item/clothing/head/helmet/space/rig
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight)
	light_power = 1.7
	var/brightness_on = 4 //Luminosity when on. If modified, do NOT run update_brightness() directly
	var/on = 0 //Remember to run update_brightness() when modified, otherwise disasters happen
	var/no_light = 0 //Disables the helmet light when set to 1. Make sure to run check_light() if this is updated
	_color = "engineering" //Determines used sprites: rig[on]-[_color]. Use update_icon() directly to update the sprite. NEEDS TO BE SET CORRECTLY FOR HELMETS
	action_button_name = "Toggle Helmet Light"
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	pressure_resistance = 200 * ONE_ATMOSPHERE
	eyeprot = 3
	species_restricted = list("exclude","Vox")

/obj/item/clothing/head/helmet/space/rig/New()
	..()
	//Needed to properly handle helmets with no lights
	check_light()
	//Useful for helmets with special starting conditions (namely, starts lit)
	update_brightness()
	update_icon()

/obj/item/clothing/head/helmet/space/rig/examine(mob/user)

	..()
	if(!no_light) //There is a light attached or integrated
		to_chat(user, "The helmet is mounted with an Internal Lighting System, it is [on ? "":"un"]lit.")

//We check no_light and update everything accordingly
//Used to clear up the action button and shut down the light if broken
//Minimizes snowflake coding and allows dynamically disabling the helmet's light if needed
/obj/item/clothing/head/helmet/space/rig/proc/check_light()


	if(no_light) //There's no light on the helmet
		if(on) //The helmet light is currently on
			on = 0 //Force it off
			update_brightness() //Update as neccesary
		action_button_name = null //Disable the action button (which is only used to toggle the light, in theory)
	else //We have a light
		action_button_name = initial(action_button_name) //Make sure we restore the action button

/obj/item/clothing/head/helmet/space/rig/proc/update_brightness()


	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	update_icon()

/obj/item/clothing/head/helmet/space/rig/update_icon()

	icon_state = "rig[on]-[_color]" //No need for complicated if trees

/obj/item/clothing/head/helmet/space/rig/attack_self(mob/user)
	if(no_light)
		return

	on = !on
	update_icon()
	user.update_inv_head()

	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	user.update_inv_head()

/obj/item/clothing/suit/space/rig
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = 1
	species_restricted = list("exclude","Vox")
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/device/rcd, /obj/item/weapon/wrench/socket)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	pressure_resistance = 200 * ONE_ATMOSPHERE

//Chief Engineer's rig
/obj/item/clothing/head/helmet/space/rig/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "rig0-white"
	item_state = "ce_helm"
	_color = "white"
	species_restricted = list("exclude","Vox")
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	flags = FPRINT  | PLASMAGUARD

/obj/item/clothing/suit/space/rig/elite
	icon_state = "rig-white"
	name = "advanced hardsuit"
	species_restricted = list("exclude","Vox")
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	flags = FPRINT  | PLASMAGUARD


//Mining rig
/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "rig0-mining"
	item_state = "mining_helm"
	_color = "mining"
	species_restricted = list("exclude","Vox")
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	item_state = "mining_hardsuit"
	species_restricted = list("exclude","Vox")
	pressure_resistance = 40 * ONE_ATMOSPHERE


//Syndicate rig
/obj/item/clothing/head/helmet/space/rig/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced helmet designed for work in special operations. Property of Gorlex Marauders."
	icon_state = "rig0-syndi"
	item_state = "syndie_helm"
	species_fit = list("Vox")
	_color = "syndi"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 60)
	action_button_name = "Toggle Helmet Camera" //This helmet does not have a light, but we'll do as if
	siemens_coefficient = 0.6
	var/obj/machinery/camera/camera
	pressure_resistance = 40 * ONE_ATMOSPHERE

	species_restricted = null

/obj/item/clothing/head/helmet/space/rig/syndi/attack_self(mob/user)
	if(camera)
		..(user)
	else
		camera = new /obj/machinery/camera(src)
		camera.network = list("NUKE")
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		to_chat(user, "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>")

/obj/item/clothing/head/helmet/space/rig/syndi/examine(mob/user)
	..()
	if(get_dist(user,src) <= 1)
		to_chat(user, "<span class='info'>This helmet has a built-in camera. It's [camera ? "" : "in"]active.</span>")

/obj/item/clothing/suit/space/rig/syndi
	icon_state = "rig-syndi"
	name = "blood-red hardsuit"
	desc = "An advanced suit that protects against injuries during special operations. Property of Gorlex Marauders."
	item_state = "syndie_hardsuit"
	species_fit = list("Vox")
	slowdown = 1
	w_class = 3
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs)
	siemens_coefficient = 0.6
	pressure_resistance = 40 * ONE_ATMOSPHERE

	species_restricted = null

//Wizard Rig
/obj/item/clothing/head/helmet/space/rig/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state = "wiz_helm"
	_color = "wiz"
	species_restricted = list("exclude","Vox")
	unacidable = 1 //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7

	wizard_garb = 1

	species_restricted = null

/obj/item/clothing/suit/space/rig/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	slowdown = 1
	w_class = 3
	unacidable = 1
	species_restricted = list("exclude","Vox")
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7

	wizard_garb = 1

	species_restricted = null

//Medical Rig
/obj/item/clothing/head/helmet/space/rig/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has minor radiation shielding."
	icon_state = "rig0-medical"
	item_state = "medical_helm"
	_color = "medical"
	species_restricted = list("exclude","Vox")
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/suit/space/rig/medical
	icon_state = "rig-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has minor radiation shielding."
	item_state = "medical_hardsuit"
	species_restricted = list("exclude","Vox")
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	pressure_resistance = 40 * ONE_ATMOSPHERE


	//Security
/obj/item/clothing/head/helmet/space/rig/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous low pressure environment. Has an additional layer of armor."
	icon_state = "rig0-sec"
	item_state = "sec_helm"
	_color = "sec"
	species_restricted = list("exclude","Vox")
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	siemens_coefficient = 0.7
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/suit/space/rig/security
	icon_state = "rig-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	species_restricted = list("exclude","Vox")
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton)
	siemens_coefficient = 0.7
	pressure_resistance = 40 * ONE_ATMOSPHERE

//Atmospherics Rig (BS12)
/obj/item/clothing/head/helmet/space/rig/atmos
	desc = "A special helmet designed for work in hazardous low pressure environments. Has reduced radiation shielding to allow for greater mobility."
	name = "atmospherics hardsuit helmet"
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	_color = "atmos"
	species_restricted = list("exclude","Vox")
	flags = FPRINT  | PLASMAGUARD
	armor = list(melee = 40, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/rig/atmos
	desc = "A special suit that protects against hazardous low pressure environments. Has reduced radiation shielding to allow for greater mobility."
	icon_state = "rig-atmos"
	name = "atmos hardsuit"
	item_state = "atmos_hardsuit"
	species_restricted = list("exclude","Vox")
	flags = FPRINT  |  PLASMAGUARD
	armor = list(melee = 40, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

//Firefighting/Atmos RIG (old /vg/)
/obj/item/clothing/head/helmet/space/rig/atmos/gold
	desc = "A special helmet designed for work in hazardous low pressure environments and extreme temperatures. In other words, perfect for atmos."
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE*2
	name = "atmos hardsuit helmet"
	icon_state = "rig0-atmos_gold"
	item_state = "atmos_gold_helm"
	_color = "atmos_gold"
	species_restricted = list("exclude","Vox")
	no_light = 1

/obj/item/clothing/suit/space/rig/atmos/gold
	desc = "A special suit that protects against hazardous low pressure environments and extreme temperatures. In other words, perfect for atmos."
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE*4
	gas_transfer_coefficient = 0.80
	permeability_coefficient = 0.25
	icon_state = "rig-atmos_gold"
	name = "atmos hardsuit"
	item_state = "atmos_gold_hardsuit"
	slowdown = 2
	armor = list(melee = 30, bullet = 5, laser = 40,energy = 5, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/backpack/satchel_norm,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/device/rcd, /obj/item/weapon/extinguisher, /obj/item/weapon/)

//ADMINBUS RIGS. SOVIET + NAZI
/obj/item/clothing/head/helmet/space/rig/nazi
	name = "nazi hardhelmet"
	desc = "This is the face of das vaterland's top elite. Gas or energy are your only escapes."
	item_state = "rig0-nazi"
	icon_state = "rig0-nazi"
	species_restricted = list("exclude","Vox")//GAS THE VOX
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	_color = "nazi"
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/suit/space/rig/nazi
	name = "nazi hardsuit"
	desc = "The attire of a true krieger. All shall fall, and only das vaterland will remain."
	item_state = "rig-nazi"
	icon_state = "rig-nazi"
	slowdown = 1
	species_restricted = list("exclude","Vox")//GAS THE VOX
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/)
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/head/helmet/space/rig/soviet
	name = "soviet hardhelmet"
	desc = "Crafted with the pride of the proletariat. The vengeful gaze of the visor roots out all fascists and capitalists."
	item_state = "rig0-soviet"
	icon_state = "rig0-soviet"
	species_restricted = list("exclude","Vox")//HET
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	_color = "soviet"
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/suit/space/rig/soviet
	name = "soviet hardsuit"
	desc = "Crafted with the pride of the proletariat. The last thing the enemy sees is the bottom of this armor's boot."
	item_state = "rig-soviet"
	icon_state = "rig-soviet"
	slowdown = 1
	species_restricted = list("exclude","Vox")//HET
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/)
	pressure_resistance = 40 * ONE_ATMOSPHERE


//Death squad rig
/obj/item/clothing/head/helmet/space/rig/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "rig0-deathsquad"
	item_state = "rig0-deathsquad"
	armor = list(melee = 65, bullet = 55, laser = 35,energy = 20, bomb = 40, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	species_restricted = list("exclude","Vox")
	_color = "deathsquad"
	flags = FPRINT | PLASMAGUARD

/obj/item/clothing/suit/space/rig/deathsquad
	name = "deathsquad suit"
	desc = "A heavily armored suit that protects against a lot of things. Used in special operations."
	icon_state = "rig-deathsquad"
	item_state = "rig-deathsquad"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/pinpointer,/obj/item/weapon/shield/energy,/obj/item/weapon/plastique,/obj/item/weapon/disk/nuclear)
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.5
	species_restricted = list("exclude","Vox")
	flags = FPRINT | PLASMAGUARD


//Knight armour rigs
/obj/item/clothing/head/helmet/space/rig/knight
	name = "Space-Knight helm"
	desc = "A well polished helmet belonging to a Space-Knight. Favored by space-jousters for its ability to stay on tight after being launched from a mass driver."
	icon_state = "rig0-knight"
	item_state = "rig0-knight"
	armor = list(melee = 60, bullet = 40, laser = 40,energy = 30, bomb = 50, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	species_restricted = list("exclude","Vox")
	_color = "knight"
	flags = FPRINT | PLASMAGUARD

/obj/item/clothing/suit/space/rig/knight
	name = "Space-Knight armour"
	desc = "A well polished set of armour belonging to a Space-Knight. Maidens Rescued in Space: 100, Maidens who have slept with me in Space: 0"
	icon_state = "rig-knight"
	item_state = "rig-knight"
	slowdown = 1
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/melee/baton,/obj/item/weapon/tank,/obj/item/weapon/shield/energy,/obj/item/weapon/claymore)
	armor = list(melee = 60, bullet = 40, laser = 40,energy = 30, bomb = 50, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.5
	species_restricted = list("exclude","Vox")
	flags = FPRINT | PLASMAGUARD

/obj/item/clothing/head/helmet/space/rig/knight/black
	name = "Black Knight's helm"
	desc = "An ominous black helmet with a gold trim. The small viewports create an intimidating look, while also making it nearly impossible to see anything."
	icon_state = "rig0-blackknight"
	item_state = "rig0-blackknight"
	armor = list(melee = 70, bullet = 65, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)
	_color="blackknight"

/obj/item/clothing/suit/space/rig/knight/black
	name = "Black Knight's armour"
	desc = "An ominous black suit of armour with a gold trim. Surprisingly good at preventing accidental loss of limbs."
	icon_state = "rig-blackknight"
	item_state = "rig-blackknight"
	armor = list(melee = 70, bullet = 65, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)

/obj/item/clothing/head/helmet/space/rig/knight/solaire
	name = "Solar helm"
	desc = "A simple helmet. 'Made in Astora' is inscribed on the back."
	icon_state = "rig0-solaire"
	item_state = "rig0-solaire"
	armor = list(melee = 60, bullet = 65, laser = 90,energy = 30, bomb = 60, bio = 100, rad = 100)
	_color="solaire"

/obj/item/clothing/suit/space/rig/knight/solaire
	name = "Solar armour"
	desc = "A solar powered hardsuit with a fancy insignia on the chest. Perfect for stargazers and adventurers alike."
	icon_state = "rig-solaire"
	item_state = "rig-solaire"
	armor = list(melee = 60, bullet = 65, laser = 90,energy = 30, bomb = 60, bio = 100, rad = 100)


/obj/item/clothing/suit/space/rig/t51b
	name = "T-51b Power Armor"
	desc = "Relic of a bygone era, the T-51b is powered by a TX-28 MicroFusion Pack, which holds enough fuel to power its internal hydraulics for a century!"
	icon_state = "rig-t51b"
	item_state = "rig-t51b"
	armor = list(melee = 35, bullet = 35, laser = 40, energy = 40, bomb = 80, bio = 100, rad = 100)

/obj/item/clothing/head/helmet/space/rig/t51b
	name = "T-51b Power Armor Helmet"
	desc = "Relic of a bygone era, the T-51b is powered by a TX-28 MicroFusion Pack, which holds enough fuel to power its internal hydraulics for a century!"
	icon_state = "rig0-t51b"
	item_state = "rig0-t51b"
	armor = list(melee = 35, bullet = 35, laser = 40, energy = 40, bomb = 80, bio = 100, rad = 100)
	_color="t51b"
