/obj/item/weapon/gun/energy/prototype
	name = "prototype energy gun"
	desc = "A barebones energy gun chassis. Contains an integrated control chip that allows for users to control module activation."
	icon = 'icons/obj/guncrafting/energy/chassis.dmi'
	icon_state = 'default'
	item_state =
	ammo_type = list(/obj/item/ammo_casing/energy/prototype)
	var/datum/projectile/energy
	cell_type = /obj/item/weapon/stock_parts/cell/infinite	//We're not using this.
	w_class = 3



