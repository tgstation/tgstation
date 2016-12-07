/obj/item/weapon/gun_attachment/base
	name = "base"
	var/mag_type = /obj/item/ammo_box/magazine/m10mm
	var/energy_type = /obj/item/ammo_casing/energy/laser
	var/obj/item/ammo_casing/energy/energy_ref

/obj/item/weapon/gun_attachment/base/on_attach(var/obj/item/weapon/gun/owner)
	..()
	owner.base = src
	switch(gun_type)
		if(PROJECTILE)
			var/obj/item/weapon/gun/projectile/O = owner
			O.mag_type = mag_type
			O.magazine = new mag_type(O)
			O.chamber_round(1)
		if(ENERGY)
			var/obj/item/weapon/gun/energy/E = owner
			energy_ref = new energy_type
			E.ammo_type += energy_ref
	return

/obj/item/weapon/gun_attachment/base/on_remove(var/obj/item/weapon/gun/owner)
	..()
	switch(gun_type)
		if(PROJECTILE)
			var/obj/item/weapon/gun/projectile/O = owner
			O.mag_type = null
		if(ENERGY)
			var/obj/item/weapon/gun/energy/E = owner
			E.ammo_type -= energy_ref
			E.power_supply = new(E)
	owner.base = null
	return