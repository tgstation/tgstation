/datum/unit_test/leash
	abstract_type = /datum/unit_test/leash
	priority = TEST_LONGER

	var/atom/movable/owner
	var/atom/movable/pet

	var/max_distance = 3

	var/forcibly_teleported = FALSE
	var/datum/leash_wait/leash_wait

/datum/unit_test/leash/New()
	. = ..()

	owner = allocate(/obj/item/pen)
	pet = allocate(/obj/item/pen)

	pet.AddComponent(/datum/component/leash, owner, max_distance)

	RegisterSignal(pet, COMSIG_LEASH_FORCE_TELEPORT, PROC_REF(on_leash_force_teleport))
	RegisterSignal(pet, COMSIG_LEASH_PATH_STARTED, PROC_REF(on_leash_path_started))
	RegisterSignal(pet, COMSIG_LEASH_PATH_COMPLETE, PROC_REF(on_leash_path_complete))

/datum/unit_test/leash/Destroy()
	QDEL_NULL(owner)
	QDEL_NULL(pet)

	return ..()

/datum/unit_test/leash/proc/on_leash_force_teleport()
	SIGNAL_HANDLER
	forcibly_teleported = TRUE

/datum/unit_test/leash/proc/on_leash_path_complete()
	SIGNAL_HANDLER
	leash_wait?.completed()

/datum/unit_test/leash/proc/on_leash_path_started()
	SIGNAL_HANDLER
	leash_wait?.started()

/datum/unit_test/leash/proc/move_away(atom/movable/mover, distance)
	RETURN_TYPE(/datum/leash_wait)
	leash_wait = new

	for (var/_ in 1 to distance)
		mover.Move(get_step(mover, EAST))

	return leash_wait

/datum/leash_wait
	var/completed = FALSE
	var/started = FALSE

	var/timed_out = FALSE

/datum/leash_wait/New()
	addtimer(VARSET_CALLBACK(src, timed_out, TRUE), 80 SECONDS)

/datum/leash_wait/proc/completed()
	completed = TRUE

/datum/leash_wait/proc/started()
	started = TRUE

/datum/leash_wait/proc/assert_unmoved()
	ASSERT(!started, "Leash started to move when it should not have")

/datum/leash_wait/proc/wait()
	ASSERT(started, "Leash doesn't plan on moving")

	UNTIL(completed || timed_out)
	ASSERT(!timed_out, "Waiting for leash movement timed out, it didn't want to move")

/// Validates the leash component will keep its parent within range without teleporting
/// when possible.
/datum/unit_test/leash/no_teleport

/datum/unit_test/leash/no_teleport/Run()
	move_away(owner, 1).assert_unmoved()
	TEST_ASSERT_EQUAL(get_dist(owner, pet), 1, "Pet should not have moved")

	move_away(owner, max_distance).wait() // max_distance + 1 = we move closer, but don't teleport
	TEST_ASSERT_EQUAL(get_dist(owner, pet), max_distance, "Pet should have stayed directly outside range of owner")

	TEST_ASSERT(!forcibly_teleported, "Pet should not have been forcibly teleported")

/// Validates that the leash component will forcibly teleport when necessary
/datum/unit_test/leash/will_teleport

/datum/unit_test/leash/will_teleport/Run()
	leash_wait = new
	owner.forceMove(locate(1, 1, 1))
	leash_wait.wait()
	TEST_ASSERT(forcibly_teleported, "Pet should have been forcibly teleported, since they are too far away with no valid path")

/// Validates that the leashed object cannot move outside of the max distance from owner
/datum/unit_test/leash/limit_range

/datum/unit_test/leash/limit_range/Run()
	move_away(pet, max_distance + 1)
	TEST_ASSERT_EQUAL(get_dist(owner, pet), max_distance, "Pet should not have moved farther than max_distance")
