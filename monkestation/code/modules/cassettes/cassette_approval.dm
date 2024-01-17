GLOBAL_LIST_INIT(cassette_reviews, list())

#define ADMIN_OPEN_REVIEW(id) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];open_music_review=[id]'>Open Review</a>)"
/proc/submit_cassette_for_review(obj/item/device/cassette_tape/submitted, mob/user)
	if(!user.client)
		return
	var/datum/cassette_review/new_review = new
	new_review.submitter = user
	new_review.submitted_ckey = user.client.ckey
	for(var/num = 1 to length(submitted.song_names["side1"]))
		new_review.cassette_data["side1"]["song_name"] += submitted.song_names["side1"][num]
		new_review.cassette_data["side1"]["song_url"] += submitted.songs["side1"][num]

	for(var/num = 1 to length(submitted.song_names["side2"]))
		new_review.cassette_data["side2"]["song_name"] += submitted.song_names["side2"][num]
		new_review.cassette_data["side2"]["song_url"] += submitted.songs["side2"][num]

	if(!length(new_review.cassette_data))
		return
	new_review.id = "[random_string(4, GLOB.hex_characters)]_[new_review.submitted_ckey]"
	new_review.submitted_tape = submitted

	GLOB.cassette_reviews["[new_review.id]"] = new_review
	SEND_NOTFIED_ADMIN_MESSAGE('sound/items/bikehorn.ogg', "[span_big(span_admin("[span_prefix("MUSIC APPROVAL:")] <EM>[key_name(user)]</EM> [ADMIN_OPEN_REVIEW(new_review.id)] \
															has requested a review on their cassette."))]")
	to_chat(user, span_notice("Your Cassette has been sent to the Space Board of Music for review, you will be notified when an outcome has been made."))

/obj/item/device/cassette_tape/proc/generate_cassette_json()
	if(approved_tape)
		return
	if(!length(GLOB.approved_ids))
		GLOB.approved_ids = json_decode(file2text("data/cassette_storage/ids.json"))
	var/list/data = list()
	data["name"] = name
	data["desc"] = cassette_desc_string
	data["side1_icon"] = side1_icon
	data["side2_icon"] = side2_icon
	data["author_ckey"] = ckey_author
	data["author_name"] = author_name
	data["approved"] = TRUE
	data["songs"] = songs
	data["song_names"] = song_names

	approved_tape = TRUE
	update_appearance()
	var/json_name = "[random_string(16, GLOB.hex_characters)]_[ckey_author]"

	WRITE_FILE(file("data/cassette_storage/[json_name].json"), json_encode(data))
	var/list/names = json_decode(file2text(file("data/cassette_storage/ids.json")))
	fdel(file("data/cassette_storage/ids.json"))
	names += json_name
	GLOB.approved_ids += json_name
	WRITE_FILE(file("data/cassette_storage/ids.json"), json_encode(names))

/datum/cassette_review
	///the cassette_id random 4 characters + _submitted_ckey
	var/id
	///the submitting mob
	var/mob/submitter
	///the submitted mobs ckey
	var/submitted_ckey
	///the list of youtube links with the titles beside them as double list ie 1 = list(name, link)
	var/list/cassette_data = list(
		"side1" = list(
			"song_name" = list(),
			"song_url" = list()
		),
		"side2" = list(
			"song_name" = list(),
			"song_url" = list()
		)
	)
	var/obj/item/device/cassette_tape/submitted_tape

	var/action_taken = FALSE

/datum/cassette_review/Destroy(force, ...)
	. = ..()
	QDEL_LIST(cassette_data)
	submitter = null

	GLOB.cassette_reviews["[id]"] -= src
	GLOB.cassette_reviews -= id

/datum/cassette_review/ui_state(mob/user)
	return GLOB.always_state

/datum/cassette_review/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(action_taken)
		var/choice = tgui_alert(user, "This tape has already been actioned by another admin do you wish to look it over?", "Cassette Review", list("Yes", "No"))
		if(!choice)
			return
		if(choice == "No")
			return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteReview", "[submitted_ckey]'s Cassette")
		ui.open()

/datum/cassette_review/ui_data(mob/user)
	. = ..()
	var/list/data = list()

	data["ckey"] = submitted_ckey
	data["submitters_name"] = submitter.real_name
	data["side1"] = cassette_data["side1"]
	data["side2"] = cassette_data["side2"]

	return data

/datum/cassette_review/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("approve")
			approve_review(usr)
		if("deny")
			to_chat(submitter, span_warning("You feel a wave of disapointment wash over you, you can tell that your cassette was denied by the Space Board of Music"))
			logger.Log(LOG_CATEGORY_MUSIC, "[submitter]'s tape has been rejected by [usr]", list("approver" = usr.name, "submitter" = submitter.name))
			action_taken = TRUE

/datum/cassette_review/proc/approve_review(mob/user)
	if(!check_rights_for(user.client, R_FUN))
		return
	submitted_tape.generate_cassette_json()
	to_chat(submitter, span_notice("You can feel the Space Board of Music has approved your cassette:[submitted_tape.name]."))
	submitted_tape.forceMove(get_turf(submitter))
	message_admins("[submitter]'s tape has been approved by [user]")
	logger.Log(LOG_CATEGORY_MUSIC, "[submitter]'s tape has been approved by [user]", list("approver" = user.name, "submitter" = submitter.name))
	action_taken = TRUE

/proc/fetch_review(id)
	return GLOB.cassette_reviews[id]

#undef ADMIN_OPEN_REVIEW
