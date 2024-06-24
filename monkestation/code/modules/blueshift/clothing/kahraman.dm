// Backpacks

/obj/item/storage/backpack/industrial/frontier_colonist
	name = "frontier backpack"
	desc = "A rugged backpack often used by settlers and explorers. Holds all of your equipment and then some."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "backpack"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	worn_icon_state = "backpack"
	inhand_icon_state = "backpack"

/obj/item/storage/backpack/industrial/frontier_colonist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

/obj/item/storage/backpack/industrial/frontier_colonist/satchel
	name = "frontier satchel"
	desc = "A rugged satchel often used by settlers and explorers. Holds less of your equipment than a backpack will."
	icon_state = "satchel"
	worn_icon_state = "satchel"

/obj/item/storage/backpack/industrial/frontier_colonist/messenger
	name = "frontier messenger bag"
	desc = "A rugged messenger bag often used by settlers and explorers. Holds less of your equipment than a backpack will."
	icon_state = "messenger"
	worn_icon_state = "messenger"

// Belts

/obj/item/storage/belt/utility/frontier_colonist
	name = "frontier chest rig"
	desc = "A versatile chest rig with pockets to store really whatever you could think of within. \
		That is, if whatever you could think of is within the realms of a utility belt. Fashion like this \
		comes at a price you know!"
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "harness"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	worn_icon_state = "harness"
	inhand_icon_state = null

/obj/item/storage/belt/utility/frontier_colonist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)
	atom_storage.max_slots = 6
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	// Can hold whatever a toolbelt can + some mining equipment for convenience
	atom_storage.set_holdable(list(
		/obj/item/airlock_painter,
		/obj/item/analyzer,
		/obj/item/assembly/signaler,
		/obj/item/clothing/gloves,
		/obj/item/construction,
		/obj/item/crowbar,
		/obj/item/extinguisher/mini,
		/obj/item/flashlight,
		/obj/item/forcefield_projector,
		/obj/item/geiger_counter,
		/obj/item/holosign_creator,
		/obj/item/inducer,
		/obj/item/lightreplacer,
		/obj/item/multitool,
		/obj/item/pipe_dispenser,
		/obj/item/pipe_painter,
		/obj/item/plunger,
		/obj/item/radio,
		/obj/item/screwdriver,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/gps,
		/obj/item/knife,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/shovel,
		/obj/item/survivalcapsule,
		/obj/item/storage/bag/ore,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/wormhole_jaunter,
		/obj/item/resonator,
	))

// Its modsuiting time

