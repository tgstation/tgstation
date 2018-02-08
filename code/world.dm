//This file is just for the necessary /world definition
//Try looking in game/world.dm

/world
	mob = /mob/living/carbon/human/lobby
	turf = /turf/open/space/basic
	area = /area/space
	view = "15x15"
	hub = "Exadv1.spacestation13"
	name = "/tg/ Station 13"
	fps = 20
#ifdef FIND_REF_NO_CHECK_TICK
	loop_checks = FALSE
#endif
