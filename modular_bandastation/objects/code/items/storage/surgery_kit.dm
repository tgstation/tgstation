/obj/item/storage/medkit/surgery_kit
	name = "surgery kit"
	desc = "Коробка для медицинских принадлежностей и инструментов."
	icon = 'modular_bandastation/objects/icons/obj/items/medical.dmi'
	icon_state = "surgery_kit"
	inhand_icon_state = "surgery_kit"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/surgery_kit_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/surgery_kit_righthand.dmi'
	storage_type = /datum/storage/medkit/surgery_kit

/datum/storage/medkit/surgery_kit
	max_slots = 9
	max_total_storage = 24
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/medkit/surgery_kit/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound, list/holdables)
	holdables = list(
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/blood_filter,
		/obj/item/healthanalyzer,
		/obj/item/blood_scanner,
		/obj/item/reflexhammer,
		/obj/item/shears,
		/obj/item/bodybag,
		/obj/item/reagent_containers/medigel,
		/obj/item/stack/medical/wrap/sticky_tape,
		/obj/item/stack/medical,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/blood,
	)
	return ..()

/datum/crafting_recipe/surgery_kit
	name = "surgery kit"
	result = /obj/item/storage/medkit/surgery_kit
	time = 12 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/storage/medkit = 1,
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/sheet/plastic = 10,
		/obj/item/stack/medical/wrap/sticky_tape = 2
	)
	category = CAT_CONTAINERS
	crafting_flags = CRAFT_SKIP_MATERIALS_PARITY
