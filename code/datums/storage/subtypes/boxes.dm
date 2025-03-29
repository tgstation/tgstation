///Small box storage
/datum/storage/box
	open_sound = 'sound/items/handling/cardboard_box/cardboard_box_open.ogg'
	rustle_sound = 'sound/items/handling/cardboard_box/cardboard_box_rustle.ogg'
	max_specific_storage = WEIGHT_CLASS_SMALL

///Flat box
/datum/storage/box/flat
	max_slots = 3

///Ingredient box
/datum/storage/box/ingredients
	max_specific_storage = WEIGHT_CLASS_NORMAL

///Coffee box
/datum/storage/box/coffee
	max_slots = 5

/datum/storage/box/coffee/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/food/grown/coffee)

///Donk pocket box
/datum/storage/box/donk_pockets/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/food/donkpocket)

///Bubble gum box
/datum/storage/box/bubble_gum
	max_slots = 4

/datum/storage/box/bubble_gum/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/food/bubblegum)

///Snappops box
/datum/storage/box/snappops
	max_slots = 8

/datum/storage/box/snappops/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/toy/snappop)

///Minor modkits box
/datum/storage/box/minor_modkits
	numerical_stacking = TRUE

/datum/storage/box/minor_modkits/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(list(
		/obj/item/borg/upgrade/modkit,
		/obj/item/crusher_trophy
	))

///Survival box
/datum/storage/box/survival/New(obj/item/storage/box/survival/parent, max_slots = src.max_slots, max_specific_storage, max_total_storage = src.max_total_storage)
	if(parent.crafted || !HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		return ..()

	//update storage
	max_slots += 2
	max_total_storage += 4

	//update parent
	parent.name = "large [parent.name]"
	parent.icon_state = "[parent.icon_state]_large"

	return ..()

///Bandages box
/datum/storage/box/bandages
	max_slots = 6

/datum/storage/box/bandages/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(list(
		/obj/item/stack/medical/bandage,
		/obj/item/reagent_containers/applicator/pill,
		/obj/item/reagent_containers/applicator/patch,
	))

///Monkey cubes box
/datum/storage/box/monkey_cubes/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/food/monkeycube, /obj/item/food/monkeycube/gorilla)

///Gorilla cubes box
/datum/storage/box/gorilla_cubes
	max_slots = 3

/datum/storage/box/gorilla_cubes/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/food/monkeycube/gorilla)

///Match box
/datum/storage/box/matches
	max_slots = 10

/datum/storage/box/matches/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/match)

///Lights box
/datum/storage/box/lights
	max_slots = 21
	max_total_storage = 21 * WEIGHT_CLASS_NORMAL
	allow_quick_gather = FALSE //temp workaround to re-enable filling the light replacer with the box

/datum/storage/box/lights/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(list(
		/obj/item/light/tube,
		/obj/item/light/bulb
	))

///Balloon box
/datum/storage/box/balloons
	max_slots = 24
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = 24 * WEIGHT_CLASS_NORMAL
	allow_quick_gather = FALSE

/datum/storage/box/balloons/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/toy/balloon/long)

///Wizard box
/datum/storage/box/wizard
	max_specific_storage = WEIGHT_CLASS_NORMAL

///Syndicate box
/datum/storage/box/syndicate
	allow_big_nesting = TRUE

///Syndicate contractor box
/datum/storage/box/syndicate/contractor
	max_total_storage = 25
	max_specific_storage = WEIGHT_CLASS_BULKY

///Syndicate contractor kit box
/datum/storage/box/syndicate/contract_kit
	allow_big_nesting = TRUE
	max_specific_storage = WEIGHT_CLASS_NORMAL

///Syndicate contractor loadout box
/datum/storage/box/syndicate/contractor_loadout
	max_slots = 12
	max_total_storage = 27
	max_specific_storage = WEIGHT_CLASS_BULKY

///Syndicate conractor loadout
/datum/storage/box/syndicate/contractor_loadout
	max_specific_storage = WEIGHT_CLASS_BULKY

///Stickers box
/datum/storage/box/stickers
	max_slots = 8

/datum/storage/box/stickers/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/sticker)

///Holy box
/datum/storage/box/holy
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/box/holy/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/clothing)

///Holy Caplin box
/datum/storage/box/holy/follower
	max_total_storage = 15

///Hero box
/datum/storage/box/hero
	max_slots = 12
	max_total_storage = 30
	max_specific_storage = WEIGHT_CLASS_BULKY
	allow_big_nesting = TRUE

///Floor camo box
/datum/storage/box/floor_camo
	allow_big_nesting = TRUE

///Skub box
/datum/storage/box/stickers/skub
	max_slots = 3

