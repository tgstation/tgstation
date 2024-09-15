// Backpacks

/obj/item/storage/backpack/industrial/frontier_colonist
	name = "frontier backpack"
	desc = "A rugged backpack often used by settlers and explorers. Holds all of your equipment and then some."
	icon = 'modular_doppler/kahraman_equipment/icons/clothes/clothing.dmi'
	icon_state = "backpack"
	worn_icon = 'modular_doppler/kahraman_equipment/icons/clothes/clothing_worn.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
//	worn_icon_teshari = 'modular_doppler/kahraman_equipment/icons/clothes/clothing_worn_teshari.dmi'
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
	icon = 'modular_doppler/kahraman_equipment/icons/clothes/clothing.dmi'
	icon_state = "harness"
	worn_icon = 'modular_doppler/kahraman_equipment/icons/clothes/clothing_worn.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
//	worn_icon_teshari = 'modular_doppler/kahraman_equipment/icons/clothes/clothing_worn_teshari.dmi'
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
		/obj/item/spess_knife,
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
