/datum/symptom/necroseed
	name = "Necropolis Seed"
	desc = "An infantile form of the root of Lavaland's tendrils. Forms a symbiotic bond with the host, making them stronger and hardier, at the cost of speed. Should the disease be cured, the host will be severely weakened"
	stealth = 0
	resistance = 3
	stage_speed = -5
	transmittable = -3
	level = 8
	base_message_chance = 5
	severity = -1
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/tendrils = FALSE
	var/chest = FALSE
	var/fireproof = FALSE
	threshold_descs = list(
		"Stealth 7" = "Upon death, the host's soul will solidify into an unholy artifact, rendering them utterly unrevivable in the process.",
		"Resistance 12" = "The area near the host roils with paralyzing tendrils.",
		"Resistance 15" = "Host becomes Immune to heat and ash",

	)
	var/list/cached_tentacle_turfs
	var/turf/last_location
	var/tentacle_recheck_cooldown = 100

/datum/symptom/necroseed/Start(datum/disease/advance/advanced_disease)
	if(!..())
		return
	if(advanced_disease.totalResistance() >= 12)
		tendrils = TRUE
		if(advanced_disease.totalResistance() >= 15)
			fireproof = TRUE
	if(advanced_disease.totalStealth() >= 7)
		chest = TRUE

/datum/symptom/necroseed/Activate(datum/disease/advance/advanced_disease)
	if(!..())
		return
	var/mob/living/carbon/Victim = advanced_disease.affected_mob
	switch(advanced_disease.stage)
		if(2)
			if(prob(base_message_chance))
				to_chat(Victim, "<span class='notice'>Your skin feels scaly.</span>")
		if(3, 4)
			if(prob(base_message_chance))
				to_chat(Victim, "<span class='notice'>[pick("Your skin is hard.", "You feel stronger.", "You feel powerful.")]</span>")
		if(5)
			if(tendrils)
				tendril(advanced_disease)
			Victim.dna.species.brutemod = min(0.6, Victim.dna.species.brutemod)
			Victim.dna.species.burnmod = min(0.6, Victim.dna.species.burnmod)
			Victim.dna.species.heatmod = min(0.6, Victim.dna.species.heatmod)
			Victim.add_movespeed_modifier(/datum/movespeed_modifier/necro_virus)
			ADD_TRAIT(Victim, TRAIT_PIERCEIMMUNE, DISEASE_TRAIT)
			if(fireproof)
				ADD_TRAIT(Victim, TRAIT_RESISTHEAT, DISEASE_TRAIT)
				ADD_TRAIT(Victim, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
				ADD_TRAIT(Victim, TRAIT_LAVA_IMMUNE, DISEASE_TRAIT)
				ADD_TRAIT(Victim, TRAIT_ASHSTORM_IMMUNE, DISEASE_TRAIT)
				ADD_TRAIT(Victim, TRAIT_SNOWSTORM_IMMUNE, DISEASE_TRAIT)
	return

/datum/movespeed_modifier/necro_virus
	multiplicative_slowdown = 0.65
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/symptom/necroseed/proc/tendril(datum/disease/advance/advanced_disease)
	. = advanced_disease.affected_mob
	var/mob/living/loc = advanced_disease.affected_mob.loc
	if(isturf(loc))
		if(!LAZYLEN(cached_tentacle_turfs) || loc != last_location || tentacle_recheck_cooldown <= world.time)
			LAZYCLEARLIST(cached_tentacle_turfs)
			last_location = loc
			tentacle_recheck_cooldown = world.time + initial(tentacle_recheck_cooldown)
			for(var/turf/open/Tentacle in (RANGE_TURFS(1, loc)-loc))
				LAZYADD(cached_tentacle_turfs, Tentacle)
		for(var/Tentacle2 in cached_tentacle_turfs)
			if(isopenturf(Tentacle2))
				if(prob(5))
					new /obj/effect/temp_visual/goliath_tentacle/necro(Tentacle2, advanced_disease.affected_mob)
			else
				cached_tentacle_turfs -= Tentacle2

/datum/symptom/necroseed/End(datum/disease/advance/advanced_disease)
	if(!..())
		return
	var/mob/living/carbon/Victim = advanced_disease.affected_mob
	to_chat(Victim, "<span class='danger'>You feel weak and powerless as the necropolis' blessing leaves your body, leaving you slow and vulnerable.</span>")
	Victim.dna.species.brutemod = initial(Victim.dna.species.heatmod)
	Victim.dna.species.burnmod = initial(Victim.dna.species.heatmod)
	Victim.dna.species.heatmod = initial(Victim.dna.species.heatmod)
	Victim.remove_movespeed_modifier(/datum/movespeed_modifier/necro_virus)
	REMOVE_TRAIT(Victim, TRAIT_PIERCEIMMUNE, DISEASE_TRAIT)
	if(fireproof)
		REMOVE_TRAIT(Victim, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
		REMOVE_TRAIT(Victim, TRAIT_RESISTHEAT, DISEASE_TRAIT)
		REMOVE_TRAIT(Victim, TRAIT_LAVA_IMMUNE, DISEASE_TRAIT)
		REMOVE_TRAIT(Victim, TRAIT_ASHSTORM_IMMUNE, DISEASE_TRAIT)
		REMOVE_TRAIT(Victim, TRAIT_SNOWSTORM_IMMUNE, DISEASE_TRAIT)

/datum/symptom/necroseed/OnDeath(datum/disease/advance/advanced_disease)
	if(!..())
		return
	var/mob/living/carbon/Victim = advanced_disease.affected_mob
	if(chest && advanced_disease.stage >= 5)
		to_chat(Victim, "<span class='danger'>Your soul is ripped from your body!</span>")
		Victim.visible_message("<span class='danger'>An unearthly roar shakes the ground as [Victim] expires, leaving behind an ominous, fleshy chest.</span>")
		playsound(Victim.loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, 1, 1)
		Victim.dust(FALSE,TRUE,TRUE) //so if stealth is 8, they get dusted on death, this and no monke farming reduces the ways they can farm chests to using cloners...with are slow.
		to_chat(Victim, "<span class='danger'>DEBUG MESSAGE Victim=[Victim] advanced_disease=[advanced_disease]</span>")
		Victim.visible_message("<span class='danger'>DEBUG MESSAGE Victim=[Victim] advanced_disease=[advanced_disease]</span>")
		if(ismonkey(Victim))// anti chest farming
			return
		if(iscarbon(Victim)) // if carbon and not monkey, drop a chest.
			new /obj/structure/closet/crate/necropolis/tendril(Victim.loc)


/obj/effect/temp_visual/goliath_tentacle/necro
	name = "fledgling necropolis tendril"

/obj/effect/temp_visual/goliath_tentacle/necro/trip()
	var/latched = FALSE
	for(var/mob/living/Goliath_tentacles in loc)
		if(Goliath_tentacles == spawner)
			retract()
			return
		visible_message("<span class='danger'>[src] grabs hold of [Goliath_tentacles]!</span>")
		Goliath_tentacles.Stun(40)
		Goliath_tentacles.adjustBruteLoss(rand(1,10))
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, .proc/retract), 10, TIMER_STOPPABLE)
