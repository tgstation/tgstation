/mob/living/carbon/human/create_internal_organs()
  internal_organs += new /obj/item/organ/butt
  return ..()

/mob/living/carbon/human/CanSuicide()
	var/datum/mutation/human/HM = GLOB.mutations_list[CLUWNE]
	if(dna.species.id == "tarajan" || dna.species.id == "meeseeks" || HM in dna.mutations)
		return FALSE
	else
		return ..()