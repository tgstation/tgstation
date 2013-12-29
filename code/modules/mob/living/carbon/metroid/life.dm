/mob/living/carbon/slime
	var/AIproc = 0 // determines if the AI loop is activated
	var/Atkcool = 0 // attack cooldown
	var/Tempstun = 0 // temporary temperature stuns
	var/Discipline = 0 // if a slime has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/SStun = 0 // stun variable



/mob/living/carbon/slime/Life()
	set invisibility = 0
	set background = 1

	if (src.monkeyizing)
		return

	..()

	if(stat != DEAD)
		//Chemicals in the body
		handle_chemicals_in_body()

		handle_nutrition()

		handle_targets()


	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(src.loc)
		environment = loc.return_air()


	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	src.blinded = null

	// Basically just deletes any screen objects :<
	regular_hud_updates()

	//Handle temperature/pressure differences between body and environment
	if(environment)
		handle_environment(environment)

	//Status updates, death etc.
	handle_regular_status_updates()



/mob/living/carbon/slime/proc/AIprocess()  // the master AI process

	//world << "AI proc started."
	if(AIproc || stat == DEAD || client) return

	var/hungry = 0
	var/starving = 0
	if(istype(src, /mob/living/carbon/slime/adult))
		switch(nutrition)
			if(400 to 1100) hungry = 1
			if(0 to 399)
				starving = 1
	else
		switch(nutrition)
			if(150 to 900) hungry = 1
			if(0 to 149) starving = 1
	AIproc = 1
	//world << "AIproc [AIproc] && stat != 2 [stat] && (attacked > 0 [attacked] || starving [starving] || hungry [hungry] || rabid [rabid] || Victim [Victim] || Target [Target]"
	while(AIproc && stat != 2 && (attacked > 0 || starving || hungry || rabid || Victim))
		if(Victim) // can't eat AND have this little process at the same time
			//world << "break 1"
			break

		if(!Target || client)
			//world << "break 2"
			break


		if(Target.health <= -70 || Target.stat == 2)
			Target = null
			AIproc = 0
			//world << "break 3"
			break

		if(Target)
			//world << "[Target] Target Found"
			for(var/mob/living/carbon/slime/M in view(1,Target))
				if(M.Victim == Target)
					Target = null
					AIproc = 0
					//world << "break 4"
					break
			if(!AIproc)
				//world << "break 5"
				break

			if(Target in view(1,src))

				if(istype(Target, /mob/living/silicon))
					if(!Atkcool)
						spawn()
							Atkcool = 1
							sleep(15)
							Atkcool = 0

						if(Target.Adjacent(src))
							Target.attack_slime(src)
					//world << "retrun 1"
					return
				if(!Target.lying && prob(80))

					if(Target.client && Target.health >= 20)
						if(!Atkcool)
							spawn()
								Atkcool = 1
								sleep(25)
								Atkcool = 0

							if(Target.Adjacent(src))
								Target.attack_slime(src)


						if(prob(30))
							step_to(src, Target)

					else
						if(!Atkcool && Target.Adjacent(src))
							Feedon(Target)

				else
					if(!Atkcool && Target.Adjacent(src))
						Feedon(Target)

			else
				if(Target in view(7, src))
					if(Target.Adjacent(src))
						step_to(src, Target)

				else
					Target = null
					AIproc = 0
					//world << "break 6"
					break

		var/sleeptime = movement_delay()
		if(sleeptime <= 0) sleeptime = 1

		sleep(sleeptime + 2) // this is about as fast as a player slime can go

	AIproc = 0
	//world << "AI proc ended."

/mob/living/carbon/slime/proc/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		adjustToxLoss(rand(10,20))
		return

	//var/environment_heat_capacity = environment.heat_capacity()
	var/loc_temp = get_temperature(environment)

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
				adjustToxLoss(200)
			else
				adjustToxLoss(round(sqrt(bodytemperature)) * 2)

	else
		Tempstun = 0

	updatehealth()

	return //TODO: DEFERRED


/mob/living/carbon/slime/proc/adjust_body_temperature(current, loc_temp, boost)
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

/mob/living/carbon/slime/proc/handle_chemicals_in_body()

	if(reagents) reagents.metabolize(src)


	src.updatehealth()

	return //TODO: DEFERRED


/mob/living/carbon/slime/proc/handle_regular_status_updates()

	if(istype(src, /mob/living/carbon/slime/adult))
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
		if (src.paralysis || src.stunned || src.weakened || (status_flags && FAKEDEATH)) //Stunned etc.
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

	if (src.sdisabilities & BLIND)
		src.blinded = 1
	if (src.sdisabilities & DEAF)
		src.ear_deaf = 1

	if (src.eye_blurry > 0)
		src.eye_blurry = 0

	if (src.druggy > 0)
		src.druggy = 0

	return 1


