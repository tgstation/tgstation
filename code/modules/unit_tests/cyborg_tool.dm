/// Regression test for the cyborg omnitool to ensure it goes through proper channels
/datum/unit_test/cyborg_tool
	var/times_wrenched = 0

/datum/unit_test/cyborg_tool/Run()
	var/mob/living/carbon/human/consistent/not_a_borg = allocate(__IMPLIED_TYPE__)
	var/obj/item/borg/cyborg_omnitool/engineering/tool = allocate(__IMPLIED_TYPE__)
	tool.tool_behaviour = TOOL_WRENCH

	not_a_borg.put_in_active_hand(tool)

	var/obj/structure/frame/machine/frame = allocate(__IMPLIED_TYPE__)
	RegisterSignal(frame, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), PROC_REF(wrenched))

	not_a_borg.ClickOn(frame)
	TEST_ASSERT_EQUAL(times_wrenched, 1, "Wrenching the frame with a cyborg omnitool should have triggered the wrenched signal")

/datum/unit_test/cyborg_tool/proc/wrenched(...)
	SIGNAL_HANDLER
	times_wrenched += 1
