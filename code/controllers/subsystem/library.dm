/// Manages library data, loading bookselves, etc
SUBSYSTEM_DEF(library)
	name = "Library Loading"
	flags = SS_NO_FIRE

	/// List of bookselves to prefill with books
	var/list/shelves_to_load = list()
	/// List of book datums that we consider to be "in" any one area.
	var/list/books_by_area = list()

	/// List of acceptable search categories for book consoles
	var/list/search_categories = list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
	/// List of acceptable categories for a book to be
	var/list/upload_categories = list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion")

	/// List of poster typepaths we're ok with being printable
	var/list/printable_posters = list()
	/// List of areas that count as "a library", modified by map config
	var/list/library_areas = list()

/datum/controller/subsystem/library/Initialize()
	prepare_official_posters()
	prepare_library_areas()
	load_shelves()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/library/proc/load_shelves()
	var/list/datum/callback/load_callbacks = list()

	for(var/obj/structure/bookcase/case_to_load as anything in shelves_to_load)
		if(!case_to_load)
			stack_trace("A null bookcase somehow ended up in SSlibrary's shelves_to_load list. Did something harddel?")
			continue
		load_callbacks += CALLBACK(case_to_load, TYPE_PROC_REF(/obj/structure/bookcase, load_shelf))
	shelves_to_load = null

	//Load all of the shelves asyncronously at the same time, blocking until the last one is finished.
	callback_select(load_callbacks, savereturns = FALSE)

/// Returns a list of copied book datums that we consider to be "in" the passed in area at roundstart
/datum/controller/subsystem/library/proc/get_area_books(area/book_parent)
	var/list/areas = list(book_parent.type)
	// If we have an area that's in the global libraries list, we want all the others too
	if(length(areas & library_areas))
		areas |= library_areas

	var/list/books = list()
	for(var/area_type in areas)
		for(var/datum/book_info/info in books_by_area[area_type])
			books += info.return_copy()

	return books

/datum/controller/subsystem/library/proc/prepare_official_posters()
	printable_posters = list()
	for(var/obj/structure/sign/poster/official/poster_type as anything in subtypesof(/obj/structure/sign/poster/official))
		if (initial(poster_type.printable) == TRUE) //Mostly this check exists to keep directionals from ending up in the printable list
			printable_posters[initial(poster_type.name)] = poster_type

/datum/controller/subsystem/library/proc/prepare_library_areas()
	library_areas = typesof(/area/station/service/library) - /area/station/service/library/abandoned
	var/list/additional_areas = SSmapping.current_map.library_areas
	if(additional_areas)
		library_areas += additional_areas
