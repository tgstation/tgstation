// .357 (Syndie Revolver)

/obj/item/ammo_casing/a357
	name = ".357 bullet casing"
	desc = "A .357 bullet casing."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet/a357

// 7.62 (Nagant Rifle)

/obj/item/ammo_casing/a762
	name = "7.62 bullet casing"
	desc = "A 7.62 bullet casing."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = /obj/item/projectile/bullet/a762

/obj/item/ammo_casing/a762/enchanted
	projectile_type = /obj/item/projectile/bullet/a762_enchanted

// 7.62x38mmR (Nagant Revolver)

/obj/item/ammo_casing/n762
	name = "7.62x38mmR bullet casing"
	desc = "A 7.62x38mmR bullet casing."
	caliber = "n762"
	projectile_type = /obj/item/projectile/bullet/n762

// .50AE (Desert Eagle)

/obj/item/ammo_casing/a50AE
	name = ".50AE bullet casing"
	desc = "A .50AE bullet casing."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/a50AE

// .38 (Detective's Gun)

/obj/item/ammo_casing/c38
	name = ".38 bullet casing"
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = /obj/item/projectile/bullet/c38

// 10mm (Stechkin)

/obj/item/ammo_casing/c10mm
	name = ".10mm bullet casing"
	desc = "A 10mm bullet casing."
	caliber = "10mm"
	projectile_type = /obj/item/projectile/bullet/c10mm

/obj/item/ammo_casing/c10mm/ap
	name = ".10mm armor-piercing bullet casing"
	desc = "A 10mm armor-piercing bullet casing."
	projectile_type = /obj/item/projectile/bullet/c10mm_ap

/obj/item/ammo_casing/c10mm/hp
	name = ".10mm hollow-point bullet casing"
	desc = "A 10mm hollow-point bullet casing."
	projectile_type = /obj/item/projectile/bullet/c10mm_hp

/obj/item/ammo_casing/c10mm/fire
	name = ".10mm incendiary bullet casing"
	desc = "A 10mm incendiary bullet casing."
	projectile_type = /obj/item/projectile/bullet/incendiary/c10mm

// 9mm (Stechkin APS)

/obj/item/ammo_casing/c9mm
	name = "9mm bullet casing"
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/c9mm

/obj/item/ammo_casing/c9mm/ap
	name = "9mm armor-piercing bullet casing"
	desc = "A 9mm armor-piercing bullet casing."
	projectile_type =/obj/item/projectile/bullet/c9mm_ap

/obj/item/ammo_casing/c9mm/inc
	name = "9mm incendiary bullet casing"
	desc = "A 9mm incendiary bullet casing."
	projectile_type = /obj/item/projectile/bullet/incendiary/c9mm

// 4.6x30mm (Autorifles)

/obj/item/ammo_casing/c46x30mm
	name = "4.6x30mm bullet casing"
	desc = "A 4.6x30mm bullet casing."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/c46x30mm

/obj/item/ammo_casing/c46x30mm/ap
	name = "4.6x30mm armor-piercing bullet casing"
	desc = "A 4.6x30mm armor-piercing bullet casing."
	projectile_type = /obj/item/projectile/bullet/c46x30mm_ap

/obj/item/ammo_casing/c46x30mm/inc
	name = "4.6x30mm incendiary bullet casing"
	desc = "A 4.6x30mm incendiary bullet casing."
	projectile_type = /obj/item/projectile/bullet/incendiary/c46x30mm

// .45 (M1911)

/obj/item/ammo_casing/c45
	name = ".45 bullet casing"
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/c45

/obj/item/ammo_casing/c45/nostamina
	projectile_type = /obj/item/projectile/bullet/c45_nostamina

// 5.56mm (M-90gl Carbine)

/obj/item/ammo_casing/a556
	name = "5.56mm bullet casing"
	desc = "A 5.56mm bullet casing."
	caliber = "a556"
	projectile_type = /obj/item/projectile/bullet/a556

// 40mm (Grenade Launcher)

