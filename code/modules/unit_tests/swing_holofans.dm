/// Tests the ability to place holosigns from a holosign creator.
/datum/unit_test/place_holosign

/datum/unit_test/place_holosign/Run()
	var/mob/living/carbon/human/jannie = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/holosign_creator/janibarrier/jannie_holosign_creator = allocate(/obj/item/holosign_creator/janibarrier)

	jannie.put_in_active_hand(jannie_holosign_creator, forced = TRUE)
	var/turf/open/next_to_the_jannie = locate(jannie.x + 1, jannie.y, jannie.z)

	click_wrapper(jannie, next_to_the_jannie)

	var/obj/structure/holosign/barrier/wetsign/placed_sign = locate() in next_to_the_jannie
	TEST_ASSERT_NOTNULL(placed_sign, "Holosign creator failed to place a holosign in an adjacent tile.")
