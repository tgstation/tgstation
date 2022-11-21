/**
 * Allow RND machines to be connected via multitool
 * But only if we're connected to science's node by default
 * Check is for stuff like Autolathes.
 */
/obj/machinery/rnd/Destroy()
	unsync_research_servers()
	return ..()

/obj/machinery/rnd/unsync_research_servers()
	if(stored_research)
		stored_research.connected_machines -= src
		stored_research = null

/obj/machinery/rnd/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(stored_research && !QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb)) //disconnect old one
		stored_research.connected_machines -= src
	. = ..()
	if(.)
		stored_research.connected_machines += src //connect new one
		say("Linked to Server!")
		return TRUE

/**
 * Tied to Production
 */
/obj/machinery/rnd/production/update_designs()
	if(!stored_research)
		return
	return ..()
