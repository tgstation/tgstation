/datum/unit_test/mecha_construction_icons

/datum/unit_test/mecha_construction_icons/Run()
	for(var/chassis_type in subtypesof(/obj/item/mecha_parts/chassis))
		var/obj/item/mecha_parts/chassis/chassis = allocate(chassis_type)
		var/datum/component/construction/unordered/mecha_chassis/chassis_comp = chassis.GetComponent(/datum/component/construction/unordered/mecha_chassis)
		if(isnull(chassis_comp))
			TEST_FAIL("[chassis_type]: Mecha chassis without a construction component")
			continue
		chassis_comp.spawn_result()

		var/datum/component/construction/mecha/construction_comp = chassis.GetComponent(/datum/component/construction/mecha)
		if(isnull(construction_comp))
			TEST_FAIL("[chassis_type]: Finished chassis without a mech construction component")
			continue
		if(!QDELETED(chassis_comp))
			TEST_FAIL("[chassis_type]: Chassis construction component was not deleted after applying the mecha construction component")
			continue
		if(isnull(construction_comp.base_icon))
			continue // apparently valid, for construction which don't have *any* icon states

		var/list/all_chassis_icon_states = icon_states_fast(chassis.icon)
		var/list/step_icon_states = list()
		for(var/list/step_data as anything in construction_comp.steps)
			var/icon_state = step_data["icon_state"]
			if(isnull(icon_state))
				continue // valid, it just means the step doesn't change the icon

			if(!(icon_state in all_chassis_icon_states))
				TEST_FAIL("[chassis_type]: Mecha construction step has invalid icon_state '[icon_state]'")
				continue

			step_icon_states += icon_state

		for(var/icon_state in all_chassis_icon_states - step_icon_states)
			// little extra logic here to avoid false positives like finding "mech" in "darkmech"
			if(!findtext("test-[icon_state]", "test-[construction_comp.base_icon]"))
				continue
			TEST_FAIL("[chassis_type]: Mecha construction has an unused icon state '[icon_state]'")
