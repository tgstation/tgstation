/// Pocket items (Moved to backpack)
/datum/loadout_category/pocket
	category_name = "Other"
	category_ui_icon = FA_ICON_QUESTION
	type_to_generate = /datum/loadout_item/pocket_items
	tab_order = /datum/loadout_category/head::tab_order + 5
	/// How many pocket items are allowed
	VAR_PRIVATE/max_allowed = 2

/datum/loadout_category/pocket/New()
	. = ..()
	category_info = "([max_allowed] allowed)"

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
	list/preference_list,
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	// Backpack items aren't created if it's a visual equipping, so don't do any on equip stuff. It doesn't exist.
	if(visuals_only)
		return NONE

	return ..()


/datum/loadout_item/pocket_items/plush
	group = "Plushies"
	abstract_type = /datum/loadout_item/pocket_items/plush
	can_be_named = TRUE

/datum/loadout_item/pocket_items/plush/bee
	name = "Plush (Bee)"
	item_path = /obj/item/toy/plush/beeplushie

/datum/loadout_item/pocket_items/plush/carp
	name = "Plush (Carp)"
	item_path = /obj/item/toy/plush/carpplushie

/datum/loadout_item/pocket_items/plush/lizard_greyscale
	name = "Plush (Lizard, Colorable)"
	item_path = /obj/item/toy/plush/lizard_plushie/greyscale

/datum/loadout_item/pocket_items/plush/lizard_random
	name = "Plush (Lizard, Random)"
	can_be_greyscale = DONT_GREYSCALE
	ui_icon = 'icons/obj/fluff/previews.dmi'
	ui_icon_state = "plushie_lizard_random"
	item_path = /obj/item/toy/plush/lizard_plushie

/datum/loadout_item/pocket_items/plush/moth
	name = "Plush (Moth)"
	item_path = /obj/item/toy/plush/moth

/datum/loadout_item/pocket_items/plush/nukie
	name = "Plush (Nukie)"
	item_path = /obj/item/toy/plush/nukeplushie

/datum/loadout_item/pocket_items/plush/peacekeeper
	name = "Plush (Peacekeeper)"
	item_path = /obj/item/toy/plush/pkplush

/datum/loadout_item/pocket_items/plush/plasmaman
	name = "Plush (Plasmaman)"
	item_path = /obj/item/toy/plush/plasmamanplushie

/datum/loadout_item/pocket_items/plush/human
	name = "Plush (human)"
	item_path = /obj/item/toy/plush/human

/datum/loadout_item/pocket_items/plush/rouny
	name = "Plush (Rouny)"
	item_path = /obj/item/toy/plush/rouny

/datum/loadout_item/pocket_items/plush/snake
	name = "Plush (Snake)"
	item_path = /obj/item/toy/plush/snakeplushie

/datum/loadout_item/pocket_items/plush/horse
	name = "Plush (Horse)"
	item_path = /obj/item/toy/plush/horse

/datum/loadout_item/pocket_items/dice
	group = "Dice"
	abstract_type = /datum/loadout_item/pocket_items/dice

/datum/loadout_item/pocket_items/dice/dice_bag
	name = "Dice Bag"
	item_path = /obj/item/storage/dice

/datum/loadout_item/pocket_items/dice/d1
	name = "D1"
	item_path = /obj/item/dice/d1

/datum/loadout_item/pocket_items/dice/d2
	name = "D2"
	item_path = /obj/item/dice/d2

/datum/loadout_item/pocket_items/dice/d4
	name = "D4"
	item_path = /obj/item/dice/d4

/datum/loadout_item/pocket_items/dice/d6
	name = "D6"
	item_path = /obj/item/dice/d6

/datum/loadout_item/pocket_items/dice/d6_ebony
	name = "D6 (Ebony)"
	item_path = /obj/item/dice/d6/ebony

/datum/loadout_item/pocket_items/dice/d6_space
	name = "D6 (Space)"
	item_path = /obj/item/dice/d6/space

/datum/loadout_item/pocket_items/dice/d8
	name = "D8"
	item_path = /obj/item/dice/d8

/datum/loadout_item/pocket_items/dice/d10
	name = "D10"
	item_path = /obj/item/dice/d10

