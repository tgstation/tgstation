
/obj/item/disk/surgery
	name = "Surgery Procedure Disk"
	desc = "A disk that contains advanced surgery procedures, must be loaded into an Operating Console."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)
	var/list/surgeries

/obj/item/disk/surgery/debug
	name = "Debug Surgery Disk"
	desc = "A disk that contains all existing surgery procedures."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)

/obj/item/disk/surgery/debug/Initialize()
	. = ..()
	surgeries = list()
	var/list/req_tech_surgeries = subtypesof(/datum/component)
	for(var/datum/component/surgery/beep as anything in req_tech_surgeries)
		if(initial(beep.requires_tech))
			surgeries += beep