/datum/mod_theme/frontier_colonist
	name = "frontier hazard protective"
	desc = "An unusual design of suit, in reality being no more than a slim underlayer with a built in coat and sealed helmet."
	extended_desc = "The pinnacle of frontier cheap technology. Suits like this are usually not unified in design \
		though are common in frontier settlements with less than optimal infrastructure. As with most unofficial \
		designs, there are flaws and no single one is perfect, but they achieve a singular goal and that is the \
		important part. Suits such as these are made specifically for the rare emergency that creates a hazard \
		environment that other equipment just can't quite handle. Often, these suits are able to protect their users \
		from not only electricity, but also radiation, biological hazards, other people, so on. This suit will not, \
		however, protect you from yourself."

	default_skin = "colonist"
	armor_type = /datum/armor/colonist_hazard
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_inactive = 1.5
	slowdown_active = 1
	inbuilt_modules = list(
		/obj/item/mod/module/plate_compression/permanent,
		/obj/item/mod/module/joint_torsion/permanent
	)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/flashlight,
		/obj/item/gun,
		/obj/item/melee,
		/obj/item/tank/internals,
		/obj/item/storage/belt/holster,
		/obj/item/construction,
		/obj/item/fireaxe,
		/obj/item/pipe_dispenser,
		/obj/item/storage/bag,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/storage/medkit,
	)
	skins = list(
		"colonist" = list(
			MOD_ICON_OVERRIDE = 'monkestation/code/modules/blueshift/icons/modsuits/mod.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/code/modules/blueshift/icons/modsuits/mod_worn.dmi',
			HELMET_FLAGS= list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS= list(
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

/obj/item/mod/control/pre_equipped/frontier_colonist
	theme = /datum/mod_theme/frontier_colonist
	applied_cell = /obj/item/stock_parts/cell/high
	applied_modules = list(
		/obj/item/mod/module/welding,
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/thermal_regulator,
		/obj/item/mod/module/rad_protection,
	)
	default_pins = list(
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/thermal_regulator,
	)

/obj/item/mod/control/pre_equipped/frontier_colonist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

// Plate compression module that cannot be removed

/obj/item/mod/module/plate_compression/permanent
	removable = FALSE
	complexity = 0

// Joint torsion module that can't be removed and has no complexity

/obj/item/mod/module/joint_torsion/permanent
	removable = FALSE
	complexity = 0

// Jumpsuit

/obj/item/clothing/under/frontier_colonist
	name = "frontier jumpsuit"
	desc = "A heavy grey jumpsuit with extra padding around the joints. Two massive pockets included. \
		No matter what you do to adjust it, its always just slightly too large."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "jumpsuit"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn_digi.dmi'
	worn_icon_state = "jumpsuit"
	has_sensor = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/frontier_colonist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

// Boots

/obj/item/clothing/shoes/jackboots/frontier_colonist
	name = "heavy frontier boots"
	desc = "A well built pair of tall boots usually seen on the feet of explorers, first wave colonists, \
		and LARPers across the galaxy."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "boots"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn_digi.dmi'
	armor_type = /datum/armor/colonist_clothing
	resistance_flags = NONE

/obj/item/clothing/shoes/jackboots/frontier_colonist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

// Jackets

/obj/item/clothing/suit/jacket/frontier_colonist
	name = "frontier trenchcoat"
	desc = "A knee length coat with a water-resistant exterior and relatively comfortable interior. \
		In between? Just enough protective material to stop the odd sharp thing getting through, \
		though don't expect miracles."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "jacket"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	worn_icon_state = "jacket"
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK
	armor_type = /datum/armor/colonist_clothing
	resistance_flags = NONE
	allowed = null

/obj/item/clothing/suit/jacket/frontier_colonist/Initialize(mapload)
	. = ..()
	allowed += GLOB.colonist_suit_allowed
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

/obj/item/clothing/suit/jacket/frontier_colonist/short
	name = "frontier jacket"
	desc = "A short coat with a water-resistant exterior and relatively comfortable interior. \
		In between? Just enough protective material to stop the odd sharp thing getting through, \
		though don't expect miracles."
	icon_state = "jacket_short"
	worn_icon_state = "jacket_short"

/obj/item/clothing/suit/jacket/frontier_colonist/medical
	name = "frontier medical jacket"
	desc = "A short coat with a water-resistant exterior and relatively comfortable interior. \
		In between? Just enough protective material to stop the odd sharp thing getting through, \
		though don't expect miracles. This one is colored a bright red and covered in white \
		stripes to denote that someone wearing it might be able to provide medical assistance."
	icon_state = "jacket_med"
	worn_icon_state = "jacket_med"

// Flak Jacket

/obj/item/clothing/suit/frontier_colonist_flak
	name = "frontier flak jacket"
	desc = "A simple flak jacket with an exterior of water-resistant material. \
		Jackets like these are often found on first wave colonists that want some armor \
		due to the fact they can be made easily within a colony core type machine."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "flak"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	worn_icon_state = "flak"
	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor_type = /datum/armor/colonist_armor
	resistance_flags = NONE
	allowed = null

/obj/item/clothing/suit/frontier_colonist_flak/Initialize(mapload)
	. = ..()
	allowed += GLOB.colonist_suit_allowed
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

// Various softcaps

/obj/item/clothing/head/soft/frontier_colonist
	name = "frontier cap"
	desc = "It's a robust baseball hat in a rugged green color."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "cap"
	soft_type = "cap"
	soft_suffix = null
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	worn_icon_state = "cap"

/obj/item/clothing/head/soft/frontier_colonist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

/obj/item/clothing/head/soft/frontier_colonist/medic
	name = "frontier medical cap"
	desc = "It's a robust baseball hat in a stylish red color. Has a white diamond to denote that its wearer might be able to provide medical assistance."
	icon_state = "cap_medical"
	soft_type = "cap_medical"
	worn_icon_state = "cap_medical"

// Helmet (Is it a helmet? Questionable? I'm not sure what to call this thing)

/obj/item/clothing/head/frontier_colonist_helmet
	name = "frontier soft helmet"
	desc = "A unusual piece of headwear somewhere between a proper helmet and a normal cap."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "tanker"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	worn_icon_state = "tanker"
	armor_type = /datum/armor/colonist_armor
	resistance_flags = NONE
	flags_inv = 0
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/frontier_colonist_helmet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

// Headset

/obj/item/radio/headset/headset_frontier_colonist
	name = "frontier radio headset"
	desc = "A bulky headset that should hopefully survive exposure to the elements better than station headsets might. \
		Has a built-in antenna allowing the headset to work independently of a communications network."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "radio"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	worn_icon_state = "radio"
	alternate_worn_layer = FACEMASK_LAYER + 0.5
	subspace_transmission = FALSE

/obj/item/radio/headset/headset_frontier_colonist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

// Gloves

/obj/item/clothing/gloves/frontier_colonist
	name = "frontier gloves"
	desc = "A sturdy pair of black gloves that'll keep your precious fingers protected from the outside world. \
		They go a bit higher up the arm than most gloves should, and you aren't quite sure why."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "gloves"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	worn_icon_state = "gloves"
	greyscale_colors = "#3a373e"
	siemens_coefficient = 0.25 // Doesn't insulate you entirely, but makes you a little more resistant
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	clothing_traits = list(TRAIT_QUICK_CARRY)

/obj/item/clothing/gloves/frontier_colonist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

// Special mask

/obj/item/clothing/mask/gas/atmos/frontier_colonist
	name = "frontier gas mask"
	desc = "An improved gas mask commonly seen in places where the atmosphere is less than breathable, \
		but otherwise more or less habitable. Its certified to protect against most biological hazards \
		to boot."
	icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing.dmi'
	icon_state = "mask"
	worn_icon = 'monkestation/code/modules/blueshift/icons/clothes/clothing_worn.dmi'
	worn_icon_state = "mask"
	flags_inv = HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	armor_type = /datum/armor/colonist_hazard

/obj/item/clothing/mask/gas/atmos/frontier_colonist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_KAHRAMAN)

/datum/armor/colonist_clothing
	laser = ARMOR_LEVEL_TINY
	energy = ARMOR_LEVEL_TINY
	bomb = ARMOR_LEVEL_TINY
	bio = ARMOR_LEVEL_TINY
	fire = ARMOR_LEVEL_WEAK
	acid = ARMOR_LEVEL_TINY
	wound = WOUND_ARMOR_WEAK

/datum/armor/colonist_armor
	melee = ARMOR_LEVEL_WEAK
	bullet = ARMOR_LEVEL_WEAK
	laser = ARMOR_LEVEL_TINY
	energy = ARMOR_LEVEL_TINY
	bomb = ARMOR_LEVEL_TINY
	bio = ARMOR_LEVEL_TINY
	fire = ARMOR_LEVEL_WEAK
	acid = ARMOR_LEVEL_TINY
	wound = WOUND_ARMOR_STANDARD

/datum/armor/colonist_hazard
	melee = ARMOR_LEVEL_TINY
	bullet = ARMOR_LEVEL_TINY
	laser = ARMOR_LEVEL_WEAK
	energy = ARMOR_LEVEL_WEAK
	bomb = ARMOR_LEVEL_MID
	bio = 100
	fire = 100
	acid = ARMOR_LEVEL_MID
	wound = WOUND_ARMOR_WEAK
