#define CARP_STANCE_IDLE 1
#define CARP_STANCE_ATTACK 2
#define CARP_STANCE_ATTACKING 3

/mob/living/simple_animal/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	icon_gib = "carp_gib"
	speak_chance = 0
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/carpmeat
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = -1
	stop_automated_movement_when_pulled = 0
	maxHealth = 25
	health = 25

	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	//Space carp aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	var/stance = CARP_STANCE_IDLE	//Used to determine behavior
	var/stance_step = 0				//Used to delay checks depending on what stance the bear is in
	var/mob/living/target_mob		//Once the bear enters attack stance, it will try to chase this mob. This it to prevent it changing it's mind between multiple mobs.

/mob/living/simple_animal/carp/Life()
	if(stat == DEAD)
		walk(src,0)//STOP FUCKING MOVING GODDAMN
		if(health > 0)
			icon_state = icon_living
			dead_mob_list -= src
			living_mob_list += src
			stat = CONSCIOUS
			density = 1
		return


	if(health < 1)
		Die()

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
			if(CARP_STANCE_IDLE)
				stop_automated_movement = 0
				stance_step++
				if(stance_step > 5)
					stance_step = 0
					for(var/atom/A in view(7,src))
						if(iscarp(A))
							continue

						if(isliving(A))
							var/mob/living/L = A
							if(!L.stat)
								stance = CARP_STANCE_ATTACK
								target_mob = L
								break

						if(istype(A, /obj/mecha))
							var/obj/mecha/M = A
							if (M.occupant)
								stance = CARP_STANCE_ATTACK
								target_mob = M
								break
					if (target_mob)
						emote("nashes at [target_mob]")

			if(CARP_STANCE_ATTACK)	//This one should only be active for one tick
				stop_automated_movement = 1
				if(!target_mob || SA_attackable(target_mob))
					stance = CARP_STANCE_IDLE
					stance_step = 5 //Make it very alert, so it quickly attacks again if a mob returns
				if(target_mob in view(7,src))
					walk_to(src, target_mob, 1, 3)
					stance = CARP_STANCE_ATTACKING
					stance_step = 0

			if(CARP_STANCE_ATTACKING)
				stop_automated_movement = 1
				stance_step++
				if(!target_mob || SA_attackable(target_mob))
					stance = CARP_STANCE_IDLE
					stance_step = 3 //Make it very alert, so it quickly attacks again if a mob returns
					target_mob = null
					return
				if(!(target_mob in view(7,src)))
					stance = CARP_STANCE_IDLE
					stance_step = 1
					target_mob = null
					return
				if(get_dist(src, target_mob) <= 1)	//Attacking
					if(isliving(target_mob))
						var/mob/living/L = target_mob
						L.attack_animal(src)
						if(prob(10))
							L.Weaken(5)
							L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")
					if(istype(target_mob,/obj/mecha))
						var/obj/mecha/M = target_mob
						M.attack_animal(src)

/mob/living/simple_animal/carp/Process_Spacemove(var/check_drift = 0)
	return	//No drifting in space for space carp!	//original comments do not steal