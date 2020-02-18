/obj/projectile/magic/ray
	hitscan = TRUE

/obj/projectile/magic/ray/frost
	name = "ray of frost"
	icon_state = "ice_2"
	damage = 8
	damage_type = BURN
	nodamage = FALSE

/obj/projectile/ray/frost/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.bodytemperature -= 100
		L.apply_status_effect(/datum/status_effect/freon)
	if(isobj(target))
		var/obj/O = target
		if(O.resistance_flags & FREEZE_PROOF)
			return
		if(!(O.obj_flags & FROZEN))
			O.make_frozen_visual()