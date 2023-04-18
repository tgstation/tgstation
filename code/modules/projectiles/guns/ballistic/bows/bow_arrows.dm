///base arrow
/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stabby Stabman!"
	icon_state = "arrow"
	inhand_icon_state = "arrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow
	flags_1 = NONE
	throwforce = 1
	firing_effect_type = null
	caliber = CALIBER_ARROW
	heavy_metal = FALSE

///base arrow projectile
/obj/projectile/bullet/reusable/arrow
	name = "arrow"
	desc = "Ow! Get it out of me!"
	icon = 'icons/obj/weapons/guns/bows/arrows.dmi'
	icon_state = "arrow_projectile"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	damage = 50
	speed = 1
	range = 25

/// despawning arrow type
/obj/item/ammo_casing/caseless/arrow/despawning/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(floor_vanish)), 5 SECONDS)

/obj/item/ammo_casing/caseless/arrow/despawning/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/// holy arrows
/obj/item/ammo_casing/caseless/arrow/holy
	name = "holy arrow"
	desc = "A holy diver seeking its target."
	icon_state = "holy_arrow"
	inhand_icon_state = "holy_arrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow/holy

/// holy arrow projectile
/obj/projectile/bullet/reusable/arrow/holy
	name = "holy arrow"
	desc = "Here it comes, cultist scum!"
	icon = "holy_arrow_projectile"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/holy
	damage = 20 //still a lot but this is roundstart gear so far less

/obj/projectile/bullet/reusable/arrow/holy/Initialize(mapload)
	. = ..()
	//50 damage to revenants
	AddElement(/datum/element/bane, target_type = /mob/living/simple_animal/revenant, damage_multiplier = 0, added_damage = 30)
