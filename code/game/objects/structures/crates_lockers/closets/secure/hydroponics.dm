/obj/structure/closet/secure_closet/hydroponics
	name = "botanist's locker"
	req_access = list(ACCESS_HYDROPONICS)
	icon_state = "hydro"

/obj/structure/closet/secure_closet/hydroponics/PopulateContents()
	..()
	new /obj/item/weapon/storage/bag/plants/portaseeder(src)
	new /obj/item/device/plant_analyzer(src)
	new /obj/item/device/radio/headset/headset_srv(src)
	new /obj/item/weapon/cultivator(src)
	new /obj/item/weapon/hatchet(src)
	new /obj/item/weapon/storage/box/disks_plantgene(src)