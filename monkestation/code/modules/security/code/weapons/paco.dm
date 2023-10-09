/obj/item/gun/ballistic/automatic/pistol/paco //Sec pistol, Paco(renamed to TACO) from CEV Eris.
	name = "\improper FS HG .35 Auto \"Taco\""
	desc = "A modern and reliable sidearm for the soldier in the field. Commonly issued as a sidearm to Security Officers. Uses standard and rubber .35 and high capacity magazines."
	icon = 'monkestation/code/modules/security/icons/paco.dmi'
	icon_state = "paco"
	inhand_icon_state = "paco"
	lefthand_file = 'monkestation/code/modules/security/icons/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/security/icons/guns_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m35
	can_suppress = FALSE
	fire_sound = 'sound/weapons/gun/pistol/shot_alt.ogg'
	rack_sound = 'sound/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/slide_drop.ogg'

/obj/item/gun/ballistic/automatic/pistol/paco/no_mag
	spawnwithmagazine = FALSE

//Lethal ammo for Taco.
/obj/item/ammo_casing/c35
	name = ".35 bullet casing"
	desc = "A .35 bullet casing."
	caliber = CALIBER_35
	projectile_type = /obj/projectile/bullet/c35

/obj/item/ammo_box/magazine/m35
	name = "\improper \"Taco\" pistol magazine (.35)"
	desc = "A .35 pistol magazine for the Taco handgun. Consult your head of security before use."
	icon = 'monkestation/code/modules/security/icons/paco_ammo.dmi'
	icon_state = "35"
	base_icon_state = "35"
	ammo_type = /obj/item/ammo_casing/c35
	caliber = CALIBER_35
	max_ammo = 16
	multiple_sprites = AMMO_BOX_PER_BULLET
	multiple_sprite_use_base = TRUE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/magazine/m35/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 2)]"

/obj/projectile/bullet/c35
	name = ".35 bullet"
	damage = 20

/obj/item/ammo_box/c35
	name = "ammo box (.35)"
	desc = "An ammo box with .35 ammo for the \"Taco\" handgun. This one has a heart on it, d'awww."
	icon = 'monkestation/code/modules/security/icons/paco_ammo.dmi'
	icon_state = "35_ammobox"
	ammo_type = /obj/item/ammo_casing/c35
	max_ammo = 40
	w_class = WEIGHT_CLASS_NORMAL

//Rubber ammo for Taco.
/obj/item/ammo_box/magazine/m35/rubber
	name = "\improper \"Taco\" pistol magazine (.35 Rubber)"
	desc = "A .35 rubber pistol magazine for the \"Taco\" handgun. Loaded with rubber ammo for assisting in arrests."
	icon_state = "35r"
	base_icon_state = "35r"
	ammo_type = /obj/item/ammo_casing/c35/rubber

/obj/item/ammo_casing/c35/rubber
	name = ".35 rubber bullet casing"
	desc = "A .35 rubber bullet casing."
	projectile_type = /obj/projectile/bullet/c35/rubber

/obj/projectile/bullet/c35/rubber
	name = ".35 rubber bullet"
	damage = 4
	stamina = 35 //10 less than disabler
	sharpness = NONE
	embedding = null

/obj/item/ammo_box/c35/rubber
	name = "ammo box (.35 Rubber)"
	desc = "An ammo box with .35 rubber ammo for the \"Taco\" handgun."
	icon_state = "35r_ammobox"
	ammo_type = /obj/item/ammo_casing/c35/rubber
	max_ammo = 40
