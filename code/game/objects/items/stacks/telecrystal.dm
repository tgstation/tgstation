/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "Covered in a web of finely engraved geometrical patterns, pulsing with suspiciously enticing energies."
	singular_name = "telecrystal"
	icon_state = "telecrystal"
	dye_color = DYE_SYNDICATE
	full_w_class = WEIGHT_CLASS_TINY
	w_class = WEIGHT_CLASS_TINY
	max_amount = 50
	item_flags = NOBLUDGEON
	merge_type = /obj/item/stack/telecrystal
	novariants = FALSE
	material_type = /datum/material/telecrystal
	mats_per_unit = list(/datum/material/telecrystal = SHEET_MATERIAL_AMOUNT)

/obj/item/stack/telecrystal/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with != user) // You can't go around smacking people with crystals to find out if they have an uplink or not.
		return NONE

	for(var/obj/item/implant/uplink/uplink in interacting_with)
		if(!uplink.imp_in)
			continue

		var/datum/component/uplink/hidden_uplink = uplink.GetComponent(/datum/component/uplink)
		if(!hidden_uplink)
			continue
		hidden_uplink.uplink_handler.add_telecrystals(amount)
		use(amount)
		to_chat(user, span_notice("You press [src] onto yourself and charge your hidden uplink."))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/stack/telecrystal/five
	amount = 5

/obj/item/stack/telecrystal/twenty
	amount = 20

/obj/item/stack/sheet/telepolycrystal
	name = "tele-polycrystal"
	singular_name = "tele-polycrystal"
	desc = "A \"somewhat\" stable chunk of telecrystal. It lacks the precision-carved tuning channels, making it useless for long-range matter teleportation."
	icon_state = "telepolycrystal"
	inhand_icon_state = null
	full_w_class = WEIGHT_CLASS_TINY
	w_class = WEIGHT_CLASS_TINY
	dye_color = DYE_SYNDICATE
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/telepolycrystal
	material_type = /datum/material/telecrystal
	mats_per_unit = list(/datum/material/telecrystal = SHEET_MATERIAL_AMOUNT)
