/datum/mod_theme/covert
	name = "covert"
	desc = "A rarely seen MOD design of unknown origin, covered in sleek armor and with a menacingly solid faceplate."
	extended_desc = "Not all that much is known about this type of suit, dubbed the 'Covert' type by most who come across it. \
		The build is a streamlined layering consisting of shaped Plastitanium, and composite ceramic, while the under suit is \
		lined with a lightweight Kevlar and durathread hybrid weave to provide ample protection to the user where the plating \
		doesn't, with an illegal onboard electric powered ablative shield module to provide resistance against conventional \
		energy firearms. In addition, it has an in-built chameleon system, allowing you to disguise the suit while undeployed. \
		Aside from that, there are no manufcaturer marks or tags to be found, and even the color scheme is unfamiliar when \
		it comes to most known MOD producers."
	default_skin = "stealth"
	armor_type = /datum/armor/mod_theme_covert
	resistance_flags = FIRE_PROOF | ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_inactive = 0
	slowdown_active = 0
	ui_theme = "hackerman"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	inbuilt_modules = list(
		/obj/item/mod/module/storage/belt,
		/obj/item/mod/module/chameleon/contractor,
		/obj/item/mod/module/welding/camera_vision,
		/obj/item/mod/module/stealth,
	)
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
	)
	skins = list(
		"stealth" = list(
			MOD_ICON_OVERRIDE = 'monkestation/code/modules/assault_ops/icons/modsuits/mod.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/code/modules/assault_ops/icons/modsuits/wornmod.dmi',
			HELMET_LAYER = NECK_LAYER,
			HELMET_FLAGS = list(
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			CHESTPLATE_FLAGS  = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)

/datum/armor/mod_theme_covert
	melee = 30
	bullet = 50
	laser = 40
	energy = 30
	bomb = 30
	bio = 30
	fire = 100
	acid = 100
	wound = 25

/obj/item/mod/control/pre_equipped/stealth_operative
	worn_icon = 'monkestation/code/modules/assault_ops/icons/modsuits/wornmod.dmi'
	icon = 'monkestation/code/modules/assault_ops/icons/modsuits/mod.dmi'
	icon_state = "stealth-control"
	theme = /datum/mod_theme/covert
	applied_cell = /obj/item/stock_parts/cell/hyper
	applied_modules = list(
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/visor/night,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/tether,
		/obj/item/mod/module/holster,
	)

/obj/machinery/suit_storage_unit/industrial/assault_operative
	mod_type = /obj/item/mod/control/pre_equipped/stealth_operative
	storage_type = /obj/item/tank/internals/emergency_oxygen/double
