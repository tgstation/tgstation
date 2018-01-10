//This file is just for the necessary /world definition
//Try looking in game/world.dm

/world
	mob = /mob/dead/new_player
	turf = /turf/open/space/basic
	area = /area/space
	view = "15x15"
	hub = "Exadv1.spacestation13"
	name = "/tg/ Station 13"
	fps = 20
<<<<<<< HEAD
	visibility = 1
#ifdef GC_FAILURE_HARD_LOOKUP
=======
#ifdef FIND_REF_NO_CHECK_TICK
>>>>>>> 17c45467da... Fixes FIND_REF_NO_CHECK_TICK not actually disabling world.loop_checks (#34217)
	loop_checks = FALSE
#endif
