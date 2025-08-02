//For storage types that are small enough to fit in this file

///Test tube rack
/datum/storage/test_tube_rack
	max_slots = 8
	screen_max_columns = 4
	screen_max_rows = 2
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE

/datum/storage/test_tube_rack/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/reagent_containers/cup/tube)

///Surgery tray
/datum/storage/surgery_tray
	max_total_storage = 30
	max_slots = 14
	animated = FALSE

/datum/storage/surgery_tray/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
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
		/obj/item/reagent_containers/medigel/sterilizine,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/stack/medical/bone_gel,
		/obj/item/stack/sticky_tape/surgical,
		/obj/item/surgical_drapes,
		/obj/item/surgicaldrill,
		/obj/item/blood_scanner,
	))

///Organ box
/datum/storage/organ_box
	max_specific_storage = WEIGHT_CLASS_BULKY
	max_total_storage = 21

/datum/storage/organ_box/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/organ,
		/obj/item/bodypart,
		/obj/item/food/icecream,
	))

/datum/storage/organ_box/handle_enter(obj/item/storage/organbox/source, obj/item/arrived)
	. = ..()
	if(istype(arrived) && istype(source) && source.coolant_to_spend())
		arrived.freeze()

/datum/storage/organ_box/handle_exit(datum/source, obj/item/gone)
	. = ..()
	if(istype(gone))
		gone.unfreeze()

///Portable chem mixer
/datum/storage/portable_chem_mixer
	max_total_storage = 200
	max_slots = 50

/datum/storage/portable_chem_mixer/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/cup/glass/waterbottle,
		/obj/item/reagent_containers/condiment,
	))

///Implant
/datum/storage/implant
	max_total_storage = 6
	max_slots = 2
	silent = TRUE
	allow_big_nesting = TRUE

/datum/storage/implant/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(cant_hold_list = /obj/item/disk/nuclear)

///Drone storage
/datum/storage/drone
	max_total_storage = 40
	max_slots = 10
	do_rustle = FALSE

/datum/storage/drone/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/crowbar/drone,
		/obj/item/screwdriver/drone,
		/obj/item/wrench/drone,
		/obj/item/weldingtool/drone,
		/obj/item/wirecutters/drone,
		/obj/item/multitool/drone,
		/obj/item/pipe_dispenser/drone,
		/obj/item/t_scanner/drone,
		/obj/item/analyzer/drone,
		/obj/item/soap/drone,
	))

/datum/storage/drone/dump_content_at(atom/dest_object, dump_loc, mob/user)
	return //no dumping of contents allowed

///Basket
/datum/storage/basket
	max_total_storage = 21

///Easter basket
/datum/storage/basket/easter/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/food/egg,
		/obj/item/food/chocolateegg,
		/obj/item/food/boiledegg,
		/obj/item/surprise_egg
	))

/datum/storage/basket/easter/handle_enter(datum/source, obj/item/arrived)
	. = ..()
	countEggs(source)

/datum/storage/basket/easter/proc/countEggs(obj/item/storage/basket/easter/basket)
	basket.cut_overlays()
	basket.add_overlay("basket-grass")
	basket.add_overlay("basket-egg[min(basket.contents.len, 5)]")

/datum/storage/basket/easter/handle_exit(datum/source, obj/item/gone)
	. = ..()
	countEggs(source)

///Briefcase
/datum/storage/briefcase
	max_total_storage = 21

///Pill bottle
/datum/storage/pillbottle
	allow_quick_gather = TRUE
	open_sound = 'sound/items/handling/pill_bottle_open.ogg'
	open_sound_vary = FALSE

/datum/storage/pillbottle/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/reagent_containers/applicator,
		/obj/item/food/bait/natural,
	))

///Six pack beer
/datum/storage/sixcan
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = 12
	max_slots = 6

/datum/storage/sixcan/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/reagent_containers/cup/soda_cans,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/reagent_containers/cup/glass/bottle/ale,
		/obj/item/reagent_containers/cup/glass/waterbottle,
	))

///Wallet storage
/datum/storage/wallet
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_slots = 4

/datum/storage/wallet/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(
		can_hold_list = list(
			/obj/item/stack/spacecash,
			/obj/item/holochip,
			/obj/item/card,
			/obj/item/cigarette,
			/obj/item/clothing/accessory/dogtag,
			/obj/item/coin,
			/obj/item/coupon,
			/obj/item/dice,
			/obj/item/disk,
			/obj/item/flashlight/pen,
			/obj/item/folder/biscuit,
			/obj/item/food/chococoin,
			/obj/item/implanter,
			/obj/item/laser_pointer,
			/obj/item/lighter,
			/obj/item/lipstick,
			/obj/item/match,
			/obj/item/paper,
			/obj/item/pen,
			/obj/item/photo,
			/obj/item/reagent_containers/dropper,
			/obj/item/reagent_containers/syringe,
			/obj/item/reagent_containers/applicator,
			/obj/item/screwdriver,
			/obj/item/seeds,
			/obj/item/spess_knife,
			/obj/item/stack/medical,
			/obj/item/stamp,
			/obj/item/toy/crayon,
		),
		cant_hold_list = list(
			/obj/item/screwdriver/power
		)
	)

///Crayons storage
/datum/storage/crayons/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(
		can_hold_list = /obj/item/toy/crayon,
		cant_hold_list = list(
			/obj/item/toy/crayon/spraycan,
			/obj/item/toy/crayon/mime,
			/obj/item/toy/crayon/rainbow,
		),
	)

///Dice storage
/datum/storage/dice
	allow_quick_gather = TRUE

/datum/storage/dice/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/dice)

///Mail counterfeit
/datum/storage/mail_counterfeit
	max_slots = 1
	allow_big_nesting = TRUE

///Mail counterfeit advanced
/datum/storage/mail_counterfeit/advanced
	max_slots = 21
	max_total_storage = 21

///Mail counterfeit bluespace
/datum/storage/mail_counterfeit/bluespace
	max_total_storage = 35
	max_slots = 30
	max_specific_storage = WEIGHT_CLASS_GIGANTIC

///Card binder
/datum/storage/card_binder
	max_total_storage = 120
	max_slots = 60

/datum/storage/card_binder/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/tcgcard)

///Toilet bong
/datum/storage/toiletbong
	max_slots = 12
	max_total_storage = 100
	attack_hand_interact = FALSE
	do_rustle = FALSE
	animated = FALSE

/datum/storage/toiletbong/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/food)

/// Carved Books
/datum/storage/carved_book
	max_slots = 1

/datum/storage/carved_book/bible
	max_specific_storage = WEIGHT_CLASS_SMALL
