/obj/structure/closet/secure_closet/blueshield
	name = "blueshield's locker"
	icon_state = "blueshield"
	icon = 'modular_bandastation/objects/icons/obj/storage/closet.dmi'
	req_access = list(ACCESS_BLUESHIELD)

/obj/structure/closet/secure_closet/blueshield/PopulateContents()
	var/static/list/items_inside = list(
		/obj/item/storage/briefcase/secure = 1,
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/storage/belt/security/full = 1,
		/obj/item/storage/bag/garment/blueshield = 1,
		/obj/item/radio/headset/blueshield = 1,
		/obj/item/radio/headset/blueshield/alt = 1,
		/obj/item/sensor_device = 1,
		/obj/item/pinpointer/crew = 1,
	)
	generate_items_inside(items_inside, src)
