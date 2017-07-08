/obj/item/projectile/energy/electrode
	stun = 0
	knockdown = 0
	stamina = 60

/obj/item/projectile/energy/electrode/on_hit(atom/target, blocked = 0)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(50))
			C.drop_item()
		..()

/obj/item/projectile/beam/disabler
	speed = 0.7
	damage = 26 //it should take about four shots to down someone, but seeing as people regen stamina all the time, setting it to 25 means you would need 5 shots.


