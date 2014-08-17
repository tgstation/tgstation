/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/a418
	desc = "A .418 bullet casing."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet/suffocationbullet


/obj/item/ammo_casing/a666
	desc = "A .666 bullet casing."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet/cyanideround


/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = /obj/item/projectile/bullet/weakbullet2


/obj/item/ammo_casing/c10mm
	desc = "A 10mm bullet casing."
	caliber = "10mm"
	projectile_type = /obj/item/projectile/bullet/midbullet3


/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/midbullet2


/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/midbullet


/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge slug."
	icon_state = "blshell"
	caliber = "shotgun"
	projectile_type = /obj/item/projectile/bullet
	m_amt = 4000


/obj/item/ammo_casing/shotgun/buckshot
	name = "shotgun shell"
	desc = "A 12 gauge shell."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet
	pellets = 5
	variance = 0.8


/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet
	m_amt = 250


/obj/item/ammo_casing/shotgun/stunshell
	name = "stun shell"
	desc = "A stunning shell."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/stunshot
	m_amt = 200


/obj/item/ammo_casing/shotgun/meteorshot
	name = "meteorshot shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "mshell"
	projectile_type = /obj/item/projectile/bullet/meteorshot

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = /obj/item/projectile/beam/pulse/shot

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary shell which fires a single slug of incendiary ammo."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	name = "dragonsbreath shell"
	desc = "An incendiary shell which fires a spread of incendiary ammo."
	icon_state = "ishell2"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath
	pellets = 4
	variance = 0.9

/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	icon_state = "cshell"
	projectile_type = null

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Can be injected with up to 30 units of any chemical."
	icon_state = "cshell"
	projectile_type = /obj/item/projectile/bullet/dart

/obj/item/ammo_casing/shotgun/dart/New()
	..()
	flags |= NOREACT
	flags |= OPENCONTAINER
	create_reagents(30)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/a762
	desc = "A 7.62mm bullet casing."
	caliber = "a762"
	projectile_type = /obj/item/projectile/bullet


/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."


/obj/item/ammo_casing/caseless/fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, params, var/distro, var/quiet)
	if (..())
		loc = null
		return 1
	else
		return 0


/obj/item/ammo_casing/caseless/a75
	desc = "A .75 bullet casing."
	caliber = "75"
	projectile_type = /obj/item/projectile/bullet/gyro
