/obj/item/gun/ballistic/automatic/pistol/paco //Sec pistol, Paco from CEV Eris.
	name = "FS HG .35 Auto \"Paco\""
	desc = "A modern and reliable sidearm for the soldier in the field. Commonly issued as a sidearm to Security Officers. Uses standard .35 and high capacity magazines."
	icon = 'monkestation/icons/obj/guns/paco.dmi'
	icon_state = "paco"
	inhand_icon_state = "paco"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m35
	can_suppress = FALSE
	fire_sound = 'sound/weapons/gun/pistol/shot_alt.ogg'
	rack_sound = 'sound/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/slide_drop.ogg'

//Lethal ammo for Paco.
/obj/item/ammo_casing/c35
	name = ".35 bullet casing"
	desc = "A .35 bullet casing."
	caliber = CALIBER_35
	projectile_type = /obj/projectile/bullet/c35

/obj/item/ammo_box/magazine/m35
	name = "\improper Paco pistol magazine (.35)"
	desc = "A .35 pistol magazine for the Paco handgun. Consult your head of security before use."
	icon = 'monkestation/icons/obj/guns/ammo.dmi'
	icon_state = "35"
	base_icon_state = "35"
	ammo_type = /obj/item/ammo_casing/c35
	caliber = CALIBER_35
	max_ammo = 16
	multiple_sprites = AMMO_BOX_PER_BULLET
	multiple_sprite_use_base = TRUE

/obj/item/ammo_box/magazine/m35/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 2)]"

/obj/projectile/bullet/c35
	name = ".35 bullet"
	damage = 15

//Rubber ammo for Paco.
/obj/item/ammo_box/magazine/m35/rubber
	name = "\improper Paco pistol magazine (.35 Rubber)"
	desc = "A .35 rubber pistol magazine for the Paco handgun. Loaded with rubber ammo for assisting in arrests."
	icon_state = "35r"
	base_icon_state = "35r"
	ammo_type = /obj/item/ammo_casing/c35/rubber

/obj/item/ammo_casing/c35/rubber
	name = ".35 rubber bullet casing"
	desc = "A .35 rubber bullet casing."
	projectile_type = /obj/projectile/bullet/c35/rubber

/obj/projectile/bullet/c35/rubber
	name = ".35 rubber bullet"
	damage = 5
	stamina = 35 //10 less than disabler
	sharpness = NONE
	embedding = null
