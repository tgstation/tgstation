/mob/living/silicon/robot/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	. = ..()
	handle_robot_hud_updates()
	handle_robot_cell(seconds_per_tick, times_fired)

/mob/living/silicon/robot/proc/handle_robot_cell(seconds_per_tick, times_fired)
	if(stat == DEAD)
		return

	if(low_power_mode)
		if(cell?.charge)
			low_power_mode = FALSE
	else if(stat == CONSCIOUS)
		use_energy(seconds_per_tick, times_fired)

/mob/living/silicon/robot/proc/use_energy(seconds_per_tick, times_fired)
	if(cell?.charge)
		if(cell.charge <= 0.01 * STANDARD_CELL_CHARGE)
			drop_all_held_items()
		var/energy_consumption = max(lamp_power_consumption * lamp_enabled * lamp_intensity * seconds_per_tick, BORG_MINIMUM_POWER_CONSUMPTION * seconds_per_tick) //Lamp will use a max of 5 * [BORG_LAMP_POWER_CONSUMPTION], depending on brightness of lamp. If lamp is off, borg systems consume [BORG_MINIMUM_POWER_CONSUMPTION], or the rest of the cell if it's lower than that.
		cell.use(energy_consumption, force = TRUE)
	else
		drop_all_held_items()
		low_power_mode = TRUE
		toggle_headlamp(TRUE)
	diag_hud_set_borgcell()

/mob/living/silicon/robot/proc/handle_robot_hud_updates()
	if(!client)
		return

	update_cell_hud_icon()

/mob/living/silicon/robot/update_health_hud()
	if(!client || !hud_used)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			if(health >= maxHealth)
				hud_used.healths.icon_state = "health0"
			else if(health > maxHealth*0.6)
				hud_used.healths.icon_state = "health2"
			else if(health > maxHealth*0.2)
				hud_used.healths.icon_state = "health3"
			else if(health > -maxHealth*0.2)
				hud_used.healths.icon_state = "health4"
			else if(health > -maxHealth*0.6)
				hud_used.healths.icon_state = "health5"
			else
				hud_used.healths.icon_state = "health6"
		else
			hud_used.healths.icon_state = "health7"

/mob/living/silicon/robot/proc/update_cell_hud_icon()
	if(cell)
		var/cellcharge = cell.charge/cell.maxcharge
		switch(cellcharge)
			if(0.75 to INFINITY)
				clear_alert(ALERT_CHARGE)
			if(0.5 to 0.75)
				throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/lowcell, 1)
			if(0.25 to 0.5)
				throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/lowcell, 2)
			if(0.01 to 0.25)
				throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/lowcell, 3)
			else
				throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/emptycell)
	else
		throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/nocell)
