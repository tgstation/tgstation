/mob/living/simple_animal/hostile/asteroid/
	vision_range = 2
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "mining"
	wall_smash = 1
	minbodytemp = 0
	heat_damage_per_tick = 20
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	var/aggro_vision_range = 8
	var/idle_vision_range = null
	var/icon_aggro = null
	var/ranged_message = "fires"
	var/throw_message = "bounces off of"

/mob/living/simple_animal/hostile/asteroid/New()
	idle_vision_range = vision_range
	..()

/mob/living/simple_animal/hostile/asteroid/GiveTarget(var/new_target)
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
	return

/mob/living/simple_animal/hostile/asteroid/LoseTarget()
	..()
	LoseAggro()

/mob/living/simple_animal/hostile/asteroid/LostTarget()
	..()
	LoseAggro()

/mob/living/simple_animal/hostile/asteroid/proc/Aggro()
	vision_range = aggro_vision_range
	icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/proc/LoseAggro()
	vision_range = idle_vision_range
	icon_state = icon_living

/mob/living/simple_animal/hostile/asteroid/adjustBruteLoss(var/damage)
	..(damage)
	if(stance == HOSTILE_STANCE_IDLE)
		Aggro()
		var/new_target = FindTarget()
		GiveTarget(new_target)
	if(stance == HOSTILE_STANCE_ATTACK)//No more pulling a mob forever and having a second player attack it, it can switch targets now
		if(target != null && prob(25))
			world << "We're calling FindTarget due to being damaged"
			var/new_target = FindTarget()
			GiveTarget(new_target)

/mob/living/simple_animal/hostile/asteroid/bullet_act(var/obj/item/projectile/P)
	if(P.damage < 30)
		visible_message("<span class='danger'>The [P.name] had no effect on [src.name]!</span>")
		return
	..()

//ALL THIS SHIT IS FOR TRACKING PEOPLE AND TARGETTING//

/mob/living/simple_animal/hostile/asteroid/FindTarget()
	var/list/Targets = list()
	var/Target
	world << "We're about to run FindTarget"
	stop_automated_movement = 0
	for(var/atom/A in ListTargets())
		if(Found(A))//Just in case people want to override targetting IE: Mouse sees cheese
			Target = A
			break
		if(CanAttack(A))//Can we attack it?
			Targets.Add(A)
			continue
	world << "We're about to run PickTarget"
	Target = PickTarget(Targets)
	return Target //We now have a target

/mob/living/simple_animal/hostile/asteroid/proc/PickTarget(var/list/Targets)
	if(target != null)
		world << "There IS a target in PickTarget"
		for(var/atom/A in Targets)
			var/target_dist = get_dist(src, target)
			var/possible_target_distance = get_dist(src, A)
			world << "Distance to current target [target.name] [target_dist], Distance to possible target [A.name] [possible_target_distance]"
			if(target_dist < possible_target_distance)
				Targets -= A
	for(var/A in Targets)
		world << "[A]"
	if(!Targets.len)
		return
	var/chosen_target = pick(Targets)
	world << "IIIII We chose [chosen_target]"
	return chosen_target

/mob/living/simple_animal/hostile/asteroid/CanAttack(var/atom/the_target)
	if(see_invisible < the_target.invisibility)
		return 0
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(L.stat != CONSCIOUS || L.faction == src.faction && !attack_same)
			return 0
		if(L in friends)
			return 0
		return 1
	if(istype(the_target, /obj/mecha))
		var/obj/mecha/M = the_target
		if(M.occupant)
			return 1
	return 0

//END SHIT FOR TRACKING PEOPLE AND TARGETTING//

/mob/living/simple_animal/hostile/asteroid/Die()
	LoseAggro()
	..()

/mob/living/simple_animal/hostile/asteroid/MoveToTarget()
	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
	if(target in ListTargets())
		if(get_dist(src, target) >= 2 && ranged)
			OpenFire(target)
		Goto(target, move_to_delay)
		if(isturf(loc) && target.Adjacent(src))	//Attacking
			AttackingTarget()
		return
	LostTarget()

/mob/living/simple_animal/hostile/asteroid/OpenFire(var/the_target)

	var/target = the_target
	visible_message("\red <b>[src]</b> [ranged_message] at [target]!", 1)

	var/tturf = get_turf(target)
	if(rapid)
		spawn(1)
			Shoot(tturf, src.loc, src)
			if(casingtype)
				new casingtype(get_turf(src))
		spawn(4)
			Shoot(tturf, src.loc, src)
			if(casingtype)
				new casingtype(get_turf(src))
		spawn(6)
			Shoot(tturf, src.loc, src)
			if(casingtype)
				new casingtype(get_turf(src))
	else
		Shoot(tturf, src.loc, src)
		if(casingtype)
			new casingtype
	return

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM)
	if(istype(AM, /obj/item))
		var/obj/item/T = AM
		if(T.throwforce <= 15)//No floor tiling them to death, wiseguy
			visible_message("<span class='notice'>The [T.name] [src.throw_message] [src.name]!</span>")
			Aggro()
			return
	..()

/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "Basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/item/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "stares"
	throw_message = "rebounds off its hard shell to no effect"
	vision_range = 2
	speed = 3
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "bites into "
	a_intent = "harm"
	attack_sound = 'sound/weapons/bladeslice.ogg'

