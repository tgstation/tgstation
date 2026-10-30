/// Checks that move loops queued for different times are processed separately, even late into a round
/datum/unit_test/movement_loop_buckets

/datum/unit_test/movement_loop_buckets/Run()
	// These times should be assigned to separate buckets
	var/list/times = list(100001.5, 100002, 100002.5)
	var/list/datum/move_loop/loops = list()
	for(var/time in times)
		var/datum/move_loop/loop = new()
		loop.timer = time
		SSmovement.queue_loop(loop)
		loops += loop

	var/buckets_used = 0
	for(var/list/bucket_info as anything in SSmovement.sorted_buckets)
		if(length(bucket_info[MOVEMENT_BUCKET_LIST] & loops))
			buckets_used++

	for(var/datum/move_loop/loop as anything in loops)
		SSmovement.dequeue_loop(loop)
		qdel(loop)

	TEST_ASSERT_EQUAL(buckets_used, length(loops), "Move loops queued for different times shared a bucket")
