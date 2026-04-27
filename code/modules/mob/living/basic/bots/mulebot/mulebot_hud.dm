/mob/living/basic/bot/mulebot/proc/set_cell_hud()
	if(!has_power())
		set_hud_image_state(DIAG_BATT_HUD, "hudnobatt")
		return

	set_hud_image_state(DIAG_BATT_HUD, "hudbatt[RoundDiagBar(cell.charge/cell.maxcharge)]")
