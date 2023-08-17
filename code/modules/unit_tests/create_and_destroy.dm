///Delete one of every type, sleep a while, then check to see if anything has gone fucky
/datum/unit_test/create_and_destroy
	//You absolutely must run after (almost) everything else
	priority = TEST_CREATE_AND_DESTROY

GLOBAL_VAR_INIT(running_create_and_destroy, FALSE)
/datum/unit_test/create_and_destroy/Run()
	//We'll spawn everything here
	var/turf/spawn_at = run_loc_floor_bottom_left

	var/list/cached_contents = spawn_at.contents.Copy()
	var/original_turf_type = spawn_at.type
	var/original_baseturfs = islist(spawn_at.baseturfs) ? spawn_at.baseturfs.Copy() : spawn_at.baseturfs
	var/original_baseturf_count = length(original_baseturfs)

	GLOB.running_create_and_destroy = TRUE
	for(var/type_path in typesof(/atom/movable, /turf) - uncreatables) //No areas please
		if(ispath(type_path, /turf))
			spawn_at.ChangeTurf(type_path)
			//We change it back to prevent baseturfs stacking and hitting the limit
			spawn_at.ChangeTurf(original_turf_type, original_baseturfs)
			if(original_baseturf_count != length(spawn_at.baseturfs))
				TEST_FAIL("[type_path] changed the amount of baseturfs from [original_baseturf_count] to [length(spawn_at.baseturfs)]; [english_list(original_baseturfs)] to [islist(spawn_at.baseturfs) ? english_list(spawn_at.baseturfs) : spawn_at.baseturfs]")
				//Warn if it changes again
				original_baseturfs = islist(spawn_at.baseturfs) ? spawn_at.baseturfs.Copy() : spawn_at.baseturfs
				original_baseturf_count = length(original_baseturfs)
		else
			var/atom/creation = new type_path(spawn_at)
			if(QDELETED(creation))
				continue
			//Go all in
			qdel(creation, force = TRUE)
			//This will hold a ref to the last thing we process unless we set it to null
			//Yes byond is fucking sinful
			creation = null

		//There's a lot of stuff that either spawns stuff in on create, or removes stuff on destroy. Let's cut it all out so things are easier to deal with
		var/list/to_del = spawn_at.contents - cached_contents
		if(length(to_del))
			for(var/atom/to_kill in to_del)
				qdel(to_kill)

	GLOB.running_create_and_destroy = FALSE

	// Drastically lower the amount of time it takes to GC, since we don't have clients that can hold it up.
	SSgarbage.collection_timeout[GC_QUEUE_CHECK] = 10 SECONDS
	//Clear it, just in case
	cached_contents.Cut()

	var/list/queues_we_care_about = list()
	// All of em, I want hard deletes too, since we rely on the debug info from them
	for(var/i in 1 to GC_QUEUE_HARDDELETE)
		queues_we_care_about += i

	//Now that we've qdel'd everything, let's sleep until the gc has processed all the shit we care about
	// + 2 seconds to ensure that everything gets in the queue.
	var/time_needed = 2 SECONDS
	for(var/index in queues_we_care_about)
		time_needed += SSgarbage.collection_timeout[index]

	var/start_time = world.time
	var/real_start_time = REALTIMEOFDAY
	var/garbage_queue_processed = FALSE

	sleep(time_needed)
	while(!garbage_queue_processed)
		var/oldest_packet_creation = INFINITY
		for(var/index in queues_we_care_about)
			var/list/queue_to_check = SSgarbage.queues[index]
			if(!length(queue_to_check))
				continue

			var/list/oldest_packet = queue_to_check[1]
			//Pull out the time we inserted at
			var/qdeld_at = oldest_packet[GC_QUEUE_ITEM_GCD_DESTROYED]

			oldest_packet_creation = min(qdeld_at, oldest_packet_creation)

		//If we've found a packet that got del'd later then we finished, then all our shit has been processed
		//That said, if there are any pending hard deletes you may NOT sleep, we gotta handle that shit
		if(oldest_packet_creation > start_time && !length(SSgarbage.queues[GC_QUEUE_HARDDELETE]))
			garbage_queue_processed = TRUE
			break

		if(REALTIMEOFDAY > real_start_time + time_needed + 50 MINUTES) //If this gets us gitbanned I'm going to laugh so hard
			TEST_FAIL("Something has gone horribly wrong, the garbage queue has been processing for well over 30 minutes. What the hell did you do")
			break

		//Immediately fire the gc right after
		SSgarbage.next_fire = 1
		//Unless you've seriously fucked up, queue processing shouldn't take "that" long. Let her run for a bit, see if anything's changed
		sleep(20 SECONDS)

	//Alright, time to see if anything messed up
	var/list/cache_for_sonic_speed = SSgarbage.items
	for(var/path in cache_for_sonic_speed)
		var/datum/qdel_item/item = cache_for_sonic_speed[path]
		if(item.failures)
			TEST_FAIL("[item.name] hard deleted [item.failures] times out of a total del count of [item.qdels]")
		if(item.no_respect_force)
			TEST_FAIL("[item.name] failed to respect force deletion [item.no_respect_force] times out of a total del count of [item.qdels]")
		if(item.no_hint)
			TEST_FAIL("[item.name] failed to return a qdel hint [item.no_hint] times out of a total del count of [item.qdels]")
		if(LAZYLEN(item.extra_details))
			var/details = item.extra_details.Join("\n")
			TEST_FAIL("[item.name] failed with extra info: \n[details]")

	cache_for_sonic_speed = SSatoms.BadInitializeCalls
	for(var/path in cache_for_sonic_speed)
		var/fails = cache_for_sonic_speed[path]
		if(fails & BAD_INIT_NO_HINT)
			TEST_FAIL("[path] didn't return an Initialize hint")
		if(fails & BAD_INIT_QDEL_BEFORE)
			TEST_FAIL("[path] qdel'd in New()")
		if(fails & BAD_INIT_SLEPT)
			TEST_FAIL("[path] slept during Initialize()")

	//This shouldn't be needed, but let's be polite
	SSgarbage.collection_timeout[GC_QUEUE_CHECK] = GC_CHECK_QUEUE
