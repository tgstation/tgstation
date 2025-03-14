///Normal bag
/datum/storage/bag
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	numerical_stacking = TRUE

///Trash bag
/datum/storage/bag/trash_bag
	max_slots = 30
	max_total_storage = 30
	supports_smart_equip = FALSE
	max_specific_storage = WEIGHT_CLASS_SMALL

/datum/storage/bag/trash_bag/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(cant_hold_list = /obj/item/disk/nuclear)

/datum/storage/bag/trash_bag/remove_single(mob/removing, obj/item/thing, atom/remove_to_loc, silent)
	real_location.visible_message(
		span_notice("[removing] starts fishing around inside [parent]."),
		span_notice("You start digging around in [parent] to try and pull something out."),
	)
	if(!do_after(removing, 1.5 SECONDS, parent))
		return FALSE

	return ..()

///Bluespace trash bag
/datum/storage/bag/trash_bag/bluespace
	max_slots = 60
	max_total_storage = 60

///Ore bag
/datum/storage/bag/ore_bag
	max_total_storage = 50
	numerical_stacking = TRUE
	allow_quick_empty = TRUE
	allow_quick_gather = TRUE
	silent_for_user = TRUE
	max_specific_storage = WEIGHT_CLASS_HUGE

/datum/storage/bag/ore_bag/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/stack/ore)

///Bluespace ore bag
/datum/storage/bag/ore_bag/bluespace
	max_slots = INFINITY
	max_specific_storage = INFINITY
	max_total_storage = INFINITY

///Plant bag
/datum/storage/bag/plants
	max_slots = 100
	max_total_storage = 100
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/bag/plants/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
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
	allow_quick_empty = TRUE
	allow_quick_gather = TRUE
	numerical_stacking = TRUE

/datum/storage/bag/sheet_snatcher/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(
		can_hold_list = list(
			/obj/item/stack/sheet
		),
		cant_hold_list = list(
			/obj/item/stack/sheet/mineral/sandstone,
			/obj/item/stack/sheet/mineral/wood,
		),
	)

///Sheet snatcher debug bag
/datum/storage/bag/sheet_snatcher/debug/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/stack)

///Sheet snatcher cyborg bag
/datum/storage/bag/sheet_snatcher_cyborg
	max_total_storage = 250

///Book bag
/datum/storage/bag/books
	max_slots = 7
	max_total_storage = 21
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/bag/books/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(list(
		/obj/item/book,
		/obj/item/spellbook,
		/obj/item/poster,
	))

///Tray bag
/datum/storage/bag/tray
	max_slots = 8
	max_total_storage = 16
	insert_preposition = "on"
	max_specific_storage = WEIGHT_CLASS_BULKY //Plates are required bulky to keep them out of backpacks

/datum/storage/bag/tray/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
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
	max_slots = 50
	max_total_storage = 200

/datum/storage/bag/chemistry/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
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
	max_slots = 25
	max_total_storage = 200

/datum/storage/bag/bio/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
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

///Science bag
/datum/storage/bag/science
	max_slots = 25
	max_total_storage = 200

/datum/storage/bag/science/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
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

/datum/storage/bag/construction/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
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
	))

///Harpoon quiver
/datum/storage/bag/harpoon_quiver
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 40
	max_total_storage = 100

/datum/storage/bag/harpoon_quiver/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/ammo_casing/harpoon)

///New bar quiver
/datum/storage/bag/rebar_quiver
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 10
	max_total_storage = 15

/datum/storage/bag/rebar_quiver/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(list(
		/obj/item/ammo_casing/rebar,
		/obj/item/ammo_casing/rebar/syndie,
		/obj/item/ammo_casing/rebar/healium,
		/obj/item/ammo_casing/rebar/hydrogen,
		/obj/item/ammo_casing/rebar/zaukerite,
		/obj/item/ammo_casing/rebar/paperball,
	))

///Syndicate rebar quiver
/datum/storage/bag/rebar_quiver/syndicate
	max_slots = 20
	max_total_storage = 20

///Garment bag
/datum/storage/bag/garment
	max_slots = 18
	max_total_storage = 200
	max_specific_storage = WEIGHT_CLASS_BULKY
	numerical_stacking = FALSE
	insert_preposition = "in"

/datum/storage/bag/garment/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/clothing)


///Mail storage bag
/datum/storage/bag/mail
	max_total_storage = 42
	max_slots = 21
	numerical_stacking = FALSE
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/bag/mail/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(list(
		/obj/item/mail,
		/obj/item/delivery/small,
		/obj/item/paper
	))

///Fishing bag
/datum/storage/bag/fishing
	max_total_storage = 24 // Up to 8 normal fish
	max_slots = 21

/datum/storage/bag/fishing/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	. = ..()

	if(!length(holdables))
		holdables = list(/obj/item/fish)

	set_holdable(/obj/item/fish)

///Carpskin fishing bag
/datum/storage/bag/fishing/carpskin
	max_total_storage = 42 // Up to 14 normal fish, but we're assuming that you'll be storing a bunch of gear as well

/datum/storage/bag/fishing/carpskin/New(atom/parent, max_slots, max_specific_storage, max_total_storage, list/holdables)
	holdables = list(
		/obj/item/fish,
		/obj/item/fishing_line,
		/obj/item/fishing_hook,
		/obj/item/fishing_lure,
		/obj/item/fish_analyzer,
		/obj/item/bait_can,
	)

	return ..()

///Dutchmen bag
/datum/storage/bag/dutchmen
	max_slots = 19
	max_total_storage = 21

///Money bag
/datum/storage/bag/money
	max_slots = 40
	max_specific_storage = 40

/datum/storage/bag/money/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(list(
		/obj/item/coin,
		/obj/item/stack/spacecash,
		/obj/item/holochip
	))

///Bag of quivers
/datum/storage/bag/quivers
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 40
	max_total_storage = 100
	numerical_stacking = TRUE

/datum/storage/bag/quivers/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/ammo_casing/arrow)

///Bag of smaller quivers
/datum/storage/bag/quivers/lesser
	max_slots = 10

///Endless quivers
/datum/storage/bag/quivers/endless
	max_slots = 1

/datum/storage/bag/quivers/endless/handle_exit(datum/source, obj/item/gone)
	. = ..()

	var/obj/item/storage/bag/quiver/store = source

	new store.arrow_path(store)
