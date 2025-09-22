/// Unit coverage for ai_equipment_reservation datum ensuring expiry and priority helpers behave.

/datum/unit_test/ai_control_reservation_unit/renew_and_defaults
	name = "AI Equipment Reservation: renew enforces default durations and stores priority"

/datum/unit_test/ai_control_reservation_unit/renew_and_defaults/Run()
	var/start_time = world.time
	var/datum/ai_equipment_reservation/reservation = new(null, "crew-profile", 3, 2.5)

	var/initial_delta = reservation.expires_at - start_time
	TEST_ASSERT_EQUAL(initial_delta, round(2.5 * 10), "supplied duration converted to deciseconds")
	TEST_ASSERT_EQUAL(reservation.priority_score, 3, "priority stored during initialization")
	TEST_ASSERT_EQUAL(reservation.profile_id, "crew-profile", "profile id preserved")

	reservation.renew(-1)
	var/default_delta = reservation.expires_at - world.time
	var/expected_default = round(AI_CONTROL_DEFAULT_RESERVATION_SECONDS * 10)
	TEST_ASSERT(default_delta >= expected_default && default_delta <= expected_default + 1, "negative renew falls back to default expiry")

	var/obj/item/test_item = EASY_ALLOCATE()
	reservation.set_equipment(test_item)
	TEST_ASSERT_EQUAL(reservation.get_equipment(), test_item, "weakref resolves to stored equipment")
	reservation.set_equipment(null)
	TEST_ASSERT_NULL(reservation.get_equipment(), "clearing equipment reference nulls weakref")
	QDEL_NULL(test_item)

	return UNIT_TEST_PASSED

/datum/unit_test/ai_control_reservation_unit/expiry_helpers
	name = "AI Equipment Reservation: expiry helpers clamp remaining time"

/datum/unit_test/ai_control_reservation_unit/expiry_helpers/Run()
	var/datum/ai_equipment_reservation/reservation = new
	reservation.expires_at = world.time + 20
	TEST_ASSERT(!reservation.is_expired(world.time), "future expiry should not mark reservation expired")
	TEST_ASSERT_EQUAL(reservation.time_remaining(world.time), 20, "time_remaining returns decisecond delta")
	TEST_ASSERT(reservation.is_expired(reservation.expires_at), "reservation expires when current time reaches expires_at")

	reservation.expires_at = world.time - 5
	TEST_ASSERT(reservation.is_expired(world.time), "past expiry reports as expired")
	TEST_ASSERT_EQUAL(reservation.time_remaining(world.time), 0, "time_remaining clamps to zero for expired reservations")

	return UNIT_TEST_PASSED
