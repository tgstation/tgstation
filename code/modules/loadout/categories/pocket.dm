// --- Loadout item datums for backpack / pocket items ---

/// Pocket items (Moved to backpack)
/datum/loadout_category/pocket
	category_name = "Other"
	type_to_generate = /datum/loadout_item/pocket_items
	/// How many pocket items are allowed
	VAR_PRIVATE/max_allowed = 3

/datum/loadout_category/pocket/New()
	. = ..()
	ui_title = "Backpack Items ([max_allowed] max)"

/datum/loadout_category/pocket/handle_duplicate_entires(
	datum/preference_middleware/loadout/manager,
	datum/loadout_item/conflicting_item,
	datum/loadout_item/added_item,
	list/datum/loadout_item/all_loadout_items,
)
	var/list/datum/loadout_item/pocket_items/other_pocket_items = list()
	for(var/datum/loadout_item/pocket_items/other_pocket_item in all_loadout_items)
		other_pocket_items += other_pocket_item

	if(length(other_pocket_items) >= max_allowed)
		// We only need to deselect something if we're above the limit
		// (And if we are we prioritize the first item found, FIFO)
		manager.deselect_item(other_pocket_items[1])
	return TRUE

/datum/loadout_item/pocket_items
	abstract_type = /datum/loadout_item/pocket_items

/datum/loadout_item/pocket_items/on_equip_item(
	obj/item/equipped_item,
	datum/preferences/preference_source,
	list/preference_list = preference_source?.read_preference(/datum/preference/loadout),
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	// Backpack items aren't created if it's a visual equipping, so don't do any on equip stuff. It doesn't exist.
	if(visuals_only)
		return

	return ..()

/datum/loadout_item/pocket_items/lipstick_black
	name = "Black Lipstick"
	item_path = /obj/item/lipstick/black

/datum/loadout_item/pocket_items/lipstick_blue
	name = "Blue Lipstick"
	item_path = /obj/item/lipstick/blue

/datum/loadout_item/pocket_items/lipstick_green
	name = "Green Lipstick"
	item_path = /obj/item/lipstick/green

/datum/loadout_item/pocket_items/lipstick_jade
	name = "Jade Lipstick"
	item_path = /obj/item/lipstick/jade

/datum/loadout_item/pocket_items/lipstick_purple
	name = "Purple Lipstick"
	item_path = /obj/item/lipstick/purple

/datum/loadout_item/pocket_items/lipstick_red
	name = "Red Lipstick"
	item_path = /obj/item/lipstick

/datum/loadout_item/pocket_items/lipstick_white
	name = "White Lipstick"
	item_path = /obj/item/lipstick/white

/datum/loadout_item/pocket_items/plush
	abstract_type = /datum/loadout_item/pocket_items/plush
	can_be_named = TRUE

/datum/loadout_item/pocket_items/plush/bee
	name = "Bee Plush"
	item_path = /obj/item/toy/plush/beeplushie

/datum/loadout_item/pocket_items/plush/carp
	name = "Carp Plush"
	item_path = /obj/item/toy/plush/carpplushie

/datum/loadout_item/pocket_items/plush/lizard_greyscale
	name = "Greyscale Lizard Plush"
	item_path = /obj/item/toy/plush/lizard_plushie/greyscale

/datum/loadout_item/pocket_items/plush/lizard_random
	name = "Random Lizard Plush"
	can_be_greyscale = DONT_GREYSCALE
	item_path = /obj/item/toy/plush/lizard_plushie
	additional_tooltip_contents = list(TOOLTIP_RANDOM_COLOR)

/datum/loadout_item/pocket_items/plush/moth
	name = "Moth Plush"
	item_path = /obj/item/toy/plush/moth

/datum/loadout_item/pocket_items/plush/narsie
	name = "Nar'sie Plush"
	item_path = /obj/item/toy/plush/narplush

/datum/loadout_item/pocket_items/plush/nukie
	name = "Nukie Plush"
	item_path = /obj/item/toy/plush/nukeplushie

/datum/loadout_item/pocket_items/plush/peacekeeper
	name = "Peacekeeper Plush"
	item_path = /obj/item/toy/plush/pkplush

/datum/loadout_item/pocket_items/plush/plasmaman
	name = "Plasmaman Plush"
	item_path = /obj/item/toy/plush/plasmamanplushie

/datum/loadout_item/pocket_items/plush/ratvar
	name = "Ratvar Plush"
	item_path = /obj/item/toy/plush/ratplush

/datum/loadout_item/pocket_items/plush/rouny
	name = "Rouny Plush"
	item_path = /obj/item/toy/plush/rouny

/datum/loadout_item/pocket_items/plush/snake
	name = "Snake Plush"
	item_path = /obj/item/toy/plush/snakeplushie

/datum/loadout_item/pocket_items/card_binder
	name = "Card Binder"
	item_path = /obj/item/storage/card_binder

/datum/loadout_item/pocket_items/card_deck
	name = "Playing Card Deck"
	item_path = /obj/item/toy/cards/deck

/datum/loadout_item/pocket_items/kotahi_deck
	name = "Kotahi Deck"
	item_path = /obj/item/toy/cards/deck/kotahi

/datum/loadout_item/pocket_items/wizoff_deck
	name = "Wizoff Deck"
	item_path = /obj/item/toy/cards/deck/wizoff

/datum/loadout_item/pocket_items/dice_bag
	name = "Dice Bag"
	item_path = /obj/item/storage/dice

/datum/loadout_item/pocket_items/d1
	name = "D1"
	item_path = /obj/item/dice/d1

/datum/loadout_item/pocket_items/d2
	name = "D2"
	item_path = /obj/item/dice/d2

/datum/loadout_item/pocket_items/d4
	name = "D4"
	item_path = /obj/item/dice/d4

/datum/loadout_item/pocket_items/d6
	name = "D6"
	item_path = /obj/item/dice/d6

/datum/loadout_item/pocket_items/d6_ebony
	name = "D6 (Ebony)"
	item_path = /obj/item/dice/d6/ebony

/datum/loadout_item/pocket_items/d6_space
	name = "D6 (Space)"
	item_path = /obj/item/dice/d6/space

/datum/loadout_item/pocket_items/d8
	name = "D8"
	item_path = /obj/item/dice/d8

/datum/loadout_item/pocket_items/d10
	name = "D10"
	item_path = /obj/item/dice/d10

/datum/loadout_item/pocket_items/d12
	name = "D12"
	item_path = /obj/item/dice/d12

/datum/loadout_item/pocket_items/d20
	name = "D20"
	item_path = /obj/item/dice/d20

/datum/loadout_item/pocket_items/d100
	name = "D100"
	item_path = /obj/item/dice/d100

/datum/loadout_item/pocket_items/d00
	name = "D00"
	item_path = /obj/item/dice/d00
