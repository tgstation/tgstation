#define PAINTINGS_DATA_FORMAT_VERSION 2

// Patronage thresholds for paintings. Different cosmetic frames become available as more credits are spent on the patronage.
#define PATRONAGE_OK_FRAME PAYCHECK_CREW * 3 // 150 credits, as of march 2022
#define PATRONAGE_NICE_FRAME PATRONAGE_OK_FRAME * 2.5
#define PATRONAGE_GREAT_FRAME PATRONAGE_NICE_FRAME * 2
#define PATRONAGE_EXCELLENT_FRAME PATRONAGE_GREAT_FRAME * 2
#define PATRONAGE_AMAZING_FRAME PATRONAGE_EXCELLENT_FRAME * 2
#define PATRONAGE_SUPERB_FRAME PATRONAGE_AMAZING_FRAME * 2
#define PATRONAGE_LEGENDARY_FRAME PATRONAGE_SUPERB_FRAME * 2

/*
{
	"version":2
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
			"medium" : "Oil on canvas",
			"frame_type" : "bones"
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
	/// The appearance of the frame overlay that appears when the painting if framed.
	var/frame_type = "simple"
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
	patron_name = json_data["patron_name"]
	credit_value = json_data["credit_value"]
	width = json_data["width"]
	height = json_data["height"]
	medium = json_data["medium"]
	frame_type = json_data["frame_type"]
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
	new_data["frame_type"] = frame_type
	return new_data

SUBSYSTEM_DEF(persistent_paintings)
	name = "Persistent Paintings"
	init_order = INIT_ORDER_PERSISTENT_PAINTINGS
	flags = SS_NO_FIRE

	/// A list of painting frames that this controls
	var/list/obj/structure/sign/painting/painting_frames = list()
	/// Hashes of paintings deleted this round
	var/list/deleted_paintings_md5s = list()

	/// A list of /datum/paintings saved or ready to be saved this round.
	var/list/paintings = list()

	///The list of available frame reskins (they are purely cosmetic) and the associated patronage amount required for them.
	var/list/frame_types_by_patronage_tier = list(
		"simple" = 0,
		"iron" = PATRONAGE_OK_FRAME,
		"bamboo" = PATRONAGE_OK_FRAME,
		"bones" = PATRONAGE_OK_FRAME,
		"bronze" = PATRONAGE_NICE_FRAME,
		"clown" = PATRONAGE_NICE_FRAME,
		"frog" = PATRONAGE_NICE_FRAME,
		"silver" = PATRONAGE_GREAT_FRAME,
		"necropolis" = PATRONAGE_GREAT_FRAME,
		"gold" = PATRONAGE_EXCELLENT_FRAME,
		"diamond" = PATRONAGE_AMAZING_FRAME,
		"rainbow" = PATRONAGE_SUPERB_FRAME,
		"supermatter" = PATRONAGE_LEGENDARY_FRAME
			)

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

/**
 * Generates painting data ready to be consumed by ui.
 * Args:
 * * filter: a bitfield argument is used to filter out paintings that don't match certain requisites.
 * * admin : whether all the json data of the painting is added to the return value or only the more IC details
 * * search_text : text to search for if the PAINTINGS_FILTER_SEARCH_TITLE or PAINTINGS_FILTER_SEARCH_CREATOR filters are enabled.
 */
