/obj/structure/closet/secure_closet/magistrate
	name = "magistrate's locker"
	icon_state = "magistrate"
	icon = 'modular_bandastation/objects/icons/obj/storage/closet.dmi'
	req_access = list(ACCESS_MAGISTRATE)

/obj/structure/closet/secure_closet/magistrate/populate_contents_immediate()
	new /obj/item/storage/briefcase/secure(src)
	new /obj/item/pai_card(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/radio/headset/heads/magistrate(src)
	new /obj/item/radio/headset/heads/magistrate/alt(src)
	new /obj/item/gavelblock(src)
	new /obj/item/gavelhammer(src)
	new /obj/item/clothing/accessory/medal/silver/bureaucracy(src)
	new /obj/item/clothing/accessory/lawyers_badge(src)
	new /obj/item/storage/bag/garment/magistrate(src)
