/obj/item/storage/epic_loot_medpen_case
	name = "autoinjector case"
	desc = "A semi-rigid case for holding a large number of autoinjectors inside of."
	icon = 'modular_doppler/epic_loot/icons/storage_items.dmi'
	icon_state = "pencase"
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	pickup_sound = SFX_CLOTH_PICKUP
	drop_sound = SFX_CLOTH_DROP
	storage_type = /datum/storage/maintenance_loot_structure/epic_loot_medpen_case
	slot_flags = ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_BULKY

/datum/storage/maintenance_loot_structure/epic_loot_medpen_case
	max_slots = 6
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = WEIGHT_CLASS_SMALL * 6
	numerical_stacking = TRUE
	opening_sound = 'sound/items/zip/un_zip.ogg'

/datum/storage/maintenance_loot_structure/epic_loot_medpen_case/New()
	. = ..()

	can_hold = typecacheof(list(
		/obj/item/dnainjector,
		/obj/item/hypospray,
		/obj/item/implant,
		/obj/item/implantcase,
		/obj/item/implanter,
		/obj/item/lazarus_injector,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/applicator/pill,
		/obj/item/storage/pill_bottle,
	))

/obj/item/storage/epic_loot_docs_case
	name = "documents case"
	desc = "A large pouch conveniently shaped to hold all of the valueable paperwork in the galaxy."
	icon = 'modular_doppler/epic_loot/icons/storage_items.dmi'
	icon_state = "documents"
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	pickup_sound = SFX_CLOTH_PICKUP
	drop_sound = SFX_CLOTH_DROP
	storage_type = /datum/storage/maintenance_loot_structure/epic_loot_docs_case
	slot_flags = ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_BULKY

/datum/storage/maintenance_loot_structure/epic_loot_docs_case
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = WEIGHT_CLASS_BULKY * 4
	screen_max_columns = 2
	numerical_stacking = TRUE
	opening_sound = 'sound/items/handling/cloth/cloth_pickup1.ogg'

/datum/storage/maintenance_loot_structure/epic_loot_docs_case/New()
	. = ..()

	can_hold = typecacheof(list(
		/obj/item/folder,
		/obj/item/epic_loot/intel_folder,
		/obj/item/epic_loot/corpo_folder,
		/obj/item/epic_loot/slim_diary,
		/obj/item/epic_loot/diary,
		/obj/item/computer_disk,
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/documents,
		/obj/item/paperwork,
		/obj/item/clipboard,
	))

/obj/item/storage/epic_loot_org_pouch
	name = "organizational pouch"
	desc = "A pouch with every possible type of pocket and organizer stuck into it, to hold all of the small stuff you could think of."
	icon = 'modular_doppler/epic_loot/icons/storage_items.dmi'
	icon_state = "sick"
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	pickup_sound = SFX_CLOTH_PICKUP
	drop_sound = SFX_CLOTH_DROP
	storage_type = /datum/storage/maintenance_loot_structure/epic_loot_org_pouch
	slot_flags = ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_BULKY

/datum/storage/maintenance_loot_structure/epic_loot_org_pouch
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = WEIGHT_CLASS_SMALL * 4
	screen_max_columns = 2
	numerical_stacking = TRUE
	opening_sound = 'sound/items/zip/un_zip.ogg'

/obj/item/storage/epic_loot_cooler
	name = "compact cooler"
	desc = "A wonder in food storage technology, it's a blue bag that you can put food in."
	icon = 'modular_doppler/epic_loot/icons/storage_items.dmi'
	icon_state = "cooler"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	inhand_icon_state = "toolbox_blue"
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	storage_type = /datum/storage/maintenance_loot_structure/epic_loot_cooler
	w_class = WEIGHT_CLASS_BULKY

/datum/storage/maintenance_loot_structure/epic_loot_cooler
	max_slots = 12
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = WEIGHT_CLASS_BULKY * 12
	screen_max_columns = 4
	numerical_stacking = FALSE
	opening_sound = 'sound/items/zip/un_zip.ogg'

/datum/storage/maintenance_loot_structure/epic_loot_cooler/New()
	. = ..()

	can_hold = typecacheof(list(
		/obj/item/food,
		/obj/item/reagent_containers/condiment,
		/obj/item/reagent_containers/cup,
	))

/obj/item/storage/epic_loot_money_case
	name = "money case"
	desc = "A heavy duty case for the transportation of (bribe) money."
	icon = 'modular_doppler/epic_loot/icons/storage_items.dmi'
	icon_state = "money_case"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	inhand_icon_state = "lockbox"
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	storage_type = /datum/storage/maintenance_loot_structure/epic_loot_the_money
	w_class = WEIGHT_CLASS_BULKY

/datum/storage/maintenance_loot_structure/epic_loot_the_money
	max_slots = 6
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = WEIGHT_CLASS_NORMAL * 6
	screen_max_columns = 2
	numerical_stacking = FALSE
	opening_sound = 'modular_doppler/epic_loot/sound/wood_crate_1.mp3'

/datum/storage/maintenance_loot_structure/epic_loot_the_money/New()
	. = ..()

	can_hold = typecacheof(list(
		/obj/item/stack/spacecash,
		/obj/item/coin,
	))

/obj/item/storage/epic_loot_medical_case
	name = "medical case"
	desc = "A heavy duty case for the transportation of medical supplies."
	icon = 'modular_doppler/epic_loot/icons/storage_items.dmi'
	icon_state = "medical"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	inhand_icon_state = "bitrunning"
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	storage_type = /datum/storage/maintenance_loot_structure/epic_loot_medkit
	w_class = WEIGHT_CLASS_BULKY

/datum/storage/maintenance_loot_structure/epic_loot_medkit
	max_slots = 21
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = WEIGHT_CLASS_BULKY * 21
	screen_max_columns = 7
	numerical_stacking = FALSE
	opening_sound = 'modular_doppler/epic_loot/sound/wood_crate_1.mp3'

/datum/storage/maintenance_loot_structure/epic_loot_medkit/New()
	. = ..()

	can_hold = typecacheof(list(
		/obj/item/blood_filter,
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/muzzle,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/suit/toggle/labcoat/hospitalgown,
		/obj/item/construction/plumbing,
		/obj/item/dnainjector,
		/obj/item/extinguisher/mini,
		/obj/item/flashlight/pen,
		/obj/item/geiger_counter,
		/obj/item/gun/syringe/syndicate,
		/obj/item/healthanalyzer,
		/obj/item/hemostat,
		/obj/item/holosign_creator/medical,
		/obj/item/hypospray,
		/obj/item/implant,
		/obj/item/implantcase,
		/obj/item/implanter,
		/obj/item/lazarus_injector,
		/obj/item/lighter,
		/obj/item/pinpointer/crew,
		/obj/item/plunger,
		/obj/item/radio,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/applicator/pill,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/syringe,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/shears,
		/obj/item/stack/medical,
		/obj/item/stack/sticky_tape,
		/obj/item/stamp,
		/obj/item/sensor_device,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/surgical_drapes,
		/obj/item/surgicaldrill,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/wrench/medical,
		/obj/item/emergency_bed,
		/obj/item/storage/box/bandages,
		/obj/item/bodybag,
	))
