///Regular medkit
/datum/storage/medkit
	open_sound = 'sound/items/handling/medkit/medkit_open.ogg'
	open_sound_vary = TRUE
	rustle_sound = 'sound/items/handling/medkit/medkit_rustle.ogg'
	max_specific_storage = WEIGHT_CLASS_SMALL

	///List of everything a medkit can hold
	VAR_FINAL/static/list/obj/item/list_of_everything_medkits_can_hold = list(
		//surgery tools
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/blood_filter,

		//special tools
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/lazarus_injector,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,

		//stacks
		/obj/item/stack/medical,
		/obj/item/stack/sticky_tape,

		//containers
		/obj/item/reagent_containers/applicator,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/blood,

		//storage items
		/obj/item/storage/box/bandages,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/box/evilmeds,

		//clothing
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/clothing/gloves,
		/obj/item/clothing/mask/muzzle,
		/obj/item/clothing/glasses,

		//mod suite
		/obj/item/mod/module/thread_ripper,
		/obj/item/mod/module/surgical_processor/preloaded,
		/obj/item/mod/module/defibrillator/combat,
		/obj/item/mod/module/health_analyzer,

		//misc
		/obj/item/lighter,
		/obj/item/sensor_device,
		/obj/item/radio,
		/obj/item/bikehorn/rubberducky,
		/obj/item/shears,
		/obj/item/geiger_counter,
		/obj/item/flashlight/pen,
		/obj/item/extinguisher/mini,
		/obj/item/stamp,
		/obj/item/wrench/medical,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/gun/syringe/syndicate,
		/obj/item/pinpointer/crew,
		/obj/item/holosign_creator/medical,
		/obj/item/autosurgeon/syndicate/emaggedsurgerytoolset,
	)

/datum/storage/medkit/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables = null)
	. = ..()
	if(!isnull(holdables))
		set_holdable(holdables)

///Surgery medkit
/datum/storage/medkit/surgery
	max_slots = 12
	max_total_storage = 24
	max_specific_storage = WEIGHT_CLASS_NORMAL //holds the same equipment as a medibelt

/datum/storage/medkit/surgery/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	holdables = list_of_everything_medkits_can_hold
	return ..()

///Tactical medkit
/datum/storage/medkit/tactical
	max_slots = 21
	max_total_storage = 24
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/medkit/tactical/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	holdables = list_of_everything_medkits_can_hold
	return ..()

///Premium tactical medkit
/datum/storage/medkit/tactical/premium
	allow_big_nesting = TRUE // so you can put back the box you took out
	max_total_storage = 34

///Coroner medkit
/datum/storage/medkit/coroner
	max_slots = 14
	max_total_storage = 24
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/medkit/coroner/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	holdables = list(
		/obj/item/reagent_containers,
		/obj/item/bodybag,
		/obj/item/toy/crayon,
		/obj/item/pen,
		/obj/item/paper,
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/autopsy_scanner,
	)
	return ..()
