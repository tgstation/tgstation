/datum/loadout_category/erp
	category_name = "Erotic"
	category_ui_icon = FA_ICON_HEART
	erp_category = TRUE
	type_to_generate = /datum/loadout_item/erp
	tab_order = /datum/loadout_category/pocket::tab_order + 1
	var/max_allowed = MAX_ALLOWED_ERP_ITEMS

/datum/loadout_category/erp/New()
	. = ..()
	category_info = "([MAX_ALLOWED_ERP_ITEMS] allowed)"

/datum/loadout_category/erp/handle_duplicate_entires(
	datum/preference_middleware/loadout/manager,
	datum/loadout_item/conflicting_item,
	datum/loadout_item/added_item,
	list/datum/loadout_item/all_loadout_items,
)
	var/list/datum/loadout_item/erp/other_items = list()
	for(var/datum/loadout_item/erp/other_item in all_loadout_items)
		other_items += other_item

	if(length(other_items) >= MAX_ALLOWED_ERP_ITEMS)
		manager.deselect_item(other_items[1])
	return TRUE

/datum/loadout_item/erp/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	return FALSE

/datum/loadout_item/erp
	abstract_type = /datum/loadout_item/erp
	erp_item = TRUE
	erp_box = TRUE

/*
*	SEX TOYS
*/

/datum/loadout_item/erp/banana
	name = "Banana"
	item_path = /obj/item/food/grown/banana

/datum/loadout_item/erp/pickle
	name = "Pickle"
	item_path = /obj/item/food/pickle
