/datum/mod_theme/waffles
	name = "Waffles' corporate"
	desc = "A heavily modified suit created by Waffles to distinguish himself from other CentCom Officers. If you are not Waffles you shouldn't be wearing this!"
	default_skin = "waffles"
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = 50
	armor_type= /datum/armor/mod_theme_waffles
	charge_drain = DEFAULT_CHARGE_DRAIN * 0
	siemens_coefficient = 0
	slowdown_inactive = 0
	slowdown_active = 0
	ui_theme = "wizard"
	inbuilt_modules = list(/obj/item/mod/module/anti_magic/wizard)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	skins = list(
		"waffles" = list(
			MOD_ICON_OVERRIDE = 'monkestation/icons/obj/clothing/modsuits/modsuit.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/icons/mob/clothing/worn_modsuit.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
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

/datum/armor/mod_theme_waffles
	melee = 50
	bullet = 60
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	wound = 30
