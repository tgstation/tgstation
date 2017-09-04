/mob/living/carbon/monkey/proc/throw_stuff(atom/target)
	if(get_dist(src, target) >= 2 && prob(18))
		src.visible_message("<span class='danger'>[src] throws poo at [target]!</span>", "You throw poo at [target]!")
		var/turf/proj_turf = loc
		if(!isturf(proj_turf))
			return FALSE
		var/obj/item/projectile/monkey/F = new /obj/item/projectile/monkey(proj_turf)
		F.preparePixelProjectile(target, get_turf(target), src)
		F.firer = src
		F.fire()
		playsound(src, 'hippiestation/sound/voice/scream_monkey.ogg', 100, 1)
		frustration = min(frustration - 1, 0)
		return TRUE
	return FALSE