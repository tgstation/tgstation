/obj/structure/closet/secure_closet/cargotech
	name = "Cargo Technician's Locker"
	req_access = list(access_cargo)
	//icon_state = "secureeng1"
	//icon_closed = "secureeng"
	//icon_locked = "secureeng1"
	//icon_opened = "toolclosetopen"
	//icon_broken = "secureengbroken"
	//icon_off = "secureengoff"

	//Needs proper sprites

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/cargotech(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/device/radio/headset/headset_cargo(src)
		new /obj/item/clothing/gloves/black(src)
		new /obj/item/weapon/cartridge/quartermaster(src)
		return