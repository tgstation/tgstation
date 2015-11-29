
/mob/living/simple_animal/bee
	name = "bees"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bees1"
	icon_dead = "bees1"

	size = SIZE_TINY
	can_butcher = 0

	var/strength = 1
	var/feral = 0
	var/mut = 0
	var/toxic = 0
	var/turf/target_turf
	var/mob/target
	var/obj/machinery/apiary/parent
	pass_flags = PASSTABLE
	turns_per_move = 6
	density = 0
	var/obj/machinery/portable_atmospherics/hydroponics/my_hydrotray

	// Allow final solutions.
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 360

	holder_type = null //Can't pick BEES up!
	flying = 1
	meat_type = 0

	var/max_hive_dist=5

/mob/living/simple_animal/bee/New(loc, var/obj/machinery/apiary/new_parent)
	..()
	parent = new_parent

/mob/living/simple_animal/bee/Destroy()
	..()
	if(parent)
		parent.owned_bee_swarms.Remove(src)

/mob/living/simple_animal/bee/Die()
	returnToPool(src)

/mob/living/simple_animal/bee/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	dead_mob_list -= src

	qdel(src)

/mob/living/simple_animal/bee/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return 1

/mob/living/simple_animal/bee/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	if(O.force)
		var/damage = O.force
		if (O.damtype == HALLOSS)
			damage = 0
		adjustBruteLoss(damage)
		user.visible_message("<span class='danger'>[src] has been attacked with [O] by [user]. </span>")
		panic_attack(user)

/mob/living/simple_animal/bee/bullet_act(var/obj/item/projectile/P)
	..()
	if(P && P.firer)
		panic_attack(P.firer)

/mob/living/simple_animal/bee/attack_hand(mob/living/carbon/human/M as mob)//punching bees!
	..()
	if((M.a_intent == I_HURT) || (M.a_intent == I_DISARM))
		panic_attack(M)

/mob/living/simple_animal/bee/proc/panic_attack(mob/damagesource)
	for(var/mob/living/simple_animal/bee/B in range(src,3))
		B.feral = 15
		B.target = damagesource

/mob/living/simple_animal/bee/wander_move(var/turf/dest)
	var/goodmove=0
	if(!my_hydrotray || my_hydrotray.loc != src.loc || my_hydrotray.dead || !my_hydrotray.seed)
		// Wander the wastes
		goodmove=1
	else
		// Restrict bee to area within distance of tray
		var/turf/hiveturf = get_turf(my_hydrotray)
		var/current_dist = get_dist(src,hiveturf)
		var/new_dist = get_dist(dest,hiveturf)
		// If we're beyond hive max range and we're not feral, we can only move towards or parallel to the hive.
		if(current_dist > max_hive_dist && !feral)
			if(new_dist <= current_dist)
				goodmove=1
		else
			// Otherwise, we can move anywhere we like.
			goodmove=1
	if(goodmove)
		Move(dest)

/mob/living/simple_animal/bee/proc/newTarget()
	var/list/neabyMobs = list()
	for(var/mob/living/G in view(src,7))
		neabyMobs += G
	target = pick(neabyMobs)

