/obj/item/weapon/gun/energy/frame
	name = "energy gun frame"
	desc = "A frame for constructing an Energy Gun."
	customizable_type = CUSTOMIZABLE_ENERGY
	icon = 'icons/obj/guncrafting/ausops_new.dmi'
	icon_state = "frame_energy"
	charge_sections = 2
	ammo_type = list()
	unique_rename = 1
	var/battery_state = "battery_normal"

/obj/item/weapon/gun/energy/frame/New()
	..()
	icon_state = "frame_energy[rand(1,3)]"

/obj/item/weapon/gun/energy/frame/testing
	pin = null

/obj/item/weapon/gun/energy/frame/testing/high
	name = "high energy gun frame"
	cell_type = /obj/item/weapon/stock_parts/cell/high
	battery_state = "battery_high"

/obj/item/weapon/gun/energy/frame/testing/super
	name = "super energy gun frame"
	cell_type = /obj/item/weapon/stock_parts/cell/super
	battery_state = "battery_super"

/obj/item/weapon/gun/energy/frame/testing/hyper
	name = "hyper energy gun frame"
	cell_type = /obj/item/weapon/stock_parts/cell/hyper
	battery_state = "battery_hyper"

/obj/item/weapon/gun/energy/frame/testing/bluespace
	name = "bluespace energy gun frame"
	cell_type = /obj/item/weapon/stock_parts/cell/bluespace
	battery_state = "battery_bluespace"


/obj/item/weapon/gun/ballistic/frame
	name = "projectile gun frame"
	desc = "This is my rifle. There are many like it, but this one is mine. My rifle is my best friend. It is my life. I must master it as I must master my life. My rifle, without me, is useless. Without my rifle, I am useless. I must fire my rifle true. I must shoot straighter than my enemy who is trying to kill me. I must shoot him before he shoots me."
	customizable_type = CUSTOMIZABLE_PROJECTILE
	icon = 'icons/obj/guncrafting/ausops_new.dmi'
	icon_state = "frame_projectile"
	unique_rename = 1
	spawnwithmagazine = 0
	var/random_frame = 1

/obj/item/weapon/gun/ballistic/frame/New()
	..()
	if(random_frame)
		icon_state = "frame_projectile[rand(1,3)]"

/obj/item/weapon/gun/ballistic/frame/revolver
	name = "revolver frame"
	desc = "Six bullets. More than enough to kill anything that moves."
	customizable_type = CUSTOMIZABLE_REVOLVER
	icon = 'icons/obj/guncrafting/ausops_new.dmi'
	icon_state = "frame_revolver"
	unique_rename = 1
	spawnwithmagazine = 0
	random_frame = 0

/obj/item/weapon/gun/ballistic/frame/testing
	pin = null

/obj/item/weapon/gun/ballistic/frame/revolver/testing
	pin = null

/obj/item/weapon/random_guncrafting_guns
	name = "FUCKKK"

/obj/item/weapon/random_guncrafting_guns/New()
	..()
	var/list/energy_bases = list(/obj/item/weapon/gun_attachment/base/stun,
								/obj/item/weapon/gun_attachment/base/laser,
								/obj/item/weapon/gun_attachment/base/disable)
	var/list/projectile_bases = list(/obj/item/weapon/gun_attachment/base/assault,
								/obj/item/weapon/gun_attachment/base/pistol,
								/obj/item/weapon/gun_attachment/base/shotgun)
	var/list/revolver_bases = list(/obj/item/weapon/gun_attachment/base/revolver_357,
								/obj/item/weapon/gun_attachment/base/revolver_38)
	var/obj/item/weapon/gun/energy/frame/EF = new(get_turf(src))
	var/obj/item/weapon/gun/ballistic/frame/revolver/RF = new(get_turf(src))
	var/obj/item/weapon/gun/ballistic/frame/BF = new(get_turf(src))
	var/f1 = pick((subtypesof(/obj/item/weapon/gun_attachment/barrel) - subtypesof(/obj/item/weapon/gun_attachment/barrel/revolver)))
	var/f2 = pick(subtypesof(/obj/item/weapon/gun_attachment/barrel/revolver))
	var/f3 = pick((subtypesof(/obj/item/weapon/gun_attachment/barrel) - subtypesof(/obj/item/weapon/gun_attachment/barrel/revolver)))
	var/obj/item/weapon/gun_attachment/barrel/B1 = new f1
	var/obj/item/weapon/gun_attachment/barrel/B2 = new f2
	var/obj/item/weapon/gun_attachment/barrel/B3 = new f3
	EF.force_attach(B1)
	RF.force_attach(B2)
	BF.force_attach(B3)
	var/f4 = pick(energy_bases)
	var/f5 = pick(revolver_bases)
	var/f6 = pick(projectile_bases)
	var/obj/item/weapon/gun_attachment/base/E1 = new f4
	var/obj/item/weapon/gun_attachment/base/E2 = new f5
	var/obj/item/weapon/gun_attachment/base/E3 = new f6
	EF.force_attach(E1)
	RF.force_attach(E2)
	BF.force_attach(E3)
	var/f7 = pick((subtypesof(/obj/item/weapon/gun_attachment/handle) - /obj/item/weapon/gun_attachment/handle/revolver))
	var/f8 = /obj/item/weapon/gun_attachment/handle/revolver
	var/f9 = pick((subtypesof(/obj/item/weapon/gun_attachment/handle) - /obj/item/weapon/gun_attachment/handle/revolver))
	var/obj/item/weapon/gun_attachment/handle/H1 = new f7
	var/obj/item/weapon/gun_attachment/handle/H2 = new f8
	var/obj/item/weapon/gun_attachment/handle/H3 = new f9
	EF.force_attach(H1)
	RF.force_attach(H2)
	BF.force_attach(H3)
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
	update_icon()


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
	update_icon()

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
	update_icon()

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
	update_icon()

/obj/item/weapon/gun/ballistic/frame/revolver/revolver_38
	name = ".38 Special revolver"

/obj/item/weapon/gun/ballistic/frame/revolver/revolver_38/New()
	..()
	var/obj/item/weapon/gun_attachment/barrel/B = new /obj/item/weapon/gun_attachment/barrel/revolver/medium
	force_attach(B)
	var/obj/item/weapon/gun_attachment/base/E = new /obj/item/weapon/gun_attachment/base/revolver_38
	force_attach(E)
	var/obj/item/weapon/gun_attachment/handle/H = new /obj/item/weapon/gun_attachment/handle/revolver
	force_attach(H)
	update_icon()