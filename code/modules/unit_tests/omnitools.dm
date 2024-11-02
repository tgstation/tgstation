/datum/unit_test/omnitools_engiboorg/Run()
	var/mob/living/silicon/robot/borg = allocate(/mob/living/silicon/robot)

	//transform to engiborg
	borg.model.transform_to(/obj/item/robot_model/engineering, forced = TRUE)
	var/obj/item/borg/cyborg_omnitool/engineering/engi_tool = null
	for(var/obj/item/borg/tool as anything in borg.model.modules)
		if(istype(tool, /obj/item/borg/cyborg_omnitool/engineering))
			engi_tool = tool
			break
	borg.shown_robot_modules = TRUE //stops hud from updating which would runtime cause our mob does not have one
	borg.equip_module_to_slot(engi_tool, 1)
	borg.select_module(1)
	var/obj/item/held_item = borg.get_active_held_item()

	//Tests for omnitool wrench
	engi_tool.reference = engi_tool.omni_toolkit[1]
	engi_tool.tool_behaviour = initial(engi_tool.reference.tool_behaviour)
	var/obj/machinery/cell_charger/charger = allocate(/obj/machinery/cell_charger)
	//Test 1: charger must be anchored
	held_item.melee_attack_chain(borg, charger)
	TEST_ASSERT(!charger.anchored, "Cell charger was not anchored by borg omnitool wrench!")
	//Test 2: charger must be unanchored
	held_item.melee_attack_chain(borg, charger)
	TEST_ASSERT(charger.anchored, "Cell charger was not unanchored by borg omnitool wrench!")

	//Tests for omnitool wirecutter
	engi_tool.reference = engi_tool.omni_toolkit[2]
	engi_tool.tool_behaviour = initial(engi_tool.reference.tool_behaviour)
	//Test 1: is holding wirecutters for wires
	TEST_ASSERT(borg.is_holding_tool_quality(TOOL_WIRECUTTER), "Cannot find borg omnitool wirecutters in borgs hand!")
	//Test 2: frame wires must be cut
	var/obj/structure/frame/machine/test_frame = allocate(/obj/structure/frame/machine)
	test_frame.state = FRAME_STATE_WIRED
	held_item.melee_attack_chain(borg, test_frame)
	TEST_ASSERT_EQUAL(test_frame.state, FRAME_STATE_EMPTY, "Machine frame's wires were not cut by the borg omnitool wirecutters!")

	//Test for omnitool screwdriver
	engi_tool.reference = engi_tool.omni_toolkit[3]
	engi_tool.tool_behaviour = initial(engi_tool.reference.tool_behaviour)
	//Test 1: dissemble frame
	held_item.melee_attack_chain(borg, test_frame)
	TEST_ASSERT(QDELETED(test_frame), "Machine frame was not deconstructed by borg omnitool screwdriver!")

	//Test for borg omnitool crowbar
	engi_tool.reference = engi_tool.omni_toolkit[4]
	engi_tool.tool_behaviour = initial(engi_tool.reference.tool_behaviour)
	var/obj/machinery/recharger/recharger = allocate(/obj/machinery/recharger)
	recharger.panel_open = TRUE
	//Test 1: should dissemble the charger
	held_item.melee_attack_chain(borg, recharger)
	TEST_ASSERT(QDELETED(recharger), "Recharger was not deconstructed by borg omnitool crowbar!")

	//Test for borg omnitool multitool
	engi_tool.reference = engi_tool.omni_toolkit[5]
	engi_tool.tool_behaviour = initial(engi_tool.reference.tool_behaviour)
	var/obj/machinery/ore_silo/silo = allocate(/obj/machinery/ore_silo)
	//Test 1: should store silo in buffer
	held_item.melee_attack_chain(borg, silo)
	var/obj/item/multitool/tool = held_item.get_proxy_attacker_for(silo, borg)
	TEST_ASSERT(istype(tool), "Borg failed to switch internal tool to multitool")
	TEST_ASSERT(istype(tool.buffer, /obj/machinery/ore_silo), "Borg omnitool multitool failed to log ore silo!")
