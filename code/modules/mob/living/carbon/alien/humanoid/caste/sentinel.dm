/mob/living/carbon/alien/humanoid/sentinel/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien sentinel")
		src.name = text("alien sentinel ([rand(1, 1000)])")
	src.real_name = src.name
	spawn (1)
		src.verbs += /mob/living/carbon/alien/humanoid/proc/corrode_target
		src.stand_icon = new /icon('alien.dmi', "aliens_s")
		src.lying_icon = new /icon('alien.dmi', "aliens_l")
		src.resting_icon = new /icon('alien.dmi', "aliens_sleep")
		src.icon = src.stand_icon
		update_clothing()
		src << "\blue Your icons have been generated!"


/mob/living/carbon/alien/humanoid/sentinel

	updatehealth()
		if (src.nodamage == 0)
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
			src.health = 125 - src.getOxyLoss() - src.getFireLoss() - src.getBruteLoss()
		else
			src.health = 125
			src.stat = 0

	handle_regular_hud_updates()

		if (src.stat == 2 || src.mutations & XRAY)
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
			src.see_in_dark = 8
			src.see_invisible = 2
		else if (src.stat != 2)
			src.sight |= SEE_MOBS
			src.sight &= SEE_TURFS
			src.sight &= ~SEE_OBJS
			src.see_in_dark = 7
			src.see_invisible = 3

		if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
		if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

		if (src.healths)
			if (src.stat != 2)
				switch(health)
					if(125 to INFINITY)
						src.healths.icon_state = "health0"
					if(100 to 125)
						src.healths.icon_state = "health1"
					if(75 to 100)
						src.healths.icon_state = "health2"
					if(25 to 75)
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
			if(health >= 125)
				adjustToxLoss(10)

			else
				adjustBruteLoss(-10)
				adjustFireLoss(-10)


	handle_regular_status_updates()

		health = 150 - (getOxyLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

		if(getOxyLoss() > 50) Paralyse(3)

		if(src.sleeping)
			Paralyse(3)
			if (prob(10) && health) spawn(0) emote("snore")
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

		if (src.eye_blind)
			src.eye_blind--
			src.blinded = 1

		if (src.ear_deaf > 0) src.ear_deaf--
		if (src.ear_damage < 25)
			src.ear_damage -= 0.05
			src.ear_damage = max(src.ear_damage, 0)

		src.density = !( src.lying )

		if ((src.sdisabilities & 1))
			src.blinded = 1
		if ((src.sdisabilities & 4))
			src.ear_deaf = 1

		if (src.eye_blurry > 0)
			src.eye_blurry--
			src.eye_blurry = max(0, src.eye_blurry)

		if (src.druggy > 0)
			src.druggy--
			src.druggy = max(0, src.druggy)

		return 1

//Sentinel verbs

/mob/living/carbon/alien/humanoid/sentinel/verb/spit(mob/target as mob in oview())
	set name = "Spit Neurotoxin (50)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	set category = "Alien"

	if(powerc(50))
		if(isalien(target))
			src << "\green Your allies are not a valid target."
			return
		adjustToxLoss(-50)
		src << "\green You spit neurotoxin at [target]."
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << "\red [src] spits neurotoxin at [target]!"
		//I'm not motivated enough to revise this. Prjectile code in general needs update.
		var/turf/T = loc
		var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

		if(!U || !T)
			return
		while(U && !istype(U,/turf))
			U = U.loc
		if(!istype(T, /turf))
			return
		if (U == T)
			usr.bullet_act(src, src.get_organ_target())
			return
		if(!istype(U, /turf))
			return

		var/obj/item/projectile/energy/dart/A = new /obj/item/projectile/energy/dart(usr.loc)

		A.current = U
		A.yo = U.y - T.y
		A.xo = U.x - T.x
		A.process()
	return