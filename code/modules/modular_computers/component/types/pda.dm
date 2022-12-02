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

/datum/modular_computer_host/item/pda/New(datum/holder)
	. = ..()
	add_messenger()

/datum/modular_computer_host/item/pda/Destroy(force, ...)
	. = ..()
	remove_messenger()

///Adds ourself to the global list of tablet messengers.
/datum/modular_computer_host/proc/add_messenger()
	GLOB.TabletMessengers += src

///Removes ourselves to the global list of tablet messengers.
/datum/modular_computer_host/proc/remove_messenger()
	GLOB.TabletMessengers -= src

/datum/modular_computer_host/item/pda/proc/ring(ringtone) // bring bring
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		playsound(src, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, TRUE)
	else
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
	physical.visible_message("*[ringtone]*")
