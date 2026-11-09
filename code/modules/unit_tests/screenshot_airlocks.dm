/// Ensures common airlock overlays work
/datum/unit_test/screenshot_airlocks

/datum/unit_test/screenshot_airlocks/Run()
	var/obj/machinery/door/airlock/instant/door = allocate(__IMPLIED_TYPE__)
	var/obj/machinery/door/airlock/instant/glass/glass_door = allocate(__IMPLIED_TYPE__)

	var/icon/final_icon = icon('icons/effects/effects.dmi', "nothing")

	final_icon.Insert(getFlatIcon(door, no_anim = TRUE), dir = NORTH, frame = 1)
	final_icon.Insert(getFlatIcon(glass_door, no_anim = TRUE), dir = SOUTH, frame = 1)

	door.open()
	glass_door.open()

	final_icon = icon(final_icon)
	final_icon.Insert(getFlatIcon(door, no_anim = TRUE), dir = NORTH, frame = 2)
	final_icon.Insert(getFlatIcon(glass_door, no_anim = TRUE), dir = SOUTH, frame = 2)

	door.close()
	glass_door.close()
	door.bolt()
	glass_door.bolt()

	final_icon = icon(final_icon)
	final_icon.Insert(getFlatIcon(door, no_anim = TRUE), dir = NORTH, frame = 3)
	final_icon.Insert(getFlatIcon(glass_door, no_anim = TRUE), dir = SOUTH, frame = 3)

	door.unbolt()
	glass_door.unbolt()
	door.welded = TRUE
	door.update_appearance()
	glass_door.welded = TRUE
	glass_door.update_appearance()

	final_icon = icon(final_icon)
	final_icon.Insert(getFlatIcon(door, no_anim = TRUE), dir = NORTH, frame = 4)
	final_icon.Insert(getFlatIcon(glass_door, no_anim = TRUE), dir = SOUTH, frame = 4)

	test_screenshot("icons", final_icon)
