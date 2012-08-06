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

	stop_automated_movement_when_pulled = 0
	maxHealth = 25
	health = 25

	harm_intent_damage = 8
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'bite.ogg'

	//Space carp aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0		//so they don't freeze in space
	maxbodytemp = 295	//if it's just 25 degrees, they start to burn up

	var/stance = CARP_STANCE_IDLE	//Used to determine behavior
	var/stance_step = 0				//Used to delay checks depending on what stance the bear is in
	var/mob/living/target_mob		//Once the bear enters attack stance, it will try to chase this mob. This it to prevent it changing it's mind between multiple mobs.
	heat_damage_per_tick = 1

/mob/living/simple_animal/carp/elite
	desc = "A ferocious, fang-bearing creature that resembles a fish. It has an evil gleam in its eye."
	maxHealth = 50
	health = 50
	melee_damage_lower = 10
	melee_damage_upper = 20

/proc/iscarp(var/mob/M)
	return istype(M, /mob/living/simple_animal/carp)

/mob/living/simple_animal/carp/Life()
	..()

	if(!stat)
		switch(stance)
			if(CARP_STANCE_IDLE)
				stop_automated_movement = 0
				stance_step++
				if(stance_step > 5)
					stance_step = 0
					for( var/mob/living/L in viewers(7,src) )
						if(iscarp(L)) continue
						if(!L.stat)
							if(prob(50))
								src.visible_message("<b>[src]</b> gnashes at [L]!")
							stance = CARP_STANCE_ATTACK
							target_mob = L
							break

			if(CARP_STANCE_ATTACK)	//This one should only be active for one tick
				stop_automated_movement = 1
				if(!target_mob || target_mob.stat)
					stance = CARP_STANCE_IDLE
					stance_step = 5 //Make it very alert, so it quickly attacks again if a mob returns
				if(target_mob in viewers(7,src))
					walk_to(src, target_mob, 1, 3)
					stance = CARP_STANCE_ATTACKING
					stance_step = 0

			if(CARP_STANCE_ATTACKING)
				stop_automated_movement = 1
				stance_step++
				if(!target_mob || target_mob.stat)
					stance = CARP_STANCE_IDLE
					stance_step = 4 //Make it very alert, so it quickly attacks again if a mob returns
					target_mob = null
					walk(src,0)
					return
				if(!(target_mob in viewers(7,src)))
					stance = CARP_STANCE_IDLE
					stance_step = 1
					target_mob = null
					walk(src,0)
					return
				if(get_dist(src, target_mob) <= 1)	//Attacking
					if(isliving(target_mob))
						var/mob/living/L = target_mob
						L.attack_animal(src)
						if(prob(10))
							L.Weaken(5)
							L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/carp/Die()
	..()
	target_mob = null
	stance = CARP_STANCE_IDLE
	walk(src,0)

/mob/living/simple_animal/carp/Process_Spacemove(var/check_drift = 0)
	return 0	//No drifting in space for space carp!	//original comments do not steal

/mob/living/simple_animal/carp/Process_Spaceslipping(var/prob_slip = 5)
	return 0

//----

/mob/living/simple_animal/carp/cyborg
	name = "cyborg space carp"
	desc = "A ferocious, fang-bearing cyborg that resembles a fish. It has glowing red eyes."
	speak = list("Objective established.","Goal: Terminate.","Mission parameters defined.","All casualties are acceptable.")
	speak_emote = list("beeps")
	emote_hear = list("makes a sinister clanking noise.","hisses and steams.","makes a menacing beeping noise.")
	emote_see = list("sparks slightly.","flashes a red light ominously.")
	speak_chance = 10
	var/firing = 0

/mob/living/simple_animal/carp/cyborg/Life()
	..()
	walk(src,0)

	if(!stat)
		if(prob(5))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
		switch(stance)
			if(CARP_STANCE_ATTACKING)
				if(target_mob)
					src.dir = get_dir(src, target_mob)
					/*if(get_dist(src, target_mob) > 5)
						step_towards(src,target_mob)*/
					if(get_dist(src, target_mob) > 1 && !firing)
						//fire laser eyes
						firing = 1
						if(prob(40))
							emote("auto",1,"[pick("makes an ominous whining noise!","makes a low humming noise!","begins charging up something!")]")

						spawn(40)
							if(!target_mob)
								return
							firing = 0
							//load_into_chamber()
							var/obj/item/projectile/beam/B = new(src)

							B.firer = src
							//B.def_zone = targloc
							//in_chamber.def_zone = user.zone_sel.selecting

							var/turf/targloc = get_turf(target_mob)
							var/turf/myloc = get_turf(src)

							B.original = targloc
							B.loc = myloc
							B.starting = myloc
							B.silenced = 0
							B.current = myloc
							B.yo = targloc.y - myloc.y
							B.xo = targloc.x - myloc.x
							//
							B.fired()

							//shake the camera? probably not, these lasers don't explode... yet
							/*for(var/mob/M in view(src,7))
								shake_camera(user, recoil + 1, recoil)*/
							playsound(src, pick('pulse.ogg','pulse2.ogg','pulse3.ogg'), 50, 1)

/mob/living/simple_animal/carp/cyborg/Die()
	if(prob(15))
		src.say_auto("I'll be back!")
	..()
