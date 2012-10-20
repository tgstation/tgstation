#define BEAR_STANCE_IDLE 1
#define BEAR_STANCE_ALERT 2
#define BEAR_STANCE_ATTACK 3
#define BEAR_STANCE_ATTACKING 4
#define BEAR_STANCE_TIRED 5

//Space bears!
/mob/living/simple_animal/bear
	name = "space bear"
	desc = "RawrRawr!!"
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_emote = list("growls", "roars")
	emote_hear = list("rawrs","grumbles","grawls")
	emote_see = list("stares ferociously", "stomps")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "pokes the"
	stop_automated_movement_when_pulled = 0
	maxHealth = 60
	health = 60
	melee_damage_lower = 20
	melee_damage_upper = 30

	//Space bears aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	var/stance = BEAR_STANCE_IDLE //Used to determine behavior
	var/stance_step = 0 //Used to delay checks depending on what stance the bear is in
	var/mob/living/target_mob //Once the bear enters attack stance, it will try to chase this mob. This it to prevent it changing it's mind between multiple mobs.

//SPACE BEARS! SQUEEEEEEEE~     OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/simple_animal/bear/Hudson
	name = "Hudson"
	desc = ""
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"

/mob/living/simple_animal/bear/Life()
	..()

	if(client) return //Player controlled bears shouldnt be processing AI stuff

	if(stat)
		walk(src,0)//Stops the movement

	if(!stat)
		if(loc && istype(loc,/turf/space))
			icon_state = "bear"
		else
			icon_state = "bearfloor"

		switch(stance)
			if(BEAR_STANCE_IDLE)
				stop_automated_movement = 0
				stance_step++
				if(stance_step > 5)
					stance_step = 0
					for(var/atom/A in view(7,src))
						if(isbear(A))
							continue

						if(isliving(A))
							var/mob/living/L = A
							if(!L.stat)
								stance = BEAR_STANCE_ATTACK
								target_mob = L
								break

						if(istype(A, /obj/mecha))
							var/obj/mecha/M = A
							if (M.occupant)
								stance = BEAR_STANCE_ATTACK
								target_mob = M
								break
					if (target_mob)
						emote("stares alertly at [target_mob]")

			if(BEAR_STANCE_ALERT)
				stop_automated_movement = 1
				var/found_mob = 0
				if(target_mob in view(7,src))
					if(target_mob && !(SA_attackable(target_mob)))
						stance_step = max(0, stance_step) //If we have not seen a mob in a while, the stance_step will be negative, we need to reset it to 0 as soon as we see a mob again.
						stance_step++
						found_mob = 1
						src.dir = get_dir(src,target_mob)	//Keep staring at the mob

						if(stance_step in list(1,4,7)) //every 3 ticks
							var/action = pick( list( "growls at [target_mob]", "stares angrily at [target_mob]", "prepares to attack [target_mob]", "closely watches [target_mob]" ) )
							if(action)
								emote(action)
				if(!found_mob)
					stance_step--

				if(stance_step <= -20) //If we have not found a mob for 20-ish ticks, revert to idle mode
					stance = BEAR_STANCE_IDLE
				if(stance_step >= 7)   //If we have been staring at a mob for 7 ticks,
					stance = BEAR_STANCE_ATTACK
			if(BEAR_STANCE_ATTACK)	//This one should only be active for one tick,
				stop_automated_movement = 1
				if(!target_mob || SA_attackable(target_mob))
					stance = BEAR_STANCE_ALERT
					stance_step = 5 //Make it very alert, so it quickly attacks again if a mob returns
				if(target_mob in view(7,src))
					walk_to(src, target_mob, 1, 3)
					stance = BEAR_STANCE_ATTACKING
					stance_step = 0
			if(BEAR_STANCE_ATTACKING)

				stop_automated_movement = 1
				stance_step++
				if(!target_mob || SA_attackable(target_mob))
					stance = BEAR_STANCE_ALERT
					stance_step = 5 //Make it very alert, so it quickly attacks again if a mob returns
					return
				if(!(target_mob in view(7,src)))
					stance = BEAR_STANCE_ALERT
					stance_step = 5 //Make it very alert, so it quickly attacks again if a mob returns
					target_mob = null
					return
				if(get_dist(src, target_mob) <= 1)	//Attacking
					emote( pick( list("slashes at [target_mob]", "bites [target_mob]") ) )

					var/damage = rand(20,30)

					if(ishuman(target_mob))
						var/mob/living/carbon/human/H = target_mob
						var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
						var/datum/organ/external/affecting = H.get_organ(ran_zone(dam_zone))
						H.apply_damage(damage, BRUTE, affecting, H.run_armor_check(affecting, "melee"))
					else if(isliving(target_mob))
						var/mob/living/L = target_mob
						L.adjustBruteLoss(damage)
					else if(istype(target_mob,/obj/mecha))
						var/obj/mecha/M = target_mob
						M.attack_animal(src)

				if(stance_step >= 20)	//attacks for 20 ticks, then it gets tired and needs to rest
					emote( "is worn out and needs to rest" )
					stance = BEAR_STANCE_TIRED
					stance_step = 0
					walk(src, 0) //This stops the bear's walking
					return
			if(BEAR_STANCE_TIRED)
				stop_automated_movement = 1
				stance_step++
				if(stance_step >= 10) //rests for 10 ticks
					if(target_mob && target_mob in view(7,src))
						stance = BEAR_STANCE_ATTACK //If the mob he was chasing is still nearby, resume the attack, otherwise go idle.
					else
						stance = BEAR_STANCE_IDLE


/mob/living/simple_animal/bear/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(stance != BEAR_STANCE_ATTACK && stance != BEAR_STANCE_ATTACKING)
		stance = BEAR_STANCE_ALERT
		stance_step = 6
		target_mob = user
	..()

/mob/living/simple_animal/bear/attack_hand(mob/living/carbon/human/M as mob)
	if(stance != BEAR_STANCE_ATTACK && stance != BEAR_STANCE_ATTACKING)
		stance = BEAR_STANCE_ALERT
		stance_step = 6
		target_mob = M
	..()

/mob/living/simple_animal/bear/Process_Spacemove(var/check_drift = 0)
	return	//No drifting in space for space bears!