/datum/mod_theme/contractor
	name = "contractor"
	desc = "A top-tier MODSuit developed with cooperation of Cybersun Industries and the Gorlex Marauders, a favorite of Syndicate Contractors."
	extended_desc = "A rare depart from the Syndicate's usual color scheme, the Contractor MODsuit is produced and manufactured \
		for specialty contractors. The build is a streamlined layering consisting of shaped Plastitanium, \
		and composite ceramic, while the under suit is lined with a lightweight Kevlar and durathread hybrid weave \
		to provide ample protection to the user where the plating doesn't, with an illegal onboard electric powered \
		ablative shield module to provide resistance against conventional energy firearms. \
		In addition, it has an in-built chameleon system, allowing you to disguise the suit while undeployed. \
		A small tag hangs off of it reading; 'Property of the Gorlex Marauders, with assistance from Cybersun Industries. \
		All rights reserved, tampering with suit will void warranty."
	default_skin = "contractor"
	armor_type = /datum/armor/mod_contractor_armor
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	ui_theme = "syndicate"
	inbuilt_modules = list(/obj/item/mod/module/armor_booster/contractor, /obj/item/mod/module/chameleon/contractor)
	allowed_suit_storage = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun/ballistic,
		/obj/item/gun/energy,
		/obj/item/gun/microfusion,
	)
	skins = list(
		"contractor" = list(
			MOD_ICON_OVERRIDE = 'monkestation/icons/obj/clothing/modsuits/modsuit.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/icons/mob/clothing/worn_modsuit.dmi',
			HELMET_LAYER = NECK_LAYER,
			HELMET_FLAGS = list(
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)
//ICONS BORKED
/datum/armor/mod_contractor_armor
	melee = 30
	bullet = 35
	laser = 15
	energy = 15
	bomb = 30
	bio = 40
	fire = 80
	acid = 90
	wound = 30
