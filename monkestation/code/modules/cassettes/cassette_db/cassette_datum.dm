/datum/cassette_data
	var/cassette_name
	var/cassette_author
	var/cassette_desc
	var/cassette_author_ckey

	var/cassette_design_front
	var/cassette_design_back

	var/list/songs

	var/list/song_names

	var/cassette_id
	var/approved
	var/file_name


/datum/cassette_data/proc/populate_data(file_id)
	var/file = file("data/cassette_storage/[file_id].json")
	if(!fexists(file))
		return FALSE
	var/list/data = json_decode(file2text(file))

	cassette_name = data["name"]
	cassette_desc = data["desc"]

	cassette_design_front = data["side1_icon"]
	cassette_design_back = data["side2_icon"]

	songs = data["songs"]

	song_names = data["song_names"]

	cassette_author = data["author_name"]
	cassette_author_ckey = data["author_ckey"]

	cassette_id = file_id

	approved = data["approved"]

	file_name = "data/cassette_storage/[file_id].json"

	return TRUE

/datum/cassette_data/proc/generate_cassette(turf/location)
	if(!location)
		return
	var/obj/item/device/cassette_tape/new_tape = new(location)
	new_tape.name = cassette_name
	new_tape.cassette_desc_string = cassette_desc
	new_tape.icon_state = cassette_design_front
	new_tape.side1_icon = cassette_design_front
	new_tape.side2_icon = cassette_design_back
	new_tape.songs = songs
	new_tape.song_names = song_names
	new_tape.author_name = cassette_author
	new_tape.ckey_author = cassette_author_ckey
	new_tape.approved_tape = approved

	new_tape.update_appearance()
