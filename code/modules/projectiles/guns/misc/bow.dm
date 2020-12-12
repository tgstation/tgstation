
/obj/item/gun/ballistic/bow
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "bow"
	fire_sound = null
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	force = 15
	attack_verb_continuous = list("whipped", "cracked")
	attack_verb_simple = list("whip", "crack")
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	var/drawn = FALSE

/obj/item/gun/ballistic/bow/dropped(mob/user)
	. = ..()
	drop_arrow()

/obj/item/gun/ballistic/bow/update_icon()
	. = ..()
	if(!chambered)
		icon_state = "bow"
	else
		icon_state = "bow_[drawn]"

/obj/item/gun/ballistic/bow/proc/drop_arrow()
	if(!chambered)
		return
	drawn = FALSE
	chambered = magazine.get_round()
	chambered.forceMove(drop_location())
	update_icon()

/obj/item/gun/ballistic/bow/chamber_round()
	if(chambered || !magazine)
		return
	if(magazine.ammo_count())
		chambered = magazine.get_round(TRUE)
		chambered.forceMove(src)

/obj/item/gun/ballistic/bow/attack_self(mob/user)
	drawn = !drawn
	update_icon()

/obj/item/gun/ballistic/bow/attack_hand(mob/user)
	. = ..()
	if(chambered)
		drop_arrow()

/obj/item/gun/ballistic/bow/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	drawn = FALSE
	update_icon()
	. = ..()

/obj/item/ammo_box/magazine/internal/bow
	name = "bowstring"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	max_ammo = 1
	start_empty = TRUE
	caliber = "arrow"

/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stabby Stabman!"
	flags_1 = NONE
	throwforce = 1
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	firing_effect_type = null
	caliber = "arrow"
	heavy_metal = FALSE

/obj/projectile/bullet/reusable/arrow
	name = "arrow"
	desc = "Ow! Get it out of me!"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	damage = 25
	speed = 0.8
	range = 25
