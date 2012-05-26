/obj/structure/closet/secure_closet/cargotech
	name = "Cargo Technician's Locker"
	req_access = list(access_cargo)
	icon_state = "securecargo1"
	icon_closed = "securecargo"
	icon_locked = "securecargo1"
	icon_opened = "securecargoopen"
	icon_broken = "securecargobroken"
	icon_off = "securecargooff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/cargotech(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/device/radio/headset/headset_cargo(src)
		new /obj/item/clothing/gloves/black(src)
//		new /obj/item/weapon/cartridge/quartermaster(src)
		return

/obj/structure/closet/secure_closet/quartermaster
	name = "Quartermaster's Locker"
	req_access = list(access_qm)
	icon_state = "secureqm1"
	icon_closed = "secureqm"
	icon_locked = "secureqm1"
	icon_opened = "secureqmopen"
	icon_broken = "secureqmbroken"
	icon_off = "secureqmoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/cargo(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/device/radio/headset/heads/qm(src)
		new /obj/item/clothing/gloves/black(src)
//		new /obj/item/weapon/cartridge/quartermaster(src)
		new /obj/item/clothing/suit/fire/firefighter(src)
		new /obj/item/weapon/tank/emergency_oxygen(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/glasses/meson(src)
		return