/datum/controller/subsystem/persistent_paintings/proc/painting_ui_data(filter=NONE, admin=FALSE, search_text)
	. = list()
	var/searching = filter & (PAINTINGS_FILTER_SEARCH_TITLE|PAINTINGS_FILTER_SEARCH_CREATOR) && search_text
	for(var/datum/painting/painting as anything in paintings)
		if(filter & PAINTINGS_FILTER_AI_PORTRAIT && ((painting.width != 24 && painting.width != 23) || (painting.height != 24 && painting.height != 23)))
			continue
		if(searching)
			var/haystack_text = ""
			if(filter & PAINTINGS_FILTER_SEARCH_TITLE)
				haystack_text = painting.title
			else if(filter & PAINTINGS_FILTER_SEARCH_CREATOR)
				haystack_text = painting.creator_name
			if(!findtext(haystack_text, search_text))
				continue
		if(admin)
			var/list/pdata = painting.to_json()
			pdata["ref"] = REF(painting)
			. += list(pdata)
		else
			. += list(list(
				"title" = painting.title,
				"creator" = painting.creator_name,
				"md5" = painting.md5,
				"ref" = REF(painting),
				"ratio" = painting.width/painting.height,
				))

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

	var/version = current_data["version"]
	if(version < 1)
		current_data =  migrate_to_version_1(current_data)
	if(version < 2) //Makes sure old paintings get a cosmetic frame type from their patronage tiers.
		current_data =  migrate_to_version_2(current_data)

	return current_data

/datum/controller/subsystem/persistent_paintings/proc/migrate_to_version_1(list/current_data)
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
	return result

/datum/controller/subsystem/persistent_paintings/proc/migrate_to_version_2(list/current_data)
	fcopy("data/paintings.json","data/paintings_migration_backup_1.json") //Better safe than sorry
	current_data["version"] = 2
	for(var/painting_data in current_data["paintings"])
		painting_data["tags"] |= "Migrated from version 1"
		var/credit_value = painting_data["credit_value"]
		var/list/possible_frame_types = get_available_frames(credit_value, only_current_tier = TRUE)
		painting_data["frame_type"] = pick(possible_frame_types) || "simple"
	return current_data

/**
 * returns a list of cosmetic frames which patronage tier values are are within credit_value.
 * If only_current_tier is TRUE, the list will be populated only by the ones from the highest tier.
 */
/datum/controller/subsystem/persistent_paintings/proc/get_available_frames(credit_value, only_current_tier = FALSE)
	var/list/frame_candidates = list()
	var/current_tier_patronage = 0
	for(var/frametype in frame_types_by_patronage_tier)
		var/required_patronage = frame_types_by_patronage_tier[frametype]
		if(credit_value >= required_patronage)
			if(only_current_tier && current_tier_patronage < required_patronage)
				current_tier_patronage = required_patronage
				frame_candidates.Cut()
			frame_candidates += frametype
	return frame_candidates

/// Saves all persistent paintings
/datum/controller/subsystem/persistent_paintings/proc/save_paintings()
	// Collect new painting data
	for(var/obj/structure/sign/painting/painting_frame as anything in painting_frames)
		painting_frame.save_persistent()

	save_to_file()

/// Saves all currently tracked painting data to file
/datum/controller/subsystem/persistent_paintings/proc/save_to_file()
	var/json_file = file("data/paintings.json")

	var/list/collated_data = list()
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		for(var/list/painting_data as anything in old_data["paintings"])
			collated_data[painting_data["md5"]] = painting_data

	var/list/painting_data = list()
	for(var/datum/painting/painting as anything in paintings)
		collated_data[painting.md5] = painting.to_json() //Current data has priority over old data

	// Remove deleted paintings from the list
	collated_data -= deleted_paintings_md5s

	// Flatten the resulting list
	for(var/key in collated_data)
		painting_data += list(collated_data[key])

	var/list/all_data = list("version" = PAINTINGS_DATA_FORMAT_VERSION)
	all_data["paintings"] = painting_data
	var/payload = json_encode(all_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

#undef PATRONAGE_OK_FRAME
#undef PATRONAGE_NICE_FRAME
#undef PATRONAGE_GREAT_FRAME
#undef PATRONAGE_EXCELLENT_FRAME
#undef PATRONAGE_AMAZING_FRAME
#undef PATRONAGE_SUPERB_FRAME
#undef PATRONAGE_LEGENDARY_FRAME

