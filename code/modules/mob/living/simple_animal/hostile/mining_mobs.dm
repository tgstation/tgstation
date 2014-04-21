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
	environment_smash = 2
	minbodytemp = 0
	heat_damage_per_tick = 20
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	a_intent = "harm"
	var/throw_message = "bounces off of"
	var/icon_aggro = null // for swapping to when we get aggressive

/mob/living/simple_animal/hostile/asteroid/Aggro()
	..()
	icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/LoseAggro()
	..()
	icon_state = icon_living

/mob/living/simple_animal/hostile/asteroid/bullet_act(var/obj/item/projectile/P)//Reduces damage from most projectiles to curb off-screen kills
	if(!stat)
		Aggro()
	if(P.damage < 30 && P.damage_type != BRUTE)
		P.damage = (P.damage / 3)
		visible_message("<span class='danger'>[P] has a reduced effect on [src]!</span>")
	..()

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM)//No floor tiling them to death, wiseguy
	if(istype(AM, /obj/item))
		var/obj/item/T = AM
		if(!stat)
			Aggro()
		if(T.throwforce <= 20)
			visible_message("<span class='notice'>The [T.name] [src.throw_message] [src.name]!</span>")
			return
	..()

/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
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
	ranged_cooldown_cap = 20
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites into"
	a_intent = "harm"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	ranged_cooldown_cap = 4
	aggro_vision_range = 9
	idle_vision_range = 2
	turns_per_move = 5

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

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity)
	switch(severity)
		if(1.0)
			gib()
		if(2.0)
			adjustBruteLoss(140)
		if(3.0)
			adjustBruteLoss(110)

/mob/living/simple_animal/hostile/asteroid/basilisk/Die()
	var/counter
	for(counter=0, counter<2, counter++)
		var/obj/item/weapon/ore/diamond/D = new /obj/item/weapon/ore/diamond(src.loc)
		D.layer = 4.1
	..()

/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	vision_range = 2
	aggro_vision_range = 9
	idle_vision_range = 2
	move_to_delay = 5
	friendly = "harmlessly rolls into"
	maxHealth = 45
	health = 45
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "barrels into"
	a_intent = "help"
	throw_message = "sinks in slowly, before being pushed out of "
	status_flags = CANPUSH
	search_objects = 1
	wanted_objects = list(/obj/item/weapon/ore/diamond, /obj/item/weapon/ore/gold, /obj/item/weapon/ore/silver,
						  /obj/item/weapon/ore/uranium)

	var/list/ore_types_eaten = list()
	var/alerted = 0
	var/ore_eaten = 1
	var/chase_time = 100

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(var/new_target)
	target = new_target
	if(target != null)
		if(istype(target, /obj/item/weapon/ore))
			visible_message("<span class='notice'>The [src.name] looks at [target.name] with hungry eyes.</span>")
			stance = HOSTILE_STANCE_ATTACK
			return
		if(isliving(target))
			Aggro()
			stance = HOSTILE_STANCE_ATTACK
			visible_message("<span class='danger'>The [src.name] tries to flee from [target.name]!</span>")
			retreat_distance = 10
			minimum_distance = 10
			Burrow()
			return
	return

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore))
		EatOre(target)
		return
	..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(var/atom/targeted_ore)
	for(var/obj/item/weapon/ore/O in targeted_ore.loc)
		ore_eaten++
		if(!(O.type in ore_types_eaten))
			ore_types_eaten += O.type
		qdel(O)
	if(ore_eaten > 5)//Limit the scope of the reward you can get, or else things might get silly
		ore_eaten = 5
	visible_message("<span class='notice'>The ore was swallowed whole!</span>")

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//Begin the chase to kill the goldgrub in time
	if(!alerted)
		alerted = 1
		spawn(chase_time)
		if(alerted)
			visible_message("<span class='danger'>The [src.name] buries into the ground, vanishing from sight!</span>")
			qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Reward()
	if(!ore_eaten || ore_types_eaten.len == 0)
		return
	visible_message("<span class='danger'>[src] spits up the contents of its stomach before dying!</span>")
	var/counter
	for(var/R in ore_types_eaten)
		for(counter=0, counter < ore_eaten, counter++)
			new R(src.loc)
	ore_types_eaten.Cut()
	ore_eaten = 0


/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(var/obj/item/projectile/P)
	visible_message("<span class='danger'>The [P.name] was repelled by [src.name]'s girth!</span>")
	return

/mob/living/simple_animal/hostile/asteroid/goldgrub/Die()
	alerted = 0
	Reward()
	..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustBruteLoss(var/damage)
	idle_vision_range = 9
	..()

