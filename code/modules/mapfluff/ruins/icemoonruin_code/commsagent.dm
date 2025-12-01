/obj/item/tape/frozen
	name = "frozen tape"
	desc = "A frozen old tape. The cold has somewhat preserved the recording inside."
	icon_state = "tape_white"
	used_capacity = 10 MINUTES
	storedinfo = list(
		"\[00:04\]Three.",
		"\[00:05\]Years.",
		"\[00:07\]Three FUCKING years in this frozen hellhole",
		"\[00:11\]My mission's supposed to be over already!",
		"\[00:15\]Nanotrasen has left their place to rot for like what,",
		"\[00:20\]8, 9, 10 months? I lost track of it",
		"\[00:25\]This was supposed to be a mission for TWO men,",
		"\[00:29\]But the other agent hasn't even given any signs of waking up...",
		//long silence
		"\[02:00\]I can't do this anymore, man.",
		"\[02:03\]I need to get out,",
		"\[02:06\]Maybe with the gorilla gloves, i could...",
		"\[02:11\]Hm.",
		//shorter silence
		"\[02:34\]I'm gonna go for it.",
		"\[02:37\]If anyone finds this tape,",
		"\[02:40\]whatever the outcome was,",
		"\[02:43\]just know that i didn't regret it."
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
		"\[00:01\]"
	)
