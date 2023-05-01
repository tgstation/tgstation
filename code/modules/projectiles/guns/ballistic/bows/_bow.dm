
/obj/item/gun/ballistic/bow
	icon = 'icons/obj/weapons/guns/bows/bows.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/bows_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bows_righthand.dmi'
	icon_state = "bow"
	inhand_icon_state = "bow"
	base_icon_state = "bow"
	load_sound = null
	fire_sound = null
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	force = 15
	attack_verb_continuous = list("whipped", "cracked")
	attack_verb_simple = list("whip", "crack")
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	internal_magazine = TRUE
	cartridge_wording = "arrow"
	bolt_type = BOLT_TYPE_NO_BOLT
	/// whether the bow is drawn back
	var/drawn = FALSE

/obj/item/gun/ballistic/bow/update_icon_state()
	. = ..()
	icon_state = chambered ? "[base_icon_state]_[drawn ? "drawn" : "nocked"]" : "[base_icon_state]"

/obj/item/gun/ballistic/bow/proc/drop_arrow()
	drawn = FALSE
	if(chambered)
		chambered.forceMove(drop_location())
		magazine.get_round(keep = FALSE)
		chambered = null
	update_appearance()

/obj/item/gun/ballistic/bow/chamber_round(keep_bullet = FALSE, spin_cylinder, replace_new_round)
	if(chambered || !magazine)
		return
	if(magazine.ammo_count())
		chambered = magazine.get_round(TRUE)
		chambered.forceMove(src)

/obj/item/gun/ballistic/bow/attack_self(mob/user)
	if(!chambered)
		balloon_alert(user, "no arrow nocked!")
	else
		balloon_alert(user, "[drawn ? "string released" : "string drawn"]")
		drawn = !drawn
	update_appearance()

/obj/item/gun/ballistic/bow/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!chambered)
		return
	if(!drawn)
		to_chat(user, span_warning("Without drawing the bow, the arrow uselessly falls to the ground."))
		drop_arrow()
		update_appearance()
		return
	drawn = FALSE
	. = ..() //fires, removing the arrow
	update_appearance()

/obj/item/gun/ballistic/bow/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_BACK && chambered)
		balloon_alert(user, "the arrow falls out!")
		drop_arrow()
		drawn = FALSE
		update_appearance()

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber(mob/living/user)
	return //no clicking sounds please

/obj/item/ammo_box/magazine/internal/bow
	name = "bowstring"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	max_ammo = 1
	start_empty = TRUE
	caliber = CALIBER_ARROW
