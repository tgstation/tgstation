/obj/structure/closet/secure_closet/cargotech
	name = "Cargo Technician's Locker"
	req_access = list(ACCESS_CARGO)
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

/obj/structure/closet/secure_closet/qm_personal
	name = "Quartermaster's Locker"
	req_access = list(ACCESS_QM)
	icon_state = "secureqm1"
	icon_closed = "secureqm"
	icon_locked = "secureqm1"
	icon_opened = "secureqmopen"
	icon_broken = "secureqmbroken"
	icon_off = "secureqmoff"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/qm(src)
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/weapon/clipboard(src)
		new /obj/item/device/pda/quartermaster(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/device/radio/headset/heads/qm(src)

/obj/structure/closet/secure_closet/cargo_tech_personal
	name = "Cargo Tech's Locker"
	req_access = list(ACCESS_CARGO)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/cargo_tech(src)
		//
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/pda/quartermaster(src)
		new /obj/item/device/radio/headset/headset_cargo(src)

/obj/structure/closet/secure_closet/miner_personal
	name = "Miner's Locker"
	req_access = list(ACCESS_CARGO)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/cargo_tech(src)
		//
		var/obj/item/weapon/storage/backpack/industrial/BPK = new /obj/item/weapon/storage/backpack/industrial(src)
		var/obj/item/weapon/storage/box/B = new(BPK)
		new /obj/item/weapon/pen(B)
		new /obj/item/device/radio/headset/headset_mine(src)