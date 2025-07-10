///Normal bag
/datum/storage/bag
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	numerical_stacking = TRUE

///Trash Bag
/datum/storage/bag/trash
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = 30
	max_slots = 30
	supports_smart_equip = FALSE

/datum/storage/bag/trash/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(cant_hold_list = /obj/item/disk/nuclear)

/datum/storage/bag/trash/remove_single(mob/removing, obj/item/thing, atom/remove_to_loc, silent)
	real_location.visible_message(
		span_notice("[removing] starts fishing around inside [parent]."),
		span_notice("You start digging around in [parent] to try and pull something out."),
	)
	if(!do_after(removing, 1.5 SECONDS, parent))
		return FALSE

	return ..()

///Bluespace trash bag
/datum/storage/bag/trash/bluespace
	max_total_storage = 60
	max_slots = 60

///Ore Bag
/datum/storage/bag/ore
	max_specific_storage = WEIGHT_CLASS_HUGE
	max_total_storage = 50
	silent_for_user = TRUE

/datum/storage/bag/ore/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/stack/ore)

///Ore bag of holding
/datum/storage/bag/ore/holding
	max_slots = INFINITY
	max_specific_storage = INFINITY
	max_total_storage = INFINITY

///Plant bag
/datum/storage/bag/plants
	max_total_storage = 100
	max_slots = 100

/datum/storage/bag/plants/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/food/grown,
		/obj/item/graft,
		/obj/item/grown,
		/obj/item/food/honeycomb,
		/obj/item/seeds,
	))

///Sheet snatcher bag
/datum/storage/bag/sheet_snatcher
	max_total_storage = 150

/datum/storage/bag/sheet_snatcher/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(
		can_hold_list = /obj/item/stack/sheet,
		cant_hold_list = list(
			/obj/item/stack/sheet/mineral/sandstone,
			/obj/item/stack/sheet/mineral/wood,
		),
	)

///Borg sheet snatcher bag
/datum/storage/bag/sheet_snatcher/borg
	max_total_storage = 250

///Debug sheet snatcher bag
/datum/storage/bag/sheet_snatcher_debug
	allow_big_nesting = TRUE
	max_slots = 99
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 5000

/datum/storage/bag/sheet_snatcher_debug/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/stack/sheet,
		/obj/item/stack/sheet/mineral/sandstone,
		/obj/item/stack/sheet/mineral/wood,
	))

///Book bag
/datum/storage/bag/books
	max_total_storage = 21
	max_slots = 7

/datum/storage/bag/books/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/book,
		/obj/item/spellbook,
		/obj/item/poster,
	))

///Tray bag
/datum/storage/bag/tray
	max_specific_storage = WEIGHT_CLASS_BULKY //Plates are required bulky to keep them out of backpacks
	insert_preposition = "on"
	max_slots = 8
	max_total_storage = 16

/datum/storage/bag/tray/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(
		can_hold_list = list(
			/obj/item/cigarette,
			/obj/item/food,
			/obj/item/kitchen,
			/obj/item/lighter,
			/obj/item/organ,
			/obj/item/plate,
			/obj/item/reagent_containers/condiment,
			/obj/item/reagent_containers/cup,
			/obj/item/rollingpaper,
			/obj/item/storage/box/gum,
			/obj/item/storage/box/matches,
			/obj/item/storage/fancy,
			/obj/item/trash,
		),
		cant_hold_list = list(
			/obj/item/plate/oven_tray,
			/obj/item/reagent_containers/cup/soup_pot,
		),
	) //Should cover: Bottles, Beakers, Bowls, Booze, Glasses, Food, Food Containers, Food Trash, Organs, Tobacco Products, Lighters, and Kitchen Tools.

///Chemistry bag
/datum/storage/bag/chemistry
	max_total_storage = 200
	max_slots = 50

/datum/storage/bag/chemistry/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/reagent_containers/chem_pack,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/glass/waterbottle,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/applicator,
		/obj/item/reagent_containers/syringe,
	))

///Bio bag
/datum/storage/bag/bio
	max_total_storage = 200
	max_slots = 25

/datum/storage/bag/bio/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/bodypart,
		/obj/item/food/monkeycube,
		/obj/item/healthanalyzer,
		/obj/item/organ,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/reagent_containers/syringe,
	))

///Xeno bag
/datum/storage/bag/xeno
	max_total_storage = 200
	max_slots = 25

/datum/storage/bag/xeno/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/bodypart,
		/obj/item/food/deadmouse,
		/obj/item/food/monkeycube,
		/obj/item/organ,
		/obj/item/petri_dish,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/syringe,
		/obj/item/slime_extract,
		/obj/item/swab,
	))

///Construction bag
/datum/storage/bag/construction
	max_total_storage = 100
	max_slots = 50
	max_specific_storage = WEIGHT_CLASS_SMALL

/datum/storage/bag/construction/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/assembly,
		/obj/item/circuitboard,
		/obj/item/electronics,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/stack/cable_coil,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stock_parts,
		/obj/item/wallframe/camera,
		/obj/item/stack/sheet,
		/obj/item/rcd_ammo,
		/obj/item/stack/rods,
	))

///Harpoon quiver bag
/datum/storage/bag/harpoon_quiver
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 40
	max_total_storage = 100

/datum/storage/bag/harpoon_quiver/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/ammo_casing/harpoon)

///Rebar quiber bag
/datum/storage/bag/rebar_quiver
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 10
	max_total_storage = 15

/datum/storage/bag/rebar_quiver/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/ammo_casing/rebar,
	))

///Syndicate rebar quiver bag
/datum/storage/bag/rebar_quiver/syndicate
	max_slots = 20
	max_total_storage = 20

///Mail bag
/datum/storage/bag/mail
	max_total_storage = 42
	max_slots = 21
	numerical_stacking = FALSE

/datum/storage/bag/mail/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/mail,
		/obj/item/delivery/small,
		/obj/item/paper
	))

///Garment bag
/datum/storage/bag/garment
	numerical_stacking = FALSE
	max_total_storage = 200
	max_slots = 15
	insert_preposition = "in"

/datum/storage/bag/garment/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/clothing)

///Quiver bag
/datum/storage/bag/quiver
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 40
	max_total_storage = 100

/datum/storage/bag/quiver/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/ammo_casing/arrow)

///Quiver bag less
/datum/storage/bag/quiver/less
	max_slots = 10

///Quiver bag endless
/datum/storage/bag/quiver/endless
	max_slots = 1

/datum/storage/bag/quiver/endless/handle_exit(datum/source, obj/item/gone)
	. = ..()
	var/obj/item/storage/bag/quiver/endless/store = real_location
	new store.arrow_path(store)

///Money bag
/datum/storage/bag/money
	max_slots = 40
	max_specific_storage = 40

/datum/storage/bag/money/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/coin,
		/obj/item/stack/spacecash,
		/obj/item/holochip
	))

///Fishing bag
/datum/storage/bag/fishing
	max_total_storage = 24 // Up to 8 normal fish
	max_slots = 21

/datum/storage/bag/fishing/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/fish)
