/area/centcom/central_command_areas
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING

/area/centcom/tdome
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING

/area/centcom/tdome/arena/actual
	name = "Thunder Dome Arena Area"

/area/centcom/central_command_areas/ghost_spawn
	name = "Centcom Ghost Spawn"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING


/area/centcom/central_command_areas/supply
	area_flags = UNIQUE_AREA | NOTELEPORT | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/pre_shuttle
	name = "Centcomm Pre Shuttle"
	area_flags = UNIQUE_AREA | NOTELEPORT | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/supply
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING | NO_GHOSTS_DURING_ROUND
/area/centcom/central_command_areas/borbop
	name = "Borbop's Bar"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/kitchen
	name = "Papa's Pizzeria"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/medical
	name = "Centcom Medical"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/botany
	name = "Centcom Botany"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA  | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/hall
	name = "Centcom Hall"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/admin_hangout
	name = "Admin Hangout"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING | NO_GHOSTS_DURING_ROUND

/area/centcom/central_command_areas/ghost_blocker
	name = "During Round Ghost Blocker"
	area_flags = NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING | NO_GHOSTS_DURING_ROUND

/area/centcom/central_command_areas/evacuation
	area_flags = NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING | NO_GHOSTS_DURING_ROUND

/area/centcom/central_command_areas/admin
	area_flags = NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING | NO_GHOSTS_DURING_ROUND

/area/centcom/central_command_areas/firing_range
	name = "Centcom Firing Range"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/firing_range_checkpoint_control
	area_flags = UNIQUE_AREA | NOTELEPORT | NO_EXPLOSIONS_DURING

/area/Entered(mob/M)
	. = ..()
	if(!(area_flags & GHOST_AREA) && istype(M, /mob/living/carbon/human/ghost))
		var/mob/living/carbon/human/ghost/mob = M
		mob.move_to_ghostspawn()

	if((area_flags & NO_GHOSTS_DURING_ROUND) && istype(M, /mob/living/carbon/human/ghost) && SSticker.current_state != GAME_STATE_FINISHED)
		var/mob/living/carbon/human/ghost/mob = M
		mob.move_to_ghostspawn()
