// Some defines for tracking if the correct cinematic / animation is playing.
#define PLAYING_CORRECT_ANIMATION 2
#define PLAYING_INCORRECT_NUKE_ANIMATION 1
#define NOT_PLAYING_ANIMATION 0

/**
 * Unit tests that a nuke going off plays a cinematic,
 * and that it actually kills people.
 */
/datum/unit_test/nuke_cinematic
	/// Used to track via signal if the correct cinematic / animation is playing.
	var/cinematic_playing = NOT_PLAYING_ANIMATION
	/// Tracks what typepath of cinematic is being played.
	var/cinematic_playing_type

/datum/unit_test/nuke_cinematic/Run()
	var/obj/machinery/nuclearbomb/syndicate/nuke = allocate(/obj/machinery/nuclearbomb/syndicate)
	var/mob/living/carbon/human/nuked = allocate(/mob/living/carbon/human/consistent)
	var/datum/client_interface/mock_client = new
	nuked.mock_client = mock_client
	mock_client.mob = nuked

	var/obj/effect/landmark/observer_start/observer_point = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	TEST_ASSERT_NOTNULL(observer_point, "Nuke cinematic test couldn't find observer spawn to place the nuke.")

	var/turf/turf_on_station = get_turf(observer_point)
	TEST_ASSERT(is_station_level(turf_on_station.z), "Nuke cinematic test didn't get a turf which was located on the station.")

	nuke.forceMove(turf_on_station)
	nuked.forceMove(turf_on_station)

	// Pause the check so we don't, y'know, end the round
	SSticker.roundend_check_paused = TRUE
	RegisterSignal(SSdcs, COMSIG_GLOB_PLAY_CINEMATIC, PROC_REF(check_cinematic))
	// actually_explode calls really_actually_explode which sleeps, so this will take a moment.
	var/nuke_result = nuke.actually_explode()

	TEST_ASSERT_EQUAL(nuke_result, DETONATION_HIT_STATION, "A nuke went off on station, but didn't return DETONATION_HIT_STATION (4). (Got: [nuke_result])")
	TEST_ASSERT(GLOB.station_was_nuked, "A nuke went off on station, but didn't set station_was_nuked.")
	// Reset the nuke var back so we don't end the round
	GLOB.station_was_nuked = FALSE
	SSticker.roundend_check_paused = FALSE

	switch(cinematic_playing)
		if(NOT_PLAYING_ANIMATION)
			TEST_FAIL("No nuke cinematic was played when a nuke was detonated.")

		if(PLAYING_INCORRECT_NUKE_ANIMATION)
			TEST_FAIL("An incorrect cinematic was played on nuke detonation. (Expected: /datum/cinematic/nuke/self_destruct, Got: [cinematic_playing_type])")

	TEST_ASSERT(QDELETED(nuked), "The nuke victim next to the nuke wasn't gibbed by the nuke.")
	TEST_ASSERT(QDELETED(nuke), "The nuke itself was not deleted after successfully exploding.")
	mock_client.mob = null

/// Used to track whenever a cinematic starts playing, so we can check if it's the right one.
/datum/unit_test/nuke_cinematic/proc/check_cinematic(datum/source, datum/cinematic/playing)
	SIGNAL_HANDLER

	cinematic_playing_type = playing.type
	if(istype(playing, /datum/cinematic/nuke/self_destruct))
		cinematic_playing = PLAYING_CORRECT_ANIMATION

	else if(istype(playing, /datum/cinematic/nuke))
		cinematic_playing = PLAYING_INCORRECT_NUKE_ANIMATION

#undef PLAYING_CORRECT_ANIMATION
#undef PLAYING_INCORRECT_NUKE_ANIMATION
#undef NOT_PLAYING_ANIMATION
