#define ON_PURRBATION(H) (!(H.dna.features["tail_human"] == "None" && H.dna.features["ears"] == "None"))

/proc/mass_purrbation()
	for(var/M in mob_list)
		if(ishumanbasic(M))
			purrbation_apply(M)
		CHECK_TICK

/proc/mass_remove_purrbation()
	for(var/M in mob_list)
		if(ishumanbasic(M))
			purrbation_remove(M)
		CHECK_TICK

/proc/purrbation_toggle(mob/living/carbon/human/H)
	if(!ishumanbasic(H))
		return
	if(!ON_PURRBATION(H))
		purrbation_apply(H)
		. = TRUE
	else
		purrbation_remove(H)
		. = FALSE

/proc/purrbation_apply(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(ON_PURRBATION(H))
		return
	H << "Something is nya~t right."
	H.dna.features["tail_human"] = "Cat"
	H.dna.features["ears"] = "Cat"
	H.regenerate_icons()
	playsound(get_turf(H), 'sound/effects/meow1.ogg', 50, 1, -1)

/proc/purrbation_remove(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!ON_PURRBATION(H))
		return
	H << "You are no longer a cat."
	H.dna.features["tail_human"] = "None"
	H.dna.features["ears"] = "None"
	H.regenerate_icons()
