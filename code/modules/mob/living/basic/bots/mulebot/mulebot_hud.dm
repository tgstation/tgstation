/mob/living/basic/bot/mulebot/proc/set_cell_hud()
	if(!has_power())
		set_hud_image_state(DIAG_BATT_HUD, "hudnobatt")
		return

	var/atom/movable/screen/mob_charge/charge_hud = hud_used?.screen_objects[HUD_MULEBOT_CHARGE]
	charge_hud?.calculate_charge()
	set_hud_image_state(DIAG_BATT_HUD, "hudbatt[RoundDiagBar(cell.charge/cell.maxcharge)]")

/atom/movable/screen/mob_charge
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "ccharger"
	screen_loc = ui_stamina
	///used to find the overlay for charger icon
	var/current_charge_level = 4
	///dynamic, based on what cell our nulebot's using
	var/image/battery_overlay
	///maptext that displays charge in numbers
	var/image/charge_overlay
	///is there a mouse on us
	var/hovering = FALSE

/atom/movable/screen/mob_charge/proc/update_battery_overlay(atom/target_battery)
	var/obj/item/stock_parts/power_store/cell/my_cell = target_battery || (locate() in get_mob())
	if(isnull(my_cell))
		battery_overlay = null
	else
		battery_overlay = image(icon = my_cell.icon, icon_state = my_cell.icon_state, loc = src, layer = src.layer + 0.1)
	update_appearance(UPDATE_ICON)

/atom/movable/screen/mob_charge/proc/calculate_charge()
	var/obj/item/stock_parts/power_store/cell/my_battery = locate() in get_mob()
	var/charge_value = isnull(my_battery) ? 0 : round(my_battery.charge/my_battery.maxcharge * 100 , 1)
	current_charge_level = round(charge_value * 4 / 100)
	charge_overlay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative'>[charge_value]%</div>")
	update_appearance(UPDATE_ICON)

/atom/movable/screen/mob_charge/New(loc, ...)
	. = ..()
	charge_overlay = image(loc = src, layer = src.layer+0.2, pixel_y = -5)
	update_battery_overlay()

/atom/movable/screen/mob_charge/Destroy()
	charge_overlay = null
	battery_overlay = null
	return ..()

/atom/movable/screen/mob_charge/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "ccharger-o[current_charge_level]")
	if(battery_overlay)
		. |= battery_overlay
	if(hovering)
		. |= charge_overlay

/atom/movable/screen/mob_charge/MouseEntered(location,control,params)
	if(usr != get_mob())
		return
	. = ..()
	hovering = TRUE
	calculate_charge()

/atom/movable/screen/mob_charge/MouseExited(location, control, params)
	if(usr != get_mob())
		return
	. = ..()
	hovering = FALSE
	update_appearance(UPDATE_ICON)

/datum/hud/living/mulebot

/datum/hud/living/mulebot/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/mob_charge, HUD_MULEBOT_CHARGE, HUD_GROUP_INFO)
