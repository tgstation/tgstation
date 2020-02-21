/obj/projectile/magic/projectile/acid
	name = "acid splash"
	icon_state = "declone"
	damage = 8
	damage_type = BURN
	nodamage = TRUE

/obj/projectile/magic/projectile/acid/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.acid_act(42.0, 30)
		L.adjustFireLoss(roll(4,6))
	if(isobj(target))
		var/obj/O = target
		O.acid_act(42.0, 30)
	if(isturf(target))
		var/turf/T = target
		T.acid_act(42.0, 30)

/obj/projectile/magic/projectile/chill_touch
	name = "chill touch"
	icon_state = "cursehand1"
	damage = 8
	damage_type = BURN
	nodamage = TRUE

/obj/projectile/magic/projectile/chill_touch/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.apply_status_effect(/datum/status_effect/grouped/chill_touch)
		L.adjustBruteLoss(roll(4,8))