/datum/component/wormborn

/datum/component/wormborn/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/wormborn/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(second_breath))

/datum/component/wormborn/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)

/datum/component/wormborn/proc/second_breath(mob/living/source)
	SIGNAL_HANDLER

	if(get_area(source) == GLOB.areas_by_type[/area/centcom/wizard_station])
		return
	source.buckled?.unbuckle_mob(source, force = TRUE)

	if(source.movement_type & VENTCRAWLING)
		source.forceMove(get_turf(source))

	var/mob/living/worm = new /mob/living/basic/heretic_summon/armsy/wizard(get_turf(source))
	source.mind?.transfer_to(worm)
	source.forceMove(worm)

/mob/living/basic/heretic_summon/armsy/wizard
	icon_state = "wizard_start"
	icon_living = "wizard_start"
	base_icon_state = "wizard"
	maxHealth = 200
	health = 200
	back = /mob/living/basic/heretic_summon/armsy/wizard
