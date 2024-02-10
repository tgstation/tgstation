/mob/living/carbon/update_body(is_creating = FALSE)
	. = ..()
	dna?.update_body_height()
