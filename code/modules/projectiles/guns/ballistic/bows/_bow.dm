
/obj/item/gun/ballistic/bow
	icon = 'icons/obj/weapons/bows/bows.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/bows_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bows_righthand.dmi'
	name = "bow"
	desc = "Seems out-of-place in this day and age, but at least it's reliable."
	icon_state = "bow"
	inhand_icon_state = "bow"
	base_icon_state = "bow"
	load_sound = 'sound/weapons/gun/general/ballistic_click.ogg'
	fire_sound = 'sound/weapons/gun/bow/bow_fire.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/bow
	force = 15
	pinless = TRUE
	attack_verb_continuous = list("whipped", "cracked")
	attack_verb_simple = list("whip", "crack")
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	internal_magazine = TRUE
	cartridge_wording = "arrow"
	bolt_type = BOLT_TYPE_NO_BOLT
	click_on_low_ammo = FALSE
	must_hold_to_load = TRUE
	/// whether the bow is drawn back
	var/drawn = FALSE

/obj/item/gun/ballistic/bow/update_icon_state()
	. = ..()
	icon_state = chambered ? "[base_icon_state]_[drawn ? "drawn" : "nocked"]" : "[base_icon_state]"

/obj/item/gun/ballistic/bow/AltClick(mob/user)
	if(isnull(chambered))
		return ..()

	user.put_in_hands(chambered)
	chambered = magazine.get_round()
	update_appearance()

/obj/item/gun/ballistic/bow/proc/drop_arrow()
	chambered.forceMove(drop_location())
	chambered = magazine.get_round()
	update_appearance()

/obj/item/gun/ballistic/bow/chamber_round(spin_cylinder, replace_new_round)
	if(chambered || !magazine)
		return
	chambered = magazine.get_round()
	RegisterSignal(chambered, COMSIG_MOVABLE_MOVED, PROC_REF(clear_chambered))
	update_appearance()

/obj/item/gun/ballistic/bow/clear_chambered(datum/source)
	. = ..()
	drawn = FALSE

/obj/item/gun/ballistic/bow/attack_self(mob/user)
	if(!chambered)
		balloon_alert(user, "no arrow nocked!")
		return
	balloon_alert(user, "[drawn ? "string released" : "string drawn"]")
	drawn = !drawn
	playsound(src, 'sound/weapons/gun/bow/bow_draw.ogg', 25, TRUE)
	update_appearance()

/obj/item/gun/ballistic/bow/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!chambered)
		return
	if(!drawn)
		to_chat(user, span_warning("Without drawing the bow, the arrow uselessly falls to the ground."))
		drop_arrow()
		return
	return ..() //fires, removing the arrow

/obj/item/gun/ballistic/bow/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS && chambered)
		balloon_alert(user, "the arrow falls out!")
		if(drawn)
			playsound(src, 'sound/weapons/gun/bow/bow_fire.ogg', 25, TRUE)
		drop_arrow()


/obj/item/gun/ballistic/bow/dropped(mob/user, silent)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(drop_arrow_if_not_held)), 0.1 SECONDS)

/obj/item/gun/ballistic/bow/proc/drop_arrow_if_not_held()
	if(ismob(loc) || !chambered)
		return
	if(drawn)
		playsound(src, 'sound/weapons/gun/bow/bow_fire.ogg', 25, TRUE)
	drop_arrow()

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber(mob/living/user)
	return //no clicking sounds please

/obj/item/ammo_box/magazine/internal/bow
	name = "bowstring"
	ammo_type = /obj/item/ammo_casing/arrow
	max_ammo = 1
	start_empty = TRUE
	caliber = CALIBER_ARROW
