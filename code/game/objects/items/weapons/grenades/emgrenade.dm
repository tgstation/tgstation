/obj/item/weapon/grenade/empgrenade
	name = "classic emp grenade"
	icon_state = "emp"
	item_state = "emp"
	origin_tech = "materials=2;magnets=3"

/obj/item/weapon/grenade/empgrenade/prime()
	update_mob()
	empulse(src, 4, 10)
	del(src)

