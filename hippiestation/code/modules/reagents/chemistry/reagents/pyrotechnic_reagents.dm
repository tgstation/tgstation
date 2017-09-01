/datum/reagent/cryogenic_fluid
	name = "Cryogenic Fluid"
	id = "cryogenic_fluid"
	description = "Extremely cold superfluid used to put out fires that will viciously freeze people on contact causing severe pain and burn damage, weak if ingested."
	color = "#b3ffff"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/cryogenic_fluid/on_mob_life(mob/living/M) //not very pleasant but fights fires
	M.adjust_fire_stacks(-2)
	M.adjustStaminaLoss(2)
	M.adjustBrainLoss(1)
	M.bodytemperature = max(M.bodytemperature - 10, TCMB)
	return ..()

/datum/reagent/cryogenic_fluid/on_tick()
	holder.chem_temp -= 5
	return ..()

/datum/reagent/cryogenic_fluid/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST,INJECT))
			M.bodytemperature = max(M.bodytemperature - 50, TCMB)
			if(show_message)
				to_chat(M, "<span class='warning'>You feel like you are freezing from the inside!</span>")
		else
			if (reac_volume >= 5)
				if(show_message)
					to_chat(M, "<span class='danger'>You can feel your body freezing up and your metabolism slow, the pain is excruciating!</span>")
				M.bodytemperature = max(M.bodytemperature - 5*reac_volume, TCMB) //cold
				M.adjust_fire_stacks(-(12*reac_volume))
				M.losebreath += (0.2*reac_volume) //no longer instadeath rape but losebreath instead much more immulshion friendly
				M.drowsyness += 2
				M.confused += 6
				M.brainloss += (0.25*reac_volume) //hypothermia isn't good for the brain

			else
			 M.bodytemperature = max(M.bodytemperature - 15, TCMB)
			 M.adjust_fire_stacks(-(6*reac_volume))
	return ..()

/datum/reagent/cryogenic_fluid/reaction_turf(turf/T, reac_volume)
	if (!istype(T))
		return FALSE
	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T) //instantly delts hotspots
	if(isopenturf(T))
		var/turf/open/O = T
		if(hotspot)
			if(O.air)
				var/datum/gas_mixture/G = O.air
				G.temperature = 0
				G.react()
				qdel(hotspot)
		if(reac_volume >= 6)
			O.freon_gas_act() //freon in my pocket