/// Tests whether a [normal/bluespace] light replacer is capable of replacing a [broken/absent/burnt] light within a [near/far] [normal/bulb/floor] light fixure, and that resources are properly consumed, and all that.
/datum/unit_test/light_replacer

/datum/unit_test/light_replacer/Run()
	var/mob/living/carbon/human/consistent/janitor = EASY_ALLOCATE()
	var/obj/item/lightreplacer/replacer = EASY_ALLOCATE()
	var/obj/item/lightreplacer/blue/rangedreplacer = EASY_ALLOCATE()
	var/obj/machinery/light/current_close_light = allocate(/obj/machinery/light/unbroken, run_loc_floor_bottom_left)
	var/obj/machinery/light/far_bulb = allocate(/obj/machinery/light/small/unbroken, run_loc_floor_top_right)

	janitor.put_in_active_hand(replacer)
	far_bulb.break_light_tube(TRUE)

	click_wrapper(janitor, current_close_light)
	TEST_ASSERT_EQUAL(replacer.uses, initial(replacer.uses), "Light replacer consumed resources replacing an already intact tube")

	click_wrapper(janitor, far_bulb)
	TEST_ASSERT_EQUAL(far_bulb.status, LIGHT_BROKEN, "Normal light replacer fixed a light from range")

	current_close_light.break_light_tube(TRUE)
	click_wrapper(janitor, current_close_light)
	TEST_ASSERT_EQUAL(current_close_light.status, LIGHT_OK, "Light replacer failed to replace a tube")
	TEST_ASSERT_NOTEQUAL(replacer.uses, initial(replacer.uses), "Light replacer did not consume resources replacing a tube")

	janitor.put_in_active_hand(rangedreplacer, TRUE)
	qdel(current_close_light)
	current_close_light = allocate(/obj/machinery/light/floor/unbroken, run_loc_floor_bottom_left)
	current_close_light.burn_out()

	click_wrapper(janitor, far_bulb)
	TEST_ASSERT_EQUAL(far_bulb.status, LIGHT_OK, "Ranged light replacer failed to replace broken bulb from range")

	click_wrapper(janitor, current_close_light)
	TEST_ASSERT_EQUAL(current_close_light.status, LIGHT_OK, "Ranged light replacer failed to replace burnt floor bulb in melee")

/obj/machinery/light/unbroken
	allow_break_on_init = FALSE

/obj/machinery/light/floor/unbroken
	allow_break_on_init = FALSE

/obj/machinery/light/small/unbroken
	allow_break_on_init = FALSE
