
/obj/item/gun/ballistic/bow
	name = "longbow"
	desc = "While pretty finely crafted, surely you can find something better to use in the current year."
	icon = 'icons/obj/guns/ballistic.dmi'
	icon_state = "bow"
	inhand_icon_state = "bow"
	load_sound = null
	fire_sound = null
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	force = 15
	attack_verb_continuous = list("whipped", "cracked")
	attack_verb_simple = list("whip", "crack")
	weapon_weight = WEAPON_HEAVY
	atom_size = ITEM_SIZE_BULKY
	internal_magazine = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	var/drawn = FALSE

/obj/item/gun/ballistic/bow/update_icon_state()
	. = ..()
	icon_state = chambered ? "bow_[drawn]" : "bow"

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
	if(chambered)
		to_chat(user, span_notice("You [drawn ? "release the tension on" : "draw the string on"] [src]."))
		drawn = !drawn
	update_appearance()

/obj/item/gun/ballistic/bow/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
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

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber(mob/living/user)
	return //so clicking sounds please

/obj/item/ammo_box/magazine/internal/bow
	name = "bowstring"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	max_ammo = 1
	start_empty = TRUE
	caliber = CALIBER_ARROW

/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stabby Stabman!"
	icon_state = "arrow"
	flags_1 = NONE
	throwforce = 1
	projectile_type = /obj/projectile/bullet/reusable/arrow
	firing_effect_type = null
	caliber = CALIBER_ARROW
	heavy_metal = FALSE

/obj/item/ammo_casing/caseless/arrow/despawning/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 5 SECONDS)

/obj/item/ammo_casing/caseless/arrow/despawning/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/projectile/bullet/reusable/arrow
	name = "arrow"
	desc = "Ow! Get it out of me!"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	damage = 50
	speed = 1
	range = 25



/obj/item/storage/bag/quiver
	name = "quiver"
	desc = "Holds arrows for your bow. Good, because while pocketing arrows is possible, it surely can't be pleasant."
	icon_state = "quiver"
	inhand_icon_state = "quiver"
	worn_icon_state = "harpoon_quiver"
	max_atom_size = ITEM_SIZE_TINY
	max_total_atom_size = ITEM_SIZE_TINY * 100
	max_items = 40
	var/arrow_path = /obj/item/ammo_casing/caseless/arrow

/obj/item/storage/bag/quiver/Initialize(mapload)
	. = ..()
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	storage.set_holdable(list(
		/obj/item/ammo_casing/caseless/arrow
		))

/obj/item/storage/bag/quiver/PopulateContents()
	. = ..()
	for(var/i in 1 to 10)
		new arrow_path(src)

/obj/item/storage/bag/quiver/despawning
	arrow_path = /obj/item/ammo_casing/caseless/arrow/despawning
