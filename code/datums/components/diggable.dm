/// Lets you make hitting a turf with a shovel pop something out, and scrape the turf
/datum/component/diggable
	/// Typepath to spawn on hit
	var/datum/to_spawn
	/// What should we tell the user they did?
	var/action_text

/datum/component/diggable/Initialize(to_spawn, action_text)
	. = ..()
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE

	src.to_spawn = to_spawn
	src.action_text = action_text
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/handle_attack)

/datum/component/diggable/proc/handle_attack(datum/source, /obj/item/hit_by, /mob/living/bastard, params)
	if(!hit_by.tool_behaviour == TOOL_SHOVEL || !params)
		return
	var/turf/parent_turf = parent
 	new /obj/item/stack/sheet/mineral/snow(parent_turf, 2)
	user.visible_message(span_notice("[user] digs up [parent_turf]."), span_notice("You [action_text] [parent_turf]."))
	playsound(parent_turf, 'sound/effects/shovel_dig.ogg', 50, TRUE)
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
