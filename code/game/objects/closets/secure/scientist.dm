/obj/structure/closet/secure_closet/RD
	name = "Research Director"
	req_access = list(access_rd)


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