/datum/storage/box/stickers/skub/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(exception_hold_list = list(
		/obj/item/skub,
		/obj/item/clothing/suit/costume/wellworn_shirt/skub,
	))

///Anti skub box
/datum/storage/box/stickers/anti_skub/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(exception_hold_list = /obj/item/clothing/suit/costume/wellworn_shirt/skub)

///SyndiKit box
/datum/storage/box/syndie_kit
	max_specific_storage = WEIGHT_CLASS_NORMAL

///SyndiKit space box
/datum/storage/box/syndie_kit/space/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(list(
		/obj/item/clothing/suit/space/syndicate,
		/obj/item/clothing/head/helmet/space/syndicate,
	))

///SyndiKit chemical box
/datum/storage/box/syndie_kit/chemical
	max_slots = 15
	max_total_storage = 15

///SyndiKit Rebar x bow box
/datum/storage/box/syndie_kit/rebarxbowsyndie
	allow_big_nesting = TRUE

///SyndiKit mail counterfeit box
/datum/storage/box/syndie_kit/mail_counterfeit
	allow_big_nesting = TRUE
	max_total_storage = 6 * WEIGHT_CLASS_NORMAL

///SyndiKit cowboy box
/datum/storage/box/syndie_kit/cowboy
	max_total_storage = 20
	allow_big_nesting = TRUE
	max_specific_storage = WEIGHT_CLASS_BULKY

///SyniKit induction kit
/datum/storage/box/syndie_kit/induction_kit
	allow_big_nesting = TRUE

///SyndiKit centcom costume box
/datum/storage/box/syndie_kit/centcom_costume
	max_slots = 8
	max_total_storage = 24
	allow_big_nesting = TRUE
	max_specific_storage = WEIGHT_CLASS_BULKY

///SyndiKit tuberculosis grenade box
/datum/storage/box/syndie_kit/tuberculosisgrenade
	max_slots = 8

///SyndiKit demoman box
/datum/storage/box/syndie_kit/demoman
	allow_big_nesting = TRUE
	max_specific_storage = WEIGHT_CLASS_BULKY

///SyndiKit Imp death rattle box
/datum/storage/box/syndie_kit/imp_deathrattle
	max_slots = 9

///SyndiKit pinata box
/datum/storage/box/syndie_kit/pinata
	max_specific_storage = WEIGHT_CLASS_BULKY
	allow_big_nesting = TRUE

///SyndiKit chaemelon box
/datum/storage/box/syndie_kit/chaemelon
	max_slots = 15
	max_total_storage = 38
	allow_big_nesting = TRUE
	max_specific_storage = WEIGHT_CLASS_BULKY

///SyndiKit throwing weapons box
/datum/storage/box/syndie_kit/weapons
	max_slots = 9 // 5 + 2 + 2
	max_total_storage = 18 // 5*2 + 2*1 + 3*2

/datum/storage/box/syndie_kit/weapons/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(list(
		/obj/item/restraints/legcuffs/bola/tactical,
		/obj/item/paperplane/syndicate,
		/obj/item/throwing_star,
	))

///SyndiKit cutouts box
/datum/storage/box/syndie_kit/cutouts
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_BULKY

///Fishing lures box
/datum/storage/box/fishing_lures/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	set_holdable(list(
		/obj/item/fishing_lure,
		/obj/item/paper/lures_instructions
	)) //can only hold lures

	//adds an extra slot, so we can put back the lures even if we didn't take out the instructions.
	max_slots = length(typesof(/obj/item/fishing_lure)) + 1
	max_total_storage = WEIGHT_CLASS_SMALL * (max_slots + 1)

	return ..()

///Stock parts box
/datum/storage/box/stockparts
	max_slots = 15
	max_total_storage = 15 * WEIGHT_CLASS_SMALL

///Tiziran goods box
/datum/storage/box/tiziran_goods
	max_slots = 8
	max_total_storage = 8 * WEIGHT_CLASS_NORMAL

///Tiziran cans box
/datum/storage/box/tiziran_cans
	max_slots = 8
	max_total_storage = 8 * WEIGHT_CLASS_SMALL

///Tiziran meat box
/datum/storage/box/tiziran_meats
	max_slots = 10
	max_total_storage = 10 * WEIGHT_CLASS_SMALL

///Mothic goods box
/datum/storage/box/mothic_goods
	max_slots = 12
	max_specific_storage = WEIGHT_CLASS_NORMAL

///Mothic cans sauces box
/datum/storage/box/mothic_cans_sauces
	max_slots = 8
	max_total_storage = 8 * WEIGHT_CLASS_SMALL

///Debug box
/datum/storage/box/debug_tools
	allow_big_nesting = TRUE
