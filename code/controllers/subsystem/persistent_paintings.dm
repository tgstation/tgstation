#define PAINTINGS_DATA_FORMAT_VERSION 1
/*
{
	"version":1
	"paintings":[
		{
			"md5":"2e117d9d372fb6823bd81d3542a419d6", //unique identifier
			"creator_ckey" : "example",
			"creator_name" : "example",
			"creation_date" : "YYYY-MM-DD hh:mm:ss",
			"creation_round_id": 222,
			"title": "example title",
			"tags": ["library","library_private"],
			"patron_ckey" : "example",
			"patron_name" : "example",
			"credit_value" : 999,
			"width" : 24,
			"height" : 24,
			"medium" : "Oil on canvas"
		},
	]
}
*/

/datum/painting
	/// md5 of the png file, also the filename.
	var/md5
	/// Title
	var/title
	/// Author's ckey
	var/creator_ckey
	/// Author's name
	var/creator_name
	/// Timestamp when painting was made (finalized ?)
	var/creation_date
	/// Round if when the painting was made
	var/creation_round_id
	/// List of this painting string tags if any
	var/list/tags
	/// Patron ckey
	var/patron_ckey
	/// Patron name
	var/patron_name
	/// Amount paid by last patron for this painting
	var/credit_value = 0
	/// painting width
	var/width
	/// painting height
	var/height
	/// short painting medium description
	var/medium
	/// Was the painting loaded from json or created this round
	var/loaded_from_json = FALSE

/datum/painting/proc/load_from_json(list/json_data)
	md5 = json_data["md5"]
	title = json_data["title"]
	creator_ckey = json_data["creator_ckey"]
	creator_name = json_data["creator_name"]
	creation_date = json_data["creation_date"]
	creation_round_id = json_data["creation_round_id"]
	tags = json_data["tags"]
	patron_ckey = json_data["patron_ckey"]
	credit_value = json_data["credit_value"]
	width = json_data["width"]
	height = json_data["height"]
	medium = json_data["medium"]
	loaded_from_json = TRUE

/datum/painting/proc/to_json()
	var/list/new_data = list()
	new_data["md5"] = md5
	new_data["title"] = title
	new_data["creator_ckey"] = creator_ckey
	new_data["creator_name"] = creator_name
	new_data["creation_date"] = creation_date
	new_data["creation_round_id"] = creation_round_id
	new_data["tags"] = tags
	new_data["patron_ckey"] = patron_ckey
	new_data["patron_name"] = patron_name
	new_data["credit_value"] = credit_value
	new_data["width"] = width
	new_data["height"] = height
	new_data["medium"] = medium
	return new_data

/// Only returns paintings with 23x23 or 24x24 sizes fitting AI display icon.
#define PAINTINGS_FILTER_AI_PORTRAIT 1

SUBSYSTEM_DEF(persistent_paintings)
	name = "Persistent Paintings"
	init_order = INIT_ORDER_PERSISTENT_PAINTINGS
	flags = SS_NO_FIRE

	/// A list of painting frames that this controls
	var/list/obj/structure/sign/painting/painting_frames = list()

	/// A list of /datum/paintings saved or ready to be saved this round.
	var/list/paintings = list()

/datum/controller/subsystem/persistent_paintings/Initialize(start_timeofday)
	var/json_file = file("data/paintings.json")
	if(fexists(json_file))
		var/list/raw_data = update_format(json_decode(file2text(json_file)))
		for(var/list/painting_data as anything in raw_data["paintings"])
			var/datum/painting/loaded_painting = new
			loaded_painting.load_from_json(painting_data)
			paintings += loaded_painting

	for(var/obj/structure/sign/painting/painting_frame as anything in painting_frames)
		painting_frame.load_persistent()

	return ..()

/// Generates painting data ready to be consumed by ui
/datum/controller/subsystem/persistent_paintings/proc/painting_ui_data(filter=NONE,admin=FALSE)
	. = list()
	for(var/datum/painting/painting as anything in paintings)
		if(filter & PAINTINGS_FILTER_AI_PORTRAIT && ((painting.width != 24 && painting.width != 23) || (painting.height != 24 && painting.height != 23)))
			continue
		if(admin)
			var/list/pdata = painting.to_json()
			pdata["ref"] = REF(painting)
			. += list(pdata)
		else
			. += list(list("title" = painting.title,"md5" = painting.md5,"ref" = REF(painting)))

/// Returns paintings with given tag.
/datum/controller/subsystem/persistent_paintings/proc/get_paintings_with_tag(tag_name)
	. = list()
	for(var/datum/painting/painting as anything in paintings)
		if(!painting.tags || !(tag_name in painting.tags))
			continue
		. += painting

/// Updates paintings data format to latest if necessary
/datum/controller/subsystem/persistent_paintings/proc/update_format(current_data)
	if(current_data["version"] && current_data["version"] == PAINTINGS_DATA_FORMAT_VERSION)
		return current_data

	var/current_format = current_data["version"] || 0
	switch(current_format)
		if(0)
			fcopy("data/paintings.json","data/paintings_migration_backup_0.json") //Better safe than losing all metadata
			var/list/result = list()
			result["version"] = 1
			var/list/data = list()
			// Squash categories into tags
			for(var/category in current_data)
				for(var/old_data in current_data[category])
					var/duplicate_found = FALSE
					for(var/list/entry in data)
						if(entry["md5"] == old_data["md5"])
							entry["tags"] |= category
							duplicate_found = TRUE
							break
					if(duplicate_found)
						continue
					var/old_png_path = "data/paintings/[category]/[old_data["md5"]].png"
					var/new_png_path = "data/paintings/images/[old_data["md5"]].png"
					fcopy(old_png_path,new_png_path)
					fdel(old_png_path)
					var/icon/painting_icon = new(new_png_path)
					var/width = painting_icon.Width()
					var/height = painting_icon.Height()
					var/list/new_data = list()
					new_data["md5"] = old_data["md5"]
					new_data["title"] = old_data["title"] || "Untitled Artwork"
					new_data["creator_ckey"] = old_data["ckey"] || ""
					new_data["creator_name"] = "Anonymous"
					new_data["creation_date"] = time2text(world.realtime) // Could use creation/modified file helpers in rustg
					new_data["creation_round_id"] = GLOB.round_id
					new_data["tags"] = list(category,"Migrated from version 0")
					new_data["patron_ckey"] = ""
					new_data["patron_name"] = ""
					new_data["credit_value"] = 0
					new_data["width"] = width
					new_data["height"] = height
					new_data["medium"] = "Spraypaint on canvas" //Let's go with most common tool.
					data += list(new_data)
			result["paintings"] = data
			//We're going to save this immidiately this is non-recoverable operation
			var/json_file = file("data/paintings.json")
			fdel(json_file)
			WRITE_FILE(json_file, json_encode(result))
			return update_format(result)

/// Saves all persistent paintings
/datum/controller/subsystem/persistent_paintings/proc/save_paintings()
	// Collect new painting data
	for(var/obj/structure/sign/painting/painting_frame as anything in painting_frames)
		painting_frame.save_persistent()

	save_to_file()

/// Saves all currently tracked painting data to file
/datum/controller/subsystem/persistent_paintings/proc/save_to_file()
	var/json_file = file("data/paintings.json")
	fdel(json_file)
	var/list/all_data = list("version" = PAINTINGS_DATA_FORMAT_VERSION)
	var/list/painting_data = list()
	for(var/datum/painting/painting as anything in paintings)
		painting_data += list(painting.to_json())
	all_data["paintings"] = painting_data
	WRITE_FILE(json_file, json_encode(all_data))
