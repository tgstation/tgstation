/obj/item/ammo_casing/energy/gravityrepulse
	projectile_type = /obj/item/projectile/gravityrepulse
	e_cost = 0
	fire_sound = 'sound/weapons/wave.ogg'
	select_name = "repulse"
	delay = 50
	var/obj/item/gun/energy/gravity_gun/gun

/obj/item/ammo_casing/energy/gravityrepulse/Initialize(mapload, obj/item/gun/energy/gravity_gun/G)
	gun = G
	. = ..()

/obj/item/ammo_casing/energy/gravityattract
	projectile_type = /obj/item/projectile/gravityattract
	e_cost = 0
	fire_sound = 'sound/weapons/wave.ogg'
	select_name = "attract"
	delay = 50
	var/obj/item/gun/energy/gravity_gun/gun


/obj/item/ammo_casing/energy/gravityattract/Initialize(mapload, obj/item/gun/energy/gravity_gun/G)
	gun = G
	. = ..()

/obj/item/ammo_casing/energy/gravitychaos
	projectile_type = /obj/item/projectile/gravitychaos
	e_cost = 0
	fire_sound = 'sound/weapons/wave.ogg'
	select_name = "chaos"
	delay = 50
	var/obj/item/gun/energy/gravity_gun/gun

/obj/item/ammo_casing/energy/gravitychaos/Initialize(mapload, obj/item/gun/energy/gravity_gun/G)
	gun = G
	. = ..()
