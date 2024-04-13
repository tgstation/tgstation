/datum/unit_test/strip_menu_ui_status/Run()
	// We just need something that doesn't have strippable by default, so we can add it ourselves.
	var/obj/target = allocate(/obj/item/pen, run_loc_floor_bottom_left)
	var/datum/element/strippable/strippable = target.AddElement(/datum/element/strippable)

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	ADD_TRAIT(user, TRAIT_PRESERVE_UI_WITHOUT_CLIENT, TRAIT_SOURCE_UNIT_TESTS)

	var/datum/strip_menu/strip_menu = allocate(/datum/strip_menu, target, strippable)

	var/ui_state = strip_menu.ui_state(user)

	TEST_ASSERT_EQUAL(strip_menu.ui_status(user, ui_state), UI_INTERACTIVE, "Perfect conditions were not interactive.")

	user.set_body_position(LYING_DOWN)
	// Necessary for tying shoes.
	TEST_ASSERT_EQUAL(strip_menu.ui_status(user, ui_state), UI_INTERACTIVE, "Lying down was not interactive.")

	user.forceMove(locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	TEST_ASSERT_EQUAL(strip_menu.ui_status(user, ui_state), UI_UPDATE, "Being too far away while lying down was not update-only.")

	user.set_body_position(STANDING_UP)
	TEST_ASSERT_EQUAL(strip_menu.ui_status(user, ui_state), UI_UPDATE, "Being too far away while standing up was not update-only.")

	var/handcuffs = allocate(/obj/item/restraints/handcuffs, user)
	user.forceMove(target.loc)
	user.set_handcuffed(handcuffs)
	user.update_handcuffed()
	TEST_ASSERT_EQUAL(strip_menu.ui_status(user, ui_state), UI_UPDATE, "Being within range but cuffed was not update-only.")
	user.set_handcuffed(null)
	qdel(handcuffs)

	user.set_body_position(LYING_DOWN)
	user.death()
	TEST_ASSERT_EQUAL(strip_menu.ui_status(user, ui_state), UI_UPDATE, "Being within range but dead was not update-only.")

	var/mob/dead/observer/observer = allocate(/mob/dead/observer)
	// observers set their own turf, so we can't just pass it into allocate
	observer.forceMove(run_loc_floor_bottom_left)

	// A mocked client is needed for providing view
	var/datum/client_interface/mock_client = new
	observer.mock_client = mock_client
	ADD_TRAIT(observer, TRAIT_PRESERVE_UI_WITHOUT_CLIENT, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_EQUAL(strip_menu.ui_status(observer, ui_state), UI_UPDATE, "Being within range but an observer was not update-only.")

	var/mob/living/silicon/robot/borg = allocate(/mob/living/silicon/robot, run_loc_floor_bottom_left)
	ADD_TRAIT(borg, TRAIT_PRESERVE_UI_WITHOUT_CLIENT, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_EQUAL(strip_menu.ui_status(borg, ui_state), UI_INTERACTIVE, "Being within range as a borg was not interactive.")

	// Borgs can normally access tgui's regardless of position if it's within view range.
	// This makes sense for machinery, but not for this abstract UI.
	borg.forceMove(locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	TEST_ASSERT_EQUAL(strip_menu.ui_status(borg, ui_state), UI_UPDATE, "Being too far away as a borg was not update-only.")

	var/mob/living/carbon/alien/rouny = allocate(/mob/living/carbon/alien, run_loc_floor_bottom_left)
	ADD_TRAIT(rouny, TRAIT_PRESERVE_UI_WITHOUT_CLIENT, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_EQUAL(strip_menu.ui_status(rouny, ui_state), UI_INTERACTIVE, "Being within range as a xeno was not interactive.")

	var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(strip_menu.ui_status(corgi, ui_state), UI_UPDATE, "Being within range as a corgi was not update-only.")
