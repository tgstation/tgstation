/mob/living/carbon/alien/humanoid/hunter/New()
	spawn (1)
		src.verbs -= /mob/living/carbon/alien/humanoid/verb/corrode
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		src.stand_icon = new /icon('alien.dmi', "alienh_s")
		src.lying_icon = new /icon('alien.dmi', "alienh_l")
		src.icon = src.stand_icon
		if(src.name == "alien hunter") src.name = text("alien hunter ([rand(1, 1000)])")
		src.real_name = src.name
		src << "\blue Your icons have been generated!"

		update_clothing()


/mob/living/carbon/alien/humanoid/hunter

	updatehealth()
		if (src.nodamage == 0)
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
			src.health = 150 - src.oxyloss - src.fireloss - src.bruteloss
		else
			src.health = 150
			src.stat = 0

	handle_regular_hud_updates()

		if (src.stat == 2 || src.mutations & 4)
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
			src.see_in_dark = 8
			src.see_invisible = 2
		else if (src.stat != 2)
			src.sight |= SEE_MOBS
			src.sight |= SEE_TURFS
			src.sight &= ~SEE_OBJS
			src.see_in_dark = 5
			src.see_invisible = 2

		if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
		if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

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
		if(locate(/obj/alien/weeds) in loc)
			if(health >= 150)
				toxloss += 5
				if(toxloss > max_plasma)
					toxloss = max_plasma

			else
				bruteloss -= 5
				fireloss -= 5

	handle_regular_status_updates()

		health = 150 - (oxyloss + fireloss + bruteloss)

		if(oxyloss > 50) paralysis = max(paralysis, 3)

		if(src.sleeping)
			src.paralysis = max(src.paralysis, 3)
			if (prob(10) && health) spawn(0) emote("snore")
			src.sleeping--

		if(src.resting)
			src.weakened = max(src.weakened, 5)

		if(health < -100 || src.brain_op_stage == 4.0)
			death()
		else if(src.health < 0)
			if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

			//if(!src.rejuv) src.oxyloss++
			if(!src.reagents.has_reagent("inaprovaline")) src.oxyloss++

			if(src.stat != 2)	src.stat = 1
			src.paralysis = max(src.paralysis, 5)

		if (src.stat != 2) //Alive.

			if (src.paralysis || src.stunned || src.weakened) //Stunned etc.
				if (src.stunned > 0)
					src.stunned--
					src.stat = 0
				if (src.weakened > 0)
					src.weakened--
					src.lying = 1
					src.stat = 0
				if (src.paralysis > 0)
					src.paralysis--
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

//Hunter verbs

/mob/living/carbon/alien/humanoid/hunter/verb/invis()
	set name = "Invisibility (50)"
	set desc = "Makes you invisible for 15 seconds"
	set category = "Alien"

	if(src.stat)
		src << "\green You must be conscious to do this"
		return
	if(src.toxloss >= 50)
		src.toxloss -= 50
		src.alien_invis = 1.0
		src << "\green You are now invisible."
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] fades into the surroundings!</B>"), 1)
		spawn(150)
			src.alien_invis = 0.0
			src << "\green You are no longer invisible."
	else
		src << "\green Not enough plasma stored"
	return

/mob/living/carbon/alien/humanoid/hunter/verb/ventcrawl() // -- TLE
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and appear at a random one"
	set category = "Alien"
//	if(!istype(V,/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent))
//		return

	if(src.stat)
		src << "\green You must be conscious to do this."
		return
	var/vent_found = 0
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in range(1,src))
		if(!v.welded)
			vent_found = v

	if(!vent_found)
		src << "\green You must be standing on or beside an open air vent to enter it."
		return
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc == src.loc)
			continue
		if(temp_vent.welded)
			continue
		vents.Add(temp_vent)
	var/list/choices = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent in vents)
		if(vent.loc.z != src.loc.z)
			continue
		if(vent.welded)
			continue
		var/atom/a = get_turf_loc(vent)
		choices.Add(a.loc)
	var/turf/startloc = src.loc
	var/obj/selection = input("Select a destination.", "Duct System") in choices
	var/selection_position = choices.Find(selection)
	if(src.loc != startloc)
		src << "\green You need to remain still while entering a vent."
		return
	var/obj/machinery/atmospherics/unary/vent_pump/target_vent = vents[selection_position]
	if(target_vent)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<B>[src] scrambles into the ventillation ducts!</B>"), 1)
		var/list/huggers = list()
		for(var/obj/alien/facehugger/F in view(3, src))
			if(istype(F, /obj/alien/facehugger))
				huggers.Add(F)

		src.loc = vent_found
		for(var/obj/alien/facehugger/F in huggers)
			F.loc = vent_found
		var/travel_time = get_dist(src.loc, target_vent.loc)

		spawn(round(travel_time/2))//give sound warning to anyone near the target vent
			if(!target_vent.welded)
				for(var/mob/O in hearers(target_vent, null))
					O.show_message("You hear something crawling trough the ventilation pipes.")

		spawn(travel_time)
			if(target_vent.welded)//the vent can be welded while alien scrolled through the list or travelled.
				target_vent = vent_found //travel back. No additional time required.
				src << "\red The vent you were heading to appears to be welded."
			src.loc = target_vent.loc
			for(var/obj/alien/facehugger/F in huggers)
				F.loc = src.loc