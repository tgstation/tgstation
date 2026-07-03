/obj/structure/closet/secure_closet/nanotrasen_representative
	name = "nanotrasen representative's locker"
	icon_state = "nanotrasen_representative"
	icon = 'modular_bandastation/objects/icons/obj/storage/closet.dmi'
	req_access = list(ACCESS_NANOTRASEN_REPRESENTATIVE)

/obj/structure/closet/secure_closet/nanotrasen_representative/PopulateContents()
	var/static/list/items_inside = list(
		/obj/item/storage/briefcase/secure = 1,
		/obj/item/radio/headset/heads/nanotrasen_representative = 1,
		/obj/item/pai_card = 1,
		/obj/item/assembly/flash/handheld = 1,
		/obj/item/taperecorder = 1,
		/obj/item/storage/box/tapes = 1,
		/obj/item/storage/bag/garment/nanotrasen_representative = 1,
	)
	generate_items_inside(items_inside, src)

