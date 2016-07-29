<<<<<<< HEAD
/obj/structure/closet/secure_closet/RD
	name = "\proper research director's locker"
	req_access = list(access_rd)
	icon_state = "rd"

/obj/structure/closet/secure_closet/RD/New()
	..()
	new /obj/item/clothing/suit/cloak/rd(src)
	new /obj/item/clothing/suit/bio_suit/scientist(src)
	new /obj/item/clothing/head/bio_hood/scientist(src)
	new /obj/item/clothing/suit/toggle/labcoat(src)
	new /obj/item/clothing/under/rank/research_director(src)
	new /obj/item/clothing/under/rank/research_director/alt(src)
	new /obj/item/clothing/under/rank/research_director/turtleneck(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/weapon/cartridge/rd(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/device/radio/headset/heads/rd(src)
	new /obj/item/weapon/tank/internals/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/device/megaphone/command(src)
	new /obj/item/clothing/suit/armor/reactive/teleport(src)
	new /obj/item/device/assembly/flash/handheld(src)
	new /obj/item/device/laser_pointer(src)
	new /obj/item/weapon/door_remote/research_director(src)
	new /obj/item/weapon/storage/box/firingpins(src)
=======
/obj/structure/closet/secure_closet/scientist
	name = "Scientist's Locker"
	req_access = list(access_tox_storage)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_broken = "secureresbroken"
	icon_off = "secureresoff"

/obj/structure/closet/secure_closet/scientist/New()
	..()
	sleep(2)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/suit/storage/labcoat/science(src)
	new /obj/item/clothing/shoes/white(src)
//	new /obj/item/weapon/cartridge/signal/toxins(src)
	new /obj/item/device/radio/headset/headset_sci(src)
	new /obj/item/weapon/tank/air(src)
	new /obj/item/clothing/mask/gas(src)



/obj/structure/closet/secure_closet/RD
	name = "Research Director's Locker"
	req_access = list(access_rd)
	icon_state = "rdsecure1"
	icon_closed = "rdsecure"
	icon_locked = "rdsecure1"
	icon_opened = "rdsecureopen"
	icon_broken = "rdsecurebroken"
	icon_off = "rdsecureoff"

/obj/structure/closet/secure_closet/RD/New()
	..()
	sleep(2)
	new /obj/item/clothing/suit/bio_suit/scientist(src)
	new /obj/item/clothing/head/bio_hood/scientist(src)
	new /obj/item/clothing/under/rank/research_director(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/weapon/cartridge/rd(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/latex(src)
	new /obj/item/device/radio/headset/heads/rd(src)
	new /obj/item/weapon/tank/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/device/flash(src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
