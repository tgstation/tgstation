///Normal box
/datum/storage/box
	max_specific_storage = WEIGHT_CLASS_SMALL
	open_sound = 'sound/items/handling/cardboard_box/cardboard_box_open.ogg'
	rustle_sound = 'sound/items/handling/cardboard_box/cardboard_box_rustle.ogg'

///Debug tools box
/datum/storage/box/debug
	allow_big_nesting = TRUE
	max_slots = 99
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 99

///Donk Pocket box
/datum/storage/box/donk_pockets/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/food/donkpocket)

///Coffee box
/datum/storage/box/coffee
	max_slots = 5

/datum/storage/box/coffee/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/food/grown/coffee)

///Bandage box
/datum/storage/box/bandages
	max_slots = 6

/datum/storage/box/bandages/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/stack/medical/bandage,
		/obj/item/reagent_containers/applicator/pill,
		/obj/item/reagent_containers/applicator/patch,
	))

///Monkey cube box
/datum/storage/box/monkey_cube
	max_slots = 7

/datum/storage/box/monkey_cube/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(
		can_hold_list = /obj/item/food/monkeycube,
		cant_hold_list = /obj/item/food/monkeycube/gorilla,
	)

///Gorilla cube box
/datum/storage/box/gorilla_cube_box
	max_slots = 3

/datum/storage/box/gorilla_cube_box/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/food/monkeycube/gorilla)

///Stabalized extract box
/datum/storage/box/stabilized
	allow_big_nesting = TRUE
	max_slots = 99
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 99

///Snappops box
/datum/storage/box/snappops
	max_slots = 8

/datum/storage/box/snappops/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/toy/snappop)

///Match box
/datum/storage/box/match
	max_slots = 10

/datum/storage/box/match/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/match)

///Light Box
/datum/storage/box/lights
	max_slots = 21
	max_total_storage = 21
	allow_quick_gather = FALSE //temp workaround to re-enable filling the light replacer with the box

/datum/storage/box/lights/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/light/tube,
		/obj/item/light/bulb
	))

///Balloon box
/datum/storage/box/balloon
	max_slots = 24
	max_total_storage = 24
	allow_quick_gather = FALSE

/datum/storage/box/balloon/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/toy/balloon/long)

///Stickers Box
/datum/storage/box/stickers
	max_slots = 8
	max_specific_storage = WEIGHT_CLASS_TINY

/datum/storage/box/stickers/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/sticker)

///Syndicate space box
/datum/storage/box/syndicate_space
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/box/syndicate_space/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/clothing/suit/space/syndicate,
		/obj/item/clothing/head/helmet/space/syndicate
	))

///Syndicate chemical box
/datum/storage/box/syndicate_chemical
	max_slots = 15

///Syndicate throwing weapons box
/datum/storage/box/syndicate_throwing
	max_slots = 9 // 5 + 2 + 2
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = 18 // 5*2 + 2*1 + 3*2

/datum/storage/box/syndicate_throwing/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/restraints/legcuffs/bola/tactical,
		/obj/item/paperplane/syndicate,
		/obj/item/throwing_star,
	))

///Stickers skub box
/datum/storage/box/skub
	max_slots = 3

/datum/storage/box/skub/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(exception_hold_list = list(
		/obj/item/skub,
		/obj/item/clothing/suit/costume/wellworn_shirt/skub,
	))

///Stickers anti skub box
/datum/storage/box/anti_skub/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(exception_hold_list = /obj/item/clothing/suit/costume/wellworn_shirt/skub)

///Flat box
/datum/storage/box/flat
	max_slots = 3

///Gum Box
/datum/storage/box/gum
	max_slots = 4
	allow_big_nesting = TRUE

/datum/storage/box/gum/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/storage/bubblegum_wrapper)

///Fishing lures box
/datum/storage/box/fishing_lures/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	//adds an extra slot, so we can put back the lures even if we didn't take out the instructions.
	var/static/slots = length(typesof(/obj/item/fishing_lure)) + 1
	max_slots = slots
	max_total_storage = WEIGHT_CLASS_SMALL * slots
	. = ..()
	set_holdable(/obj/item/fishing_lure) //can only hold lures
	