/datum/loadout_item/pocket_items/dice/d12
	name = "D12"
	item_path = /obj/item/dice/d12

/datum/loadout_item/pocket_items/dice/d20
	name = "D20"
	item_path = /obj/item/dice/d20

/datum/loadout_item/pocket_items/dice/d100
	name = "D100"
	item_path = /obj/item/dice/d100

/datum/loadout_item/pocket_items/dice/d00
	name = "D00"
	item_path = /obj/item/dice/d00

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

/datum/loadout_item/pocket_items/lipstick
	name = "Lipstick"
	item_path = /obj/item/lipstick

/datum/loadout_item/pocket_items/lipstick/get_item_information()
	. = ..()
	.[FA_ICON_PALETTE] = "Recolorable"

/datum/loadout_item/pocket_items/lipstick/on_equip_item(
	obj/item/lipstick/equipped_item,
	datum/preferences/preference_source,
	list/preference_list,
	mob/living/carbon/human/equipper,
	visuals_only,
)
	. = ..()
	var/picked_style = style_to_style(preference_list[item_path]?[INFO_LAYER])
	var/picked_color = preference_list[item_path]?[INFO_GREYSCALE] || /obj/item/lipstick::lipstick_color
	if(istype(equipped_item)) // can be null for visuals_only
		equipped_item.style = picked_style
		equipped_item.lipstick_color = picked_color
	equipper.update_lips(picked_style, picked_color)

/// Converts style (readable) to style (internal)
/datum/loadout_item/pocket_items/lipstick/proc/style_to_style(style)
	switch(style)
		if(UPPER_LIP)
			return "lipstick_upper"
		if(LOWER_LIP)
			return "lipstick_lower"
	return "lipstick"

/datum/loadout_item/pocket_items/lipstick/get_ui_buttons()
	. = ..()
	UNTYPED_LIST_ADD(., list(
		"label" = "Style",
		"act_key" = "select_lipstick_style",
		"button_icon" = FA_ICON_ARROWS_ROTATE,
		"active_key" = INFO_LAYER,
	))
	UNTYPED_LIST_ADD(., list(
		"label" = "Color",
		"act_key" = "select_lipstick_color",
		"button_icon" = FA_ICON_PALETTE,
		"active_key" = INFO_GREYSCALE,
	))

	return .

/datum/loadout_item/pocket_items/lipstick/handle_loadout_action(datum/preference_middleware/loadout/manager, mob/user, action, params)
	switch(action)
		if("select_lipstick_style")
			var/list/their_loadout = manager.preferences.read_preference(/datum/preference/loadout)
			var/old_style = their_loadout?[item_path]?[INFO_LAYER] || MIDDLE_LIP
			var/chosen = tgui_input_list(user, "Pick a lipstick style. (This determines where it sits on your sprite.)", "Pick a style", list(UPPER_LIP, MIDDLE_LIP, LOWER_LIP), old_style)
			their_loadout = manager.preferences.read_preference(/datum/preference/loadout) // after sleep: sanity check
			if(their_loadout?[item_path]) // Validate they still have it equipped
				their_loadout[item_path][INFO_LAYER] = chosen
				manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], their_loadout)
			return TRUE // Update UI

		if("select_lipstick_color")
			var/list/their_loadout = manager.preferences.read_preference(/datum/preference/loadout)
			var/old_color = their_loadout?[item_path]?[INFO_GREYSCALE] || /obj/item/lipstick::lipstick_color
			var/chosen = input(user, "Pick a lipstick color.", "Pick a color", old_color) as color|null
			their_loadout = manager.preferences.read_preference(/datum/preference/loadout) // after sleep: sanity check
			if(their_loadout?[item_path]) // Validate they still have it equipped
				their_loadout[item_path][INFO_GREYSCALE] = chosen
				manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], their_loadout)
			return TRUE // Update UI

	return ..()

/datum/loadout_item/pocket_items/lighter
	name = "Zippo Lighter"
	item_path = /obj/item/lighter

/datum/loadout_item/pocket_items/flask
	name = "Pocket Flask"
	item_path = /obj/item/reagent_containers/cup/glass/flask

