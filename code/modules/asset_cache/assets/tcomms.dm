/datum/asset/spritesheet/telecomms
	name = "tcomms"

/datum/asset/spritesheet/telecomms/create_spritesheets()
	var/list/inserted_states = list() // No need to send entire `telecomms.dmi`.
	for(var/obj/machinery/telecomms/machine as anything in subtypesof(/obj/machinery/telecomms))
		var/icon_state = machine::icon_state
		if(icon_state in inserted_states)
			continue

		Insert(icon_state, machine::icon, icon_state)
		inserted_states += icon_state
