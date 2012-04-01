/mob/living/carbon/metroid/Life()
	set invisibility = 0
	set background = 1

	if (src.monkeyizing)
		return

	..()

	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(src.loc)
		environment = loc.return_air()


	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	src.blinded = null

	//Disease Check
	handle_virus_updates()


	// Basically just deletes any screen objects :<
	regular_hud_updates()

	//Handle temperature/pressure differences between body and environment

	if(environment)
		handle_environment(environment)


	//Chemicals in the body
	handle_chemicals_in_body()

	//Status updates, death etc.
	handle_regular_status_updates()

	/*
	if(client)
		handle_regular_hud_updates() */

	handle_nutrition()

	if(Tempstun)
		if(!Victim) // not while they're eating!
			canmove = 0
	else
		canmove = 1

	if(attacked > 50) attacked = 50

	if(attacked > 0)
		if(prob(85))
			attacked--

	if(Discipline > 0)

		if(Discipline >= 5 && rabid)
			if(prob(60)) rabid = 0

		if(prob(10))
			Discipline--


	// Grabbing

	if(!client && stat != 2)

		if(!canmove) return

		// DO AI STUFF HERE

		if(Target)
			if(attacked <= 0)
				Target = null

		if(Victim) return // if it's eating someone already, continue eating!


		if(prob(5))
			emote(pick("click","chatter","sway","light","vibrate","chatter","shriek"))

		if(AIproc && SStun) return


		var/hungry = 0 // determines if the metroid is hungry
		var/starving = 0 // determines if the metroid is starving-hungry
		if(istype(src, /mob/living/carbon/metroid/adult))
			switch(nutrition)
				if(400 to 1100) hungry = 1
				if(0 to 399)
					starving = 1

		else
			switch(nutrition)
				if(150 to 800) hungry = 1
				if(0 to 149) starving = 1


		if(starving && !client) // if a metroid is starving, it starts losing its friends
			if(prob(15) && Friends.len > 0)
				var/friendnum = 0
				for(var/mob/M in Friends)
					friendnum++

				if(friendnum > 0)
					var/mob/nofriend = pick(Friends)
					Friends -= nofriend

		if(!Target)
			var/list/targets = list()

			for(var/mob/living/carbon/C in view(12,src))
				if(!istype(C, /mob/living/carbon/metroid)) // does not eat his bros! BROSBROSBROSBROS
					if(C.stat != 2 && C.health > 0) // chooses only healthy targets
						var/notarget = 0
						if(istype(C, /mob/living/carbon/human))
							var/mob/living/carbon/human/H = C
							if(H.mutantrace == "metroid")
								notarget = 1 // don't hurt metroidmen!

						if(!istype(src, /mob/living/carbon/metroid/adult))
							if(!starving && Discipline > 0)
								notarget = 1
								break

						if(!C.canmove)
							for(var/mob/living/carbon/metroid/M in view(1,C))
								if(M.Victim == C)
									notarget = 1

						if(C in Friends)
							notarget = 1

						if(tame && istype(C, /mob/living/carbon/human))
							notarget = 1

						if(!notarget) targets += C

			for(var/mob/living/silicon/C in view(12,src))
				if(C.stat != 2)
					var/notarget = 0

					if(!istype(src, /mob/living/carbon/metroid/adult))
						if(!starving && Discipline > 0)
							notarget = 1
							break

					if(tame)
						notarget = 1

					if(!notarget) targets += C



			if((hungry || starving) && targets.len > 0)
				if(!istype(src, /mob/living/carbon/metroid/adult))
					if(!starving)
						for(var/mob/living/carbon/monkey/M in targets)
							Target = M
							break
						for(var/mob/living/carbon/alien/larva/L in targets)
							Target = L
							break
						if(prob(5) && !Discipline)
							for(var/mob/living/carbon/alien/humanoid/H in targets)
								Target = H
								break
							for(var/mob/living/carbon/human/H in targets)
								Target = H
								break

					else
						Target = targets[1]

				else
					Target = targets[1] // closest target

			if(targets.len > 0)
				if(attacked > 0 || rabid)
					Target = targets[1]


		if(!Target)

			if(hungry || starving)
				if(prob(50) && canmove && isturf(loc))
					step(src, pick(cardinal))

			else
				if(prob(33) && canmove && isturf(loc))
					step(src, pick(cardinal))


		else
			if(!AIproc)
				spawn() AIprocess()







