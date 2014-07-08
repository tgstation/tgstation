#define SPELL_ANIMATION_TTL 2 MINUTES

/obj/item/projectile/animate
	name = "bolt of animation"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"

/obj/item/projectile/animate/Bump(var/atom/change)
	if(istype(change, /obj/item) || istype(change, /obj/structure) && !is_type_in_list(change, protected_objects))
		var/obj/O = change
		new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer, duration=SPELL_ANIMATION_TTL)
	..()