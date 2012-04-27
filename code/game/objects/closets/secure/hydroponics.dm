/obj/structure/closet/secure_closet/hydroponics
	name = "Botanist's locker"
	req_access = list(access_hydroponics)
	icon_state = "hydrosecure1"
	icon_closed = "hydrosecure"
	icon_locked = "hydrosecure1"
	icon_opened = "hydrosecureopen"
	icon_broken = "hydrosecurebroken"
	icon_off = "hydrosecureoff"


	New()
		..()
		sleep(2)
		new /obj/item/weapon/plantbag(src)
		new /obj/item/clothing/under/rank/hydroponics(src)
		new /obj/item/clothing/suit/apron(src)
		new /obj/item/clothing/under/rank/hydroponics(src)
		new /obj/item/clothing/head/helmet/greenbandana(src)
		new /obj/item/device/analyzer/plant_analyzer(src)
		new /obj/item/weapon/hatchet(src)
		return