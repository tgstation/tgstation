/obj/item/tape/frozen
	name = "frozen tape"
	desc = "A frozen old tape. The cold has somewhat preserved the recording inside."
	icon_state = "tape_white"
	used_capacity = 10 MINUTES
	storedinfo = list(
		new /datum/tape_message("00:04", text = "Три."),
		new /datum/tape_message("00:05", text = "Года."),
		new /datum/tape_message("00:07", text = "Три ЧЕРТОВЫХ года в этом морозильнике"),
		new /datum/tape_message("00:11", text = "Моя миссия должна быть закончена уже!"),
		new /datum/tape_message("00:15", text = "Nanotrasen оставил свое место сгнить на как,"),
		new /datum/tape_message("00:20", text = "8, 9, 10 месяцев? Я потерял счет"),
		new /datum/tape_message("00:25", text = "Это была миссия для ДВУХ человек,"),
		new /datum/tape_message("00:29", text = "Но другой агент даже не дает никаких признаков пробуждения..."),
		//long silence
		new /datum/tape_message("02:00", text = "Я не могу этого больше, чел."),
		new /datum/tape_message("02:03", text = "Мне нужно уйти,"),
		new /datum/tape_message("02:06", text = "Может быть, с перчатками гориллы, я могу..."),
		new /datum/tape_message("02:11", text = "Хм."),
		//shorter silence
		new /datum/tape_message("02:34", text = "Я решил рискнуть."),
		new /datum/tape_message("02:37", text = "Если кто-то найдет эту ленту,"),
		new /datum/tape_message("02:40", text = "независимо от исхода,"),
		new /datum/tape_message("02:43", text = "просто знай, что я не пожалел об этом.")
	)
	timestamp = list (
		4 SECONDS,
		5 SECONDS,
		7 SECONDS,
		11 SECONDS,
		15 SECONDS,
		20 SECONDS,
		25 SECONDS,
		29 SECONDS,
		2 MINUTES,
		2 MINUTES + 3 SECONDS,
		2 MINUTES + 6 SECONDS,
		2 MINUTES + 11 SECONDS,
		2 MINUTES + 34 SECONDS,
		2 MINUTES + 37 SECONDS,
		2 MINUTES + 40 SECONDS,
		2 MINUTES + 43 SECONDS
	)

/obj/item/tape/frozen/Initialize(mapload)
	. = ..()
	unspool() // the tape spawns damaged

/obj/item/tape/comms_wall
	icon_state = "tape_red"
	used_capacity = 10 MINUTES
	storedinfo = list(
		new /datum/tape_message("00:01")
	)
