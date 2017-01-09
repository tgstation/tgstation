/obj/item/weapon/gun/energy/frame
	name = "energy gun frame"
	desc = "A frame for constructing an Energy Gun."
	customizable_type = CUSTOMIZABLE_ENERGY
	icon = 'icons/obj/guncrafting/main.dmi'
	icon_state = "frame_energy"
	charge_sections = 2
	ammo_type = list()
	unique_rename = 1

/obj/item/weapon/gun/energy/frame/testing
	pin = null

/obj/item/weapon/gun_attachment/frame/energy
	hacky_as_fuck = /obj/item/weapon/gun/energy/frame


/obj/item/weapon/gun/energy/frame/testing/high
	name = "high energy gun frame"
	icon_state = "frame_energy_high"
	cell_type = /obj/item/weapon/stock_parts/cell/high

/obj/item/weapon/gun/energy/frame/testing/super
	name = "super energy gun frame"
	icon_state = "frame_energy_super"
	cell_type = /obj/item/weapon/stock_parts/cell/super

/obj/item/weapon/gun/energy/frame/testing/hyper
	name = "hyper energy gun frame"
	icon_state = "frame_energy_hyper"
	cell_type = /obj/item/weapon/stock_parts/cell/hyper

/obj/item/weapon/gun/energy/frame/testing/bluespace
	name = "bluespace energy gun frame"
	icon_state = "frame_energy_bluespace"
	cell_type = /obj/item/weapon/stock_parts/cell/bluespace


/obj/item/weapon/gun/ballistic/frame
	name = "projectile gun frame"
	desc = "This is my rifle. There are many like it, but this one is mine. My rifle is my best friend. It is my life. I must master it as I must master my life. My rifle, without me, is useless. Without my rifle, I am useless. I must fire my rifle true. I must shoot straighter than my enemy who is trying to kill me. I must shoot him before he shoots me."
	customizable_type = CUSTOMIZABLE_PROJECTILE
	icon = 'icons/obj/guncrafting/main.dmi'
	icon_state = "frame_projectile"
	unique_rename = 1
	spawnwithmagazine = 0

/obj/item/weapon/gun/ballistic/frame/testing
	pin = null

/obj/item/weapon/gun_attachment/frame/ballistic
	hacky_as_fuck = /obj/item/weapon/gun/ballistic/frame


/obj/item/weapon/gun_attachment/frame
	var/hacky_as_fuck = /obj/item/weapon/gun/energy/frame

/obj/item/weapon/gun_attachment/frame/New()
	..()
	new hacky_as_fuck(get_turf(src))
	qdel(src)


// PRE MADE GUNS

/obj/item/weapon/gun/energy/frame/egun
	name = "energy gun"

/obj/item/weapon/gun/energy/frame/egun/New()
	..()
	var/obj/item/weapon/gun_attachment/barrel/B = new /obj/item/weapon/gun_attachment/barrel/short
	force_attach(B)
	var/obj/item/weapon/gun_attachment/base/E = new /obj/item/weapon/gun_attachment/base/egun
	force_attach(E)
	var/obj/item/weapon/gun_attachment/handle/H = new /obj/item/weapon/gun_attachment/handle/semiauto
	force_attach(H)


/obj/item/weapon/gun/energy/frame/lasergun
	name = "laser gun"

/obj/item/weapon/gun/energy/frame/lasergun/New()
	..()
	var/obj/item/weapon/gun_attachment/barrel/B = new /obj/item/weapon/gun_attachment/barrel/short
	force_attach(B)
	var/obj/item/weapon/gun_attachment/base/E = new /obj/item/weapon/gun_attachment/base/laser
	force_attach(E)
	var/obj/item/weapon/gun_attachment/handle/H = new /obj/item/weapon/gun_attachment/handle/semiauto
	force_attach(H)

/obj/item/weapon/gun/energy/frame/hybrid_taser
	name = "hybrid taser"

/obj/item/weapon/gun/energy/frame/hybrid_taser/New()
	..()
	var/obj/item/weapon/gun_attachment/barrel/B = new /obj/item/weapon/gun_attachment/barrel/short
	force_attach(B)
	var/obj/item/weapon/gun_attachment/base/E = new /obj/item/weapon/gun_attachment/base/htaser
	force_attach(E)
	var/obj/item/weapon/gun_attachment/handle/H = new /obj/item/weapon/gun_attachment/handle/semiauto
	force_attach(H)

// ballistic

/obj/item/weapon/gun/ballistic/frame/double_barrel
	name = "double barrel shotgun"

/obj/item/weapon/gun/ballistic/frame/double_barrel/New()
	..()
	var/obj/item/weapon/gun_attachment/barrel/B = new /obj/item/weapon/gun_attachment/barrel/long
	force_attach(B)
	var/obj/item/weapon/gun_attachment/base/E = new /obj/item/weapon/gun_attachment/base/shotgun_db
	force_attach(E)
	var/obj/item/weapon/gun_attachment/handle/H = new /obj/item/weapon/gun_attachment/handle/semiauto
	force_attach(H)

/obj/item/weapon/gun/ballistic/frame/revolver_38
	name = ".38 Special revolver"

/obj/item/weapon/gun/ballistic/frame/revolver_38/New()
	..()
	var/obj/item/weapon/gun_attachment/barrel/B = new /obj/item/weapon/gun_attachment/barrel/medium
	force_attach(B)
	var/obj/item/weapon/gun_attachment/base/E = new /obj/item/weapon/gun_attachment/base/revolver_38
	force_attach(E)
	var/obj/item/weapon/gun_attachment/handle/H = new /obj/item/weapon/gun_attachment/handle/semiauto
	force_attach(H)