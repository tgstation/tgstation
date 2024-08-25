/datum/artifact_effect/vomit
	weight = ARTIFACT_UNCOMMON
	type_name = "Vomiting Inducer Effect"
	activation_message = "starts emitting disgusting imagery!"
	deactivation_message = "falls silent, its aura dissipating!"
	valid_origins = list(
		/datum/artifact_origin/narsie,
		/datum/artifact_origin/wizard,
		/datum/artifact_origin/martian,
	) //silicons dont like organic stuff or something
	var/range = 0
	var/spew_range = 1
	var/spew_organs = FALSE
	var/bloody_vomit = FALSE
	COOLDOWN_DECLARE(cooldown)

	research_value = 100 //To busy vomiting cant research


	examine_discovered = span_warning("It appears to be some sort of sick prank")

/datum/artifact_effect/vomit/setup()
	switch(rand(1,100))
		if(1 to 84)
			range = rand(2,3)
		if(85 to 100) //15%
			range = rand(2,7)
	if(prob(12))
		spew_organs = TRUE //trolling
		potency += 20
	if(prob(40))
		spew_range = rand(1,5)
		potency += spew_range
	bloody_vomit = prob(50)
	potency += (range) * 4
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/artifact, artifact_deactivate)), round(30 * (potency * 10) SECONDS))


/datum/artifact_effect/vomit/effect_process()
	for(var/mob/living/carbon/viewed in view(range, src))
		if(prob(100 - potency))
			continue
		viewed.vomit(blood = bloody_vomit, stun = (spew_organs ? TRUE : prob(25)), distance = spew_range)
		if(spew_organs && prob(10))
			viewed.spew_organ()
