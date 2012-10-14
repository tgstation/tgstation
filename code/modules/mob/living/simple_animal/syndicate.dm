#define SYNDICATE_STANCE_IDLE 1
#define SYNDICATE_STANCE_ATTACK 2
#define SYNDICATE_STANCE_ATTACKING 3

/mob/living/simple_animal/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 0
	stop_automated_movement_when_pulled = 0
	maxHealth = 75
	health = 75
	var/ranged = 0
	var/target
	var/rapid = 0
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	a_intent = "harm"
	var/corpse = /obj/effect/landmark/corpse/syndicatesoldier
	var/weapon1
	var/weapon2
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15

	var/stance = SYNDICATE_STANCE_IDLE	//Used to determine behavior
	var/mob/living/target_mob

/mob/living/simple_animal/syndicate/Life()
	..()
	if(stat == 2)
		new corpse (src.loc)
		if(weapon1)
			new weapon1 (src.loc)
		if(weapon2)
			new weapon2 (src.loc)
		del src
		return


	if(health < 1)
		Die()

	if(health > maxHealth)
		health = maxHealth

	if(!ckey && !stop_automated_movement)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby))
					Move(get_step(src,pick(cardinal)))
					turns_since_move = 0

	if(!stat)
		switch(stance)
			if(SYNDICATE_STANCE_IDLE)
				stop_automated_movement = 0
				for( var/mob/living/L in viewers(7,src) )
					if(isSyndicate(L)) continue
					if(!L.stat)
						stance = SYNDICATE_STANCE_ATTACK
						target_mob = L
						break

			if(SYNDICATE_STANCE_ATTACK)	//This one should only be active for one tick
				stop_automated_movement = 1
				if(!target_mob || target_mob.stat)
					stance = SYNDICATE_STANCE_IDLE
				if(target_mob in viewers(10,src))
					if(ranged)
						if(get_dist(src, target_mob) <= 6)
							OpenFire(target_mob)
						else
							walk_to(src, target_mob, 1, 3)
					else
						walk_to(src, target_mob, 1, 3)
						stance = SYNDICATE_STANCE_ATTACKING

			if(SYNDICATE_STANCE_ATTACKING)
				stop_automated_movement = 1
				if(!target_mob || target_mob.stat)
					stance = SYNDICATE_STANCE_IDLE
					target_mob = null
					return
				if(!(target_mob in viewers(7,src)))
					stance = SYNDICATE_STANCE_IDLE
					target_mob = null
					return
				if(get_dist(src, target_mob) <= 1)	//Attacking
					if(isliving(target_mob))
						var/mob/living/L = target_mob
						L.attack_animal(src)



/mob/living/simple_animal/syndicate/proc/OpenFire(target_mob)
	src.target = target_mob
	visible_message("\red <b>[src]</b> fires at [src.target]!", 1)

	var/tturf = get_turf(target)
	if(rapid)
		spawn(1)
			Shoot(tturf, src.loc, src)
			new /obj/item/ammo_casing/a12mm(get_turf(src))
		spawn(4)
			Shoot(tturf, src.loc, src)
			new /obj/item/ammo_casing/a12mm(get_turf(src))
		spawn(6)
			Shoot(tturf, src.loc, src)
			new /obj/item/ammo_casing/a12mm(get_turf(src))
	else
		Shoot(tturf, src.loc, src)
		new /obj/item/ammo_casing/a12mm(get_turf(src))

	stance = SYNDICATE_STANCE_IDLE
	target_mob = null
	return


/mob/living/simple_animal/syndicate/proc/Shoot(var/target, var/start, var/user, var/bullet = 0)
	if(target == start)
		return

	var/obj/item/projectile/bullet/midbullet2/A = new /obj/item/projectile/bullet/midbullet2(user:loc)
	playsound(user, 'sound/weapons/Gunshot_smg.ogg', 100, 1)
	if(!A)	return

	if (!istype(target, /turf))
		del(A)
		return
	A.current = target
	A.yo = target:y - start:y
	A.xo = target:x - start:x
	spawn( 0 )
		A.process()
	return



///////////////Sword and shield////////////

/mob/living/simple_animal/syndicate/melee
	melee_damage_lower = 15
	melee_damage_upper = 20
	icon_state = "syndicatemelee"
	icon_living = "syndicatemelee"
	weapon1 = /obj/item/weapon/melee/energy/sword/red
	weapon2 = /obj/item/weapon/shield/energy
	attacktext = "slashes"

/mob/living/simple_animal/syndicate/melee/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.force)
		if(prob(80))
			health -= O.force
			visible_message("\red \b [src] has been attacked with the [O] by [user]. ")
		else
			visible_message("\red \b [src] blocks the [O] with its shield! ")
	else
		usr << "\red This weapon is ineffective, it does no damage."
		visible_message("\red [user] gently taps [src] with the [O]. ")


/mob/living/simple_animal/syndicate/melee/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)	return
	if(prob(80))
		src.health -= Proj.damage
	else
		visible_message("\red <B>[src] blocks [Proj] with its shield!</B>")
	return 0


/mob/living/simple_animal/syndicate/melee/space
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	icon_state = "syndicatemeleespace"
	icon_living = "syndicatemeleespace"
	name = "Syndicate Commando"
	corpse = /obj/effect/landmark/corpse/syndicatecommando
	speed = 0

/mob/living/simple_animal/syndicate/melee/space/Process_Spacemove(var/check_drift = 0)
	return

/mob/living/simple_animal/syndicate/ranged
	ranged = 1
	rapid = 1
	icon_state = "syndicateranged"
	icon_living = "syndicateranged"
	weapon1 = /obj/item/weapon/gun/projectile/automatic/c20r

/mob/living/simple_animal/syndicate/ranged/space
	icon_state = "syndicaterangedpsace"
	icon_living = "syndicaterangedpsace"
	name = "Syndicate Commando"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	corpse = /obj/effect/landmark/corpse/syndicatecommando
	speed = 0

/mob/living/simple_animal/syndicate/ranged/space/Process_Spacemove(var/check_drift = 0)
	return








/mob/living/simple_animal/syndicate/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && (FAT in tmob.mutations))
				if(prob(5))
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