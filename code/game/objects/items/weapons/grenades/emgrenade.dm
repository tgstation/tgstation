/obj/item/weapon/grenade/empgrenade
	name = "emp grenade"
	icon_state = "emp"
	item_state = "emp"
	origin_tech = "materials=2;magnets=3"

/obj/item/weapon/grenade/empgrenade/prime()
	..()
	empulse(src, 4, 10)
	spawn(5)
		qdel(src)

