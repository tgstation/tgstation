#define CYBORG_ICON 'modular_bandastation/borgs/icons/robots.dmi'

///ENGINEERING
/obj/item/robot_model/engineering
	borg_skins = list(
		"Landmate" = list(SKIN_ICON_STATE = "engineer", SKIN_ICON = CYBORG_ICON),
		"Landmate - Treads" = list(SKIN_ICON_STATE = "engi-tread", SKIN_LIGHT_KEY = "engineer", SKIN_ICON = CYBORG_ICON),
		"Сhiefmate" = list(SKIN_ICON_STATE = "chiefmate", SKIN_LIGHT_KEY = "engineer", SKIN_ICON = CYBORG_ICON),
		"Can" = list(SKIN_ICON_STATE = "caneng", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(0, 3), "west" = list(0, 3))),
		"Spider" = list(SKIN_ICON_STATE = "spidereng", SKIN_ICON = CYBORG_ICON),
		"EngBot" = list(SKIN_ICON_STATE = "engbot", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1)))
	)

///MEDICAL
/obj/item/robot_model/medical
	borg_skins = list(
		"Machinified Doctor" = list(SKIN_ICON_STATE = "medical", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(-1, 3), "west" = list(1, 3))),
		"Qualified Doctor" = list(SKIN_ICON_STATE = "qualified_doctor", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(1, 3), "west" = list(-1, 3))),
		"СhiefDoctor" = list(SKIN_ICON_STATE = "chiefbot", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(-1, 3), "west" = list(1, 3))),
		"Droid" = list(SKIN_ICON = CYBORG_ICON, SKIN_ICON_STATE = "droid", SKIN_HAT_OFFSET = list("north" = list(0, 4), "south" = list(0, 4), "east" = list(0, 4), "west" = list(0, 4))),
		"MedBot" = list(SKIN_ICON_STATE = "medbot", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1)))
	)

///JANITOR
/obj/item/robot_model/janitor
	borg_skins = list(
		"Mopgearrex" = list(SKIN_ICON_STATE = "janitor", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(-4, -1), "west" = list(4, -1))),
		"Can" = list(SKIN_ICON_STATE = "canjan", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(0, 3), "west" = list(0, 3))),
		"Spider" = list(SKIN_ICON_STATE = "spiderjan", SKIN_ICON = CYBORG_ICON),
		"JanBot" = list(SKIN_ICON_STATE = "janbot", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1)))
	)

///PEACEKEEPER
/obj/item/robot_model/peacekeeper
	borg_skins = list(
		"Peaceborg" = list(SKIN_ICON_STATE = "peace", SKIN_ICON = CYBORG_ICON),
		"Spider" = list(SKIN_ICON_STATE = "whitespider", SKIN_ICON = CYBORG_ICON),
		"PeaceBot" = list(SKIN_ICON_STATE = "peacebot", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1)))
	)

///MINING
/obj/item/robot_model/miner
	special_light_key = null
	borg_skins = list(
		"Lavaland" = list(SKIN_ICON_STATE = "miner", SKIN_ICON = CYBORG_ICON, SKIN_LIGHT_KEY = "miner"),
		"Asteroid" = list(SKIN_ICON_STATE = "minerOLD", SKIN_ICON = CYBORG_ICON, SKIN_LIGHT_KEY = "miner"),
		"Spider Miner" = list(SKIN_ICON_STATE = "spidermin", SKIN_ICON = CYBORG_ICON),
		"Can" = list(SKIN_ICON_STATE = "canmin", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(0, 3), "west" = list(0, 3)))
	)

///SERVICE
/obj/item/robot_model/service
	special_light_key = null
	borg_skins = list(
		"Waitress" = list(SKIN_ICON_STATE = "service_f", SKIN_ICON = CYBORG_ICON, SKIN_LIGHT_KEY = "service", SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1))),
		"Butler" = list(SKIN_ICON_STATE = "service_m", SKIN_ICON = CYBORG_ICON, SKIN_LIGHT_KEY = "service", SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1))),
		"Bro" = list(SKIN_ICON_STATE = "brobot", SKIN_ICON = CYBORG_ICON, SKIN_LIGHT_KEY = "service", SKIN_HAT_OFFSET = list("north" = list(0, -1), "south" = list(0, -1), "east" = list(0, -1), "west" = list(0, -1))),
		"Tophat" = list(SKIN_ICON_STATE = "tophat", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = INFINITY),
		"Kent" = list(SKIN_ICON_STATE = "kent", SKIN_ICON = CYBORG_ICON, SKIN_LIGHT_KEY = "medical", SKIN_HAT_OFFSET = list("north" = list(0, 3), "south" = list(0, 3), "east" = list(0, 3), "west" = list(0, 3))),
		"ARACHNE" = list(SKIN_ICON_STATE = "arachne_service", SKIN_ICON = CYBORG_ICON),
		"Handy" = list(SKIN_ICON_STATE = "handy-service", SKIN_ICON = CYBORG_ICON, SKIN_HAT_OFFSET = INFINITY)
	)
