/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return

/mob/living/carbon/proc/handle_nausea()
	if(!stat)
		if(getToxLoss() >= 40)
			nausea++
		if(nausea > 0) //so prob isn't rolling on every tick
			if(prob(6)) //slowly reduce nausea over time
				nausea--
			if(nausea >= 12) //not feeling so good
				if(prob(8))
					visible_message("<font color='green'>[src] retches!</font>", \
							"<font color='green'><b>you retch!</b></font>")
			if(nausea >= 25) //vomiting
				Stun(5)

				visible_message("<span class='danger'>[src] throws up!</span>", \
						"<span class='userdanger'>you throw up!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

				var/turf/location = loc
				if(istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1)

				if(nutrition >= 40)
					nutrition -= 20
				adjustToxLoss(-3)

				//feelin fine after
				nausea = 0

/mob/living/carbon/proc/handle_drunkness() //probably could use a switch for ifs
	if(drunkness > 0)
		if(prob(25))
			drunkness--
			boozeticks++ //metabolize that hooch

		if(drunkness >= (30 * boozetolerance)) //mild inebriation, do define TIPSY instead?
			jitteriness = max(jitteriness - 5, 0)
			stuttering = 4
			//slurring to replace ^
			Dizzy(5)
			if(prob(7))
				emote("burp")

		if(drunkness >= (60 * boozetolerance)) //decently drunk, define DRUNK ?
			if(prob(33))
				confused += 2

		if(drunkness >= (120 * boozetolerance)) //dangerously wrecked, define VERYDRUNK ?
			nausea++
			if(prob(7) && !stat && !lying)
				Weaken(2)
				visible_message("<span class='danger'>[src] trips over their own feet!</span>")

		if(drunkness >= (200 * boozetolerance)) //lethally drunk, define WASTED ?
			adjustToxLoss(1)
			sleeping = min(sleeping + 2, 10) //comatose

	if(boozeticks >= (50 * boozetolerance)) //building tolerance
		boozeticks = 0
		boozetolerance++