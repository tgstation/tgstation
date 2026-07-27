/datum/unit_test/slapcrafting

/datum/unit_test/slapcrafting/Run()
	var/mob/living/carbon/human/consistent/expert = EASY_ALLOCATE()
	var/obj/item/paper/disguise = EASY_ALLOCATE()
	var/obj/item/toy/mecha/odysseus/cool_robot = EASY_ALLOCATE()

	#ifdef UNIT_TESTS
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/slapcraft_tester)
	cool_robot.AddElement(/datum/element/slapcrafting, slapcraft_recipe_list)
	#else
	TEST_FAIL("Slapcrafting unit test ran without UNIT_TESTS definition")
	#endif

	expert.put_in_active_hand(disguise)
	click_wrapper(expert, cool_robot)
	var/obj/item/toy/mecha/reticence/cooler_robot = locate(/obj/item/toy/mecha/reticence) in run_loc_floor_bottom_left
	TEST_ASSERT_NOTNULL(cooler_robot, "Slapcrafting did not successfully produce an item")
	qdel(cooler_robot)

#ifdef UNIT_TESTS
/datum/crafting_recipe/slapcraft_tester
	name = "Cooler Robot"
	result = /obj/item/toy/mecha/reticence
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/toy/mecha/odysseus = 1,
	)
	time = 0
	category = CAT_ENTERTAINMENT
	crafting_flags = CRAFT_SKIP_MATERIALS_PARITY
#endif
