/obj/structure/closet/secure_closet/brig_physician
	name = "brig physician's locker"
	icon = 'monkestation/icons/obj/storage/closet.dmi'
	icon_state = "brigphys"
	req_access = list(ACCESS_BRIG)


/obj/structure/closet/secure_closet/brig_physician/PopulateContents()
	..()

	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/bag/garment/brig_physician(src)
	new /obj/item/storage/backpack/brig_physician(src)
	new /obj/item/storage/backpack/duffelbag/sec/surgery(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/defibrillator/loaded(src)
