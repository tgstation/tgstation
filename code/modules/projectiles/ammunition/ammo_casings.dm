/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/a762
	desc = "A 7.62 bullet casing."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/a762/enchanted
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = /obj/item/projectile/bullet/weakbullet2

/obj/item/ammo_casing/c10mm
	desc = "A 10mm bullet casing."
	caliber = "10mm"
	projectile_type = /obj/item/projectile/bullet/midbullet3

/obj/item/ammo_casing/c10mm/ap
	projectile_type = /obj/item/projectile/bullet/midbullet3/ap

/obj/item/ammo_casing/c10mm/fire
	projectile_type = /obj/item/projectile/bullet/midbullet3/fire

/obj/item/ammo_casing/c10mm/hp
	projectile_type = /obj/item/projectile/bullet/midbullet3/hp

/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/item/ammo_casing/c9mmap
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type =/obj/item/projectile/bullet/armourpiercing

/obj/item/ammo_casing/c9mmtox
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c9mminc
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/incendiary/firebullet

/obj/item/ammo_casing/c46x30mm
	desc = "A 4.6x30mm bullet casing."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/item/ammo_casing/c46x30mmap
	desc = "A 4.6x30mm bullet casing."
	caliber = "4.6x30mm"
	projectile_type =/obj/item/projectile/bullet/armourpiercing

/obj/item/ammo_casing/c46x30mmtox
	desc = "A 4.6x30mm bullet casing."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c46x30mminc
	desc = "A 4.6x30mm bullet casing."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/incendiary/firebullet

/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/midbullet

/obj/item/ammo_casing/c45nostamina
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/midbullet3

/obj/item/ammo_casing/n762
	desc = "A 7.62x38mmR bullet casing."
	caliber = "n762"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/a556
	desc = "A 5.56mm bullet casing."
	caliber = "a556"
	projectile_type = /obj/item/projectile/bullet/heavybullet

/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = "40mm"
	icon_state = "40mmHE"
	projectile_type = /obj/item/projectile/bullet/a40mm



/////SNIPER ROUNDS

/obj/item/ammo_casing/point50
	desc = "A .50 bullet casing."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper
	icon_state = ".50"

/obj/item/ammo_casing/soporific
	desc = "A .50 bullet casing, specialised in sending the target to sleep, instead of hell."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper/soporific
	icon_state = "sleeper"

/obj/item/ammo_casing/haemorrhage
	desc = "A .50 bullet casing, specialised in causing massive bloodloss."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper/haemorrhage
	icon_state = ".50"

/obj/item/ammo_casing/penetrator
	desc = "A .50 caliber penetrator round casing."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper/penetrator
	icon_state = ".50"

/obj/item/ammo_casing/point50/gang
	desc = "A black market .50 bullet casing."
	projectile_type = /obj/item/projectile/bullet/sniper/gang

/obj/item/ammo_casing/point50/gang/sleeper
	desc = "Am illegally modified tranquilizer round."
	projectile_type = /obj/item/projectile/bullet/sniper/gang/sleeper
	icon_state = "sleeper"

/// SAW ROUNDS

/obj/item/ammo_casing/mm195x129
	desc = "A 1.95x129mm bullet casing."
	icon_state = "762-casing"
	caliber = "mm195129"
	projectile_type = /obj/item/projectile/bullet/saw

/obj/item/ammo_casing/mm195x129/bleeding
	desc = "A 1.95x129mm bullet casing with specialized inner-casing, that when it makes contact with a target, releases tiny shrapnel to induce internal bleeding."
	icon_state = "762-casing"
	projectile_type = /obj/item/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/mm195x129/hollow
	desc = "A 1.95x129mm bullet casing designed to cause more damage to unarmored targets."
	projectile_type = /obj/item/projectile/bullet/saw/hollow

/obj/item/ammo_casing/mm195x129/ap
	desc = "A 1.95x129mm bullet casing designed with a hardened-tipped core to help penetrate armored targets."
	projectile_type = /obj/item/projectile/bullet/saw/ap

/obj/item/ammo_casing/mm195x129/incen
	desc = "A 1.95x129mm bullet casing designed with a chemical-filled capsule on the tip that when bursted, reacts with the atmosphere to produce a fireball, engulfing the target in flames. "
	projectile_type = /obj/item/projectile/bullet/saw/incen




//SHOTGUN ROUNDS

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "blshell"
	caliber = "shotgun"
	projectile_type = /obj/item/projectile/bullet
	materials = list(MAT_METAL=4000)


/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet
	pellets = 6
	variance = 25

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/rpellet
	pellets = 6
	variance = 25
	materials = list(MAT_METAL=4000)


/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet
	materials = list(MAT_METAL=250)


/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards."
	icon_state = "improvshell"
	projectile_type = /obj/item/projectile/bullet/pellet/weak
	materials = list(MAT_METAL=250)
	pellets = 10
	variance = 25


/obj/item/ammo_casing/shotgun/improvised/overload
	name = "overloaded improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards. This one has been packed with even more \
	propellant. It's like playing russian roulette, with a shotgun."
	icon_state = "improvshell"
	projectile_type = /obj/item/projectile/bullet/pellet/overload
	materials = list(MAT_METAL=250)
	pellets = 4
	variance = 40


/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/stunshot
	materials = list(MAT_METAL=250)


/obj/item/ammo_casing/shotgun/meteorshot
	name = "meteorshot shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "mshell"
	projectile_type = /obj/item/projectile/bullet/meteorshot

/obj/item/ammo_casing/shotgun/breaching
	name = "breaching shell"
	desc = "An economic version of the meteorshot, utilizing similar technologies. Great for busting down doors."
	icon_state = "mshell"
	projectile_type = /obj/item/projectile/bullet/meteorshot/weak

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = /obj/item/projectile/beam/pulse/shot

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary-coated shotgun slug."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell

/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for a 12 gauge shotgun."
	icon_state = "heshell"
	projectile_type = /obj/item/projectile/bullet/frag12

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath
	pellets = 4
	variance = 35

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
