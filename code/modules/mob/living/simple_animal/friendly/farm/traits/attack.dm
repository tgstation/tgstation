/datum/farm_animal_trait/aggressive
	name = "Aggressive"
	description = "This animal will attack other creatures at random."
	manifest_probability = 55
	continue_probability = 75
	var/atom/target
	var/attack_prob = 1
	var/calm_down_prob = 10

/datum/farm_animal_trait/aggressive/on_life(var/mob/living/simple_animal/farm/M)
	if(M.stat)
		target = null
		return
	if(!target && prob(attack_prob))
		var/list/orange_grab = oview(M,7)
		var/list/potential_prey = list()
		for(var/mob/living/C in orange_grab)
			if(C.stat)
				continue
			if(istype(C, M.type))
				continue
			potential_prey += C
		if(potential_prey.len)
			target = get_closest_atom(/mob/living, potential_prey, M)
			M.visible_message("<span class='danger'>[M] gets an evil-looking gleam in \his eye.</span>")
		else
			return
	if(target)
		if(prob(10))
			M.visible_message("<span class='notice'>[M] calms down.</span>")
			target = null
			return
		var/mob/living/T = target
		if(T && !M.Adjacent(T))
			walk_to(M, T, 1)
			spawn(30)
				if(T && M.Adjacent(T))
					walk_to(M,0)
					if(T.stat != DEAD)
						T.attack_animal(M)
						M.do_attack_animation(T)
						for(var/datum/farm_animal_trait/TA in owner.traits)
							TA.on_attack_mob(M, T)
						return
					else
						target = null
						return
		else
			if(T && M.Adjacent(T))
				walk_to(M,0)
				if(T.stat != DEAD)
					T.attack_animal(M)
					M.do_attack_animation(T)
					for(var/datum/farm_animal_trait/TA in owner.traits)
						TA.on_attack_mob(M, T)
					return
				else
					target = null
					return

/datum/farm_animal_trait/aggressive/hyper
	name = "Hyper Aggressive"
	description = "This animal will attack other creatures all the time, and won't let anything stop it."
	manifest_probability = 55
	continue_probability = 75
	attack_prob = 100
	calm_down_prob = 0

/datum/farm_animal_trait/aggressive/hyper/on_life(var/mob/living/simple_animal/farm/M)
	if(M.stat)
		target = null
		return
	if(M.buckled)
		M.buckled.attack_animal(M)
		return
	if(!isturf(M.loc) && M.loc != null)//Did someone put us in something?
		var/atom/A = M.loc
		A.attack_animal(M)//Bang on it till we get out
		return
	var/turf/T = get_step(M, M.dir)
	for(var/atom/A in T)
		if(!A.Adjacent(M))
			continue
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack))
			A.attack_animal(M)
			return
	if(target)
		if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper))
			var/atom/A = target.loc
			if(A)
				if(!A.Adjacent(M))
					walk_to(M, A, 1)
					spawn(30)
						walk_to(M,0)
						if(A.Adjacent(M))
							A.attack_animal(M)
				else
					A.attack_animal(M)
	..()

/datum/farm_animal_trait/weakening_strikes
	name = "Weakening Strikes"
	description = "This animal will deal stamina damage to those it attacks."
	manifest_probability = 55
	continue_probability = 75
	opposite_trait = /datum/farm_animal_trait/toxic_spit

/datum/farm_animal_trait/weakening_strikes/on_attack_mob(var/mob/living/simple_animal/farm/M, var/mob/living/L)
	if(L && ishuman(L))
		L.adjustStaminaLoss(M.dna.strength)
	return

/datum/farm_animal_trait/toxic_spit
	name = "Toxic Spit"
	description = "This animal will spit toxins at those it attacks, causing toxin damage."
	manifest_probability = 55
	continue_probability = 75
	opposite_trait = /datum/farm_animal_trait/weakening_strikes

/datum/farm_animal_trait/toxic_spit/on_attack_mob(var/mob/living/simple_animal/farm/M, var/mob/living/L)
	if(L)
		L.adjustToxLoss(M.dna.strength)
	return