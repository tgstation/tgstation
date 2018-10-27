/obj/item/ammo_box/a357
	name = "speed loader (.357)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/c38
	name = "speed loader (.38)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	multiple_sprites = 1
	materials = list(MAT_METAL = 20000)

/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	icon_state = "9mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 20

/obj/item/ammo_box/c45
	name = "ammo box (.45)"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/a40mm
	name = "ammo box (40mm grenades)"
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_box/a762
	name = "stripper clip (7.62mm)"
	desc = "A stripper clip."
	icon_state = "762"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 5
	multiple_sprites = 1

/obj/item/ammo_box/n762
	name = "ammo box (7.62x38mmR)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14

/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40
	materials = list(MAT_METAL = 500)

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	materials = list(MAT_METAL = 50000)

/obj/item/ammo_box/shotgun
	name = "ammo box (12g)"
	icon_state = "12g_box"
	ammo_type = /obj/item/ammo_casing/shotgun
	max_ammo = 8
	start_empty = TRUE

/obj/item/ammo_box/shotgun/Initialize(mapload)
	..()
	if(mapload)
		start_empty = FALSE

/obj/item/ammo_box/shotgun/attack_self(mob/user)
	..()
	if(!stored_ammo.len)
		to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
		var/obj/item/I = new /obj/item/stack/sheet/cardboard
		qdel(src)
		user.put_in_hands(I)

/obj/item/ammo_box/shotgun/buckshot
	name = "ammo box (Buckshot)"
	icon_state = "buckshot_box"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/shotgun/rubbershot
	name = "ammo box (Rubbershot)"
	icon_state = "rubber_box"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot

/obj/item/ammo_box/shotgun/beanbag
	name = "ammo box (Beanbag)"
	icon_state = "rubber_box"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/shotgun/incendiary
	name = "ammo box (Incendary)"
	icon_state = "incendiary_box"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/shotgun/dart
	name = "ammo box (Dart)"
	icon_state = "dart_box"
	ammo_type = /obj/item/ammo_casing/shotgun/dart

/obj/item/ammo_box/shotgun/meteorshot
	name = "ammo box (Meteor)"
	icon_state = "meteor_box"
	ammo_type = /obj/item/ammo_casing/shotgun/meteorslug

/obj/item/ammo_box/shotgun/pulseslug
	name = "ammo box (Pulse)"
	icon_state = "pulseslug_box"
	ammo_type = /obj/item/ammo_casing/shotgun/pulseslug

/obj/item/ammo_box/shotgun/frag12
	name = "ammo box (FRAG-12)"
	icon_state = "frag12_box"
	ammo_type = /obj/item/ammo_casing/shotgun/frag12

/obj/item/ammo_box/shotgun/stunslug
	name = "ammo box (Taser)"
	icon_state = "taser_box"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/shotgun/ion
	name = "ammo box (EMP)"
	icon_state = "emp_box"
	ammo_type = /obj/item/ammo_casing/shotgun/ion

/obj/item/ammo_box/shotgun/laserslug
	name = "ammo box (Scatter Laser)"
	icon_state = "scatterlaser_box"
	ammo_type = /obj/item/ammo_casing/shotgun/laserslug

/obj/item/ammo_box/shotgun/noreact
	name = "ammo box (Cryostasis)"
	icon_state = "cryo_box"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/noreact

/obj/item/ammo_box/shotgun/dragonsbreath
	name = "ammo box (Dragonsbreath)"
	icon_state = "dragonsbreath_box"
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/shotgun/techshell
	name = "ammo box (Techshell)"
	icon_state = "techshell_box"
	ammo_type = /obj/item/ammo_casing/shotgun/techshell