/datum/component/storage/concrete/extract_inventory
	max_combined_w_class = WEIGHT_CLASS_TINY * 3
	max_items = 3
	insert_preposition = "in"
	attack_hand_interact = FALSE
	quickdraw = FALSE
//These need to be false in order for the extract's food to be unextractable
//from the inventory

/datum/component/storage/concrete/extract_inventory/Initialize()
	. = ..()
	set_holdable(list(/obj/item/food/monkeycube))
