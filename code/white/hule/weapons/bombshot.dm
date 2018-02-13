/obj/item/ammo_casing/shotgun/bombslug
	name = "FRAGZ-5-10-15 slug"
	desc = "A high explosive round for a 12 gauge shotgun."
	icon = 'code/white/hule/weapons/weapons.dmi'
	icon_state = "bombslug"
	projectile_type = /obj/item/projectile/bullet/shotgun_bombslug

/obj/item/projectile/bullet/shotgun_bombslug
	name ="FRAGZ-5-10-15 slug"
	icon_state = "missile"
	damage = 25
	knockdown = 50

/obj/item/projectile/bullet/shotgun_bombslug/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, 5, 10, 15)
	return TRUE