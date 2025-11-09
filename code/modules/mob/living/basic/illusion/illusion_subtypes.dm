/mob/living/basic/illusion/escape
	ai_controller = /datum/ai_controller/basic_controller/illusion/escape

/mob/living/basic/illusion/mirage
	density = FALSE

/mob/living/basic/illusion/mirage/death(gibbed)
	do_sparks(rand(3, 6), FALSE, src)
	return ..()
