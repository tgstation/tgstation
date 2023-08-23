/// Tests that mobs are able to bash down tables by clicking on them.
/datum/unit_test/swing_table_bash

/datum/unit_test/swing_table_bash/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	toolbox.demolition_mod = 1
	attacker.put_in_active_hand(toolbox, forced = TRUE)

	var/obj/structure/table/to_smack = allocate(/obj/structure/table)
	to_smack.forceMove(locate(attacker.x + 1, attacker.y, attacker.z))

	click_wrapper(attacker, to_smack)
	TEST_ASSERT(toolbox.loc == to_smack.loc, "The toolbox should have been placed on the table. Instead, its loc is [toolbox.loc].")
	TEST_ASSERT_EQUAL(to_smack.get_integrity(), to_smack.max_integrity, "Table took damage despite not being smacked.")

	attacker.put_in_active_hand(toolbox, forced = TRUE)
	attacker.set_combat_mode(TRUE)
	click_wrapper(attacker, to_smack)
	TEST_ASSERT_NOTEQUAL(to_smack.get_integrity(), to_smack.max_integrity, "Table failed to take damage from being smacked.")
	TEST_ASSERT(to_smack.max_integrity - to_smack.get_integrity() <= toolbox.force, "Table took more damage than expected from being smacked.")

/// Tests that mobs are able to bash down barricades / structures by clicking on them.
/datum/unit_test/swing_structure_bash

/datum/unit_test/swing_structure_bash/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	toolbox.demolition_mod = 1
	attacker.put_in_active_hand(toolbox, forced = TRUE)

	var/obj/structure/barricade/to_smack = allocate(/obj/structure/barricade)
	to_smack.forceMove(locate(attacker.x + 1, attacker.y, attacker.z))

	click_wrapper(attacker, to_smack)
	TEST_ASSERT_NOTEQUAL(to_smack.get_integrity(), to_smack.max_integrity, "The barricade should have taken damage a from a non-combat-mode click.")
	TEST_ASSERT(to_smack.max_integrity - to_smack.get_integrity() <= toolbox.force, "Barricade took more damage than expected from being attacked.")

/// Tests that common tool interactions are possible still, by attempting to open the panel of an air alarm.
/datum/unit_test/swing_machinery_tool_interaction

/datum/unit_test/swing_machinery_tool_interaction/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/screwdriver/screwdriver = allocate(/obj/item/screwdriver)

	attacker.put_in_active_hand(screwdriver, forced = TRUE)

	var/obj/machinery/airalarm/to_smack = allocate(/obj/machinery/airalarm/directional/south)
	click_wrapper(attacker, to_smack)

	TEST_ASSERT_EQUAL(to_smack.get_integrity(), to_smack.max_integrity, "The air alarm took damage instead when interacted with a screwdriver on non-combat-mode.")
	TEST_ASSERT(to_smack.panel_open, "The air alarm should have opened its panel after being interacted with a screwdriver.")
