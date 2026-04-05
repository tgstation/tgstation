/datum/unit_test/spawn_humans/Run()
	var/locs = block(run_loc_floor_bottom_left, run_loc_floor_top_right)

	for(var/I in 1 to 5)
		allocate(/mob/living/carbon/human/consistent, pick(locs))

	sleep(5 SECONDS)

/// Tests [/mob/living/carbon/human/proc/setup_organless_effects], specifically that they aren't applied when init is done
/datum/unit_test/human_default_traits

/datum/unit_test/human_default_traits/Run()
	var/mob/living/carbon/human/consistent/dummy = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(!HAS_TRAIT_FROM(dummy, TRAIT_AGEUSIA, NO_TONGUE_TRAIT), "Dummy has ageusia on init, when it should've been removed by its default tongue.")
	TEST_ASSERT(!dummy.is_blind_from(NO_EYES), "Dummy is blind on init,  when it should've been removed by its default eyes.")
	TEST_ASSERT(!HAS_TRAIT_FROM(dummy, TRAIT_DEAF, NO_EARS), "Dummy is deaf on init, when it should've been removed by its default ears.")

/// Tests that we can change a mob's hand count without everything breaking
/datum/unit_test/many_armed_humans

/datum/unit_test/many_armed_humans/Run()
	var/mob/living/carbon/human/consistent/dummy = allocate(/mob/living/carbon/human/consistent)
	dummy.change_number_of_hands(4)

/// Tests spawned humans have the correct bodypart order
/datum/unit_test/human_bodypart_order

/datum/unit_test/human_bodypart_order/Run()
	var/mob/living/carbon/human/consistent/dummy = allocate(/mob/living/carbon/human/consistent)
	var/list/obj/item/bodypart/bodyparts = dummy.get_bodyparts()
	TEST_ASSERT(bodyparts[1].body_zone == BODY_ZONE_CHEST, "First bodypart in bodyparts list is not the chest, this is important for human rendering")
	TEST_ASSERT(bodyparts[2].body_zone == BODY_ZONE_HEAD, "Second bodypart in bodyparts list is not the head, this is important for human rendering")

	var/list/obj/item/bodypart/bodyparts_by_zone = dummy.get_bodyparts_by_zones()
	TEST_ASSERT(bodyparts_by_zone[1] == BODY_ZONE_CHEST, "First bodypart in bodyparts_by_zone list is not the chest, this is important for human rendering")
	TEST_ASSERT(bodyparts_by_zone[2] == BODY_ZONE_HEAD, "Second bodypart in bodyparts_by_zone list is not the head, this is important for human rendering")
