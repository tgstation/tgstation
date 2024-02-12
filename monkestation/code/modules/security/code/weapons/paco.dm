/obj/item/gun/ballistic/automatic/pistol/paco //Sec pistol, Paco from CEV Eris.
	name = "\improper FS HG .35 Auto \"Paco\""
	desc = "A modern and reliable sidearm for the soldier in the field. Commonly issued as a sidearm to Security Officers. Uses standard and rubber .35 Auto and high capacity magazines."
	icon = 'monkestation/code/modules/security/icons/paco.dmi'
	icon_state = "paco"
	inhand_icon_state = "paco"
	lefthand_file = 'monkestation/code/modules/security/icons/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/security/icons/guns_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m35
	can_suppress = FALSE
	fire_sound = 'monkestation/code/modules/security/sound/paco/paco_shot.ogg'
	rack_sound = 'monkestation/code/modules/security/sound/paco/paco_rack.ogg'
	lock_back_sound = 'monkestation/code/modules/security/sound/paco/paco_lock.ogg'
	bolt_drop_sound = 'monkestation/code/modules/security/sound/paco/paco_drop.ogg'
	load_sound = 'monkestation/code/modules/security/sound/paco/paco_magin.ogg'
	load_empty_sound = 'monkestation/code/modules/security/sound/paco/paco_magin.ogg'
	eject_sound = 'monkestation/code/modules/security/sound/paco/paco_magout.ogg'
	eject_empty_sound = 'monkestation/code/modules/security/sound/paco/paco_magout.ogg'
	var/has_stripe = TRUE
	var/COOLDOWN_STRIPE

/obj/item/gun/ballistic/automatic/pistol/paco/Initialize(mapload) //Sec pistol, Paco(renamed to TACO... Atleast 10 percent of the time)
	. = ..()
	if(prob(10))
		name = "\improper FS HG .35 Auto \"Taco\" LE"
		desc += " <font color=#FFE733>You notice a small difference on the side of the pistol... An engraving depicting a taco! It's a Limited Run model!</font>"

/obj/item/gun/ballistic/automatic/pistol/paco/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/paco/update_icon_state()
	. = ..()
	if(!has_stripe) //Definitely turn this into a switch case statement if someone (or I) decide to add more variants, but this works for now
		icon_state = "spaco"
		inhand_icon_state = "spaco"

/obj/item/gun/ballistic/automatic/pistol/paco/add_seclight_point() //Seclite functionality
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'monkestation/icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "pacoflight", \
		overlay_x = 15, \
		overlay_y = 13)

/obj/item/gun/ballistic/automatic/pistol/paco/AltClick(mob/user) //Some people like the stripe, some people don't. Gives you the option to do the unthinkable.
	if(has_stripe && !TIMER_COOLDOWN_CHECK(src, COOLDOWN_STRIPE)) //Checks if the gun has a stripe to rip and is not on cooldown
		TIMER_COOLDOWN_START(src, COOLDOWN_STRIPE, 6 SECONDS)
		playsound(src, 'sound/items/duct_tape_snap.ogg', 50, TRUE)
		balloon_alert_to_viewers("[user] starts picking at the Paco's stripe!")
		if(do_after(user, 6 SECONDS))
			has_stripe = FALSE
			obj_flags = UNIQUE_RENAME
			desc += " You figure there's ample room to engrave something nice on it, but know that it'd offer no tactical advantage whatsoever."
			playsound(src, 'sound/items/duct_tape_rip.ogg', 50, TRUE)
			playsound(src, rack_sound, 50, TRUE) //Increases satisfaction
			balloon_alert_to_viewers("[user] rips the stripe right off the Paco!") //The implication that the stripe is just a piece of red tape is very funny
			update_icon_state()
			update_appearance() //So you don't have to rack the slide to update the sprite
			update_inhand_icon(user) //So you don't have to switch the gun inhand to update the inhand sprite

//Lethal ammo for Paco.
/obj/item/ammo_casing/c35
	name = ".35 Auto bullet casing"
	desc = "A .35 Auto bullet casing."
	icon = 'monkestation/code/modules/security/icons/paco_ammo.dmi'
	icon_state = "35_casing"
	caliber = CALIBER_35
	projectile_type = /obj/projectile/bullet/c35

/obj/item/ammo_box/magazine/m35
	name = "\improper \"Paco\" pistol magazine (.35 Auto)"
	desc = "A .35 Auto pistol magazine for the Paco handgun. Consult your head of security before use."
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
	name = ".35 Auto bullet"
	damage = 20

/obj/item/ammo_box/c35
	name = "ammunition packet (.35 Auto)"
	desc = "A shiny box containing .35 Auto ammo for the \"Paco\" handgun."
	icon = 'monkestation/code/modules/security/icons/paco_ammo.dmi'
	icon_state = "35_ammobox"
	ammo_type = /obj/item/ammo_casing/c35
	max_ammo = 40
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_NORMAL

//Rubber ammo for Paco.
/obj/item/ammo_box/magazine/m35/rubber
	name = "\improper \"Paco\" pistol magazine (.35 Auto Rubber)"
	desc = "A .35 Auto rubber pistol magazine for the \"Paco\" handgun. Loaded with rubber ammo for assisting in arrests."
	icon_state = "35r"
	base_icon_state = "35r"
	ammo_type = /obj/item/ammo_casing/c35/rubber

/obj/item/ammo_casing/c35/rubber
	name = ".35 Auto rubber bullet casing"
	desc = "A .35 Auto rubber bullet casing."
	icon_state = "35r_casing"
	projectile_type = /obj/projectile/bullet/c35/rubber

/obj/projectile/bullet/c35/rubber
	name = ".35 Auto rubber bullet"
	icon = 'monkestation/code/modules/security/icons/paco_ammo.dmi'
	icon_state = "rubber_bullet"
	damage = 4
	stamina = 45 // Turns out 35 stamina damage is not good enough.
	sharpness = NONE
	embedding = null

/obj/item/ammo_box/c35/rubber
	name = "ammunition packet (.35 Auto Rubber)"
	desc = "A shiny box containing .35 Auto rubber ammo for the \"Paco\" handgun."
	icon_state = "35r_ammobox"
	ammo_type = /obj/item/ammo_casing/c35/rubber
	max_ammo = 40
