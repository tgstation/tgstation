// Junk

/obj/item/ammo_casing/shotgun/junk
	name = "improvised junk round"
	desc = "What is in the shell? Shoot it to find out."
	icon_state = "improvshell"
	caliber = CALIBER_SHOTGUN
	projectile_type = /obj/projectile/bullet/junk
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*2, /datum/material/glass=SMALL_MATERIAL_AMOUNT*1)

// Junk Shell Spawner; used to spawn in our random shells upon crafting

/obj/effect/spawner/random/junk_shell
	name = "junk shell spawner"
	desc = "Bullet. Bullet Bullet."
	icon_state = "junkround"
	loot = list(
		/obj/item/ammo_casing/shotgun/junk = 50,
		/obj/item/ammo_casing/shotgun/junk/incendiary = 20,
		/obj/item/ammo_casing/shotgun/junk/shock = 20,
		/obj/item/ammo_casing/shotgun/junk/hunter = 20,
		/obj/item/ammo_casing/shotgun/junk/phasic = 5,
		/obj/item/ammo_casing/shotgun/junk/ripper = 5,
		/obj/item/ammo_casing/shotgun/junk/reaper = 1,
	)

/obj/item/ammo_casing/shotgun/junk/incendiary
	projectile_type = /obj/projectile/bullet/incendiary/fire/junk

/obj/item/ammo_casing/shotgun/junk/phasic
	projectile_type = /obj/projectile/bullet/junk/phasic

/obj/item/ammo_casing/shotgun/junk/shock
	projectile_type = /obj/projectile/bullet/junk/shock

/obj/item/ammo_casing/shotgun/junk/hunter
	projectile_type = /obj/projectile/bullet/junk/hunter

/obj/item/ammo_casing/shotgun/junk/ripper
	projectile_type = /obj/projectile/bullet/junk/ripper

/obj/item/ammo_casing/shotgun/junk/reaper
	projectile_type = /obj/projectile/bullet/junk/reaper