/obj/item/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	temperature = 50

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(var/new_target)
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
		if(isliving(target))
			var/mob/living/L = target
			if(L.bodytemperature > 261)
				L.bodytemperature = 261
				visible_message("<span class='danger'>The [src.name]'s stare chills [L.name] to the bone!</span>")
	return

/mob/living/simple_animal/hostile/asteroid/Goldgrub
	name = "Goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 0
	friendly = "harmlessly rolls into"
	vision_range = 2
	maxHealth = 45
	health = 45
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "barrels into"
	a_intent = "help"
	throw_message = "hits, but just bounces off its fat"
	var/alerted = 0

/mob/living/simple_animal/hostile/asteroid/Goldgrub/MoveToTarget()
	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
	if(target in ListTargets())
		walk_away(src,target,10)
		if(isturf(loc) && target.Adjacent(src))	//Attacking
			AttackingTarget()
		return
	LostTarget()

/mob/living/simple_animal/hostile/asteroid/Goldgrub/GiveTarget(var/new_target)
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
		visible_message("<span class='danger'>The [src.name] tries to flee from [target.name]!</span>")
		Burrow()
	return

/mob/living/simple_animal/hostile/asteroid/Goldgrub/proc/Burrow()
	if(!alerted)
		alerted = 1
		spawn(100)
			if(alerted)
				visible_message("<span class='danger'>The [src.name] buries into the ground, vanishing from sight!</span>")
				del(src)

/mob/living/simple_animal/hostile/asteroid/Goldgrub/bullet_act(var/obj/item/projectile/P)
	visible_message("<span class='danger'>The [P.name] was repelled by [src.name]'s girth!</span>")
	return

/mob/living/simple_animal/hostile/asteroid/Goldgrub/Die()
	alerted = 0
	..()

/mob/living/simple_animal/hostile/asteroid/Hivelord
	name = "Hivelord"
	desc = "A truly alien creature, it is a mass of unknown organic material, constantly fluctuating. When attacking, pieces of it split off and attack in tandem with the original."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Hivelord"
	icon_living = "Hivelord"
	icon_aggro = "Hivelord_alert"
	icon_dead = "Hivelord_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 0
	ranged = 1
	vision_range = 4
	speed = 3
	maxHealth = 75
	health = 75
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "lashes out"
	throw_message = "seems to have no effect on"

/mob/living/simple_animal/hostile/asteroid/Hivelord/MoveToTarget()
	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
	if(target in ListTargets())
		OpenFire(target)
		var/mob/living/simple_animal/hostile/asteroid/Hivelord/D = get_dist(src, target)
		if(D <= 5)
			step_away(src, target)
		return
	LostTarget()

/mob/living/simple_animal/hostile/asteroid/Hivelord/OpenFire(var/the_target)
	var/target = the_target
	var/tturf = get_turf(target)
	var/mob/living/simple_animal/hostile/asteroid/Hivelordbrood/A = new /mob/living/simple_animal/hostile/asteroid/Hivelordbrood(tturf)
	A.GiveTarget(target)
	step_away(A, target)
	return

/mob/living/simple_animal/hostile/asteroid/Hivelordbrood
	name = "Hivelord brood"
	desc = "A small hivelord brood, called to rally behind its parent. One isn't much of a threat, but..."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Hivelordbrood"
	icon_living = "Hivelordbrood"
	icon_aggro = "Hivelordbrood"
	icon_dead = "Hivelordbrood"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 0
	friendly = "buzzes near"
	vision_range = 10
	speed = 3
	maxHealth = 1
	health = 1
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "slashes"

/mob/living/simple_animal/hostile/asteroid/Hivelordbrood/New()
	..()
	spawn(100)
		del(src)

/mob/living/simple_animal/hostile/asteroid/Hivelordbrood/Die()
	del(src)

/mob/living/simple_animal/hostile/asteroid/Goliath
	name = "Goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 40
	ranged = 1
	friendly = "wails at"
	vision_range = 5
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 0
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "pulverizes"
	var/tentacle_recharge = 0

/obj/effect/goliath_tentacle/
	name = "Goliath tentacle"
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath_tentacle"

/obj/effect/goliath_tentacle/original

/obj/effect/goliath_tentacle/original/New()
	var/list/directions = cardinal.Copy()
	var/counter
	for(counter = 1, counter <= 3, counter++)
		var/spawndir = pick(directions)
		directions -= spawndir
		var/turf/T = get_step(src,spawndir)
		new /obj/effect/goliath_tentacle(T)
	..()

/obj/effect/goliath_tentacle/New()
	spawn(20)
		Trip()

/obj/effect/goliath_tentacle/proc/Trip()
	for(var/mob/living/M in src.loc)
		M.Weaken(5)
		visible_message("<span class='warning'>The [src.name] knocks [M.name] down!</span>")
	del(src)

/obj/effect/goliath_tentacle/Crossed(AM as mob|obj)
	if(isliving(AM))
		Trip()
		return
	..()

/mob/living/simple_animal/hostile/asteroid/Goliath/OpenFire()
	tentacle_recharge--
	if(tentacle_recharge <= 0)
		visible_message("<span class='warning'>The [src.name] digs its tentacles under [target.name]!</span>")
		var/tturf = get_turf(target)
		new /obj/effect/goliath_tentacle/original(tturf)
		tentacle_recharge = 6
		return

/mob/living/simple_animal/hostile/asteroid/Goliath/adjustBruteLoss(var/damage)
	tentacle_recharge--
	..()