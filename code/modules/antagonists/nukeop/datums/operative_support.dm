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
	gear_to_deliver += /obj/item/stack/sheet/glass/fifty
	gear_to_deliver += /obj/item/stack/sheet/iron/fifty
	gear_to_deliver += /obj/item/stack/cable_coil/thirty

	for(var/atom/thing_to_deliver in gear_to_deliver)
		new thing_to_deliver(owner_turf)

/datum/antagonist/nukeop/support/get_spawnpoint()
	return pick(GLOB.nukeop_overwatch_start)

/datum/antagonist/nukeop/support/proc/send_cameras()
	for(var/datum/mind/teammate_mind in nuke_team.members)
		teammate_mind.current.AddComponent( \
			/datum/component/simple_bodycam, \
			camera_name = "operative bodycam", \
			c_tag = "[teammate_mind.current.real_name]", \
			network = OPERATIVE_CAMERA_NET, \
			emp_proof = FALSE, \
		)
		teammate_mind.current.playsound_local(get_turf(owner.current), 'sound/weapons/egloves.ogg', 100, 0, use_reverb = FALSE)
		to_chat(span_notice("A Syndicate Overwatch Agent has been assigned to your team. Smile, you're on camera!"))

/datum/antagonist/nukeop/support/give_uplink()
	return
