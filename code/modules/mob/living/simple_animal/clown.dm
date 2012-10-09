#define CLOWN_STANCE_IDLE 1
#define CLOWN_STANCE_ATTACK 2
#define CLOWN_STANCE_ATTACKING 3

/mob/living/simple_animal/clown
	name = "Clown"
	desc = "A denizen of clown planet"
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("HONK", "Honk!", "Welcome to clown planet!")
	emote_see = list("honks")
	speak_chance = 1
	a_intent = "harm"
	stop_automated_movement_when_pulled = 0
	maxHealth = 75
	health = 75
	speed = -1
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	attack_sound = 'sound/items/bikehorn.ogg'

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 10	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	unsuitable_atoms_damage = 10

	var/hostile = 0

	var/stance = CLOWN_STANCE_IDLE	//Used to determine behavior
	var/mob/living/target_mob

/mob/living/simple_animal/clown/Life()
	..()
	if(stat == 2)
		new /obj/effect/landmark/corpse/clown (src.loc)
		del src
		return

	if(health > maxHealth)
		health = maxHealth

	if(!ckey && !stop_automated_movement)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
					Move(get_step(src,pick(cardinal)))
					turns_since_move = 0

	if(!stat)
		switch(stance)
			if(CLOWN_STANCE_IDLE)
				if (src.hostile == 0) return
				for( var/mob/living/L in viewers(7,src) )
					if(isclown(L)) continue
					if(!L.stat)
						emote("honks menacingly at [L]")
						stance = CLOWN_STANCE_ATTACK
						target_mob = L
						break

			if(CLOWN_STANCE_ATTACK)	//This one should only be active for one tick
				stop_automated_movement = 1
				if(!target_mob || target_mob.stat)
					stance = CLOWN_STANCE_IDLE
				if(target_mob in viewers(7,src))
					walk_to(src, target_mob, 1, 3)
					stance = CLOWN_STANCE_ATTACKING

			if(CLOWN_STANCE_ATTACKING)
				stop_automated_movement = 1
				if(!target_mob || target_mob.stat)
					stance = CLOWN_STANCE_IDLE
					target_mob = null
					return
				if(!(target_mob in viewers(7,src)))
					stance = CLOWN_STANCE_IDLE
					target_mob = null
					return
				if(get_dist(src, target_mob) <= 1)	//Attacking
					if(isliving(target_mob))
						var/mob/living/L = target_mob
						L.attack_animal(src)
						if(prob(10))
							L.Weaken(5)
							L.visible_message("<span class='danger'>\the [src] slips \the [L]!</span>")
						for(var/mob/M in viewers(src, null))
							if(istype(M, /mob/living/simple_animal/clown))
								var/mob/living/simple_animal/clown/C = M
								C.hostile = 1

/mob/living/simple_animal/clown/bullet_act(var/obj/item/projectile/Proj)
	..()
	hostile = 1
	for(var/mob/M in viewers(src, null))
		if(istype(M, /mob/living/simple_animal/clown))
			var/mob/living/simple_animal/clown/C = M
			C.hostile = 1
	return 0


/mob/living/simple_animal/clown/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	hostile = 1
	for(var/mob/Z in viewers(src, null))
		if(istype(Z, /mob/living/simple_animal/clown))
			var/mob/living/simple_animal/clown/C = Z
			C.hostile = 1
	return 0

/mob/living/simple_animal/clown/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	..()
	hostile = 1
	for(var/mob/Z in viewers(src, null))
		if(istype(Z, /mob/living/simple_animal/clown))
			var/mob/living/simple_animal/clown/C = Z
			C.hostile = 1
	return 0

/mob/living/simple_animal/clown/attack_hand(mob/living/carbon/human/M as mob)
	..()
	hostile = 1
	for(var/mob/Z in viewers(src, null))
		if(istype(Z, /mob/living/simple_animal/clown))
			var/mob/living/simple_animal/clown/C = Z
			C.hostile = 1
	return 0

/mob/living/simple_animal/clown/attack_animal(mob/living/simple_animal/M as mob)
	..()
	hostile = 1
	for(var/mob/Z in viewers(src, null))
		if(istype(Z, /mob/living/simple_animal/clown))
			var/mob/living/simple_animal/clown/C = Z
			C.hostile = 1
	return 0

/mob/living/simple_animal/clown/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && (FAT in tmob.mutations))
				if(prob(50))
					src << "\red <B>You fail to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
			if(tmob.nopush)
				now_pushing = 0
				return

			tmob.LAssailant = src
		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
		return
	return