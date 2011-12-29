// Contains:
//	/datum/text_parser/parser

/datum/text_parser/parser
	var/input_line = ""
	var/mob/speaker

/datum/text_parser/parser/proc/print(line)
	speaker.say(line)

/datum/text_parser/parser/proc/set_name(name)
	speaker.name = name
	speaker.real_name = name

/datum/text_parser/parser/proc/new_session()
	input_line = ""

/datum/text_parser/parser/proc/process_line()
