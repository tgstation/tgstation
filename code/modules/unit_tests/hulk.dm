/// Tests that hulks aren't given rapid attacks from rapid attack gloves
/datum/unit_test/hulk_north_star

/datum/unit_test/hulk_north_star/Run()
	var/mob/living/carbon/human/hulk = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/clothing/gloves/rapid/fotns = allocate(/obj/item/clothing/gloves/rapid)

	hulk.equip_to_appropriate_slot(fotns)
	hulk.add_mutation(/datum/mutation/human/hulk)
	hulk.set_combat_mode(TRUE)
	hulk.ClickOn(dummy)

	TEST_ASSERT_NOTEQUAL(hulk.next_move, world.time + CLICK_CD_RAPID, "Hulk should not gain the effects of the Fists of the North Star.")
	TEST_ASSERT_EQUAL(hulk.next_move, world.time + CLICK_CD_MELEE, "Hulk click cooldown was a value not expected.")
