/datum/modular_computer_host/item
	valid_on = /obj/item/modular_computer
	hardware_flag = PROGRAM_TABLET

/datum/modular_computer_host/item/laptop
	valid_on = /obj/item/modular_computer/laptop
	hardware_flag = PROGRAM_LAPTOP

GLOBAL_LIST_EMPTY(TabletMessengers) // a list of all active messengers, similar to GLOB.PDAs (used primarily with ntmessenger.dm)

/datum/modular_computer_host/item/pda
	valid_on = /obj/item/modular_computer/pda // waiting for merge
	has_light = TRUE
	max_capacity = 64
	comp_light_luminosity = 2.3

/datum/modular_computer_host/item/pda/New(datum/holder)
	. = ..()
	add_messenger()

/datum/modular_computer_host/item/pda/Destroy(force, ...)
	. = ..()
	remove_messenger()

/// A simple proc to set the ringtone from a pda.
/datum/modular_computer_host/item/pda/proc/update_ringtone(new_ringtone)
	if(!istext(new_ringtone))
		return
	for(var/datum/computer_file/program/messenger/messenger_app in stored_files)
		messenger_app.ringtone = new_ringtone

///Adds ourself to the global list of tablet messengers.
/datum/modular_computer_host/item/pda/proc/add_messenger()
	GLOB.TabletMessengers += src

///Removes ourselves to the global list of tablet messengers.
/datum/modular_computer_host/item/pda/proc/remove_messenger()
	GLOB.TabletMessengers -= src

/datum/modular_computer_host/item/pda/ui_static_data(mob/user)
	. = ..()
	.["show_imprint"] = TRUE
