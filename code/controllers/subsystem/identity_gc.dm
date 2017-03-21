var/datum/controller/subsystem/identity_gc/SSidentity_gc

#define IDENTITY_GC_MAX_ITERATIONS 3

// Slowly iterates over all minds, cleaning out expired entries in mind.faceprints, mind.voiceprints, and mind.identity_cache
// cleans one mind each fire, intended to be lazy, and slow
/datum/controller/subsystem/identity_gc
	name = "Identity GC"
	priority = 15
	flags = SS_NO_INIT|SS_BACKGROUND|SS_NO_TICK_CHECK

	var/last_cleaned = 0
	var/last_trash = "none"
	var/list/dirty_minds

/datum/controller/subsystem/identity_gc/New()
	dirty_minds = list()
	NEW_SS_GLOBAL(SSidentity_gc)

/datum/controller/subsystem/identity_gc/stat_entry(msg)
	..("M:[last_trash]|C:[last_cleaned]")

/datum/controller/subsystem/identity_gc/fire()
	if(!dirty_minds.len && ticker.minds.len)
		dirty_minds = ticker.minds.Copy()
	var/iterate = TRUE
	var/available_iterations = IDENTITY_GC_MAX_ITERATIONS
	while(iterate)
		iterate = FALSE
		if(dirty_minds.len)
			var/datum/mind/dirty = dirty_minds[dirty_minds.len]
			var/trash_cleaned = 0
			if(QDELETED(dirty))
				iterate = TRUE
			else

				var/list/dirty_cache = dirty.identity_cache
				for(var/dirty_cache_index in dirty_cache)
					var/list/dirty_cache_entry = dirty_cache[dirty_cache_index]
					if(LAZYACCESS(dirty_cache_entry, IDENTITY_CACHE_TIMESTAMP) < world.time - IDENTITY_EXPIRE_TIME)
						dirty_cache -= dirty_cache_index
						trash_cleaned++

				var/list/dirty_edit_tags = dirty.identity_edit_tags
				for(var/dirty_tag_index in dirty_edit_tags)
					var/list/dirty_tag_entry = dirty_edit_tags[dirty_tag_index]
					if(LAZYACCESS(dirty_tag_entry, IDENTITY_EDIT_TAG_TIMESTAMP) < world.time - IDENTITY_EXPIRE_TIME)
						dirty_edit_tags -= dirty_tag_index
						trash_cleaned++

				var/list/dirty_faceprints = dirty.faceprints
				for(var/dirty_faceprint_index in dirty_faceprints)
					var/list/dirty_faceprint_entry = dirty_faceprints[dirty_faceprint_index]
					if(LAZYACCESS(dirty_faceprint_entry, IDENTITY_PRINT_STATE) > IDENTITY_INTERACT && LAZYACCESS(dirty_faceprint_entry, IDENTITY_PRINT_TIMESTAMP) < world.time - IDENTITY_EXPIRE_TIME)
						dirty_faceprints -= dirty_faceprint_index
						trash_cleaned++

				var/list/dirty_voiceprints = dirty.voiceprints
				for(var/dirty_voiceprint_index in dirty_voiceprints)
					var/list/dirty_voiceprint_entry = dirty_voiceprints[dirty_voiceprint_index]
					if(LAZYACCESS(dirty_voiceprint_entry, IDENTITY_PRINT_STATE) > IDENTITY_INTERACT && LAZYACCESS(dirty_voiceprint_entry, IDENTITY_PRINT_TIMESTAMP) < world.time - IDENTITY_EXPIRE_TIME)
						dirty_voiceprints -= dirty_voiceprint_index
						trash_cleaned++

			if(trash_cleaned)
				last_cleaned = trash_cleaned
				last_trash = dirty.name
			else if(available_iterations)
				iterate = TRUE
				available_iterations--
			dirty_minds.len--

#undef IDENTITY_GC_MAX_ITERATIONS
