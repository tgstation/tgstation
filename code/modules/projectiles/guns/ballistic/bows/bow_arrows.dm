///base arrow
/obj/item/ammo_casing/arrow
	name = "arrow"
	desc = "Stabby Stabman!"
	icon = 'icons/obj/weapons/bows/arrows.dmi'
	icon_state = "arrow"
	base_icon_state = "arrow"
	inhand_icon_state = "arrow"
	projectile_type = /obj/projectile/bullet/arrow
	flags_1 = NONE
	throwforce = 1
	firing_effect_type = null
	caliber = CALIBER_ARROW
	///Whether the bullet type spawns another casing of the same type or not.
	var/reusable = TRUE

/obj/item/ammo_casing/arrow/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/envenomable_casing)
	AddElement(/datum/element/caseless, reusable)

/obj/item/ammo_casing/arrow/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]"

///base arrow projectile
/obj/projectile/bullet/arrow
	name = "arrow"
	desc = "Ow! Get it out of me!"
	icon = 'icons/obj/weapons/bows/arrows.dmi'
	icon_state = "arrow_projectile"
	damage = 50
	speed = 1
	range = 25
	shrapnel_type = null
	embed_type = /datum/embedding/arrow

/datum/embedding/arrow
	embed_chance = 90
	fall_chance = 2
	jostle_chance = 2
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.5
	pain_mult = 3
	jostle_pain_mult = 3
	rip_time = 1 SECONDS

/// sticky arrows
/obj/item/ammo_casing/arrow/sticky
	name = "sticky arrow"
	desc = "A sticky arrow. Not sharp-ended, but ripping it off yourself once hit would be rather difficult and painful."
	icon_state = "sticky_arrow"
	inhand_icon_state = "sticky_arrow"
	base_icon_state = "sticky_arrow"
	projectile_type = /obj/projectile/bullet/arrow/sticky

///sticky arrow projectile
/obj/projectile/bullet/arrow/sticky
	name = "sticky arrow"
	desc = "Quite the sticky situation..."
	icon_state = "sticky_arrow_projectile"
	damage = 30
	speed = 1.3
	range = 20
	embed_type = /datum/embedding/arrow/sticky

/datum/embedding/arrow/sticky
	embed_chance = 99
	fall_chance = 0
	jostle_chance = 1
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.7
	pain_mult = 3
	jostle_pain_mult = 3
	rip_time = 8 SECONDS

/// poison arrows
/obj/item/ammo_casing/arrow/poison
	name = "poisonous arrow"
	desc = "A poisonous arrow."
	icon_state = "poison_arrow"
	inhand_icon_state = "poison_arrow"
	base_icon_state = "poison_arrow"
	projectile_type = /obj/projectile/bullet/arrow/poison

/// poison arrow projctile
/obj/projectile/bullet/arrow/poison
	name = "poisonous arrow"
	desc = "Better to not get hit with this!"
	icon_state = "poison_arrow_projectile"
	damage = 40
	embed_type = /datum/embedding/arrow

/obj/projectile/bullet/arrow/poison/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!ishuman(target))
		return

	target.reagents?.add_reagent(/datum/reagent/toxin/cyanide, 8)
	target.reagents?.add_reagent(/datum/reagent/toxin/staminatoxin, 1)

/// holy arrows
/obj/item/ammo_casing/arrow/holy
	name = "holy arrow"
	desc = "A holy diver seeking its target."
	icon_state = "holy_arrow"
	inhand_icon_state = "holy_arrow"
	base_icon_state = "holy_arrow"
	projectile_type = /obj/projectile/bullet/arrow/holy

/// holy arrow projectile
/obj/projectile/bullet/arrow/holy
	name = "holy arrow"
	desc = "Here it comes, cultist scum!"
	icon_state = "holy_arrow_projectile"

/obj/projectile/bullet/arrow/holy/Initialize(mapload)
	. = ..()
	//50 damage to revenants
	AddElement(/datum/element/bane, target_type = /mob/living/basic/revenant, damage_multiplier = 0, added_damage = 30)

/// plastic arrows
// completely dogshit quality and they break when they hit something.
/obj/item/ammo_casing/arrow/plastic
	name = "plastic arrow"
	desc = "The earliest mining teams within the Spinward Sector were the somewhat stout ancestors of the modern settlers. These teams \
		found themselves often unable to access the quality materials they were digging up for equipment maintenance, all being sent off-site. \
		Left with few options, and in need of a way to protect themselves in the hostile work environments of the Spinward, they turned \
		to the one material they had in abundance."
	icon_state = "plastic_arrow"
	base_icon_state = "plastic_arrow"
	projectile_type = /obj/projectile/bullet/arrow/plastic
	reusable = FALSE //cheap shit

/// plastic arrow projectile
/obj/projectile/bullet/arrow/plastic
	name = "plastic arrow"
	desc = "If this is about to kill you, you should feel genuine shame."
	damage = 5
	stamina = 50
	weak_against_armour = TRUE
	icon_state = "plastic_arrow_projectile"

/// special pyre sect arrow
/// in the future, this needs a special sprite, but bows don't support non-hardcoded arrow sprites
/obj/item/ammo_casing/arrow/holy/blazing
	name = "blazing star arrow"
	desc = "A holy diver seeking its target, blessed with fire. Will ignite on hit, destroying the arrow. But if you hit an already ignited target...?"
	projectile_type = /obj/projectile/bullet/arrow/blazing
	reusable = FALSE

/obj/projectile/bullet/arrow/blazing
	name = "blazing arrow"
	desc = "THE UNMATCHED POWER OF THE SUN"
	icon_state = "holy_arrow_projectile"
	damage = 20
	embed_type = null

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
	to_chat(human_target, span_danger("[src] reacts with the flames enveloping you! Oh shit!"))
	explosion(src, light_impact_range = 1, flame_range = 2) //ow
