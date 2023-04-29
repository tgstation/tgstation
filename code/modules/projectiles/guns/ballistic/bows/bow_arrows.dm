///base arrow
/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stabby Stabman!"
	icon = 'icons/obj/weapons/guns/bows/arrows.dmi'
	icon_state = "arrow"
	inhand_icon_state = "arrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow
	flags_1 = NONE
	throwforce = 1
	firing_effect_type = null
	caliber = CALIBER_ARROW
	heavy_metal = FALSE

/obj/item/ammo_casing/caseless/arrow/Initialize(mapload)
	. = ..()
	AddComponent(/datum/element/envenomable_casing)

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

///*sigh* NON-REUSABLE base arrow projectile. In the future: let's componentize the reusable subtype, jesus
/obj/projectile/bullet/arrow
	name = "arrow"
	desc = "Ow! Get it out of me!"
	icon = 'icons/obj/weapons/guns/bows/arrows.dmi'
	icon_state = "arrow_projectile"
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
	icon_state = "holy_arrow_projectile"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/holy
	damage = 20 //still a lot but this is roundstart gear so far less

/obj/projectile/bullet/reusable/arrow/holy/Initialize(mapload)
	. = ..()
	//50 damage to revenants
	AddElement(/datum/element/bane, target_type = /mob/living/simple_animal/revenant, damage_multiplier = 0, added_damage = 30)

/// special pyre sect arrow
/// in the future, this needs a special sprite, but bows don't support non-hardcoded arrow sprites
/obj/item/ammo_casing/caseless/arrow/holy/blazing
	name = "blazing star arrow"
	desc = "A holy diver seeking its target, blessed with fire. Will ignite on hit, destroying the arrow. But if you hit an already ignited target...?"
	projectile_type = /obj/projectile/bullet/arrow/blazing

/obj/projectile/bullet/arrow/blazing
	name = "blazing arrow"
	desc = "THE UNMATCHED POWER OF THE SUN"
	icon_state = "holy_arrow_projectile"
	damage = 20

/obj/projectile/bullet/arrow/blazing/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/human_target = target
	if(!human_target.on_fire)
		to_chat(human_target, span_danger("[src] explodes into flames which quickly envelop you!"))
		human_target.adjust_fire_stacks(2)
		human_target.ignite_mob()
		return
	to_chat(human_target, span_danger("[src] reacts with the flames on y-"))
	explosion(src, light_impact_range = 1, flame_range = 2) //ow
