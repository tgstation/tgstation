/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion

/obj/item/projectile/ion/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, 1, 1)
	return TRUE

/obj/item/projectile/ion/weak

/obj/item/projectile/ion/weak/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, 0, 0)
	return TRUE
