/mob/living/simple_animal/bot/medbot/Destroy()
	unsync_research_servers()
	return ..()

/mob/living/simple_animal/bot/medbot/unsync_research_servers()
	if(linked_techweb)
		linked_techweb.connected_machines -= src
		linked_techweb = null

/mob/living/simple_animal/bot/medbot/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(linked_techweb && !QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb)) //disconnect old one
		linked_techweb.connected_machines -= src
	. = ..()
	if(.)
		linked_techweb.connected_machines += src //connect new one
		say("Linked to Server!")
		return TRUE
