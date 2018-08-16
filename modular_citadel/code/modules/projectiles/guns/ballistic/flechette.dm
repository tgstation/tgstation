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
