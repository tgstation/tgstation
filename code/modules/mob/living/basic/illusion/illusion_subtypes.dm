/// instead of hitting with heavy object, we shove 'em
/mob/living/basic/illusion/shover

/mob/living/basic/illusion/shover/on_preattack(mob/living/source, atom/attacked_target)
	. = ..()
	if(disarm(attacked_target))
		return COMPONENT_HOSTILE_NO_ATTACK

/// designed to run away as fast as possible
/mob/living/basic/illusion/escape
	target_key = BB_BASIC_MOB_FLEE_TARGET
	ai_controller = /datum/ai_controller/basic_controller/illusion/escape

/mob/living/basic/illusion/escape/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/// will run away but isn't afraid to get some punches in as it gets out of dodge
/mob/living/basic/illusion/escape/retaliate
	ai_controller = /datum/ai_controller/basic_controller/illusion/escape/retaliate

/mob/living/basic/illusion/escape/on_preattack(mob/living/source, atom/attacked_target)
	. = ..()
	var/mob/living/parent_mob = parent_mob_ref?.resolve()
	if(attacked_target == parent_mob) // we don't want to get our wires crossed and attack our owner ever.
		return COMPONENT_HOSTILE_NO_ATTACK

/// a mirage with a little more flair. not meant to move just to look cool
/mob/living/basic/illusion/mirage
	ai_controller = null
	density = FALSE

/mob/living/basic/illusion/mirage/death(gibbed)
	do_sparks(rand(3, 6), FALSE, src)
	return ..()
