/datum/outfit/get_json_data()
	. = ..()
	.["organs"] = organs

/datum/outfit/copy_from(datum/outfit/target)
	. = ..()
	organs = target.organs

/datum/outfit/load_from(list/outfit_data)
	. = ..()
	if(!.)
		return
	var/list/organ_text_paths = outfit_data["organs"]
	organs = list()
	for(var/organ_text_path in organ_text_paths)
		var/organ_type = text2path(organ_text_path)
		if(organ_type)
			organs += organ_type
	return TRUE
