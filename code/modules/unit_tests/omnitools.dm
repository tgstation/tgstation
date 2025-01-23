/datum/unit_test/omnitools
	abstract_type = /datum/unit_test/omnitools

	//The borg model tot ransform to
	var/borg_model = /obj/item/robot_model
	//Tool type
	var/tool_type = /obj/item/borg/cyborg_omnitool

///Test the current tool in the toolkit
/datum/unit_test/omnitools/proc/TestTool(mob/living/silicon/robot/borg, obj/item/borg/cyborg_omnitool)
	PROTECTED_PROC(TRUE)

	return

/datum/unit_test/omnitools/Run()
	var/mob/living/silicon/robot/borg = allocate(__IMPLIED_TYPE__)

	//transform to engiborg
	borg.model.transform_to(borg_model, forced = TRUE, transform = FALSE)
	var/obj/item/borg/cyborg_omnitool/omnitool = null
	for(var/obj/item/borg/tool as anything in borg.model.modules)
		if(istype(tool, tool_type))
			omnitool = tool
			break
	TEST_ASSERT_NOTNULL(omnitool, "Could not find [tool_type] in borg inbuilt modules!")
	borg.shown_robot_modules = TRUE //stops hud from updating which would runtime cause our mob does not have one
	borg.equip_module_to_slot(omnitool, 1)
	borg.select_module(1)

	//these must match
	TEST_ASSERT_EQUAL(borg.get_active_held_item(), omnitool, "Borg held tool is not the selected omnitool!")

	for(var/obj/item/internal_tool as anything in omnitool.omni_toolkit)
		//Initialize the tool
		omnitool.reference = internal_tool
		omnitool.tool_behaviour = initial(internal_tool.tool_behaviour)

		//Test it
		TestTool(borg, omnitool)

	borg.unequip_module_from_slot(omnitool, 1)


/// Tests for engiborg omnitool
/datum/unit_test/omnitools/engiborg
	borg_model = /obj/item/robot_model/engineering
	tool_type = /obj/item/borg/cyborg_omnitool/engineering

	/// frame to test wirecutter & screwdriver
	var/obj/structure/frame/machine/test_frame

/datum/unit_test/omnitools/engiborg/TestTool(mob/living/silicon/robot/borg, obj/item/borg/cyborg_omnitool/held_item)
	var/tool_behaviour = held_item.tool_behaviour

	switch(tool_behaviour)
		//Tests for omnitool wrench
		if(TOOL_WRENCH)
			var/obj/machinery/cell_charger/charger = allocate(__IMPLIED_TYPE__)
			//Test 1: charger must be anchored
			held_item.melee_attack_chain(borg, charger)
			TEST_ASSERT(!charger.anchored, "Cell charger was not unanchored by borg omnitool wrench!")
			//Test 2: charger must be unanchored
			held_item.melee_attack_chain(borg, charger)
			TEST_ASSERT(charger.anchored, "Cell charger was not anchored by borg omnitool wrench!")

		//Tests for omnitool wirecutter
		if(TOOL_WIRECUTTER)
			//Test 1: is holding wirecutters for wires
			TEST_ASSERT(borg.is_holding_tool_quality(TOOL_WIRECUTTER), "Cannot find borg omnitool wirecutters in borgs hand!")

			//Test 2: frame wires must be cut
			if(isnull(test_frame))
				test_frame = allocate(__IMPLIED_TYPE__)
			test_frame.state = FRAME_STATE_WIRED
			held_item.melee_attack_chain(borg, test_frame)
			TEST_ASSERT_EQUAL(test_frame.state, FRAME_STATE_EMPTY, "Machine frame's wires were not cut by the borg omnitool wirecutters!")

		//Test for omnitool screwdriver
		if(TOOL_SCREWDRIVER)
			//Test 1: dissemble frame
			held_item.melee_attack_chain(borg, test_frame)
			TEST_ASSERT(QDELETED(test_frame), "Machine frame was not deconstructed by borg omnitool screwdriver!")

		//Test for borg omnitool crowbar
		if(TOOL_CROWBAR)
			var/obj/machinery/recharger/recharger = allocate(__IMPLIED_TYPE__)
			recharger.panel_open = TRUE
			//Test 1: should dissemble the charger
			held_item.melee_attack_chain(borg, recharger)
			TEST_ASSERT(QDELETED(recharger), "Recharger was not deconstructed by borg omnitool crowbar!")

		//Test for borg omnitool multitool
		if(TOOL_MULTITOOL)
			var/obj/machinery/ore_silo/silo = allocate(__IMPLIED_TYPE__)
			//Test 1: should store silo in buffer
			held_item.melee_attack_chain(borg, silo)
			var/obj/item/multitool/tool = held_item.get_proxy_attacker_for(silo, borg)
			TEST_ASSERT(istype(tool), "Borg failed to switch internal tool to multitool")
			TEST_ASSERT(istype(tool.buffer, /obj/machinery/ore_silo), "Borg omnitool multitool failed to log ore silo!")

