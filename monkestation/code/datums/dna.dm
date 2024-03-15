/datum/dna
	var/body_height = "Normal"

/datum/dna/proc/update_body_height()
	var/mob/living/carbon/human/human_holder = holder
	if(!istype(human_holder))
		return
	var/height = GLOB.body_heights[body_height]
	if(isnull(height))
		return
	human_holder.set_mob_height(height)

/datum/dna/copy_dna(datum/dna/new_dna)
	. = ..()
	new_dna.body_height = body_height
	new_dna.update_body_height()

/datum/dna/transfer_identity(mob/living/carbon/destination, transfer_SE = FALSE, transfer_species = TRUE)
	. = ..()
	destination.dna.body_height = body_height
	destination.dna.update_body_height()
