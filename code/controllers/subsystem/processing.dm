//for subsystems that do some sort of processing on datums

/datum/subsystem/processing
	name = "Processing"
	can_fire = FALSE

	flags = SS_ABSTRACT

	var/stat_tag = "P" //Used for logging
	var/list/processing_list = list()	//what's processing
	var/list/run_cache = list()	//what's left to process in the next run
	var/delegate	//what the processing call is

/datum/subsystem/processing/stat_entry(append, forward = FALSE)
	if(forward)
		..(append)
	else if(processing_list)
		..("[stat_tag]:[processing_list.len][append]")
	else
		..("[stat_tag]:FIX THIS SHIT")

/datum/subsystem/processing/proc/start_processing(datum/D)
	if(D && !(src in D.processors))
		processing_list += D
		can_fire = TRUE
		return TRUE
	return FALSE

/datum/subsystem/processing/proc/stop_processing(datum/D, killed = FALSE)
	processing_list -= D
	if(!processing_list.len && !(flags & SS_TICKER))
		can_fire = FALSE
	if(!killed && run_cache.len)
		run_cache -= D
	if(D)
		LAZYREMOVE(D.processors, src)

/datum/subsystem/processing/fire(resumed = 0, arg = wait)
	if (!resumed)
		run_cache = processing_list.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/local_cache = run_cache
	var/local_delegate = delegate

	if(local_cache.len)
		if(local_delegate)
			do	//we know local_cache.len will always at least be 1 if we're here
				var/thing = local_cache[local_cache.len]
				local_cache.len--
				if(!thing || call(thing, local_delegate)(arg) == PROCESS_KILL)
					stop_processing(thing, TRUE)
			while (local_cache.len && MC_TICK_CHECK)
		else	//copy pasta to avoid the call()() overhead for 90% of things
			do
				var/datum/thing = local_cache[local_cache.len]
				local_cache.len--
				if(!thing || thing.process(arg) == PROCESS_KILL)
					stop_processing(thing, TRUE)
			while(local_cache.len && MC_TICK_CHECK)

/datum/subsystem/processing/Recover(datum/subsystem/processing/predecessor)
	for(var/I in predecessor.processing_list)
		var/datum/D = I
		D.processors -= predecessor
		D.processors += src
	processing_list = predecessor.processing_list		
	run_cache = predecessor.run_cache

/datum/var/list/processors

/datum/Destroy()
	. = ..()
	for(var/I in processors)
		var/datum/subsystem/processing/SS = I
		SS.stop_processing(src)
	LAZYCLEARLIST(processors)

/datum/proc/process(wait)
	set waitfor = FALSE
	return PROCESS_KILL