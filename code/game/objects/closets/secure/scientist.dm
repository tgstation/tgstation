/obj/structure/closet/secure_closet/RD
	name = "Research Director"
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
		new /obj/item/wardrobe/rd(src)
		new /obj/item/wardrobe/rd(src)
		return

//cpy
/*
	new /obj/item/wardrobe/scientist(src)
	new /obj/item/wardrobe/scientist(src)
	new /obj/item/wardrobe/scientist(src)
	new /obj/item/wardrobe/scientist(src)
	*/