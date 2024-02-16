/area/centcom/central_command_areas
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING

/area/centcom/tdome
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING

/area/centcom/tdome/arena/actual
	name = "Thunder Dome Arena Area"

/area/centcom/central_command_areas/ghost_spawn
	name = "Centcom Ghost Spawn"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_ghostspawn"
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
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "borbop"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/kitchen
	name = "Papa's Pizzeria"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_kitchen"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/medical
	name = "Centcom Medical"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_medical"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/botany
	name = "Centcom Botany"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_botany"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA  | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/hall
	name = "Centcom Hall"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_hall"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/admin_hangout
	name = "Admin Hangout"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_hangout"
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
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_firingrange"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/firing_range_checkpoint_control
	area_flags = UNIQUE_AREA | NOTELEPORT | NO_EXPLOSIONS_DURING

/area/centcom/central_command_areas/arcade
	name = "Centcom Arcade"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_arcade"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_EXPLOSIONS_DURING

// Override that handles teleporting ghost player's mobs back to Centcom ghostspawn, if they try to
// move out of it during the round.
/area/Entered(atom/movable/thing)
	. = ..()

	if(istype(thing, /mob/living/carbon/human/ghost))
		// If this is a ghost, run the teleport checks
		teleport_ghost_mob_if_needed(thing)
	else
		// Else, loop through this thing's contents...
		for(var/atom/movable/atom_inside in thing.get_all_contents())
			if(istype(atom_inside, /mob/living/carbon/human/ghost))
				// ...and for any ghosts, run the checks
				teleport_ghost_mob_if_needed(atom_inside)

// Teleports a ghost's mob to ghostspawn, if this area does not meet certain requirements.
/area/proc/teleport_ghost_mob_if_needed(mob/living/carbon/human/ghost/ghost)
	// We should teleport, if...
	var/should_teleport = FALSE
	// ...this is not an area allowed to be inhabited by ghost characters
	should_teleport |= (!(area_flags & GHOST_AREA))
	// ...this is an area ghosts are prohibited to inhabit during a round, and the round is ongoing
	should_teleport |= ((area_flags & NO_GHOSTS_DURING_ROUND) && SSticker.current_state != GAME_STATE_FINISHED)
	// Note: I realize the above bits seem sort of like the same thing. But in refactoring this, I
	// decided to leave both checks in.

	if(should_teleport)
		ghost.move_to_ghostspawn()
