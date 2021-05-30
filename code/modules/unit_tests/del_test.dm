///Delete one of every type, sleep a while, then check to see if anything has gone fucky
/datum/unit_test/del_test
	//We have special handling, be happy
	snowflake = TRUE

/datum/unit_test/del_test/Run()
	//We'll spawn everything here
	var/turf/spawn_at = run_loc_floor_bottom_left
	var/list/ignore = list(
		//This causes loc fuckery, let's just not
		/atom,
		//Never meant to be created, errors out the ass for mobcode reasons
		/mob/living/carbon,
		//Nother template type, doesn't like being created with no seed
		/obj/item/food/grown,
		//And another
		/obj/item/slimecross/recurring,
		//This should be obvious
		/obj/machinery/doomsday_device,
		//Yet more templates
		/obj/machinery/restaurant_portal
	)
	//This turf existing is an error in and of itself
	ignore += typesof(/turf/baseturf_skipover)
	ignore += typesof(/turf/baseturf_bottom)
	//This demands a borg, so we'll let if off easy
	ignore += typesof(/obj/item/modular_computer/tablet/integrated)
	//This one demands a computer, ditto
	ignore += typesof(/obj/item/modular_computer/processor)
	//Needs special input, let's be nice
	ignore += typesof(/obj/effect/abstract/proximity_checker)
	//Very finiky, blacklisting to make things easier
	ignore += typesof(/obj/item/poster/wanted)
	//We can't pass a mind into this
	ignore += typesof(/obj/item/phylactery)
	//This expects a seed, we can't pass it
	ignore += typesof(/obj/item/food/grown)
	//Nothing to hallucinate if there's nothing to hallicinate
	ignore += typesof(/obj/effect/hallucination)

	var/list/ignore_cache = list()
	for(var/type in ignore)
		ignore_cache[type] = TRUE

	for(var/type_path in typesof(/atom))
		if(ignore_cache[type_path])
			continue
		if(ispath(type_path, /turf))
			spawn_at.ChangeTurf(type_path)
			//We change it back to prevent pain, please don't ask
			spawn_at.ChangeTurf(/turf/open/floor/wood)
		else
			var/atom/creation = new type_path(spawn_at)
			//Go all in
			qdel(creation, force = TRUE)

	//Hell code, we're bound to have ended the round somehow so let's stop if from ending while we work
	SSticker.delay_end = TRUE
	//Prevent the garbage subsystem from harddeling anything, if only to save time
	//SSgarbage.collection_timeout[GC_QUEUE_HARDDELETE] = 10000 HOURS

	//Now that we've qdel'd everything, let's sleep until the gc has processed all the shit we care about
	var/time_needed = SSgarbage.collection_timeout[GC_QUEUE_CHECK]
	var/start_time = world.time
	var/garbage_queue_processed = FALSE

	sleep(time_needed)
	while(!garbage_queue_processed)
		var/list/queue_to_check = SSgarbage.queues[GC_QUEUE_CHECK]
		//How the hell did you manage to empty this? Good job!
		if(!length(queue_to_check))
			garbage_queue_processed = TRUE
			break

		var/list/oldest_packet = queue_to_check[1]
		//Pull out the time we deld at
		var/qdeld_at = oldest_packet[1]
		//If we've found a packet that got del'd later then we finished, then all our shit has been processed
		if(qdeld_at > start_time)
			garbage_queue_processed = TRUE
			break

		if(world.time > start_time + time_needed + 10 MINUTES)
			Fail("Something has gone horribly wrong, the garbage queue has been processing for well over 10 minutes. What the hell did you do")
			return

		//Unless you've seriously fucked up, queue processing shouldn't take "that" long. Let her run for a bit, see if anything's changed
		sleep(20 SECONDS)

	//Alright, time to see if anything messed up
	var/list/cache_for_sonic_speed = SSgarbage.items
	for(var/path in cache_for_sonic_speed)
		var/datum/qdel_item/item = cache_for_sonic_speed[path]
		if(item.failures)
			Fail("[item.name] hard deleted [item.failures] times out of a total del count of [item.qdels]")
		if(item.no_respect_force)
			Fail("[item.name] failed to respect force deletion [item.no_respect_force] times out of a total del count of [item.qdels]")
		if(item.no_hint)
			Fail("[item.name] failed to return a qdel hint [item.no_hint] times out of a total del count of [item.qdels]")

	SSticker.delay_end = FALSE
	//This shouldn't be needed, but let's be polite
	SSgarbage.collection_timeout[GC_QUEUE_HARDDELETE] = 10 SECONDS
