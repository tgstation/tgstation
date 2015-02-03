/obj/structure/closet/secure_closet/scientist
	name = "scientist's locker"
	req_access = list(access_tox_storage)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_broken = "secureresbroken"
	icon_off = "secureresoff"

/obj/structure/closet/secure_closet/scientist/New()
	..()
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/suit/toggle/labcoat/science(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
//	new /obj/item/weapon/cartridge/signal/toxins(src)
	new /obj/item/device/radio/headset/headset_sci(src)
	new /obj/item/weapon/tank/internals/air(src)
	new /obj/item/clothing/mask/gas(src)
	return



/obj/structure/closet/secure_closet/RD
	name = "\proper research director's locker"
	req_access = list(access_rd)
	icon_state = "rdsecure1"
	icon_closed = "rdsecure"
	icon_locked = "rdsecure1"
	icon_opened = "rdsecureopen"
	icon_broken = "rdsecurebroken"
	icon_off = "rdsecureoff"

/obj/structure/closet/secure_closet/RD/New()
	..()
	new /obj/item/clothing/suit/hooded/wintercoat/science(src)
	new /obj/item/clothing/suit/bio_suit/scientist(src)
	new /obj/item/clothing/head/bio_hood/scientist(src)
	new /obj/item/clothing/suit/toggle/labcoat(src)
	new /obj/item/clothing/under/rank/research_director(src)
	new /obj/item/clothing/under/rank/research_director/alt(src)
	new /obj/item/clothing/under/rank/research_director/turtleneck(src)
	new /obj/item/weapon/cartridge/rd(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/device/radio/headset/heads/rd(src)
	new /obj/item/weapon/tank/internals/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/suit/armor/reactive(src)
	new /obj/item/device/flash/handheld(src)
	new /obj/item/device/laser_pointer(src)
	return
