
///////XCOM X9 AR///////

/obj/item/gun/ballistic/automatic/x9	//will be adminspawn only so ERT or something can use them
	name = "\improper X9 Assault Rifle"
	desc = "A rather old design of a cheap, reliable assault rifle made for combat against unknown enemies. Uses 5.56mm ammo."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "x9"
	item_state = "arg"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/m556	//Uses the m90gl's magazine, just like the NT-ARG
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = 0
	burst_size = 6	//in line with XCOMEU stats. This can fire 5 bursts from a full magazine.
	fire_delay = 1
	spread = 30	//should be 40 for XCOM memes, but since its adminspawn only, might as well make it useable
	recoil = 1

///////security rifles special ammo///////

/obj/item/ammo_casing/c46x30mm/rubber
	name = "4.6x30mm rubberbullet casing"
	desc = "A 4.6x30mm rubberbullet casing."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/c46x30mm/rubber

/obj/item/ammo_box/magazine/wt550m9/wtrubber
	name = "wt550 magazine (Rubber bullets 4.6x30mm)"
	icon_state = "46x30mmtA-20"
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber

/obj/item/projectile/bullet/c46x30mm/rubber
	name = "4.6x30mm bullet"
	damage = 5
	stamina = 20

///toy memes///

/obj/item/ammo_box/magazine/toy/x9
	name = "foam force X9 magazine"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "toy9magazine"
	max_ammo = 30
	multiple_sprites = 2
	materials = list(MAT_METAL = 200)

/obj/item/gun/ballistic/automatic/x9/toy
	name = "\improper Foam Force X9"
	desc = "An old but reliable assault rifle made for combat against unknown enemies. Appears to be hastily converted. Ages 8 and up."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "toy9"
	can_suppress = 0
	obj_flags = 0
	mag_type = /obj/item/ammo_box/magazine/toy/x9
	casing_ejector = 0
	spread = 90		//MAXIMUM XCOM MEMES (actually that'd be 180 spread)
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY


//////Flechette Launcher//////

///projectiles///

/obj/item/projectile/bullet/cflechetteap	//shreds armor
	name = "flechette (armor piercing)"
	damage = 8
	armour_penetration = 80

/obj/item/projectile/bullet/cflechettes		//shreds flesh and forces bleeding
	name = "flechette (serrated)"
	damage = 15
	dismemberment = 10
	armour_penetration = -80

/obj/item/projectile/bullet/cflechettes/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.bleed(10)
	return ..()

///ammo casings (CASELESS AMMO CASINGS WOOOOOOOO)///

/obj/item/ammo_casing/caseless/flechetteap
	name = "flechette (armor piercing)"
	desc = "A flechette made with a tungsten alloy."
	projectile_type = /obj/item/projectile/bullet/cflechetteap
	caliber = "flechette"
	throwforce = 1
	throw_speed = 3

/obj/item/ammo_casing/caseless/flechettes
	name = "flechette (serrated)"
	desc = "A serrated flechette made of a special alloy intended to deform drastically upon penetration of human flesh."
	projectile_type = /obj/item/projectile/bullet/cflechettes
	caliber = "flechette"
	throwforce = 2
	throw_speed = 3
	embedding = list("embedded_pain_multiplier" = 0, "embed_chance" = 40, "embedded_fall_chance" = 10)

///magazine///

/obj/item/ammo_box/magazine/flechette
	name = "flechette magazine (armor piercing)"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "flechettemag"
	ammo_type = /obj/item/ammo_casing/caseless/flechetteap
	caliber = "flechette"
	max_ammo = 40
	multiple_sprites = 2

/obj/item/ammo_box/magazine/flechette/s
	name = "flechette magazine (serrated)"
	ammo_type = /obj/item/ammo_casing/caseless/flechettes

///the gun itself///

/obj/item/gun/ballistic/automatic/flechette
	name = "\improper CX Flechette Launcher"
	desc = "A flechette launching machine pistol with an unconventional bullpup frame."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "flechettegun"
	item_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = 0
	/obj/item/firing_pin/implant/pindicate
	mag_type = /obj/item/ammo_box/magazine/flechette/
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = 0
	burst_size = 5
	fire_delay = 1
	casing_ejector = 0
	spread = 10
	recoil = 0.05

