/obj/item/weapon/grenade/empgrenade
	name = "classic emp grenade"
	icon_state = "emp"
	item_state = "emp"
	origin_tech = "materials=2;magnets=3"

	prime()
		..()
		if(empulse(src, 10, 20))
			del(src)
		return

