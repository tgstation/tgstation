/obj/machinery/computer/scan_consolenew/Destroy()
	unsync_research_servers()
	return ..()

/obj/machinery/computer/scan_consolenew/unsync_research_servers()
	if(stored_research)
		stored_research.connected_machines -= src
		stored_research = null

/obj/machinery/computer/scan_consolenew/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(stored_research && !QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb)) //disconnect old one
		stored_research.connected_machines -= src
	. = ..()
	if(.)
		stored_research.connected_machines += src //connect new one
		say("Linked to Server!")
		return TRUE
