<<<<<<< HEAD
/obj/item/weapon/grenade/empgrenade
	name = "classic EMP grenade"
	desc = "It is designed to wreak havok on electronic systems."
	icon_state = "emp"
	item_state = "emp"
	origin_tech = "magnets=3;combat=2"

/obj/item/weapon/grenade/empgrenade/prime()
	update_mob()
	empulse(src, 4, 10)
	qdel(src)
=======
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

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
