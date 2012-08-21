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
		switch(rand(1,2))
			if(1)
				new /obj/item/clothing/suit/apron(src)
			if(2)
				new /obj/item/clothing/suit/apron/overalls(src)
		new /obj/item/weapon/plantbag(src)
		new /obj/item/clothing/under/rank/hydroponics(src)
		new /obj/item/device/analyzer/plant_analyzer(src)
		new /obj/item/clothing/head/greenbandana(src)
		new /obj/item/weapon/minihoe(src)
		new /obj/item/weapon/hatchet(src)
		return