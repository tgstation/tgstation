/obj/item/weapon/gun/energy/temperature
	name = "temperature gun"
	icon_state = "freezegun"
	desc = "A gun that changes temperatures."
	origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/temp, /obj/item/ammo_casing/energy/temp/hot)
	cell_type = "/obj/item/weapon/stock_parts/cell/high"
	pin = null


/obj/item/weapon/gun/energy/temperature/attack_self(mob/living/user as mob)
	select_fire(user)
	update_icon()
	return