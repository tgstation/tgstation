/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to operating tables within its line of sight for surgical tech advancement."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating

/obj/machinery/computer/operating/Destroy()
	unsync_research_servers()
	return ..()

/obj/machinery/computer/operating/unsync_research_servers()
	if(linked_techweb)
		linked_techweb.connected_machines -= src
		linked_techweb = null

/obj/machinery/computer/operating/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(linked_techweb && !QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb)) //disconnect old one
		linked_techweb.connected_machines -= src
		experiment_handler.unlink_techweb()
	. = ..()
	if(.)
		linked_techweb.connected_machines += src //connect new one
		experiment_handler.link_techweb(linked_techweb)
		say("Linked to Server!")
		return TRUE
