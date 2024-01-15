/obj/item/storage/bag/ammo
	name = "ammo pouch"
	desc = "A pouch for your ammo that goes in your pocket."
	icon = 'modular_skyrat/modules/modular_items/icons/storage.dmi'
	icon_state = "ammopouch"
	slot_flags = ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE
	custom_price = PAYCHECK_HARD * 4

/obj/item/storage/bag/ammo/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 30
	STR.max_items = 3
	STR.display_numerical_stacking = FALSE
	STR.can_hold = typecacheof(list(/obj/item/ammo_box/magazine, /obj/item/ammo_casing, /obj/item/ammo_box/revolver, /obj/item/stock_parts/cell/microfusion))

/obj/item/storage/bag/material
	name = "material pouch"
	desc = "A pouch for sheets and RCD ammunition that manages to hang where you would normally put things in your pocket."
	icon = 'modular_skyrat/modules/modular_items/icons/storage.dmi'
	icon_state = "materialpouch"
	slot_flags = ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE
	custom_price = PAYCHECK_HARD * 4

/obj/item/storage/bag/material/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = INFINITY
	STR.max_items = 2
	STR.display_numerical_stacking = TRUE
	STR.can_hold = typecacheof(list(/obj/item/rcd_ammo, /obj/item/stack/sheet))

/obj/item/storage/bag/trash
	slot_flags = ITEM_SLOT_BELT //QoL by Gandalf
	worn_icon_state = "trashbag"
	worn_icon = 'modular_skyrat/master_files/icons/mob/clothing/belt.dmi'
