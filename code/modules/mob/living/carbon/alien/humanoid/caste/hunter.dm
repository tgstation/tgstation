/mob/living/carbon/alien/humanoid/hunter/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien hunter")
		src.name = text("alien hunter ([rand(1, 1000)])")
	src.real_name = src.name
	spawn (1)
		src.verbs -= /mob/living/carbon/alien/humanoid/verb/corrode
		src.stand_icon = new /icon('alien.dmi', "alienh_s")
		src.lying_icon = new /icon('alien.dmi', "alienh_l")
		src.resting_icon = new /icon('alien.dmi', "alienh_sleep")
		src.running_icon = new /icon('alien.dmi', "alienh_running")
		src.icon = src.stand_icon
		rebuild_appearance()
		src << "\blue Your icons have been generated!"


/mob/living/carbon/alien/humanoid/hunter

	updatehealth()
		if (src.nodamage == 0)
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
			src.health = 150 - src.getOxyLoss() - src.getFireLoss() - src.getBruteLoss()
		else
			src.health = 150
			src.stat = 0

	handle_regular_hud_updates()

		..() //-Yvarov

		if (src.healths)
			if (src.stat != 2)
				switch(health)
					if(150 to INFINITY)
						src.healths.icon_state = "health0"
					if(100 to 150)
						src.healths.icon_state = "health1"
					if(50 to 100)
						src.healths.icon_state = "health2"
					if(25 to 50)
						src.healths.icon_state = "health3"
					if(0 to 25)
						src.healths.icon_state = "health4"
					else
						src.healths.icon_state = "health5"
			else
				src.healths.icon_state = "health6"

	handle_environment()

		//If there are alien weeds on the ground then heal if needed or give some toxins
		if(locate(/obj/effect/alien/weeds) in loc)
			if(health >= 150)
				adjustToxLoss(5)

			else
				adjustBruteLoss(-5)
				adjustFireLoss(-5)

	handle_regular_status_updates()

		health = 150 - (getOxyLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

		if(getOxyLoss() > 50) Paralyse(3)

		if(src.sleeping)
			Paralyse(3)
			//if (prob(10) && health) spawn(0) emote("snore") Invalid Emote
			if(!src.sleeping_willingly)
				src.sleeping--

		if(src.resting)
			Weaken(5)

		if(move_delay_add > 0)
			move_delay_add = max(0, move_delay_add - rand(1, 2))

		if(health < config.health_threshold_dead || src.brain_op_stage == 4.0)
			death()
		else if(src.health < config.health_threshold_crit)
			if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

			//if(!src.rejuv) src.oxyloss++
			if(!src.reagents.has_reagent("inaprovaline")) src.adjustOxyLoss(1)

			if(src.stat != 2)	src.stat = 1
			Paralyse(5)

		if (src.stat != 2) //Alive.

			if (src.paralysis || src.stunned || src.weakened) //Stunned etc.
				if (src.stunned > 0)
					AdjustStunned(-1)
					src.stat = 0
				if (src.weakened > 0)
					AdjustWeakened(-1)
					src.lying = 1
					src.stat = 0
				if (src.paralysis > 0)
					AdjustParalysis(-1)
					src.blinded = 1
					src.lying = 1
					src.stat = 1
				var/h = src.hand
				src.hand = 0
				drop_item()
				src.hand = 1
				drop_item()
				src.hand = h

			else	//Not stunned.
				src.lying = 0
				src.stat = 0

		else //Dead.
			src.lying = 1
			src.blinded = 1
			src.stat = 2

		if (src.stuttering) src.stuttering--
		if (src.slurring) src.slurring--

		if (src.eye_blind)
			src.eye_blind--
			src.blinded = 1

		if (src.ear_deaf > 0) src.ear_deaf--
		if (src.ear_damage < 25)
			src.ear_damage -= 0.05
			src.ear_damage = max(src.ear_damage, 0)

		src.density = !( src.lying )

		if ((src.disabilities & 128))
			src.blinded = 1
		if ((src.disabilities & 32))
			src.ear_deaf = 1

		if (src.eye_blurry > 0)
			src.eye_blurry--
			src.eye_blurry = max(0, src.eye_blurry)

		if (src.druggy > 0)
			src.druggy--
			src.druggy = max(0, src.druggy)

		return 1

//Hunter verbs

/mob/living/carbon/alien/humanoid/hunter/verb/invis()
	set name = "Invisibility (50)"
	set desc = "Makes you invisible for 15 seconds"
	set category = "Alien"

	if(powerc(50))
		adjustToxLoss(-50)
		alien_invis = 1.0
		src << "\green You are now invisible."
		for(var/mob/O in oviewers(src, null))
			O.show_message(text("\red <B>[src] fades into the surroundings!</B>"), 1)
		spawn(150)
			if(!isnull(src))//Don't want the game to runtime error when the mob no-longer exists.
				alien_invis = 0.0
				src << "\green You are no longer invisible."
	return
