
/datum/job/officer/after_spawn(mob/living/carbon/human/H, mob/M)
	var/datum/martial_art/krav_maga/style = new
	style.teach(H)