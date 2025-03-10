
/// A box containing a skub, for easier carry because skub is a bulky item.
/obj/item/storage/box/stickers/skub
	name = "skub fan pack"
	desc = "A vinyl pouch to store your skub and pro-skub shirt in. A label on the back reads: \"Skubtide, Stationwide\"."
	icon_state = "skubpack"
	illustration = "label_skub"
	w_class = WEIGHT_CLASS_SMALL
	storage_type = /datum/storage/box/stickers/skub

/obj/item/storage/box/stickers/skub/PopulateContents()
	return list(
		/obj/item/skub,
		/obj/item/sticker/skub,
		/obj/item/sticker/skub
	)

/obj/item/storage/box/stickers/anti_skub
	name = "anti-skub stickers pack"
	desc = "The enemy may have been given a skub and a shirt, but I've got more stickers! Plus the pack can hold my anti-skub shirt."
	icon_state = "skubpack"
	illustration = "label_anti_skub"
	storage_type = /datum/storage/box/stickers/anti_skub

/obj/item/storage/box/stickers/anti_skub/PopulateContents()
	return list(
		/obj/item/sticker/anti_skub,
		/obj/item/sticker/anti_skub,
		/obj/item/sticker/anti_skub,
		/obj/item/sticker/anti_skub,
	)