/mob/living/simple_animal/bee/Life()
	if(timestopped) return 0 //under effects of time magick

	..()
	if(stat != DEAD) //If we're alive, see if we can be calmed down.
		//smoke, water and steam calms us down
		var/calming = 0
		var/list/calmers = list(
			/obj/effect/decal/chemical_puff,
			/obj/effect/effect/smoke/chem,
			/obj/effect/effect/water,
			/obj/effect/effect/foam,
			/obj/effect/effect/steam,
			/obj/effect/mist,
			)

		for(var/this_type in calmers)
			var/obj/effect/check_effect = locate(this_type) in src.loc
			if(check_effect && (check_effect.reagents.has_reagent("water") || check_effect.reagents.has_reagent("holywater")))
				calming = 1
				break

		if(calming)
			var/oldferal = feral
			feral = -10
			if(oldferal > 0 && feral <= 0)
				src.visible_message("<span class='notice'>The bees calm down!</span>")
				target = null
				target_turf = null
				wander = 1
	if(stat == CONSCIOUS)
		//if we're strong enough, sting some people
		var/mob/living/carbon/human/M = target
		var/sting_prob = 100 // Bees will always try to sting.
		if(M in view(src,1)) // Can I see my target?
			if(prob(max(feral * 10, 0)))	// Am I mad enough to want to sting? And yes, when I initially appear, I AM mad enough
				if(istype(M))
					var/obj/item/clothing/worn_suit = M.wear_suit
					var/obj/item/clothing/worn_helmet = M.head
					if(worn_suit) // Are you wearing clothes?
						sting_prob -= min(worn_suit.armor["bio"],70) // Is it sealed? I can't get to 70% of your body.
					if(worn_helmet)
						sting_prob -= min(worn_helmet.armor["bio"],30) // Is your helmet sealed? I can't get to 30% of your body.
				if( prob(sting_prob) && (M.stat == CONSCIOUS || (M.stat == UNCONSCIOUS && prob(25))) ) // Try to sting! If you're not moving, think about stinging.
					M.apply_damage(min(strength,2)+mut, BRUTE) // Stinging. The more mutated I am, the harder I sting.
					M.apply_damage((round(feral/5,1)*(max((round(strength/10,1)),1)))+toxic, TOX) // Bee venom based on how angry I am and how many there are of me!
					to_chat(M, "<span class='warning'>You have been stung!</span>")
					M.flash_pain()

		//if we're chasing someone, get a little bit angry
		if(target && prob(10))
			feral++

		//calm down a little bit
		if(feral > 0)
			if(prob(feral * 10))
				feral -= 1
		else
			//if feral is less than 0, we're becalmed by smoke or steam
			if(feral < 0)
				feral += 1

			if(target)
				target = null
				target_turf = null
			if(strength > 5)
				//calm down and spread out a little
				var/turf/T = get_turf(pick(orange(src,1)))
				var/mob/living/simple_animal/bee/B = getFromPool(/mob/living/simple_animal/bee,T)
				B.strength = rand(1,5)
				src.strength -= B.strength
				if(src.strength <= 5)
					src.icon_state = "bees[src.strength]"
				B.icon_state = "bees[B.strength]"
				if(src.parent)
					B.parent = src.parent
					src.parent.owned_bee_swarms.Add(B)

		//make some noise
		if(prob(1))
			if(prob(50))
				src.visible_message("<span class='notice'>[pick("Buzzzz.","Hmmmmm.","Bzzz.")]</span>")
			playsound(get_turf(src), 'sound/effects/bees.ogg', min(20*strength,100), 1)

		for(var/mob/living/simple_animal/bee/B in src.loc)
			if(B == src)
				continue

			if(feral > 0)
				src.strength += B.strength
				returnToPool(B)
				src.icon_state = "bees[src.strength]"
				if(strength > 5)
					icon_state = "bees_swarm"
			else if(prob(10))
				//make the other swarm of bees stronger, then move away
				var/total_bees = B.strength + src.strength
				if(total_bees < 10)
					B.strength = min(5, total_bees)
					src.strength = total_bees - B.strength

					B.icon_state = "bees[B.strength]"
					if(src.strength <= 0)
						returnToPool(B)
						return
					src.icon_state = "bees[B.strength]"
					var/turf/simulated/floor/T = get_turf(get_step(src, pick(1,2,4,8)))
					if(T.Enter(src, get_turf(src)))
						src.loc = T
				break

		if(target)
			if(target in view(src,7))
				target_turf = get_turf(target)
				wander = 0

			else // My target's gone! But I might still be pissed! You there. You look like a good stinging target!
				newTarget()

		if(target_turf)
			var/tdir=get_dir(src,target_turf) // This was called thrice.  Optimize.
			var/turf/move_to=get_step(src, tdir) // Called twice.
			walk_to(src,move_to)
			if (prob(1))
				src.visible_message("<span class='notice'>The bees swarm after [target]!</span>")
			if(src.loc == target_turf)
				target_turf = null
				wander = 1
		else
			//find some flowers, harvest
			//angry bee swarms don't hang around
			if(feral > 0)
				turns_per_move = rand(1,3)
			else if(feral < 0)
				turns_since_move = 0
			else if(!my_hydrotray || my_hydrotray.loc != src.loc || my_hydrotray.dead || !my_hydrotray.seed)
				var/obj/machinery/portable_atmospherics/hydroponics/my_hydrotray = locate() in src.loc
				if(my_hydrotray)
					if(!my_hydrotray.dead && my_hydrotray.seed)
						turns_per_move = rand(20,50)
					else
						my_hydrotray = null

		animate(src, pixel_x = rand(-12,12), pixel_y = rand(-12,12), time = 10, easing = SINE_EASING)

	/*
	if(!parent && prob(10))
		strength -= 1
		if(strength <= 0)
			returnToPool(src)
		else if(strength <= 5)
			icon_state = "bees[strength]"
	*/

	if(feral > 0)
		if(strength <= 5)
			icon_state = "bees[max(strength,1)]-feral"
		else
			icon_state = "bees_swarm-feral"

	//debugging
	/*icon_state = "[strength]"
	if(strength > 5)
		icon_state = "unknown"*/
