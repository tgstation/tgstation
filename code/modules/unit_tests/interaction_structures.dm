/// Tests that mobs are able to bash down tables by clicking on them.
/datum/unit_test/structure_table_bash

/datum/unit_test/structure_table_bash/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/obj/item/storage/toolbox/toolbox = EASY_ALLOCATE()
	var/obj/structure/table/to_smack = EASY_ALLOCATE()
	attacker.put_in_active_hand(toolbox, forced = TRUE)
	click_wrapper(attacker, to_smack)
	TEST_ASSERT_EQUAL(toolbox.loc, to_smack.loc, "The toolbox should have been placed on the table. Instead, its loc is [toolbox.loc].")
	TEST_ASSERT_EQUAL(to_smack.get_integrity(), to_smack.max_integrity, "Table took damage despite not being smacked.")

	attacker.put_in_active_hand(toolbox, forced = TRUE)
	attacker.set_combat_mode(TRUE)
	click_wrapper(attacker, to_smack)
	TEST_ASSERT_NOTEQUAL(toolbox.loc, to_smack.loc, "The toolbox should not have been placed on the table.")
	TEST_ASSERT_NOTEQUAL(to_smack.get_integrity(), to_smack.max_integrity, "Table failed to take damage from being smacked.")

/// Tests that mobs are able to bash down barricades / structures by clicking on them.
/datum/unit_test/structure_generic_bash

/datum/unit_test/structure_generic_bash/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/obj/item/storage/toolbox/toolbox = EASY_ALLOCATE()
	var/obj/structure/barricade/to_smack = EASY_ALLOCATE()
	attacker.put_in_active_hand(toolbox, forced = TRUE)
	click_wrapper(attacker, to_smack)
	TEST_ASSERT_NOTEQUAL(to_smack.get_integrity(), to_smack.max_integrity, "The barricade should have taken damage a from a non-combat-mode click.")

/// Tests that common tool interactions are possible still, by attempting to open the panel of an air alarm.
/datum/unit_test/machinery_tool_interaction

/datum/unit_test/machinery_tool_interaction/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/obj/item/screwdriver/screwdriver = EASY_ALLOCATE()
	var/obj/machinery/airalarm/to_smack = EASY_ALLOCATE()
	attacker.put_in_active_hand(screwdriver, forced = TRUE)
	click_wrapper(attacker, to_smack)
	TEST_ASSERT_EQUAL(to_smack.get_integrity(), to_smack.max_integrity, "The air alarm took damage when interacted with a screwdriver.")
	TEST_ASSERT(to_smack.panel_open, "The air alarm should have opened its panel after being interacted with a screwdriver.")
