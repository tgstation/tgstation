/obj/item/projectile/energy/electrode/hippie_electrode
	stun = 0.1
	weaken = 0
	stamina = 80
	range = 8

/obj/item/projectile/beam/disabler/hippie_disabler
	speed = 0.6


/obj/item/projectile/energy/bolt/bolt_hippie
	stun = 0.1
	weaken = 0

/obj/item/projectile/energy/bolt/bolt_hippie/on_hit(atom/target, blocked = 0)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.reagents.add_reagent("skewium", 10)
		C.hallucination += 30
