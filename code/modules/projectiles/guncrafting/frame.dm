/obj/item/weapon/gun/energy/frame
	name = "energy gun frame"
	desc = "A frame for constructing an Energy Gun."
	customizable = TRUE
	customizable_type = ENERGY
	icon = 'icons/obj/guncrafting/main.dmi'
	icon_state = "frame_energy"
	charge_sections = 2
	ammo_type = list()
/obj/item/weapon/gun_attachment/frame/energy
	hacky_as_fuck = /obj/item/weapon/gun/energy/frame


/obj/item/weapon/gun/projectile/frame
	name = "projectile gun frame"
	desc = "A frame for constructing an Projectile Gun."
	customizable = TRUE
	customizable_type = PROJECTILE
	icon = 'icons/obj/guncrafting/main.dmi'
	icon_state = "frame_projectile"

/obj/item/weapon/gun_attachment/frame/projectile
	hacky_as_fuck = /obj/item/weapon/gun/projectile/frame


/obj/item/weapon/gun_attachment/frame
	var/hacky_as_fuck = /obj/item/weapon/gun/energy/frame

/obj/item/weapon/gun_attachment/frame/New()
	..()
	new hacky_as_fuck(get_turf(src))
	qdel(src)
	return