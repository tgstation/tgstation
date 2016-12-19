/obj/item/weapon/gun/energy/frame
	name = "energy gun frame"
	desc = "A frame for constructing an Energy Gun."
	customizable_type = CUSTOMIZABLE_ENERGY
	icon = 'icons/obj/guncrafting/main.dmi'
	icon_state = "frame_energy"
	charge_sections = 2
	ammo_type = list()

/obj/item/weapon/gun/energy/frame/testing
	pin = /obj/item/device/firing_pin/test_range

/obj/item/weapon/gun_attachment/frame/energy
	hacky_as_fuck = /obj/item/weapon/gun/energy/frame


/obj/item/weapon/gun/ballistic/frame
	name = "projectile gun frame"
	desc = "A frame for constructing an Projectile Gun."
	customizable_type = CUSTOMIZABLE_PROJECTILE
	icon = 'icons/obj/guncrafting/main.dmi'
	icon_state = "frame_projectile"

/obj/item/weapon/gun/ballistic/frame/testing
	pin = /obj/item/device/firing_pin/test_range

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
	var/obj/item/weapon/gun_attachment/barrel/B = new /obj/item/weapon/gun_attachment/barrel/medium
	force_attach(B)
	var/obj/item/weapon/gun_attachment/base/E = new /obj/item/weapon/gun_attachment/base/egun
	force_attach(E)
	var/obj/item/weapon/gun_attachment/handle/H = new /obj/item/weapon/gun_attachment/handle/semiauto
	force_attach(H)


/obj/item/weapon/gun/energy/frame/lasergun
	name = "laser gun"

/obj/item/weapon/gun/energy/frame/lasergun/New()
	..()
	var/obj/item/weapon/gun_attachment/barrel/B = new /obj/item/weapon/gun_attachment/barrel/medium
	force_attach(B)
	var/obj/item/weapon/gun_attachment/base/E = new /obj/item/weapon/gun_attachment/base/laser
	force_attach(E)
	var/obj/item/weapon/gun_attachment/handle/H = new /obj/item/weapon/gun_attachment/handle/semiauto
	force_attach(H)

/obj/item/weapon/gun/energy/frame/hybrid_taser
	name = "hybrid taser"

/obj/item/weapon/gun/energy/frame/hybrid_taser/New()
	..()
	var/obj/item/weapon/gun_attachment/barrel/B = new /obj/item/weapon/gun_attachment/barrel/medium
	force_attach(B)
	var/obj/item/weapon/gun_attachment/base/E = new /obj/item/weapon/gun_attachment/base/htaser
	force_attach(E)
	var/obj/item/weapon/gun_attachment/handle/H = new /obj/item/weapon/gun_attachment/handle/semiauto
	force_attach(H)