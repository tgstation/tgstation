/obj/item/ammo_box/magazine/toy
	name = "foam force META magazine"
	desc = "A magazine specifically designed for foam force \"firearms\". Probably not great for actually killing your fellow spaceman."
	abstract_type = /obj/item/ammo_box/magazine/toy
	ammo_type = /obj/item/ammo_casing/foam_dart
	caliber = CALIBER_FOAM

/obj/item/ammo_box/magazine/toy/smg
	name = "foam force SMG magazine"
	icon_state = "smg9mm"
	base_icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/foam_dart
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smg/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[LAZYLEN(stored_ammo) ? "full" : "empty"]"

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol
	name = "foam force pistol magazine"
	icon_state = "9x19p"
	max_ammo = 12
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/foam_dart/riot

/obj/item/ammo_box/magazine/toy/smgm45
	name = "donksoft SMG magazine"
	icon_state = "c20r45-toy"
	base_icon_state = "c20r45-toy"
	caliber = CALIBER_FOAM
	ammo_type = /obj/item/ammo_casing/foam_dart
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smgm45/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-base"

/obj/item/ammo_box/magazine/toy/smgm45/update_overlays()
	. = ..()
	if(!LAZYLEN(stored_ammo))
		return
	for(var/i in 1 to stored_ammo.len)
		var/round_number = round(i, 2) //i meant the number of the round in the magazine, but i guess it's a round number too lol.
		if(round_number == i) //only count odd numbers.
			continue
		var/obj/item/ammo_casing/foam_dart/boolet = stored_ammo[i]
		. += "c20r45-foam-[boolet::tip_color]-[round_number]"


/obj/item/ammo_box/magazine/toy/smgm45/riot
	icon_state = "c20r45-riot"
	base_icon_state = "c20r45-riot"
	ammo_type = /obj/item/ammo_casing/foam_dart/riot

/obj/item/ammo_box/magazine/toy/m762
	name = "donksoft box magazine"
	icon_state = "a7mm-toy"
	base_icon_state = "a7mm"
	ammo_type = /obj/item/ammo_casing/foam_dart
	max_ammo = 50

/obj/item/ammo_box/magazine/toy/m762/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 10)]"

/obj/item/ammo_box/magazine/toy/m762/riot
	icon_state = "a7mm-riot"
	ammo_type = /obj/item/ammo_casing/foam_dart/riot
