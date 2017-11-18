//This file is just for the necessary /world definition
//Try looking in game/world.dm

/world
	mob = /mob/dead/new_player
	turf = /turf/open/space/basic
	area = /area/space
	view = "15x15"
	cache_lifespan = 7
	hub = "Exadv1.spacestation13"
	name = "/tg/ Station 13"
	fps = 20
#ifdef GC_FAILURE_HARD_LOOKUP
	loop_checks = FALSE
#endif
