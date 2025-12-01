/**
 * Storage datums used for fancy storages
 */

/// Donut Boxes
/datum/storage/donut_box
	max_slots = 6

/datum/storage/donut_box/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/food/donut)

/// Egg Boxes
/datum/storage/egg_box
	max_slots = 12
	// So we have two rows of 6, like the box visually has
	screen_max_columns = 6

/datum/storage/egg_box/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/food/egg,
		/obj/item/food/chocolateegg,
		/obj/item/food/boiledegg,
		/obj/item/food/scotchegg,
		/obj/item/food/grown/eggy,
		/obj/item/surprise_egg,
	))

/// Candle Boxes
/datum/storage/candle_box
	max_slots = 5

/datum/storage/candle_box/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/flashlight/flare/candle)

/// Cigarette Boxes
/datum/storage/cigarette_box
	max_slots = 6
	display_contents = FALSE
	rustle_sound = SFX_CIG_PACK_INSERT
	remove_rustle_sound = SFX_CIG_PACK_RUSTLE

/datum/storage/cigarette_box/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/cigarette,
		/obj/item/lighter,
	))

/// Rolling Paper Packs
/datum/storage/rolling_paper_pack
	max_slots = 10
	screen_max_columns = 5

/datum/storage/rolling_paper_pack/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/rollingpaper)

/// Cigar Boxes
/datum/storage/cigar_box
	max_slots = 5
	display_contents = FALSE

/datum/storage/cigar_box/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/cigarette/cigar,
	))

/// Heart-Shaped Chocolate Boxes
/datum/storage/heart_box
	max_slots = 8
	screen_max_columns = 4

/datum/storage/heart_box/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/food/bonbon)

/// Nugget Boxes
/datum/storage/nugget_box
	max_slots = 6

/datum/storage/nugget_box/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/food/nugget,
		/obj/item/fish/fryish,
	))

/// Jars of Pickles
/datum/storage/pickles_jar
	max_slots = 10
	max_total_storage = WEIGHT_CLASS_SMALL * 10
	screen_max_columns = 5

/datum/storage/pickles_jar/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/food/pickle)

/// Coffee Condiment Displays
/datum/storage/coffee_condi_display
	max_slots = 14

/datum/storage/coffee_condi_display/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(
		/obj/item/reagent_containers/condiment/pack/sugar,
		/obj/item/reagent_containers/condiment/creamer,
		/obj/item/reagent_containers/condiment/pack/astrotame,
		/obj/item/reagent_containers/condiment/chocolate,
	))

/// Coffee Cart Racks
/datum/storage/coffee_cart_rack
	max_slots = 4

/datum/storage/coffee_cart_rack/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(/obj/item/coffee_cartridge)
