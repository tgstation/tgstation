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
		to_chat(src, "<span class='danger'><B>Your punch has applied heavy gravity to [target]</span></B>")
		add_gravity(target, 2)
		to_chat(target, "<span class='userdanger'>Everything feels really heavy!</span>")

/mob/living/simple_animal/hostile/guardian/gravitokinetic/AltClickOn(atom/A)
	if(isopenturf(A))
		var/turf/T = A
		if(isspaceturf(T))
			to_chat(src, "<span class='warning'>You cannot add gravity to space!</span>")
			return
		visible_message("<span class='danger'>[src] slams their fist into the [T]!</span>", "<span class='notice'>You modify the gravity of the [T].</span>")
		do_attack_animation(T)
		add_gravity(T, 4)
		return
	..()

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Recall(forced)
	. = ..()
	to_chat(src, "<span class='danger'><B>You have released your gravitokinetic powers!</span></B>")
	for(var/atom/target in gravito_targets)
		qdel(target.GetComponent(/datum/component/forced_gravity))
	gravito_targets = list()

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Life()
	. = ..()
	for(var/atom/target in gravito_targets)
		if(get_dist(src, target) > gravity_power_range)
			qdel(target.GetComponent(/datum/component/forced_gravity))
			gravito_targets.Remove(target)
			continue

//		if(!isopenturf(target))
//			turf_effect(target)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/add_gravity(atom/A, new_gravity = 2)
	if(!gravito_targets.len)//we are adding one, so start processing
		START_PROCESSING(SSfastprocess, src)
	gravito_targets.Add(A)
	A.AddComponent(/datum/component/forced_gravity,new_gravity)
	//sound

/*
/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/turf_effect(turf/open/T, new_gravity = 2)
	if(!T.get_filter("gravity"))
		T.add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
*/

/mob/living/simple_animal/hostile/guardian/gravitokinetic/process()
	if(!gravito_targets.len)
		return PROCESS_KILL
	for(var/atom/A in gravito_targets)
		var/matrix/M = new
		if(!isliving(A))
			M.Translate(rand(-2, 2), rand(0, 1))
		else
			M.Translate(rand(-1, 1))
		animate(A, transform=M, time=1)
		animate(transform=matrix(), time=1)
