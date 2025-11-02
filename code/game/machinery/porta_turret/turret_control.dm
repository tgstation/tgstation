#define STATUS_STUN "Non-lethal"
#define STATUS_KILL "Lethal"

/obj/machinery/turretid
	name = "turret control panel"
	desc = "Used to control a room's automated defenses."
	icon = 'icons/obj/machines/turret_control.dmi'
	icon_state = "control"
	density = FALSE
	req_access = list(ACCESS_AI_UPLOAD)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	interaction_flags_click = ALLOW_SILICON_REACH

	/// Are the turrets enabled and will shoot at targets?
	var/enabled = TRUE
	/// The status of the lethal/non-lethal equipment
	var/status = STATUS_STUN
	/// Should linked turrets shoot cyborgs?
	var/shoot_cyborgs = FALSE

	/// An area where linked turrets are located
	var/area/control_area = null
	/// Are the controls locked?
	var/locked = TRUE
	/// Is this blocked for the AI?
	var/ai_block = FALSE

	/// Weakrefs to controlled turrets
	var/list/turrets = list()

/obj/machinery/turretid/Initialize(mapload, ndir = 0, built = 0)
	. = ..()
	if(built)
		locked = FALSE
	power_change()
	find_and_hang_on_wall()
	update_overlays()

/obj/machinery/turretid/Destroy()
	turrets.Cut()
	return ..()

/obj/machinery/turretid/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	var/area/control_area_instance

	if(control_area)
		control_area_instance = get_area_instance_from_text(control_area)
		if(!control_area_instance)
			log_mapping("Bad control_area path for [src] at [AREACOORD(src)]: [control_area]")
	if(!control_area_instance)
		control_area_instance = get_area(src)

	for(var/obj/machinery/porta_turret/T in control_area_instance)
		turrets |= WEAKREF(T)

/obj/machinery/turretid/update_overlays()
  . = ..()
  overlays.Cut()

  if(machine_stat & NOPOWER)
    if(enabled)
      add_overlay(mutable_appearance(icon, "button_left"))
      if(status == STATUS_KILL)
        add_overlay(mutable_appearance(icon, "button_right"))
    return

  if(enabled)
    add_overlay(mutable_appearance(icon, "button_left"))
    add_overlay(emissive_appearance(icon, "emissive_button_left", src))
    switch(status)
      if(STATUS_STUN)
        add_overlay(mutable_appearance(icon, "stun"))
      if(STATUS_KILL)
        add_overlay(mutable_appearance(icon, "kill"))
        add_overlay(mutable_appearance(icon, "button_right"))
        add_overlay(emissive_appearance(icon, "emissive_button_right", src))
  else
    add_overlay(mutable_appearance(icon, "standby"))
  add_overlay(emissive_appearance(icon, "emissive_screen", src))

/obj/machinery/turretid/power_change()
  . = ..()
  update_appearance()

/obj/machinery/turretid/examine(mob/user)
	. += ..()
	if(issilicon(user) && !(machine_stat & BROKEN))
		. += {"[span_notice("Ctrl-click [src] to [ enabled ? "disable" : "enable"] turrets.")]
		      [span_notice("Alt-click [src] to set turrets to [ status == STATUS_KILL ? "stun" : "kill"].")]"}

/obj/machinery/turretid/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	. = NONE
	if(machine_stat & BROKEN)
		return

	if(multi_tool.buffer && istype(multi_tool.buffer, /obj/machinery/porta_turret))
		turrets |= WEAKREF(multi_tool.buffer)
		to_chat(user, span_notice("You link \the [multi_tool.buffer] with \the [src]."))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/turretid/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(machine_stat & BROKEN)
		return

	if (issilicon(user))
		return attack_hand(user)

	var/id = attacking_item.GetID()

	if(isnull(id))
		return

	if (check_access(id))
		if(obj_flags & EMAGGED)
			to_chat(user, span_warning("[src] is unresponsive!"))
			return

		locked = !locked
		to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the panel."))
	else
		to_chat(user, span_alert("Access denied."))

/obj/machinery/turretid/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "access analysis module shorted")
	obj_flags |= EMAGGED
	locked = FALSE
	return TRUE

/obj/machinery/turretid/attack_ai(mob/user)
	if(!ai_block || isAdminGhostAI(user))
		return attack_hand(user)
	else
		to_chat(user, span_warning("There seems to be a firewall preventing you from accessing this device!"))

/obj/machinery/turretid/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TurretControl", name)
		ui.open()

/obj/machinery/turretid/ui_data(mob/user)
	var/list/data = list()
	data["locked"] = locked
	data["siliconUser"] = HAS_SILICON_ACCESS(user)
	data["enabled"] = enabled
	data["lethal"] = (status == STATUS_KILL)
	data["shootCyborgs"] = shoot_cyborgs
	return data

/obj/machinery/turretid/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	switch(action)
		if("lock")
			if(!HAS_SILICON_ACCESS(user))
				return
			if((obj_flags & EMAGGED) || (machine_stat & BROKEN))
				to_chat(user, span_warning("The turret control is unresponsive!"))
				return
			locked = !locked
			return TRUE
		if("power")
			toggle_on(user)
			return TRUE
		if("mode")
			toggle_lethal(user)
			return TRUE
		if("shoot_silicons")
			shoot_silicons(user)
			return TRUE

/obj/machinery/turretid/proc/toggle_lethal(mob/user)
	status = (status == STATUS_STUN) ? STATUS_KILL : STATUS_STUN
	if (user)
		var/enabled_or_disabled = (status == STATUS_KILL) ? "disabled" : "enabled"
		balloon_alert(user, "safeties [enabled_or_disabled]")
		add_hiddenprint(user)
		log_combat(user, src, "[enabled_or_disabled] lethals on")
	updateTurrets()

/obj/machinery/turretid/proc/toggle_on(mob/user)
	enabled = !enabled
	if (user)
		var/enabled_or_disabled = enabled ? "enabled" : "disabled"
		balloon_alert(user, "[enabled_or_disabled]")
		add_hiddenprint(user)
		log_combat(user, src, "[enabled ? "enabled" : "disabled"]")
	updateTurrets()

/obj/machinery/turretid/proc/shoot_silicons(mob/user)
	shoot_cyborgs = !shoot_cyborgs
	if (user)
		var/status_text = shoot_cyborgs ? "Shooting Borgs" : "Not Shooting Borgs"
		balloon_alert(user, LOWER_TEXT(status_text))
		add_hiddenprint(user)
		log_combat(user, src, "[status_text]")
	updateTurrets()

/obj/machinery/turretid/proc/updateTurrets()
	for (var/datum/weakref/turret_ref in turrets)
		var/obj/machinery/porta_turret/turret = turret_ref.resolve()
		if(!turret)
			turrets -= turret_ref
			continue
		turret.setState(enabled, (status == STATUS_KILL), shoot_cyborgs)
	update_appearance()

/obj/item/wallframe/turret_control
	name = "turret control frame"
	desc = "Used for building turret control panels."
	icon = 'icons/obj/machines/turret_control.dmi'
	icon_state = "control_frame"
	result_path = /obj/machinery/turretid
	custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT)
	pixel_shift = 22