/mob/living/carbon/slime/proc/handle_nutrition()

	if(prob(20))
		if(istype(src, /mob/living/carbon/slime/adult)) nutrition-=rand(4,6)
		else nutrition-=rand(2,3)

	if(nutrition <= 0)
		nutrition = 0
		if(prob(75))

			adjustToxLoss(rand(0,5))

	else
		if(istype(src, /mob/living/carbon/slime/adult))
			if(nutrition >= 1000)
				if(prob(40)) amount_grown++

		else
			if(nutrition >= 800)
				if(prob(40)) amount_grown++

	if(amount_grown >= 10 && !Victim && !Target)
		if(istype(src, /mob/living/carbon/slime/adult))
			if(!client)
				for(var/i=1,i<=4,i++)
					var/newslime
					if(prob(70))
						newslime = primarytype
					else
						newslime = slime_mutation[rand(1,4)]

					var/mob/living/carbon/slime/M = new newslime(loc)
					M.powerlevel = round(powerlevel/4)
					M.Friends = Friends
					M.tame = tame
					M.rabid = rabid
					M.Discipline = Discipline
					if(i != 1) step_away(M,src)
					feedback_add_details("slime_babies_born","slimebirth_[replacetext(M.colour," ","_")]")
				del(src)

		else
			if(!client)
				var/mob/living/carbon/slime/adult/A = new adulttype(src.loc)
				A.nutrition = nutrition
//				A.nutrition += 100
				A.powerlevel = max(0, powerlevel-1)
				A.Friends = Friends
				A.tame = tame
				A.rabid = rabid
				del(src)


/mob/living/carbon/slime/proc/handle_targets()
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


	if(!client)

		if(!canmove) return

		// DO AI STUFF HERE

		if(Target)
			if(attacked <= 0)
				Target = null

		if(Victim) return // if it's eating someone already, continue eating!


		if(prob(1))
			emote(pick("bounce","sway","light","vibrate","jiggle"))

		if(AIproc && SStun) return


		var/hungry = 0 // determines if the slime is hungry
		var/starving = 0 // determines if the slime is starving-hungry
		if(istype(src, /mob/living/carbon/slime/adult)) // 1200 max nutrition
			switch(nutrition)
				if(601 to 900)
					if(prob(25)) hungry = 1//Ensures they continue eating, but aren't as aggressive at the same time
				if(301 to 600) hungry = 1
				if(0 to 300)
					starving = 1

		else
			switch(nutrition)			// 1000 max nutrition
				if(501 to 700)
					if(prob(25)) hungry = 1
				if(201 to 500) hungry = 1
				if(0 to 200) starving = 1


		if(starving && !client) // if a slime is starving, it starts losing its friends
			if(Friends.len > 0 && prob(1))
				var/mob/nofriend = pick(Friends)
				Friends -= nofriend

		if(!Target)
			var/list/targets = list()

			if(hungry || starving) //Only add to the list if we need to
				for(var/mob/living/L in view(7,src))

					//Ignore other slimes, dead mobs and simple_animals
					if(isslime(L) || L.stat != CONSCIOUS || isanimal(L))
						continue

					if(issilicon(L))
						if(!istype(src, /mob/living/carbon/slime/adult)) //Non-starving diciplined adult slimes wont eat things
							if(!starving && Discipline > 0)
								continue

						if(tame) //Tame slimes ignore electronic life
							continue

						targets += L //Possible target found!

					else if(iscarbon(L))

						if(istype(L, /mob/living/carbon/human)) //Ignore slime(wo)men
							var/mob/living/carbon/human/H = L
							if(H.dna)
								if(H.dna.mutantrace == "slime")
									continue

						if(!istype(src, /mob/living/carbon/slime/adult)) //Non-starving diciplined adult slimes wont eat things
							if(!starving && Discipline > 0)
								continue

						if(L in Friends) //No eating friends!
							continue

						if(tame && ishuman(L)) //Tame slimes dont eat people.
							continue

						if(!L.canmove) //Only one slime can latch on at a time.

							var/notarget = 0
							for(var/mob/living/carbon/slime/M in view(1,L))
								if(M.Victim == L)
									notarget = 1
							if(notarget)
								continue

						targets += L //Possible target found!



			if((hungry || starving) && targets.len > 0)
				if(!istype(src, /mob/living/carbon/slime/adult))
					if(!starving)
						for(var/mob/living/carbon/C in targets)
							if(!Discipline && prob(5))
								if(ishuman(C))
									Target = C
									break
								if(isalienadult(C))
									Target = C
									break

							if(islarva(C))
								Target = C
								break
							if(ismonkey(C))
								Target = C
								break
					else
						Target = targets[1]
				else
					Target = targets[1] // closest target

			if(targets.len > 0)
				if(attacked > 0 || rabid)
					Target = targets[1] //closest mob probably attacked it, so override Target and attack the nearest!


		if(!Target)
			if(hungry || starving)
				if(canmove && isturf(loc) && prob(50))
					step(src, pick(cardinal))

			else
				if(canmove && isturf(loc) && prob(33))
					step(src, pick(cardinal))
		else
			if(!AIproc)
				spawn() AIprocess()
