/obj/item/weapon/gun_attachment/base/c9mm
	gun_type = PROJECTILE
	name = "9mm Pistol Ballistic Base"
	icon_state = "base_projectile_9mm"
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm

/obj/item/weapon/gun_attachment/base/stun
	gun_type = ENERGY
	name = "Stun Energy Base"
	icon_state = "base_energy_stun"
	energy_type = list(/obj/item/ammo_casing/energy/electrode)

/obj/item/weapon/gun_attachment/base/htaser
	gun_type = ENERGY
	name = "Hybrid Taser Energy Base"
	icon_state = "base_energy_stun"
	energy_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)

/obj/item/weapon/gun_attachment/base/egun
	gun_type = ENERGY
	name = "Energy Gun Energy Base"
	icon_state = "base_energy_ion"
	energy_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/lasergun)

/obj/item/weapon/gun_attachment/base/laser
	gun_type = ENERGY
	name = "Laser Energy Base"
	icon_state = "base_energy_laser"
	energy_type = list(/obj/item/ammo_casing/energy/lasergun)

/obj/item/weapon/gun_attachment/base/ion
	gun_type = ENERGY
	name = "Ioniser Energy Base"
	icon_state = "base_energy_ion"
	energy_type = list(/obj/item/ammo_casing/energy/ion)