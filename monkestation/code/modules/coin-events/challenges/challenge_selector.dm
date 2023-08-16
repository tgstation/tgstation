/client
	var/datum/challenge_selector/challenge_menu

/datum/challenge_selector
	/// The client of the person using the UI
	var/client/owner

/datum/challenge_selector/New(user)
	owner = CLIENT_FROM_VAR(user)
	owner.challenge_menu = src

/datum/challenge_selector/Destroy(force, ...)
	owner = null
	return ..()

/datum/challenge_selector/ui_state(mob/user)
	return GLOB.always_state

/datum/challenge_selector/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChallengeSelector", "Select Challenges")
		ui.open()

/datum/challenge_selector/ui_data(mob/user)
	var/list/data = list()
	var/list/buyables = list()
	for(var/datum/challenge/listed as anything in subtypesof(/datum/challenge))
		var/datum/challenge/created = new listed
		buyables += list(
			list(
				"name" = created.challenge_name,
				"payout" = created.challenge_payout,
				"difficulty" = created.difficulty,
				"path" = created.type
			)
		)
	var/list/paths = list()
	for(var/listed as anything in owner.active_challenges)
		if(isnull(listed))
			owner.active_challenges -= listed
			continue
		paths += listed

	data["challenges"] = buyables
	data["selected_challenges"] = paths
	return data

/datum/challenge_selector/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	. = ..()
	if(.)
		return
	switch(action)
		if("select_challenge")
			add_selection(params)
			return TRUE

/datum/challenge_selector/proc/add_selection(list/params)
	if(isliving(usr) || isobserver(usr))
		return

	var/id = params["path"]
	var/path = text2path(id)
	if(!ispath(path, /datum/challenge))
		return

	if(length(usr.client.active_challenges))
		for(var/listed as anything in usr.client.active_challenges)
			if(listed == path)
				usr.client.active_challenges -= listed
				return

	var/datum/challenge/challenge = text2path(id)
	usr.client.active_challenges += challenge
