/obj/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	armor_flag = ENERGY
	reflectable = REFLECT_NORMAL
	impact_effect_type = /obj/effect/temp_visual/impact_effect/energy

/obj/projectile/energy/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT, INNATE_TRAIT)
