/datum/component/ammo_hud
	var/atom/movable/screen/ammo_counter/hud

/datum/component/ammo_hud/Initialize()
	. = ..()
	if(!istype(parent, /obj/item/gun) && !istype(parent, /obj/item/weldingtool))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/wake_up)

/datum/component/ammo_hud/Destroy()
	turn_off()
	return ..()

/datum/component/ammo_hud/proc/wake_up(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	RegisterSignal(parent, list(COMSIG_PARENT_PREQDELETED, COMSIG_ITEM_DROPPED), .proc/turn_off)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.is_holding(parent))
			if(H.hud_used)
				hud = H.hud_used.ammo_counter
				turn_on()
		else
			turn_off()

/datum/component/ammo_hud/proc/turn_on()
	SIGNAL_HANDLER

	RegisterSignal(parent, COMSIG_UPDATE_AMMO_HUD, .proc/update_hud)

	hud.turn_on()
	update_hud()

/datum/component/ammo_hud/proc/turn_off()
	SIGNAL_HANDLER

	UnregisterSignal(parent, list(COMSIG_PARENT_PREQDELETED, COMSIG_ITEM_DROPPED, COMSIG_UPDATE_AMMO_HUD))

	if(hud)
		hud.turn_off()
		hud = null

/datum/component/ammo_hud/proc/update_hud()
	SIGNAL_HANDLER
	if(istype(parent, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/pew = parent
		hud.maptext = null
		hud.icon_state = "backing"
		var/backing_color = COLOR_CYAN
		if(!pew.magazine)
			hud.set_hud(backing_color, "oe", "te", "he", "no_mag")
			return
		if(!pew.get_ammo())
			hud.set_hud(backing_color, "oe", "te", "he", "empty_flash")
			return

		var/indicator
		var/rounds = num2text(pew.get_ammo(TRUE))
		var/oth_o
		var/oth_t
		var/oth_h

		switch(pew.fire_select)
			if(SELECT_SEMI_AUTOMATIC)
				indicator = "semi"
			if(SELECT_BURST_SHOT)
				indicator = "burst"
			if(SELECT_FULLY_AUTOMATIC)
				indicator = "auto"

		if(pew.safety)
			indicator = "safe"

		if(pew.jammed)
			indicator = "jam"

		switch(length(rounds))
			if(1)
				oth_o = "o[rounds[1]]"
			if(2)
				oth_o = "o[rounds[2]]"
				oth_t = "t[rounds[1]]"
			if(3)
				oth_o = "o[rounds[3]]"
				oth_t = "t[rounds[2]]"
				oth_h = "h[rounds[1]]"
			else
				oth_o = "o9"
				oth_t = "t9"
				oth_h = "h9"
		hud.set_hud(backing_color, oth_o, oth_t, oth_h, indicator)

	else if(istype(parent, /obj/item/gun/energy))
		var/obj/item/gun/energy/pew = parent
		hud.icon_state = "eammo_counter"
		hud.cut_overlays()
		hud.maptext_x = -12
		var/obj/item/ammo_casing/energy/shot = pew.ammo_type[pew.select]
		var/batt_percent = FLOOR(clamp(pew.cell.charge / pew.cell.maxcharge, 0, 1) * 100, 1)
		var/shot_cost_percent = FLOOR(clamp(shot.e_cost / pew.cell.maxcharge, 0, 1) * 100, 1)
		if(batt_percent > 99 || shot_cost_percent > 99)
			hud.maptext_x = -12
		else
			hud.maptext_x = -8
		if(!pew.can_shoot())
			hud.icon_state = "eammo_counter_empty"
			hud.maptext = span_maptext("<div align='center' valign='middle' style='position:relative'><font color='[COLOR_RED]'><b>[batt_percent]%</b></font><br><font color='[COLOR_CYAN]'>[shot_cost_percent]%</font></div>")
			return
		if(batt_percent <= 25)
			hud.maptext = span_maptext("<div align='center' valign='middle' style='position:relative'><font color='[COLOR_YELLOW]'><b>[batt_percent]%</b></font><br><font color='[COLOR_CYAN]'>[shot_cost_percent]%</font></div>")
			return
		hud.maptext = span_maptext("<div align='center' valign='middle' style='position:relative'><font color='[COLOR_VIBRANT_LIME]'><b>[batt_percent]%</b></font><br><font color='[COLOR_CYAN]'>[shot_cost_percent]%</font></div>")

	else if(istype(parent, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = parent
		hud.maptext = null
		var/backing_color = COLOR_TAN_ORANGE
		hud.icon_state = "backing"

		if(welder.get_fuel() < 1)
			hud.set_hud(backing_color, "oe", "te", "he", "empty_flash")
			return

		var/indicator
		var/fuel = num2text(welder.get_fuel())
		var/oth_o
		var/oth_t
		var/oth_h

		if(welder.welding)
			indicator = "flame_on"
		else
			indicator = "flame_off"

		fuel = num2text(welder.get_fuel())

		switch(length(fuel))
			if(1)
				oth_o = "o[fuel[1]]"
			if(2)
				oth_o = "o[fuel[2]]"
				oth_t = "t[fuel[1]]"
			if(3)
				oth_o = "o[fuel[3]]"
				oth_t = "t[fuel[2]]"
				oth_h = "h[fuel[1]]"
			else
				oth_o = "o9"
				oth_t = "t9"
				oth_h = "h9"
		hud.set_hud(backing_color, oth_o, oth_t, oth_h, indicator)

	else if(istype(parent, /obj/item/gun/microfusion))
		var/obj/item/gun/microfusion/parent_gun = parent
		if(!parent_gun.phase_emitter)
			hud.icon_state = "microfusion_counter_no_emitter"
			hud.maptext = null
			return
		if(parent_gun.phase_emitter.damaged)
			hud.icon_state = "microfusion_counter_damaged"
			hud.maptext = null
			return
		if(!parent_gun.cell)
			hud.icon_state = "microfusion_counter_no_emitter"
			hud.maptext = null
			return
		if(!parent_gun.cell.charge)
			hud.icon_state = "microfusion_counter_no_emitter"
			hud.maptext = null
			return
		var/phase_emitter_state = parent_gun.phase_emitter.get_heat_icon_state()
		hud.icon_state = "microfusion_counter_[phase_emitter_state]"
		hud.cut_overlays()
		hud.maptext_x = -12
		var/obj/item/ammo_casing/energy/shot = parent_gun.microfusion_lens
		var/battery_percent = FLOOR(clamp(parent_gun.cell.charge / parent_gun.cell.maxcharge, 0, 1) * 100, 1)
		var/shot_cost_percent = FLOOR(clamp(shot.e_cost / parent_gun.cell.maxcharge, 0, 1) * 100, 1)
		if(battery_percent > 99 || shot_cost_percent > 99)
			hud.maptext_x = -12
		else
			hud.maptext_x = -8
		if(!parent_gun.can_shoot())
			hud.icon_state = "microfusion_counter_no_emitter"
			return
		if(battery_percent <= 25)
			hud.maptext = span_maptext("<div align='center' valign='middle' style='position:relative'><font color='[COLOR_YELLOW]'>[battery_percent]%</font><br><font color='[COLOR_CYAN]'>[shot_cost_percent]%</font></div>")
			return
		hud.maptext = span_maptext("<div align='center' valign='middle' style='position:relative'><font color='[COLOR_VIBRANT_LIME]'>[battery_percent]%</font><br><font color='[COLOR_CYAN]'>[shot_cost_percent]%</font></div>")


/obj/item/gun/ballistic/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/ammo_hud)

/obj/item/gun/energy/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/ammo_hud)

/obj/item/weldingtool/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/ammo_hud)