/mob/living/carbon/metroid
	var/AIproc = 0 // determines if the AI loop is activated
	var/Atkcool = 0 // attack cooldown
	var/Tempstun = 0 // temporary temperature stuns
	var/Discipline = 0 // if a metroid has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/SStun = 0 // stun variable
	proc

		AIprocess()  // the master AI process

			if(AIproc || stat == 2 || client) return

			var/hungry = 0
			var/starving = 0
			if(istype(src, /mob/living/carbon/metroid/adult))
				switch(nutrition)
					if(400 to 1100) hungry = 1
					if(0 to 399)
						starving = 1
			else
				switch(nutrition)
					if(150 to 800) hungry = 1
					if(0 to 149) starving = 1
			AIproc = 1
			while(AIproc && stat != 2 && (attacked > 0 || starving || hungry || rabid || Victim))
				if(Victim) // can't eat AND have this little process at the same time
					break

				if(!Target || client)
					break


				if(Target.health <= -70 || Target.stat == 2)
					Target = null
					AIproc = 0
					break

				if(Target)
					for(var/mob/living/carbon/metroid/M in view(1,Target))
						if(M.Victim == Target)
							Target = null
							AIproc = 0
							break
					if(!AIproc)
						break

					if(Target in view(1,src))

						if(istype(Target, /mob/living/silicon))
							if(!Atkcool)
								spawn()
									Atkcool = 1
									sleep(15)
									Atkcool = 0

								if(get_obstacle_ok(Target))
									Target.attack_metroid(src)
							return
						if(prob(80) && !Target.lying)

							if(Target.client && Target.health >= rand(10,30))
								if(!Atkcool)
									spawn()
										Atkcool = 1
										sleep(25)
										Atkcool = 0

									if(get_obstacle_ok(Target))
										Target.attack_metroid(src)


								if(prob(30))
									step_to(src, Target)

							else
								if(!Atkcool && get_obstacle_ok(Target))
									Feedon(Target)

						else
							if(!Atkcool && get_obstacle_ok(Target))
								Feedon(Target)

					else
						if(Target in view(30, src))
							if(get_obstacle_ok(Target))
								step_to(src, Target)

						else
							Target = null
							AIproc = 0
							break

				var/sleeptime = movement_delay()
				if(sleeptime <= 0) sleeptime = 1

				sleep(sleeptime + 2) // this is about as fast as a player Metroid can go

			AIproc = 0


		update_mind()
			if(!mind && client)
				mind = new
				mind.current = src
				mind.assigned_role = "Metroid"
				mind.key = key

		handle_environment(datum/gas_mixture/environment)
			if(!environment)
				adjustFireLoss(rand(10,20))
				return

			//var/environment_heat_capacity = environment.heat_capacity()
			var/loc_temp = T0C
			if(istype(loc, /turf/space))
				//environment_heat_capacity = loc:heat_capacity
				loc_temp = 2.7
			else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
				loc_temp = loc:air_contents.temperature
			else
				loc_temp = environment.temperature

			/*
			if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
				var/transfer_coefficient

				transfer_coefficient = 1
				if(wear_mask && (wear_mask.body_parts_covered & HEAD) && (environment.temperature < wear_mask.protective_temperature))
					transfer_coefficient *= wear_mask.heat_transfer_coefficient

				// handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)
			*/


			if(loc_temp < 310.15) // a cold place
				bodytemperature += adjust_body_temperature(bodytemperature, loc_temp, 1)
			else // a hot place
				bodytemperature += adjust_body_temperature(bodytemperature, loc_temp, 1)

			/*
			if(stat==2)
				bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

			*/
			//Account for massive pressure differences

			if(bodytemperature < (T0C + 5)) // start calculating temperature damage etc
				if(bodytemperature <= (T0C - 40)) // stun temperature
					Tempstun = 1

				if(bodytemperature <= (T0C - 50)) // hurt temperature
					if(bodytemperature <= 50) // sqrting negative numbers is bad
						adjustFireLoss(200)
					else
						adjustFireLoss(round(sqrt(bodytemperature)) * 2)

			else
				Tempstun = 0

			updatehealth()

			return //TODO: DEFERRED


		adjust_body_temperature(current, loc_temp, boost)
			var/temperature = current
			var/difference = abs(current-loc_temp)	//get difference
			var/increments// = difference/10			//find how many increments apart they are
			if(difference > 50)
				increments = difference/5
			else
				increments = difference/10
			var/change = increments*boost	// Get the amount to change by (x per increment)
			var/temp_change
			if(current < loc_temp)
				temperature = min(loc_temp, temperature+change)
			else if(current > loc_temp)
				temperature = max(loc_temp, temperature-change)
			temp_change = (temperature - current)
			return temp_change

		handle_chemicals_in_body()

			if(reagents) reagents.metabolize(src)


			src.updatehealth()

			return //TODO: DEFERRED


		handle_regular_status_updates()

			if(istype(src, /mob/living/carbon/metroid/adult))
				health = 200 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())
			else
				health = 150 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())




			if(health < config.health_threshold_dead && stat != 2)
				death()
				return

			else if(src.health < config.health_threshold_crit)
				// if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

				//if(!src.rejuv) src.oxyloss++
				if(!src.reagents.has_reagent("inaprovaline")) src.adjustOxyLoss(10)

				if(src.stat != DEAD)	src.stat = UNCONSCIOUS

			if(prob(30))
				adjustOxyLoss(-1)
				adjustToxLoss(-1)
				adjustFireLoss(-1)
				adjustCloneLoss(-1)
				adjustBruteLoss(-1)


			if (src.stat == DEAD)

				src.lying = 1
				src.blinded = 1

			else
				if (src.paralysis || src.stunned || src.weakened || (changeling && changeling.changeling_fakedeath)) //Stunned etc.
					if (src.stunned > 0)
						AdjustStunned(-1)
						src.stat = 0
					if (src.weakened > 0)
						AdjustWeakened(-1)
						src.lying = 0
						src.stat = 0
					if (src.paralysis > 0)
						AdjustParalysis(-1)
						src.blinded = 0
						src.lying = 0
						src.stat = 0

				else
					src.lying = 0
					src.stat = 0

			if (src.stuttering) src.stuttering = 0

			if (src.eye_blind)
				src.eye_blind = 0
				src.blinded = 1

			if (src.ear_deaf > 0) src.ear_deaf = 0
			if (src.ear_damage < 25)
				src.ear_damage = 0

			src.density = !( src.lying )

			if (src.sdisabilities & 1)
				src.blinded = 1
			if (src.sdisabilities & 4)
				src.ear_deaf = 1

			if (src.eye_blurry > 0)
				src.eye_blurry = 0

			if (src.druggy > 0)
				src.druggy = 0

			return 1


		handle_nutrition()

			if(stat == 2) return // haha wow

			if(prob(20))
				if(istype(src, /mob/living/carbon/metroid/adult)) nutrition-=rand(4,6)
				else nutrition-=rand(2,3)

			if(nutrition <= 0)
				nutrition = 0
				if(prob(75))

					adjustToxLoss(rand(0,5))

			else
				if(istype(src, /mob/living/carbon/metroid/adult))
					if(nutrition >= 1000)
						if(prob(40)) amount_grown++

				else
					if(nutrition >= 800)
						if(prob(40)) amount_grown++

			if(amount_grown >= 10 && !Victim && !Target)
				if(istype(src, /mob/living/carbon/metroid/adult))
					if(!client)
						var/number = pick(2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,4)
						for(var/i=1,i<=number,i++) // reproduce (has a small chance of producing 3 or 4 offspring)
							var/mob/living/carbon/metroid/M = new/mob/living/carbon/metroid(loc)
							M.nutrition = round(nutrition/number)
							M.powerlevel = round(powerlevel / number)
							M.Friends = Friends
							M.tame = tame
							M.rabid = rabid
							if(i != 1) step_away(M,src)

						del(src)

				else
					if(!client)
						var/mob/living/carbon/metroid/adult/A = new/mob/living/carbon/metroid/adult(src.loc)
						A.nutrition = nutrition
						A.powerlevel = max(0, powerlevel-1)
						A.Friends = Friends
						A.tame = tame
						A.rabid = rabid
						del(src)


		handle_virus_updates()
			if(bodytemperature > 406)
				for(var/datum/disease/D in viruses)
					D.cure()
			return


