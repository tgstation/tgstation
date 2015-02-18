//drunkness defines
#define TIPSY 50
#define DRUNK 100
#define VERYDRUNK 175
#define WASTED 250

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

/mob/living/carbon/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return
	if(!loc)
		return
	var/datum/gas_mixture/environment = loc.return_air()

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)

	handle_regular_status_updates() // Status updates, death etc.

	if(stat != DEAD)

		//Updates the number of stored chemicals for powers
		handle_changeling()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

		//Blud
		handle_blood()

		//Random events (vomiting etc)
		handle_random_events()

		. = 1

	handle_fire()

	//stuff in the stomach
	handle_stomach()

	update_canmove()

	update_gravity(mob_has_gravity())

	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(client)
		handle_regular_hud_updates()

	return .














//remember to remove the "proc" of the child procs of these.

/mob/living/carbon/proc/handle_changeling()
	return

/mob/living/carbon/proc/handle_mutations_and_radiation()
	return

/mob/living/carbon/proc/handle_chemicals_in_body()
	return

/mob/living/carbon/proc/handle_disabilities()
	return

/mob/living/carbon/proc/handle_blood()
	return

/mob/living/carbon/proc/handle_random_events()
	return

/mob/living/carbon/proc/handle_environment(var/datum/gas_mixture/environment)
	return

/mob/living/carbon/proc/handle_regular_status_updates()
	return

/mob/living/carbon/proc/handle_stomach()
	spawn(0)
		for(var/mob/living/M in stomach_contents)
			if(M.loc != src)
				stomach_contents.Remove(M)
				continue
			if(istype(M, /mob/living/carbon) && stat != 2)
				if(M.stat == 2)
					M.death(1)
					stomach_contents.Remove(M)
					qdel(M)
					continue
				if(SSmob.times_fired%3==1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10

/mob/living/carbon/proc/handle_regular_hud_updates()
	return

/mob/living/carbon/proc/handle_nausea()
	if(!stat)
		if(getToxLoss() >= 40)
			nausea++
		if(nausea > 0) //so prob isn't rolling on every tick
			if(prob(15)) //slowly reduce nausea over time
				nausea--
			if(nausea >= 12) //not feeling so good
				if(prob(7))
					visible_message("<font color='green'>[src] retches!</font>", \
							"<font color='green'><b>you retch!</b></font>")
			if(nausea >= 25) //vomiting
				Stun(max(2, 6 - (nutrition / 100)))

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

/mob/living/carbon/proc/handle_drunkness()
	if(drunkness > 0)
		if(prob(25))
			drunkness--
			boozeticks++ //metabolization

		if(drunkness >= (TIPSY * boozetolerance))
			jitteriness = max(jitteriness - 5, 0)
			slurring = max(4, slurring)
			Dizzy(5)
			if(prob(7))
				emote("burp")

		if(drunkness >= (DRUNK * boozetolerance))
			if(prob(33))
				confused += 2

		if(drunkness >= (VERYDRUNK * boozetolerance))
			nausea++
			if(prob(6) && !stat && !lying)
				Weaken(2)
				visible_message("<span class='danger'>[src] trips over their own feet!</span>")

		if(drunkness >= (WASTED * boozetolerance))
			adjustToxLoss(1)
			sleeping = min(sleeping + 2, 10)

	if(boozeticks >= (120 * boozetolerance)) //building tolerance
		boozeticks = 0
		boozetolerance = min(boozetolerance + 1, 5)