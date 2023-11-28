/datum/antagonist/spy
	name = "\improper Spy"
	roundend_category = "spies"
	antagpanel_category = "Spy"
	job_rank = ROLE_SPY
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 1
	ui_name = "AntagInfoSpy"
	preview_outfit = /datum/outfit/spy
	/// Whether an uplink has been created (successfully or at all)
	var/uplink_created = FALSE
	/// String displayed in the antag panel pointing the spy to where their uplink is.
	var/uplink_location
	/// Whether we give them some random objetives to aim for.
	var/spawn_with_objectives = TRUE

/datum/antagonist/spy/on_gain()
	. = ..()
	if(!uplink_created)
		create_spy_uplink(owner.current)
	if(spawn_with_objectives)
		give_random_objectives()
		update_static_data(owner.current)

/datum/antagonist/spy/ui_static_data(mob/user)
	var/list/data = ..()
	data["uplink_location"] = uplink_location
	return data

/datum/antagonist/spy/proc/create_spy_uplink(mob/living/carbon/spy)
	if(!iscarbon(spy))
		return

	var/spy_uplink_loc = spy.client?.prefs?.read_preference(/datum/preference/choiced/uplink_location)
	if(isnull(spy_uplink_loc) || spy_uplink_loc == UPLINK_IMPLANT)
		spy_uplink_loc = pick(UPLINK_PEN, UPLINK_PDA)

	var/obj/item/spy_uplink = spy.get_uplink_location(spy_uplink_loc)
	if(isnull(spy_uplink))
		return // melbert todo : Back up case?

	spy_uplink.AddComponent(/datum/component/spy_uplink, spy)
	uplink_created = TRUE
	if(istype(spy_uplink, /obj/item/modular_computer/pda))
		uplink_location = "your PDA"

	else if(istype(spy_uplink, /obj/item/pen))
		if(istype(spy_uplink.loc, /obj/item/modular_computer/pda))
			uplink_location = "your PDA's pen"
		else
			uplink_location = "a pen"

	else if(istype(spy_uplink, /obj/item/radio))
		uplink_location = "your radio headset"

/datum/antagonist/spy/proc/give_random_objectives()
	// melbert todo : make this a json
	var/list/random_garbage = list(
		"Ensure [pick("Engineering", "Research", "Medical")] is [pick("destroyed", "sabotaged", "ruined", "wrecked", "demolished", "obliterated")] by the end of the shift.",
		"Ensure [pick("Security", "Supply", "the bridge")] is [pick("destroyed", "sabotaged", "ruined", "wrecked", "demolished", "obliterated")] by the end of the shift.",
		"Make it difficult, but not impossible to [pick("escape", "leave", "evacuate", "flee", "depart")] the station.",
		"Steal as many [pick("weapons", "tools", "items", "objects", "things")] as you can.",
		"Ensure no rival [pick("agents", "spies", "operatives", "moles", "traitors")] [pick("escape", "leave", "evacuate", "flee", "depart")] the station.",
	)

	for(var/i in 1 to rand(1, 3))
		var/datum/objective/custom/your_mission = new()
		your_mission.owner = owner
		your_mission.explanation_text = "[pick_n_take(random_garbage)] (This objective is untracked, and will auto-succeed - have fun with it!)"
		objectives += your_mission

	if(prob(MARTYR_PROB))
		var/datum/objective/martyr/leave_no_trace = new()
		leave_no_trace.owner = owner
		objectives += leave_no_trace

	else if(prob(HIJACK_PROB))
		var/datum/objective/hijack/steal_the_shuttle = new()
		steal_the_shuttle.owner = owner
		objectives += steal_the_shuttle

	else
		var/datum/objective/escape/gtfo = new()
		gtfo.owner = owner
		objectives += gtfo

/datum/outfit/spy
	name = "Spy (Preview only)"

	uniform = /obj/item/clothing/under/color/black
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/balaclava
	shoes = /obj/item/clothing/shoes/jackboots
