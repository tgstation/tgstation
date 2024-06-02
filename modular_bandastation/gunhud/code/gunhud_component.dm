/datum/component/gunhud
	var/atom/movable/screen/gunhud_screen/hud

/datum/component/gunhud/Initialize()
	. = ..()
	if(!istype(parent, /obj/item/gun) && !istype(parent, /obj/item/weldingtool))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(wake_up))

/datum/component/gunhud/Destroy()
	turn_off()
	return ..()

/datum/component/gunhud/proc/wake_up(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.is_holding(parent))
			if(H.hud_used)
				hud = H.hud_used.gunhud_screen
				turn_on()
		else
			turn_off()

/datum/component/gunhud/proc/turn_on()
	SIGNAL_HANDLER

	RegisterSignals(parent, list(COMSIG_PREQDELETED, COMSIG_ITEM_DROPPED), PROC_REF(turn_off))
	RegisterSignals(parent, list(COMSIG_UPDATE_GUNHUD, COMSIG_GUN_CHAMBER_PROCESSED), PROC_REF(update_hud))
	if(istype(parent, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = parent
		if(energy_gun.cell)
			RegisterSignal(energy_gun.cell, COMSIG_CELL_GIVE, PROC_REF(update_hud))

	hud.turn_on()
	update_hud()

/datum/component/gunhud/proc/turn_off()
	SIGNAL_HANDLER

	UnregisterSignal(parent, list(COMSIG_PREQDELETED, COMSIG_ITEM_DROPPED, COMSIG_UPDATE_GUNHUD, COMSIG_GUN_CHAMBER_PROCESSED))
	if(istype(parent, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = parent
		if(energy_gun.cell)
			UnregisterSignal(energy_gun.cell, COMSIG_CELL_GIVE)

	if(hud)
		hud.turn_off()
		hud = null

/datum/component/gunhud/proc/update_hud()
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
		var/rounds = num2text(istype(parent, /obj/item/gun/ballistic/revolver) ? pew.get_ammo(FALSE, FALSE) : pew.get_ammo(TRUE)) // fucking revolvers indeed - do not count empty or chambered rounds for the display HUD
		var/oth_o
		var/oth_t
		var/oth_h

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

/obj/item/gun/ballistic/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gunhud)

/obj/item/gun/energy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gunhud)

/obj/item/gun/energy/recharge_newshot(no_cyborg_drain)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/weldingtool/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gunhud)

/obj/item/weldingtool/set_welding(new_value)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)

/obj/item/weldingtool/use(used)
	. = ..()
	SEND_SIGNAL(src, COMSIG_UPDATE_GUNHUD)
