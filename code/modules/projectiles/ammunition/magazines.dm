////////////////INTERNAL MAGAZINES//////////////////////

/obj/item/ammo_box/magazine/internal
	desc = "Oh god, this shouldn't be here"

//internals magazines are accessible, so replace spent ammo if full when trying to put a live one in
/obj/item/ammo_box/magazine/internal/give_round(obj/item/ammo_casing/R)
	return ..(R,1)



// Revolver internal mags
/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/ammo_count(countempties = 1)
	var/boolets = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet && (bullet.BB || countempties))
			boolets++

	return boolets

/obj/item/ammo_box/magazine/internal/cylinder/get_round(keep = 0)
	rotate()

	var/b = stored_ammo[1]
	if(!keep)
		stored_ammo[1] = null

	return b

/obj/item/ammo_box/magazine/internal/cylinder/proc/rotate()
	var/b = stored_ammo[1]
	stored_ammo.Cut(1,2)
	stored_ammo.Insert(0, b)

/obj/item/ammo_box/magazine/internal/cylinder/proc/spin()
	for(var/i in 1 to rand(0, max_ammo*2))
		rotate()


/obj/item/ammo_box/magazine/internal/cylinder/give_round(obj/item/ammo_casing/R, replace_spent = 0)
	if(!R || (caliber && R.caliber != caliber) || (!caliber && R.type != ammo_type))
		return 0

	for(var/i in 1 to stored_ammo.len)
		var/obj/item/ammo_casing/bullet = stored_ammo[i]
		if(!bullet || !bullet.BB) // found a spent ammo
			stored_ammo[i] = R
			R.loc = src

			if(bullet)
				bullet.loc = get_turf(src.loc)
			return 1

	return 0

/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "detective revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/rev38/can_load(mob/user)
	user << "<span class='notice'>You start reloading...</span>"
	if(!do_after(user, 30, target = user))
		return 0
	return 1

/obj/item/ammo_box/magazine/internal/cylinder/grenademulti
	name = "grenade launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = "40mm"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/rev762
	name = "nagant revolver cylinder"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = "n762"
	max_ammo = 7

// Shotgun internal mags
/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = "shotgun"
	max_ammo = 4
	multiload = 0

/obj/item/ammo_box/magazine/internal/shot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/ammo_count(countempties = 1)
	if (!countempties)
		var/boolets = 0
		for(var/obj/item/ammo_casing/bullet in stored_ammo)
			if(bullet.BB)
				boolets++
		return boolets
	else
		return ..()

/obj/item/ammo_box/magazine/internal/shot/com
	name = "combat shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/dual
	name = "double-barrel shotgun internal magazine"
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/shot/improvised
	name = "improvised shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/improvised
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/shot/riot
	name = "riot shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 6




/obj/item/ammo_box/magazine/internal/grenadelauncher
	name = "grenade launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = "40mm"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/speargun
	name = "speargun internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/magspear
	caliber = "speargun"
	max_ammo = 1

/obj/item/ammo_box/magazine/internal/rus357
	name = "russian revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/rus357/New()
	stored_ammo += new ammo_type(src)

/obj/item/ammo_box/magazine/internal/boltaction
	name = "bolt action rifle internal magazine"
	desc = "Oh god, this shouldn't be here"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 5
	multiload = 1

/obj/item/ammo_box/magazine/internal/shot/toy
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = "foam_force"
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/toy/crossbow
	max_ammo = 5

///////////EXTERNAL MAGAZINES////////////////

/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "A gun magazine."
	icon_state = "9x19p"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45)"
	icon_state = "45-8"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 8

/obj/item/ammo_box/magazine/m45/update_icon()
	..()
	icon_state = "45-[ammo_count() ? "8" : "0"]"

/obj/item/ammo_box/magazine/wt550m9
	name = "wt550 magazine (4.6x30mm)"
	icon_state = "46x30mmt-20"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = "4.6x30mm"
	max_ammo = 20

