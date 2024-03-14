/*
TODO LIST:
- GIVE GEYSERS THEIR OWN SPRITE
- GIVE THE PLASMA EXTRACTION MACHINE ITS OWN SPRITE
- GIVE PIPES THEIR OWN SPRITE (MAYBE ??)
- MAKE IT DIG & GIVE IT REWARDS (MAYBE??) - BASICALLY: https://hackmd.io/6ggJpRGMRs2g4sKxpIBeMA?view
- MAKE IT EXIST IN-GAME SO IT IS SOMETHING PLAYERS CAN ACTUALLY DO
- CHANGE HOW IT IS ACTIVATED. PREFERABLY A BUTTON ON THE CORNERS OR SOMETHING.
*/


/**
 * Base plasma extraction machine
 */
/obj/structure/plasma_extraction_hub
	name = "plasma extraction hub"
	desc = "The hub to a connection of pipes. If there aren't any, then get building!"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	anchored = TRUE
	density = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | INDESTRUCTIBLE

/**
 * Base plasma extraction machine part
 * All parts that don't have a pipe, use this.
 */
/obj/structure/plasma_extraction_hub/part
	///The main pipe that owns us as part of our 3x3 machine.
	var/obj/structure/plasma_extraction_hub/part/pipe/main/pipe_owner

/**
 * Plasma extraction machine pipe
 * There's 3 of these on each plasma extraction machine, one of which is the owner of the rest.
 */
/obj/structure/plasma_extraction_hub/part/pipe
	name = "starting pipe location"
	///List of all pipes connected to this extraction part.
	var/list/obj/structure/liquid_plasma_extraction_pipe/connected_pipes = list()
	///Reference to the 'ending' pipe, the last one to be built. This has to exist for t he machien to work.
	var/obj/structure/liquid_plasma_ending/last_pipe
	///Boolean on whether the extraction hub is currently functioning.
	var/currently_functional = FALSE

/obj/structure/plasma_extraction_hub/part/pipe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pipe_laying, src)

/obj/structure/plasma_extraction_hub/part/pipe/Destroy()
	. = ..()
	last_pipe = null
	QDEL_LIST(connected_pipes)

/**
 * Called when a pipe with a reference to us is destroyed,
 * we'll give the pipe right before it the ability to lay pipes again,
 * then destroy every single pipe made after it, and make sure they are out of our list, too.
 */
/obj/structure/plasma_extraction_hub/part/pipe/proc/on_pipe_destroyed(obj/structure/liquid_plasma_extraction_pipe/broken_pipe)
	var/position_in_list = connected_pipes.Find(broken_pipe)
	var/obj/structure/liquid_plasma_extraction_pipe/previous_pipe = connected_pipes[position_in_list - 1]
	previous_pipe.AddComponent(/datum/component/pipe_laying, src)
	for(var/obj/structure/liquid_plasma_extraction_pipe/part_pipes as anything in connected_pipes)
		var/list_item_in_list = connected_pipes.Find(part_pipes)
		if(list_item_in_list > position_in_list)
			part_pipes.connected_hub = null
			connected_pipes -= part_pipes
			qdel(part_pipes)

	connected_pipes -= broken_pipe
	if(currently_functional)
		stop_drilling() //one of our pipes got destroyed, bitch!! god motherfuckin damn!

/obj/structure/plasma_extraction_hub/part/pipe/proc/start_drilling()
	if(!check_parts())
		return FALSE
	for(var/obj/structure/liquid_plasma_extraction_pipe/part_pipes as anything in connected_pipes)
		part_pipes.pipe_status = PIPE_STATUS_ON
		part_pipes.update_appearance(UPDATE_ICON)
	currently_functional = TRUE

/obj/structure/plasma_extraction_hub/part/pipe/proc/stop_drilling()
	for(var/obj/structure/liquid_plasma_extraction_pipe/part_pipes as anything in connected_pipes)
		part_pipes.pipe_status = PIPE_STATUS_OFF
		part_pipes.update_appearance(UPDATE_ICON)
	currently_functional = FALSE

///Returns whether the pipe is able to drill. If it can't, and it currently is drilling, we'll stop.
/obj/structure/plasma_extraction_hub/part/pipe/proc/check_parts()
	if(!length(connected_pipes))
		return FALSE
	if(!last_pipe)
		return FALSE
	for(var/obj/structure/liquid_plasma_extraction_pipe/part_pipes as anything in connected_pipes)
		//if the pipe isn't perfectly built then it's not valid.
		if(part_pipes.pipe_state != PIPE_STATE_FINE)
			if(currently_functional)
				stop_drilling()
			return FALSE

	return TRUE
