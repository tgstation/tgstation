/// Chilling projectile, hurts and slows you down
/obj/projectile/temp/watcher
	name = "chilling blast"
	icon_state = "ice_2"
	damage = 10
	damage_type = BURN
	armor_flag = ENERGY
	temperature = -50

/obj/projectile/temp/watcher/on_hit(mob/living/target, blocked = 0)
	. = ..()
	if (!isliving(target))
		return
	apply_status(target)

/// Apply an additional on-hit effect
/obj/projectile/temp/watcher/proc/apply_status(mob/living/target)
	target.apply_status_effect(/datum/status_effect/freezing_blast)

/// Lava projectile, ignites you
/obj/projectile/temp/watcher/magma_wing
	name = "scorching blast"
	icon_state = "lava"
	damage = 5
	temperature = 200

/obj/projectile/temp/watcher/magma_wing/apply_status(mob/living/target)
	target.adjust_fire_stacks(0.1)
	target.ignite_mob()

/// Freezing projectile, freezes you
/obj/projectile/temp/watcher/ice_wing
	name = "freezing blast"
	damage = 5

/obj/projectile/temp/watcher/ice_wing/apply_status(mob/living/target)
	target.apply_status_effect(/datum/status_effect/freon/watcher)
