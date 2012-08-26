/obj/item/weapon/grenade/empgrenade
	name = "emp grenade"
	icon_state = "emp"
	item_state = "emp"
	origin_tech = "materials=2;magnets=3"

	prime()
		..()
		if(empulse(src, 5, 7))
			del(src)
		return
