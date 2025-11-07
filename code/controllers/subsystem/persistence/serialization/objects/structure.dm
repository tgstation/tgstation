/obj/structure/noticeboard/on_object_saved(map_string, turf/current_loc)
	for(var/obj/item/paper/paper in contents)
/*
		if(TGM_MAX_OBJ_CHECK)
			continue
		TGM_OBJ_INCREMENT
*/

		TGM_MAP_BLOCK(map_string, paper.type, generate_tgm_metadata(paper))

/obj/structure/closet/get_save_vars()
	. = ..()
	. += NAMEOF(src, welded)
	. += NAMEOF(src, opened)
	. += NAMEOF(src, locked)
	return .
