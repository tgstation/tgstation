/datum/antagonist/nukeop/support
	name = ROLE_OPERATIVE_OVERWATCH
	show_to_ghosts = TRUE
	send_to_spawnpoint = TRUE
	nukeop_outfit = /datum/outfit/syndicate/support

/datum/antagonist/nukeop/support/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/machines/printer.ogg', 100, 0, use_reverb = FALSE)
	to_chat(owner, span_big("You are a [name]! You've been temporarily assigned to provide camera overwatch and manage communications for a nuclear operative team!"))
	to_chat(owner, span_red("Use your tools to set up your equipment however you like, but do NOT attempt to leave your outpost."))
	owner.announce_objectives()

/datum/antagonist/nukeop/support/on_gain() //All consoles and gear they should get should be in here
	..()
	var/turf/owner_turf = get_turf(owner) //We use this location multiple times so we might as well just call get_turf once
	var/list/gear_to_deliver = list()
	gear_to_deliver += /obj/item/storage/toolbox/mechanical

	for(var/atom/thing_to_deliver in gear_to_deliver)
		new thing_to_deliver(owner_turf)

/datum/antagonist/nukeop/support/get_spawnpoint()
	return pick(GLOB.nukeop_overwatch_start)

	/obj/machinery/computer/crew/remote
	name = "station crew monitoring console"
	desc = "Remotely accesses the station camera net, allowing you to spy on the crew no matter where you are!"
	icon_screen = "tcboss"
	icon_keyboard = "syndie_key"
	circuit = /obj/item/circuitboard/computer/crew/remote
	light_color = LIGHT_COLOR_BLOOD_MAGIC

/obj/machinery/computer/crew/remote/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	z_level_focus = GLOB.station_levels_cache[1]