/mob/living/simple_animal/hostile/asteroid/hivelord
	name = "hivelord"
	desc = "A truly alien creature, it is a mass of unknown organic material, constantly fluctuating. When attacking, pieces of it split off and attack in tandem with the original."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Hivelord"
	icon_living = "Hivelord"
	icon_aggro = "Hivelord_alert"
	icon_dead = "Hivelord_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 14
	ranged = 1
	vision_range = 5
	aggro_vision_range = 9
	idle_vision_range = 5
	speed = 3
	maxHealth = 75
	health = 75
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "lashes out at"
	throw_message = "falls right through the strange body of the"
	ranged_cooldown = 0
	ranged_cooldown_cap = 0
	environment_smash = 0
	retreat_distance = 3
	minimum_distance = 3
	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/asteroid/hivelord/OpenFire(var/the_target)
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/A = new /mob/living/simple_animal/hostile/asteroid/hivelordbrood(src.loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction
	return

/mob/living/simple_animal/hostile/asteroid/hivelord/AttackingTarget()
	OpenFire()

/mob/living/simple_animal/hostile/asteroid/hivelord/Die()
	new /obj/item/asteroid/hivelord_core(src.loc)
	mouse_opacity = 1
	..()

/obj/item/asteroid/hivelord_core
	name = "hivelord remains"
	desc = "All that remains of a hivelord, it seems to be what allows it to break pieces of itself off without being hurt... its healing properties will soon become inert if not used quickly. Try not to think about what you're eating."
	icon = 'icons/obj/food.dmi'
	icon_state = "boiledrorocore"
	var/inert = 0

/obj/item/asteroid/hivelord_core/New()
	spawn(1200)
		inert = 1
		desc = "The remains of a hivelord that have become useless, having been left alone too long after being harvested."

/obj/item/asteroid/hivelord_core/attack(mob/living/M as mob, mob/living/user as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(inert)
			user << "<span class='notice'>[src] have become inert, its healing properties are no more.</span>"
			return
		else
			if(H.stat == DEAD)
				user << "<span class='notice'>[src] are useless on the dead.</span>"
				return
			if(H != user)
				H.visible_message("<span class='notice'>[user] forces [H] to eat [src]... they quickly regenerate all injuries!</span>")
			else
				user << "<span class='notice'>You chomp into [src], barely managing to hold it down, but feel amazingly refreshed in mere moments.</span>"
			playsound(src.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			H.revive()
			qdel(src)
	..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood
	name = "hivelord brood"
	desc = "A fragment of the original Hivelord, rallying behind its original. One isn't much of a threat, but..."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Hivelordbrood"
	icon_living = "Hivelordbrood"
	icon_aggro = "Hivelordbrood"
	icon_dead = "Hivelordbrood"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 1
	friendly = "buzzes near"
	vision_range = 10
	speed = 3
	maxHealth = 1
	health = 1
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "slashes"
	throw_message = "falls right through the strange body of the"
	environment_smash = 0
	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/New()
	..()
	spawn(100)
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/Die()
	qdel(src)

/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	attack_sound = 'sound/weapons/punch4.ogg'
	mouse_opacity = 2
	move_to_delay = 40
	ranged = 1
	ranged_cooldown_cap = 8
	friendly = "wails at"
	vision_range = 4
	speed = 3
	maxHealth = 300
	health = 300
	harm_intent_damage = 0
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "pulverizes"
	throw_message = "does nothing to the rocky hide of the"
	aggro_vision_range = 9
	idle_vision_range = 5
	anchored = 1 //Stays anchored until death as to be unpullable

/mob/living/simple_animal/hostile/asteroid/goliath/revive()
	anchored = 1
	..()

/mob/living/simple_animal/hostile/asteroid/goliath/Die()
	anchored = 0
	..()

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire()
	var/tturf = get_turf(target)
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>The [src.name] digs its tentacles under [target.name]!</span>")
		new /obj/effect/goliath_tentacle/original(tturf)
		ranged_cooldown = ranged_cooldown_cap
	return

/mob/living/simple_animal/hostile/asteroid/goliath/adjustBruteLoss(var/damage)
	ranged_cooldown--
	..()

/obj/effect/goliath_tentacle/
	name = "Goliath tentacle"
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath_tentacle"

/obj/effect/goliath_tentacle/New()
	var/turftype = get_turf(src)
	if(istype(turftype, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = turftype
		M.gets_drilled()
	spawn(20)
		Trip()

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

/obj/effect/goliath_tentacle/proc/Trip()
	for(var/mob/living/M in src.loc)
		M.Weaken(5)
		visible_message("<span class='warning'>The [src.name] knocks [M.name] down!</span>")
	qdel(src)

/obj/effect/goliath_tentacle/Crossed(AM as mob|obj)
	if(isliving(AM))
		Trip()
		return
	..()

/mob/living/simple_animal/hostile/asteroid/goliath/Die()
	var/obj/item/asteroid/goliath_hide/G = new /obj/item/asteroid/goliath_hide(src.loc)
	G.layer = 4.1
	..()

/obj/item/asteroid/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/items.dmi'
	icon_state = "goliath_hide"
	w_class = 3
	layer = 4

/obj/item/asteroid/goliath_hide/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(istype(target, /obj/item/clothing/suit/space/rig/mining) || istype(target, /obj/item/clothing/head/helmet/space/rig/mining))
			var/obj/item/clothing/C = target
			var/current_armor = C.armor
			if(current_armor.["melee"] < 80)
				current_armor.["melee"] = min(current_armor.["melee"] + 10, 80)
				user << "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>"
				qdel(src)
			else
				user << "<span class='info'>You can't improve [C] any further.</span>"
	return
