/mob/living/carbon/alien/proc/handle_chemicals_in_body()
	if(reagents)
		reagents.metabolize(src)

	if (drowsyness)
		drowsyness--
		eye_blurry = max(2, eye_blurry)
		if (prob(5))
			sleeping += 1
			Paralyse(5)

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
		jitteriness = max(0, jitteriness - 5)
	else
		dizziness = max(0, dizziness - 1)
		jitteriness = max(0, jitteriness - 1)

	updatehealth()

	return //TODO: DEFERRED

/mob/living/carbon/alien/proc/breathe()
	if(reagents)
		if(reagents.has_reagent("lexorin")) return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/breath
	// HACK NEED CHANGING LATER
	if(health <= config.health_threshold_crit)
		losebreath++

	if(losebreath>0) //Suffocating so do not take a breath
		losebreath--
		if (prob(75)) //High chance of gasping for air
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME)

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
			else if(istype(loc, /turf/))
				var/breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)

				// Handle chem smoke effect  -- Doohl
				for(var/obj/effect/effect/chem_smoke/smoke in view(1, src))
					if(smoke.reagents.total_volume)
						smoke.reagents.reaction(src, INGEST)
						spawn(5)
							if(smoke)
								smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
						break // If they breathe in the nasty stuff once, no need to continue checking


		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	handle_breath(breath)

	if(breath)
		loc.assume_air(breath)

/mob/living/carbon/alien/proc/handle_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return 0

	var/toxins_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	//Partial pressure of the toxins in our breath
	var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure

	if(Toxins_pp) // Detect toxins in air

		adjustToxLoss(breath.toxins*250)
		toxins_alert = max(toxins_alert, 1)

		toxins_used = breath.toxins

	else
		toxins_alert = 0

	//Breathe in toxins and out oxygen
	breath.toxins -= toxins_used
	breath.oxygen += toxins_used

	if(breath.temperature > (T0C+66)) // Hot air hurts :(
		if(prob(20))
			src << "<span class='danger'>You feel a searing heat in your lungs!</span>"
		fire_alert = max(fire_alert, 1)
	else
		fire_alert = 0

	//Temporary fixes to the alerts.

	return 1

/mob/living/carbon/alien/proc/handle_stomach()
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
