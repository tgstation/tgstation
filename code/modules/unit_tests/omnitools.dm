/datum/unit_test/omnitools/Run()
	var/mob/living/silicon/robot/borg = allocate(__IMPLIED_TYPE__)
	var/obj/structure/frame/machine/test_frame = allocate(__IMPLIED_TYPE__)
	test_frame.state = FRAME_STATE_WIRED

	//transform to engiborg
	borg.model.transform_to(/obj/item/robot_model/engineering, forced = TRUE, transform = FALSE)
	var/obj/item/borg/cyborg_omnitool/omnitool = null
	for(var/obj/item/borg/tool as anything in borg.model.modules)
		if(istype(tool, /obj/item/borg/cyborg_omnitool/engineering))
			omnitool = tool
			break
	TEST_ASSERT_NOTNULL(omnitool, "Could not find /obj/item/borg/cyborg_omnitool/engineering in borg inbuilt modules!")
	borg.put_in_hand(omnitool, 1)
	borg.select_module(1)

	//these must match
	TEST_ASSERT_EQUAL(borg.get_active_held_item(), omnitool, "Borg held tool is not the selected omnitool!")

	//Initialize the tool
	omnitool.set_internal_tool(/obj/item/wirecutters/cyborg)

	//Check the proxy attacker is of this type
	var/obj/item/proxy = omnitool.get_proxy_attacker_for(test_frame, borg)
	TEST_ASSERT_EQUAL(proxy.type, /obj/item/wirecutters/cyborg, "Omnitool proxy attacker [proxy.type] does not match selected type /obj/item/wirecutters/cyborg")

	//Test the attack chain to see if the internal tool interacted correctly with the target
	omnitool.melee_attack_chain(borg, test_frame)
	TEST_ASSERT_EQUAL(test_frame.state, FRAME_STATE_EMPTY, "Machine frame's wires were not cut by the borg omnitool wirecutters!")

	//unequip
	borg.drop_all_held_items()

/datum/unit_test/omnitool_icons

/datum/unit_test/omnitool_icons/Run()
	var/list/all_tools = GLOB.all_tool_behaviours.Copy()
	for(var/tool, tool_image in GLOB.tool_to_image)
		if(!(tool in GLOB.all_tool_behaviours))
			TEST_FAIL("Tool behaviour [tool] has an image defined in global tool_to_image but is not present in all_tool_behaviours list.")
		var/image/tool_image_real = tool_image
		if(!icon_exists(tool_image_real.icon, tool_image_real.icon_state))
			TEST_FAIL("Tool image for [tool] not found ([tool_image_real.icon], [tool_image_real.icon_state])")
		all_tools -= tool

	for(var/missing_tool in all_tools)
		TEST_FAIL("No tool image defined for tool behaviour [missing_tool] in global tool_to_image")
