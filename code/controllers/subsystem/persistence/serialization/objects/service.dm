// only save papers on noticeboards, folders, clipboards for now to reduce spam
GLOBAL_LIST_INIT(saveable_paper_container_whitelist, typecacheof(list(
	/obj/structure/noticeboard,
	/obj/item/folder,
	/obj/item/clipboard,
	/obj/structure/filingcabinet,
	)))

/obj/item/paper/is_saveable(turf/current_loc, list/obj_blacklist)
	if(is_empty())
		return FALSE

	if(!is_type_in_typecache(loc, GLOB.saveable_paper_container_whitelist))
		return FALSE

	return ..()

/obj/item/paper/get_custom_save_vars(save_flags=ALL)
	. = ..()
	// this is a really dumbed down version of saving that strips out stamps, pen types, fields, etc.
	// later a similar version of SSpersistence.save_message_bottle() that uses a json database would be ideal
	.[NAMEOF(src, default_raw_text)] = get_raw_text()
	return .

// seeds are easily spammable
/obj/item/seeds/get_save_vars(save_flags=ALL)
	return FALSE

// grown fruit is also spammable
/obj/item/food/grown/get_save_vars(save_flags=ALL)
	return FALSE
