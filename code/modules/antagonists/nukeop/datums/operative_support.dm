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
	desc = "Remotely accesses the station's suit sensor network, tracking all signatures on the same level as the disk carrier."
	icon_screen = "tcboss"
	icon_keyboard = "syndie_key"
	circuit = /obj/item/circuitboard/computer/crew/remote
	light_color = LIGHT_COLOR_BLOOD_MAGIC

/obj/machinery/computer/crew/remote/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	recalibrate_focus()

/obj/machinery/computer/crew/remote/ui_interact(action, list/params)
	recalibrate_focus() //If disky has moved, we re-focus on them. Doesn't update live because live tracking would be disorienting.
	..()

///Used to evaluate which z-level of sensors we should be reading out.
/obj/machinery/computer/crew/remote/proc/recalibrate_focus()
	var/obj/item/disk/nuclear/disky = locate() in SSpoints_of_interest.real_nuclear_disks
	if(!disky)
		balloon_alert_to_viewers("no disk located, uh oh!") //Defaults to same z-level as the user.
		return
	z_level_focus = disky.z
	if(!z_level_focus)
		var/turf/turf_to_check = get_turf(disky)
		z_level_focus = turf_to_check.z
