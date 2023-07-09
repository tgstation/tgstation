/obj/structure/artifact/vomit
	assoc_comp = /datum/component/artifact/vomit
/datum/component/artifact/vomit
	associated_object = /obj/structure/artifact/vomit
	weight = ARTIFACT_UNCOMMON
	type_name = "Vomiting Inducer"
	activation_message = "opens up!"
	deactivation_message = "emits a very very disgusting sound!"
	valid_origins = list(ORIGIN_NARSIE,ORIGIN_WIZARD) //silicons dont like organic stuff or something
	var/range = 0
	var/spew_range = 1
	var/spew_organs = FALSE
	var/bloody_vomit = FALSE
	COOLDOWN_DECLARE(cooldown)

/datum/component/artifact/vomit/setup()
	. = ..()
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

/datum/component/artifact/vomit/effect_activate()
	if(!COOLDOWN_FINISHED(src,cooldown))
		return Deactivate(silent=TRUE)
	should_do_vomit = TRUE
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/artifact, Deactivate)), 5 SECONDS)

/datum/component/artifact/vomit/effect_deactivate(silent)
	if(silent) //if we are deactivating silently we can assume its by an admin so we shouldnt make people do the tummy blaster
		return
	for(var/mob/living/carbon/carbon in view(range, holder))
		if(carbon.stat == DEAD)
			continue
		carbon.vomit(blood = bloody_vomit, stun = (spew_organs ? TRUE : prob(25)), distance = spew_range)
		if(spew_organs && prob(40))
			carbon.spew_organ()
		holder.Beam(carbon,icon_state="sendbeam", time = 0.7 SECONDS)
		to_chat(carbon, span_userdanger("You feel [spew_organs ? "extraordinaly sick!" : "extremely nauseous from a nearby object."]"))
	COOLDOWN_START(src,cooldown, spew_organs ? 55 SECONDS : 15 SECONDS)
