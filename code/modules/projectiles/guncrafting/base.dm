/obj/item/weapon/gun_attachment/base
	name = "base"
	var/mag_type = /obj/item/ammo_box/magazine/m10mm
	var/list/energy_type = list(/obj/item/ammo_casing/energy/laser)
	var/obj/item/ammo_casing/energy/energy_ref
	var/the_item_state = "laser"
	not_okay = /obj/item/weapon/gun_attachment/base

/obj/item/weapon/gun_attachment/base/on_attach(var/obj/item/weapon/gun/owner)
	..()
	owner.base = src
	switch(gun_type)
		if(CUSTOMIZABLE_PROJECTILE)
			var/obj/item/weapon/gun/ballistic/O = owner
			O.mag_type = mag_type
			O.magazine = new mag_type(O)
			O.chamber_round(1)
		if(CUSTOMIZABLE_ENERGY)
			var/obj/item/weapon/gun/energy/E = owner
			for(var/EN in energy_type)
				var/obj/item/ammo_casing/energy/energy_casing = EN
				energy_ref = new energy_casing
				E.ammo_type += energy_ref
			E.recharge_newshot()
			E.fire_sound = E.chambered.fire_sound

/obj/item/weapon/gun_attachment/base/on_remove(var/obj/item/weapon/gun/owner)
	..()
	switch(gun_type)
		if(CUSTOMIZABLE_PROJECTILE)
			var/obj/item/weapon/gun/ballistic/O = owner
			O.mag_type = null
		if(CUSTOMIZABLE_ENERGY)
			var/obj/item/weapon/gun/energy/E = owner
			E.ammo_type = list()
			E.power_supply = new(E)
	owner.base = null