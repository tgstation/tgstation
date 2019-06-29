/mob/living/carbon/human/proc/handle_vamp_biting(var/mob/living/carbon/human/M)
	if(!is_vampire(M) || M == src || M.zone_selected != "head")
		return FALSE
	var/datum/antagonist/vampire/V = M.mind.has_antag_datum(/datum/antagonist/vampire)
	if((NOBLOOD in dna.species.species_traits) || dna.species.exotic_blood || !blood_volume)
		to_chat(M, "<span class='warning'>They have no blood!</span>")
		return FALSE
	if(is_vampire(src))
		to_chat(M, "<span class='warning'>Your fangs fail to pierce [name]'s cold flesh</span>")
		return FALSE
	if(dna.species.name == "skeleton")
		to_chat(M, "<span class='warning'>There is no blood in a skeleton!</span>")
		return FALSE
	if(!ckey)
		to_chat(M, "<span class='warning'>[src]'s blood is stale and useless.</span>")
		return FALSE
	if(V.draining)
		return FALSE
	V.handle_bloodsucking(src)
	return TRUE