/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = "40mm"
	icon_state = "40mmHE"
	projectile_type = /obj/item/projectile/bullet/a40mm

// .50 (Sniper)

/obj/item/ammo_casing/p50
	name = ".50 bullet casing"
	desc = "A .50 bullet casing."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/p50
	icon_state = ".50"

/obj/item/ammo_casing/p50/soporific
	name = ".50 soporific bullet casing"
	desc = "A .50 bullet casing, specialised in sending the target to sleep, instead of hell."
	projectile_type = /obj/item/projectile/bullet/p50/soporific
	icon_state = "sleeper"

/obj/item/ammo_casing/p50/penetrator
	name = ".50 penetrator round bullet casing"
	desc = "A .50 caliber penetrator round casing."
	projectile_type = /obj/item/projectile/bullet/p50/penetrator

// 1.95x129mm (SAW)

/obj/item/ammo_casing/mm195x129
	name = "1.95x129mm bullet casing"
	desc = "A 1.95x129mm bullet casing."
	icon_state = "762-casing"
	caliber = "mm195129"
	projectile_type = /obj/item/projectile/bullet/mm195x129

/obj/item/ammo_casing/mm195x129/ap
	name = "1.95x129mm armor-piercing bullet casing"
	desc = "A 1.95x129mm bullet casing designed with a hardened-tipped core to help penetrate armored targets."
	projectile_type = /obj/item/projectile/bullet/mm195x129_ap

/obj/item/ammo_casing/mm195x129/hollow
	name = "1.95x129mm hollow-point bullet casing"
	desc = "A 1.95x129mm bullet casing designed to cause more damage to unarmored targets."
	projectile_type = /obj/item/projectile/bullet/mm195x129_hp

/obj/item/ammo_casing/mm195x129/incen
	name = "1.95x129mm incendiary bullet casing"
	desc = "A 1.95x129mm bullet casing designed with a chemical-filled capsule on the tip that when bursted, reacts with the atmosphere to produce a fireball, engulfing the target in flames. "
	projectile_type = /obj/item/projectile/bullet/incendiary/mm195x129

// Shotgun

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "blshell"
	caliber = "shotgun"
	projectile_type = /obj/item/projectile/bullet/shotgun_slug
	materials = list(MAT_METAL=4000)

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_beanbag
	materials = list(MAT_METAL=250)

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary-coated shotgun slug."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shotgun

/obj/item/ammo_casing/shotgun/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	projectile_type = /obj/item/projectile/bullet/incendiary/shotgun/dragonsbreath
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_stunslug
	materials = list(MAT_METAL=250)

/obj/item/ammo_casing/shotgun/meteorslug
	name = "meteorslug shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "mshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_meteorslug

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = /obj/item/projectile/beam/pulse/shotgun

/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for a 12 gauge shotgun."
	icon_state = "heshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_frag12

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_buckshot
	pellets = 6
	variance = 25

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_rubbershot
	pellets = 6
	variance = 25
	materials = list(MAT_METAL=4000)

/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards."
	icon_state = "improvshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_improvised
	materials = list(MAT_METAL=250)
	pellets = 10
	variance = 25

/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "An advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal split the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/item/projectile/ion/weak
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/laserslug
	name = "laser slug"
	desc = "An advanced shotgun shell that uses a micro laser to replicate the effects of a laser weapon in a ballistic package."
	icon_state = "lshell"
	projectile_type = /obj/item/projectile/beam/laser

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
	container_type |= OPENCONTAINER_1
	create_reagents(30)
	reagents.set_reacting(FALSE)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/dart/bioterror
	desc = "A shotgun dart filled with deadly toxins."

/obj/item/ammo_casing/shotgun/dart/bioterror/New()
	..()
	reagents.add_reagent("neurotoxin", 6)
	reagents.add_reagent("spore", 6)
	reagents.add_reagent("mutetoxin", 6) //;HELP OPS IN MAINT
	reagents.add_reagent("coniine", 6)
	reagents.add_reagent("sodium_thiopental", 6)
