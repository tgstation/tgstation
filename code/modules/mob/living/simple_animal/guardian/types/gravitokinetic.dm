//gravitokinetic
/mob/living/simple_animal/hostile/guardian/gravitokinetic
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, CLONE = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = "<span class='holoparasite'>As a <b>gravitokinetic</b> type, you can alt click to make the gravity on the ground stronger, and punching applies this effect to a target.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Singularity, an anomalous force of terror.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Gravitokinetic modules loaded. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! Caught one! It's a gravitokinetic carp! Now do you understand the gravity of the situation?</span>"
	var/list/gravito_targets = list()
	var/gravity_power_range = 10 //how close the stand must stay to the target to keep the heavy gravity

/mob/living/simple_animal/hostile/guardian/gravitokinetic/AttackingTarget()
	. = ..()
	if(isliving(target))
		to_chat(target, "<span class='danger'><B>Your punch has applied heavy gravity to [target]</span></B>")
		gravito_targets += target
		target.AddComponent(/datum/component/forced_gravity,2)
		to_chat(target, "<span class='userdanger'>You are hit by an immense weight!</span>")
		//sound

/mob/living/simple_animal/hostile/guardian/gravitokinetic/AltClickOn(atom/A)
	if(isturf(A))
		var/turf/T = A
		visible_message("<span class='danger'>[src] slams their fist into the [T]!</span>", "<span class='notice'>You modify the gravity of the [T].</span>")
		do_attack_animation(T)
		T.AddComponent(/datum/component/forced_gravity,4)
		gravito_targets += T
		//sound

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Life()
	. = ..()
	if(gravito_targets.len)
		if(loc == summoner)
			to_chat(src, "<span class='danger'><B>You have released your gravitokinetic powers!</span></B>")
			for(var/atom/i in gravito_targets)
				qdel(i.GetComponent(/datum/component/forced_gravity))
				gravito_targets -= i
			return //no more targets confirmed
		for(var/atom/target in gravito_targets)
			if(get_dist(src, target) > gravity_power_range)
				qdel(target.GetComponent(/datum/component/forced_gravity))
				gravito_targets -= target
