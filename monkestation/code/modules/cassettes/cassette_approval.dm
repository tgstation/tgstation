/proc/submit_cassette_for_review(obj/item/device/cassette_tape/submitted, mob/user)
	if(!user.client)
		return
	var/datum/cassette_review/new_review = new
	new_review.submitter = user
	new_review.submitted_ckey = user.client.ckey
	for(var/num = 0 in length(submitted.song_names["side1"]), num++)
		new_review.cassette_data["side1"] += list(
			submitted.song_names["side1"][num],
			submitted.songs["side1"][num]
		)
	for(var/num = 0 in length(submitted.song_names["side2"]), num++)
		new_review.cassette_data["side2"] += list(
			submitted.song_names["side2"][num],
			submitted.songs["side2"][num]
		)
	if(!length(new_review.cassette_data))
		return
	new_review.id = "[random_string(4, GLOB.hex_characters)]_[new_review.submitted_ckey]"
	new_review.submitted_tape = submitted


/datum/cassette_review
	///the cassette_id random 4 characters + _submitted_ckey
	var/id
	///the submitting mob
	var/mob/submitter
	///the submitted mobs ckey
	var/submitted_ckey
	///the list of youtube links with the titles beside them as double list ie 1 = list(name, link)
	var/list/cassette_data = list(
		"side1" = list(),
		"side2" = list()
	)
	var/obj/item/device/cassette_tape/submitted_tape

/datum/cassette_review/Destroy(force, ...)
	. = ..()
	QDEL_LIST(cassette_data)
	submitter = null


/obj/item/device/cassette_tape/proc/generate_cassette_json()
	if(approved_tape)
		return
	if(!length(GLOB.approved_ids))
		GLOB.approved_ids = json_decode(file2text("data/cassette_storage/ids.json"))
	var/list/data = list()
	data["name"] = name
	data["desc"] = desc
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
