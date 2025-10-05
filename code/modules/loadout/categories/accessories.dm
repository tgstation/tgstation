/// Accessory Items (Moves overrided items to backpack)
/datum/loadout_category/accessories
	category_name = "Accessory"
	category_ui_icon = FA_ICON_VEST
	type_to_generate = /datum/loadout_item/accessory
	tab_order = /datum/loadout_category/head::tab_order + 3

/datum/loadout_item/accessory
	abstract_type = /datum/loadout_item/accessory
	/// Can we adjust this accessory to be above or below suits?
	VAR_FINAL/can_be_layer_adjusted = FALSE

/datum/loadout_item/accessory/New()
	. = ..()
	if(ispath(item_path, /obj/item/clothing/accessory))
		can_be_layer_adjusted = TRUE

/datum/loadout_item/accessory/get_ui_buttons()
	if(!can_be_layer_adjusted)
		return ..()
	. = ..()
	UNTYPED_LIST_ADD(., list(
		"label" = "Layer",
		"act_key" = "set_layer",
		"active_key" = INFO_LAYER,
		"active_text" = "Above Suit",
		"inactive_text" = "Below Suit",
	))

	return .

/datum/loadout_item/accessory/handle_loadout_action(datum/preference_middleware/loadout/manager, mob/user, action, params)
	if(action == "set_layer")
		return set_accessory_layer(manager, user)

	return ..()

/datum/loadout_item/accessory/proc/set_accessory_layer(datum/preference_middleware/loadout/manager, mob/user)
	if(!can_be_layer_adjusted)
		return FALSE

	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
	if(!loadout?[item_path])
		return FALSE

	if(isnull(loadout[item_path][INFO_LAYER]))
		loadout[item_path][INFO_LAYER] = FALSE

	loadout[item_path][INFO_LAYER] = !loadout[item_path][INFO_LAYER]
	manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)
	return TRUE // Update UI

/datum/loadout_item/accessory/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.accessory)
		LAZYADD(outfit.backpack_contents, outfit.accessory)
	outfit.accessory = item_path

/datum/loadout_item/accessory/on_equip_item(obj/item/equipped_item, list/item_details, mob/living/carbon/human/equipper, datum/outfit/job/outfit, visuals_only = FALSE)
	. = ..()
	if(isnull(equipped_item))
		return .
	var/obj/item/clothing/accessory/accessory_item = equipped_item
	accessory_item.above_suit = !!item_details[INFO_LAYER]
	return . | ITEM_SLOT_OCLOTHING | ITEM_SLOT_ICLOTHING

/datum/loadout_item/accessory/maid_apron
	name = "Maid Apron"
	item_path = /obj/item/clothing/accessory/maidapron

/datum/loadout_item/accessory/waistcoat
	name = "Waistcoat"
	item_path = /obj/item/clothing/accessory/waistcoat

/datum/loadout_item/accessory/pocket_protector
	name = "Pocket Protector"
	item_path = /obj/item/clothing/accessory/pocketprotector

/datum/loadout_item/accessory/full_pocket_protector
	name = "Pocket Protector (Filled)"
	item_path = /obj/item/clothing/accessory/pocketprotector/full

/datum/loadout_item/accessory/pride
	name = "Pride Pin"
	item_path = /obj/item/clothing/accessory/pride
	loadout_flags = LOADOUT_FLAG_ALLOW_RESKIN
