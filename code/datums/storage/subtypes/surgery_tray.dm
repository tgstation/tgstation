/datum/storage/surgery_tray
	max_total_storage = 30
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 14
	animated = FALSE

/datum/storage/surgery_tray/New()
	. = ..()
	set_holdable(list(
		/obj/item/autopsy_scanner,
		/obj/item/blood_filter,
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/clothing/mask/surgical,
		/obj/item/hemostat,
		/obj/item/razor,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/stack/medical/bone_gel,
		/obj/item/stack/sticky_tape/surgical,
		/obj/item/surgical_drapes,
		/obj/item/surgicaldrill,
	))
