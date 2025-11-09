/// instead of hitting with heavy object, we shove 'em
/mob/living/basic/illusion/shover

/mob/living/basic/illusion/shover/on_preattack(mob/living/source, atom/attacked_target)
	. = ..()
	if(disarm(attacked_target))
		return COMPONENT_HOSTILE_NO_ATTACK

/// designed to run away as fast as possible
/mob/living/basic/illusion/escape
	ai_controller = /datum/ai_controller/basic_controller/illusion/escape

/// a mirage with a little more flair
/mob/living/basic/illusion/mirage
	density = FALSE

/mob/living/basic/illusion/mirage/death(gibbed)
	do_sparks(rand(3, 6), FALSE, src)
	return ..()
