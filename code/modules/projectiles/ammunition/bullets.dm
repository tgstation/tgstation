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


/obj/item/ammo_casing/a12mm
	desc = "A 12mm bullet casing."
	caliber = "12mm"
	projectile_type = /obj/item/projectile/bullet/midbullet


/obj/item/ammo_casing/shotgun
	name = "shotgun slug"							//classic
	desc = "A 12 gauge lead slug for shotguns."
	icon_state = "blshell"
	caliber = "shotgun"
	projectile_type = /obj/item/projectile/bullet
	m_amt = 4000

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"							 //combat
	desc = "A 12 gauge buckshot shell for shotguns."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet
	pellets = 5
	variance = 0.8

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"							//bartender
	desc = "A weak beanbag slug for shotguns."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet
	m_amt = 250

/obj/item/ammo_casing/shotgun/stunslug
	name = "stun slug"								//protolathe beanbag upgrade
	desc = "An electrified, stunning taser slug for shotguns."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/stunslug
	m_amt = 200

/obj/item/ammo_casing/shotgun/stunshell
	name = "stun shell"								//riot control
	desc = "A stunning shell of weak rubber pellets for a shotgun."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet
	pellets = 5
	variance = 0.8

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"						//hacked autolathe
	desc = "A smaller, flammable lead slug that coats targets in flame."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell

/obj/item/ammo_casing/shotgun/dragon
	name = "dragon's breath shell"					//syndie chaos
	desc = "A dragon's breath shell of several flammable pellets."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/mech
	pellets = 5
	variance = 0.8

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"							//hacked autolathe
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
