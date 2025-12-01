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
