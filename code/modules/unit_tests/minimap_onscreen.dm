/**
 * Generates the minimap for each station z-level and verifies that both
 * the minimap icon and its drawing toolbar fit inside the 480×480 HUD screen.
 *
 * Mirrors the layout logic in:
 *   - minimap_display.dm :: set_minimap() for the map position
 *   - minimap_display.dm :: reposition_toolbar_buttons() for button positions
 */
/datum/unit_test/minimap_onscreen

/datum/unit_test/minimap_onscreen/Run()
	// Determine toolbar height from the highest-indexed button slot.
	var/max_button_slot = 0
	for(var/button_type in subtypesof(/atom/movable/screen/minimap_toolbar_button))
		max_button_slot = max(max_button_slot, initial(button_type.button_slot))
	var/toolbar_h = (max_button_slot + 1) * ICON_SIZE_Y

	for(var/z in 1 to world.maxz)
		if(!SSmapping.level_trait(z, ZTRAIT_STATION))
			continue

		var/datum/minimap/mm = get_minimap_for_z(z)
		if(!mm || !mm.base_map)
			TEST_FAIL("z=[z]: could not generate minimap")
			continue

		var/map_w = mm.base_map.Width()
		var/map_h = mm.base_map.Height()

		// Minimap is centered on the SCREEN_PIXEL_SIZE × SCREEN_PIXEL_SIZE HUD (set_minimap).
		var/origin_x = SCREEN_PIXEL_SIZE / 2 - map_w / 2
		var/origin_y = SCREEN_PIXEL_SIZE / 2 - map_h / 2

		TEST_ASSERT(origin_x >= 0, "z=[z]: minimap left edge at [origin_x]px is off-screen (map_w=[map_w], screen=[SCREEN_PIXEL_SIZE])")
		TEST_ASSERT(origin_x + map_w <= SCREEN_PIXEL_SIZE, "z=[z]: minimap right edge at [origin_x + map_w]px overflows screen (map_w=[map_w], screen=[SCREEN_PIXEL_SIZE])")
		TEST_ASSERT(origin_y >= 0, "z=[z]: minimap bottom edge at [origin_y]px is off-screen (map_h=[map_h], screen=[SCREEN_PIXEL_SIZE])")
		TEST_ASSERT(origin_y + map_h <= SCREEN_PIXEL_SIZE, "z=[z]: minimap top edge at [origin_y + map_h]px overflows screen (map_h=[map_h], screen=[SCREEN_PIXEL_SIZE])")

		// Toolbar is placed to the minimap's left; falls back to the right if that goes off-screen.
		var/btn_x = origin_x - ICON_SIZE_X - 4
		if(btn_x < 0)
			btn_x = origin_x + map_w + 4

		TEST_ASSERT(btn_x >= 0, "z=[z]: toolbar left edge at [btn_x]px is off-screen (map_w=[map_w])")
		TEST_ASSERT(btn_x + ICON_SIZE_X <= SCREEN_PIXEL_SIZE, "z=[z]: toolbar right edge at [btn_x + ICON_SIZE_X]px overflows screen (map_w=[map_w])")

		var/btn_top_y = clamp(SCREEN_PIXEL_SIZE / 2 + toolbar_h / 2, toolbar_h, SCREEN_PIXEL_SIZE)
		TEST_ASSERT(btn_top_y - toolbar_h >= 0, "z=[z]: toolbar bottom edge at [btn_top_y - toolbar_h]px is off-screen (toolbar_h=[toolbar_h])")
		TEST_ASSERT(btn_top_y <= SCREEN_PIXEL_SIZE, "z=[z]: toolbar top edge at [btn_top_y]px overflows screen (toolbar_h=[toolbar_h])")
