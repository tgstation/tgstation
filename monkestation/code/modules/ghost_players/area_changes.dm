/area/centcom/central_command_areas
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING

/area/centcom/tdome
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING

/area/centcom/tdome/arena/actual
	name = "Thunder Dome Arena Area"

/area/centcom/central_command_areas/ghost_spawn
	name = "Centcom Ghost Spawn"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

/area/Entered(mob/M)
	. = ..()
	if(!(area_flags & GHOST_AREA) && istype(M, /mob/living/carbon/human/ghost))
		var/mob/living/carbon/human/ghost/mob = M
		mob.move_to_ghostspawn()

