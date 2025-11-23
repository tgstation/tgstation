/// Test you can mouse-drop a defib off your back to unequip it
/datum/unit_test/unequip_defib

/datum/unit_test/unequip_defib/Run()
	var/mob/living/carbon/human/consistent/dummy = EASY_ALLOCATE()
	dummy.mock_client = new()
	dummy.set_hud_used(new dummy.hud_type(dummy))
	var/obj/item/defibrillator/defib = EASY_ALLOCATE()
	dummy.equip_to_slot(defib, ITEM_SLOT_BACK)

	var/old_usr = usr

	usr = dummy // mouse drop still uses usr

	defib.MouseDrop(dummy.hud_used.hand_slots["1"])
	if(!dummy.is_holding(defib))
		TEST_FAIL("The dummy failed to remove the defib from their back via mouse drop.")

	usr = old_usr