/obj/item/ammo_box/magazine/wt550m9/update_icon()
	..()
	icon_state = "46x30mmt-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "wt550 magazine (Armour Piercing 4.6x30mm)"
	ammo_type = /obj/item/ammo_casing/c46x30mmap

/obj/item/ammo_box/magazine/wt550m9/wttx
	name = "wt550 magazine (Toxin Tipped 4.6x30mm)"
	ammo_type = /obj/item/ammo_casing/c46x30mmtox

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "wt550 magazine (Incindiary 4.6x30mm)"
	ammo_type = /obj/item/ammo_casing/c46x30mminc

/obj/item/ammo_box/magazine/uzim9mm
	name = "uzi magazine (9mm)"
	icon_state = "uzi9mm-32"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon()
	..()
	icon_state = "uzi9mm-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/smgm9mm
	name = "SMG magazine (9mm)"
	icon_state = "smg9mm-42"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 21

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "SMG magazine (Armour Piercing 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mmap

/obj/item/ammo_box/magazine/smgm9mm/toxin
	name = "SMG magazine (Toxin Tipped 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mmtox

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "SMG Magazine (Incindiary 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mminc

/obj/item/ammo_box/magazine/pistolm9mm
	name = "pistol magazine (9mm)"
	icon_state = "9x19p-8"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/update_icon()
	..()
	icon_state = "9x19p-[ammo_count() ? "8" : "0"]"

/obj/item/ammo_box/magazine/smgm45
	name = "SMG magazine (.45)"
	icon_state = "c20r45-24"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45nostamina
	caliber = ".45"
	max_ammo = 24

/obj/item/ammo_box/magazine/smgm45/update_icon()
	..()
	icon_state = "c20r45-[round(ammo_count(),2)]"

obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50ae)"
	icon_state = "50ae"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = ".50"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/magazine/m75
	name = "specialized magazine (.75)"
	icon_state = "75"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = "75"
	multiple_sprites = 2
	max_ammo = 8

/obj/item/ammo_box/magazine/m556
	name = "toploader magazine (5.56mm)"
	icon_state = "5.56m"
	origin_tech = "combat=5;syndicate=1"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "a556"
	max_ammo = 30
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g taser slugs)"
	desc = "A drum magazine."
	icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug
	origin_tech = "combat=3;syndicate=1"
	caliber = "shotgun"
	max_ammo = 8

/obj/item/ammo_box/magazine/m12g/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[Ceiling(ammo_count(0)/8)*8]"

/obj/item/ammo_box/magazine/m12g/buckshot
	name = "shotgun magazine (12g buckshot slugs)"
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/m12g/slug
	name = "shotgun magazine (12g slugs)"
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g dragon's breath)"
	icon_state = "m12gf"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12g bioterror)"
	icon_state = "m12gt"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bioterror

/obj/item/ammo_box/magazine/m12g/breach
	name = "shotgun magazine (12g breacher slugs)"
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/breaching

/obj/item/ammo_box/magazine/toy
	name = "foam force META magazine"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	caliber = "foam_force"

/obj/item/ammo_box/magazine/toy/smg
	name = "foam force SMG magazine"
	icon_state = "smg9mm-20"
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smg/update_icon()
	..()
	icon_state = "smg9mm-[round(ammo_count(),5)]"

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol
	name = "foam force pistol magazine"
	icon_state = "9x19p"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot

/obj/item/ammo_box/magazine/toy/smgm45
	name = "donksoft SMG magazine"
	caliber = "foam_force"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smgm45/update_icon()
	..()
	icon_state = "c20r45-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/toy/m762
	name = "donksoft box magazine"
	caliber = "foam_force"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	max_ammo = 50

/obj/item/ammo_box/magazine/toy/m762/update_icon()
	..()
	icon_state = "a762-[round(ammo_count(),10)]"