/datum/loadout_item/pocket_items/clipboard
	name = "Clipboard"
	item_path = /obj/item/clipboard

/datum/loadout_item/pocket_items/dye
	name = "Hair Dye"
	item_path = /obj/item/dyespray

/datum/loadout_item/pocket_items/poster
	name = "Poster (Contraband)"
	item_path = /obj/item/poster/random_contraband

/datum/loadout_item/pocket_items/poster_pinup
	name = "Poster (Pinup)"
	item_path = /obj/item/poster/random_contraband/pinup

/datum/loadout_item/pocket_items/holodisk
	name = "Holodisk"
	item_path = /obj/item/disk/holodisk

/datum/loadout_item/pocket_items/mug_nt
	name = "Nanotrasen Mug"
	item_path = /obj/item/reagent_containers/cup/glass/mug/nanotrasen

/datum/loadout_item/pocket_items/britcup
	name = "British Flag Cup"
	item_path = /obj/item/reagent_containers/cup/glass/mug/britcup

// The wallet loadout item is special, and puts the player's ID and other small items into it on initialize (fancy!)
/datum/loadout_item/pocket_items/wallet
	name = "Wallet"
	item_path = /obj/item/storage/wallet

/datum/loadout_item/pocket_items/wallet/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	return

/datum/loadout_item/pocket_items/wallet/on_equip_item(
	obj/item/equipped_item,
	datum/preferences/preference_source,
	list/preference_list,
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	// Do this at the very end of the setup process so we can insert quirk items and such
	if(!visuals_only && !isdummy(equipper))
		RegisterSignal(equipper, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED, PROC_REF(apply_after_setup), override = TRUE)
	return NONE

/datum/loadout_item/pocket_items/wallet/proc/apply_after_setup(mob/living/carbon/human/source, ...)
	SIGNAL_HANDLER
	equip_wallet(source)
	UnregisterSignal(source, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED)

/datum/loadout_item/pocket_items/wallet/proc/equip_wallet(mob/living/carbon/human/equipper)
	var/obj/item/card/id/advanced/id_card = equipper.get_item_by_slot(ITEM_SLOT_ID)
	if(istype(id_card, /obj/item/storage/wallet)) // Wallets station trait guard
		return

	var/obj/item/storage/wallet/wallet = new(equipper)
	if(!istype(id_card))
		// They must have a PDA or some other thing in their ID slot, abort
		if(!equipper.equip_to_storage(wallet, ITEM_SLOT_BACK, indirect_action = TRUE))
			wallet.forceMove(equipper.drop_location())
		return

	equipper.temporarilyRemoveItemFromInventory(id_card, force = TRUE)
	equipper.equip_to_slot_if_possible(wallet, ITEM_SLOT_ID, initial = TRUE)
	id_card.forceMove(wallet)

	for(var/obj/item/thing in equipper?.back)
		// leaves a slot free for whatever they may want
		if(length(wallet.contents) >= wallet.atom_storage.max_slots - 1)
			break
		if(thing.w_class > wallet.atom_storage.max_specific_storage)
			continue
		wallet.atom_storage.attempt_insert(thing, override = TRUE, force = STORAGE_FULLY_LOCKED, messages = FALSE)


/datum/loadout_item/pocket_items/borg_me_dogtag
	item_path = /obj/item/clothing/accessory/dogtag/borg_ready

/datum/loadout_item/pocket_items/borg_me_dogtag/on_equip_item(
	obj/item/equipped_item,
	datum/preferences/preference_source,
	list/preference_list,
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	// We're hooking this datum to add an extra bit of flavor to the dogtag - a pregenerated medical record
	if(!visuals_only && !isdummy(equipper))
		RegisterSignal(equipper, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED, PROC_REF(apply_after_setup), override = TRUE)
	return NONE

/datum/loadout_item/pocket_items/borg_me_dogtag/proc/apply_after_setup(mob/living/carbon/human/source, ...)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED)
	var/datum/record/crew/record = find_record(source.real_name)
	record?.medical_notes += new /datum/medical_note("Central Command", "Patient is a registered brain donor for Robotics research.", null)

/datum/loadout_item/pocket_items/candles
	name = "Box of Candles"
	item_path = /obj/item/storage/fancy/candle_box
