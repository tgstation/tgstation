/obj/item/projectile/energy/yellowdiamond
	name = "destabilizer blast"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = 1
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 7
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = /obj/effect/projectile/muzzle/stun
	impact_type = /obj/effect/projectile/impact/stun

/obj/item/projectile/energy/yellowdiamond/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, TRUE, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(isgem(C))
			C.setCloneLoss(9001) //FUCK EM UP!

/obj/item/projectile/energy/yellowdiamond/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, TRUE, src)
	..()
