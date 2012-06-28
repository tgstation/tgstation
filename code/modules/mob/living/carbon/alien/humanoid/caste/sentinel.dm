/mob/living/carbon/alien/humanoid/sentinel/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	verbs += /mob/living/carbon/alien/humanoid/proc/corrode_target

/mob/living/carbon/alien/humanoid/sentinel

	updatehealth()
		if(nodamage)
			health = 125
			stat = CONSCIOUS
		else
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
			health = 125 - getOxyLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()


	handle_regular_hud_updates()

		..() //-Yvarov

		if (healths)
			if (stat != 2)
				switch(health)
					if(125 to INFINITY)
						healths.icon_state = "health0"
					if(100 to 125)
						healths.icon_state = "health1"
					if(75 to 100)
						healths.icon_state = "health2"
					if(25 to 75)
						healths.icon_state = "health3"
					if(0 to 25)
						healths.icon_state = "health4"
					else
						healths.icon_state = "health5"
			else
				healths.icon_state = "health6"

	handle_environment()

		//If there are alien weeds on the ground then heal if needed or give some toxins
		if(locate(/obj/effect/alien/weeds) in loc)
			if(health >= 125)
				adjustToxLoss(10)
			else
				adjustBruteLoss(-10)
				adjustFireLoss(-10)

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
			usr.bullet_act(src, get_organ_target())
			return
		if(!istype(U, /turf))
			return

		var/obj/item/projectile/energy/dart/A = new /obj/item/projectile/energy/dart(usr.loc)

		A.current = U
		A.yo = U.y - T.y
		A.xo = U.x - T.x
		A.process()
	return