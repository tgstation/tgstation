/obj/structure/closet/secure_closet/scientist
	name = "Scientist's Locker"
	req_access = list(access_tox_storage)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_broken = "secureresbroken"
	icon_off = "secureresoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/scientist(src)
		new /obj/item/clothing/suit/labcoat(src)
		new /obj/item/clothing/shoes/white(src)
//		new /obj/item/weapon/cartridge/signal/toxins(src)
		new /obj/item/device/radio/headset/headset_sci(src)
		new /obj/item/weapon/tank/air(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/mask/gas(src)
		return



/obj/structure/closet/secure_closet/RD
	name = "Research Director's Locker"
	req_access = list(access_rd)
	icon_state = "rdsecure1"
	icon_closed = "rdsecure"
	icon_locked = "rdsecure1"
	icon_opened = "rdsecureopen"
	icon_broken = "rdsecurebroken"
	icon_off = "rdsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/suit/bio_suit/scientist(src)
		new /obj/item/clothing/head/bio_hood/scientist(src)
		new /obj/item/clothing/under/rank/research_director(src)
		new /obj/item/clothing/suit/labcoat(src)
		new /obj/item/weapon/cartridge/rd(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/device/radio/headset/heads/rd(src)
		new /obj/item/weapon/tank/air(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/device/flash(src)
		return