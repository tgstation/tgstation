/obj/structure/closet/secure_closet/RD
	name = "\proper research director's locker"
	req_access = list(access_rd)
	icon_state = "rd"

/obj/structure/closet/secure_closet/RD/New()
	..()
	new /obj/item/clothing/cloak/rd(src)
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
	new /obj/item/clothing/suit/armor/reactive(src)
	new /obj/item/device/flash/handheld(src)
	new /obj/item/device/laser_pointer(src)
