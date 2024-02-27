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
	send_cameras()
	var/turf/owner_turf = get_turf(owner) //We use this location multiple times so we might as well just call get_turf once
	var/list/gear_to_deliver = list()
	gear_to_deliver += /obj/item/storage/toolbox/mechanical

	for(var/atom/thing_to_deliver in gear_to_deliver)
		new thing_to_deliver(owner_turf)

/datum/antagonist/nukeop/support/get_spawnpoint()
	return pick(GLOB.nukeop_overwatch_start)

/datum/antagonist/nukeop/support/proc/send_cameras()
	var/obj/item/clothing/glasses/sunglasses/spy/overwatch/newglasses = new(src)
	for(var/mob/teammate in nuke_team.members)
		var/obj/item/clothing/accessory/spy_bug/overwatch/newbug = new(teammate)
		teammate.playsound_local(get_turf(owner.current), 'sound/weapons/egloves.ogg', 100, 0, use_reverb = FALSE)
		newbug.linked_glasses = newglasses
		newglasses.linked_bugs += newbug
