/obj/item/storage/box/syndie_kit/imp_hard_spear
	name = "hardlight spear implant box"

/obj/item/storage/box/syndie_kit/imp_hard_spear/PopulateContents()
	new /obj/item/implanter/hard_spear(src)



/obj/item/storage/box/syndimaid
	name = "Syndicate maid outfit"
	desc = "A box containing a 'tactical' and 'practical' maid outfit."
	icon_state = "syndiebox"

/obj/item/storage/box/syndimaid/PopulateContents()
	var/static/items_inside = list(
		/obj/item/clothing/head/maidheadband/syndicate = 1,
		/obj/item/clothing/under/syndicate/skirt/maid = 1,
		/obj/item/clothing/gloves/combat/maid = 1,
		/obj/item/clothing/accessory/maidapron/syndicate = 1,)
	generate_items_inside(items_inside,src)\
