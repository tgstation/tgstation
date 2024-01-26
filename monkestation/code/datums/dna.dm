/datum/dna/proc/update_body_height()
	var/mob/living/carbon/human/human_holder = holder
	if(!istype(holder) || !features["body_height"])
		return
	var/height = GLOB.body_heights[features["body_height"]]
	if(isnull(height))
		return
	human_holder.set_mob_height(height)