/obj/item/gun/ballistic/automatic/flechette/update_icon()
	..()
	if(magazine)
		cut_overlays()
		add_overlay("flechettegun-magazine")
	else
		cut_overlays()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

///unique variant///

/obj/item/projectile/bullet/cflechetteshredder
	name = "flechette (shredder)"
	damage = 5
	dismemberment = 40

/obj/item/ammo_casing/caseless/flechetteshredder
	name = "flechette (shredder)"
	desc = "A serrated flechette made of a special alloy that forms a monofilament edge."
	projectile_type = /obj/item/projectile/bullet/cflechettes

/obj/item/ammo_box/magazine/flechette/shredder
	name = "flechette magazine (shredder)"
	icon_state = "shreddermag"
	ammo_type = /obj/item/ammo_casing/caseless/flechetteshredder

/obj/item/gun/ballistic/automatic/flechette/shredder
	name = "\improper CX Shredder"
	desc = "A flechette launching machine pistol made of ultra-light CFRP optimized for firing serrated monofillament flechettes."
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/flechette/shredder
	spread = 15
	recoil = 0.1

/obj/item/gun/ballistic/automatic/flechette/shredder/update_icon()
	..()
	if(magazine)
		cut_overlays()
		add_overlay("shreddergun-magazine")
	else
		cut_overlays()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/*/////////////////////////////////////////////////////////////
//////////////////////// Zero's Meme //////////////////////////
*//////////////////////////////////////////////////////////////
/obj/item/ammo_box/magazine/toy/AM4B
	name = "foam force AM4-B magazine"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "AM4MAG-60"
	max_ammo = 60
	multiple_sprites = 0
	materials = list(MAT_METAL = 200)

/obj/item/gun/ballistic/automatic/AM4B
	name = "AM4-B"
	desc = "A Relic from a bygone age. Nobody quite knows why it's here. Has a polychromic coating."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "AM4"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/toy/AM4B
	can_suppress = 0
	item_flags = NEEDS_PERMIT
	casing_ejector = 0
	spread = 30		//Assault Rifleeeeeee
	w_class = WEIGHT_CLASS_NORMAL
	burst_size = 4	//Shh.
	fire_delay = 1
	var/body_color = "#3333aa"

/obj/item/gun/ballistic/automatic/AM4B/update_icon()
	..()
	var/mutable_appearance/body_overlay = mutable_appearance('modular_citadel/icons/obj/guns/cit_guns.dmi', "AM4-Body")
	if(body_color)
		body_overlay.color = body_color
	cut_overlays()		//So that it doesn't keep stacking overlays non-stop on top of each other
	add_overlay(body_overlay)
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
/obj/item/gun/ballistic/automatic/AM4B/AltClick(mob/living/user)
	if(!in_range(src, user))	//Basic checks to prevent abuse
		return
	if(user.incapacitated() || !istype(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(alert("Are you sure you want to recolor your gun?", "Confirm Repaint", "Yes", "No") == "Yes")
		var/body_color_input = input(usr,"","Choose Shroud Color",body_color) as color|null
		if(body_color_input)
			body_color = sanitize_hexcolor(body_color_input, desired_format=6, include_crunch=1)
		update_icon()
/obj/item/gun/ballistic/automatic/AM4B/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to recolor it.</span>")

/obj/item/ammo_box/magazine/toy/AM4C
	name = "foam force AM4-C magazine"
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "AM4MAG-32"
	max_ammo = 32
	multiple_sprites = 0
	materials = list(MAT_METAL = 200)

/obj/item/gun/ballistic/automatic/AM4C
	name = "AM4-C"
	desc = "A Relic from a bygone age. This one seems newer, yet less effective."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "AM4C"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/toy/AM4C
	can_suppress = 0
	item_flags = NEEDS_PERMIT
	casing_ejector = 0
	spread = 45		//Assault Rifleeeeeee
	w_class = WEIGHT_CLASS_NORMAL
	burst_size = 4	//Shh.
	fire_delay = 1
