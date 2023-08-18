/obj/item/experi_scanner/multitool_act(mob/living/user, obj/item/multitool/tool)
	var/datum/component/experiment_handler/experiment_handler = GetComponent(/datum/component/experiment_handler)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb)) //disconnect old one
		if(experiment_handler.linked_web)
			experiment_handler.unlink_techweb()
		else
			experiment_handler.link_techweb(tool.buffer, TRUE)
			say("Linked to Server!")
			return TRUE
	. = ..()
