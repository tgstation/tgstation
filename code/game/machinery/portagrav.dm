/obj/machinery/power/portagrav
	anchored = FALSE
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON
	icon = 'icons/obj/machines/gravity_generator.dmi'
	icon_state = "portagrav"
	base_icon_state = "portagrav"
	name = "Portable Gravity Unit"
	desc = "Generates gravity around itself. Powered by wire or cell. Must be anchored before use."
	max_integrity = 250
	circuit = /obj/item/circuitboard/machine/portagrav
	armor_type = /datum/armor/portable_gravity
	interaction_flags_click = ALLOW_SILICON_REACH
	//We don't use area power
	use_power = NO_POWER_USE
	///The cell we spawn with
	var/obj/item/stock_parts/power_store/cell/cell = /obj/item/stock_parts/power_store/cell/high
	///Is the machine on?
	var/on = FALSE
	/// do we use power from wire instead
	var/wire_mode = FALSE
	/// our gravity field
	var/datum/proximity_monitor/advanced/gravity/subtle_effect/gravity_field
	/// strength of our gravity
	var/grav_strength = STANDARD_GRAVITY
	/// gravity range
	var/range = 4
	/// max gravity range
	var/max_range = 6
	/// draw per range
	var/draw_per_range = BASE_MACHINE_ACTIVE_CONSUMPTION

/datum/armor/portable_gravity
	fire = 100
	melee = 10
	bomb = 40

/obj/machinery/power/portagrav/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	if(anchored && wire_mode)
		connect_to_network()

	AddElement( \
		/datum/element/contextual_screentip_bare_hands, \
		rmb_text = "Toggle power", \
	)

	var/static/list/tool_behaviors = list(
		TOOL_WRENCH = list(
			SCREENTIP_CONTEXT_LMB = "Anchor",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

/obj/machinery/power/portagrav/Destroy()
	. = ..()
	cell = null

/obj/machinery/power/portagrav/update_overlays()
	. = ..()
	if(anchored)
		. += "portagrav_anchors"
	if(on)
		. += "portagrav_o"
		. += "activated"

/obj/machinery/power/portagrav/examine(mob/user)
	. = ..()
	. += "It is [on ? "on" : "off"]."
	. += "The charge meter reads: [!isnull(cell) ? "[round(cell.percent(), 1)]%" : "NO CELL"]."
	. += "It is[anchored ? "" : " not"] anchored."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("<b>Right-click</b> to toggle [on ? "off" : "on"].")

/obj/machinery/power/portagrav/RefreshParts()
	. = ..()
	var/power_usage = initial(draw_per_range)
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		power_usage -= BASE_MACHINE_ACTIVE_CONSUMPTION / 10 * (laser.tier - 1)
	draw_per_range = power_usage
	var/new_range = 4
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		new_range += capacitor.tier
	max_range = new_range
	update_field()

/obj/machinery/power/portagrav/screwdriver_act(mob/living/user, obj/item/tool)
	. = NONE
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/power/portagrav/crowbar_act(mob/living/user, obj/item/tool)
	. = NONE
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/power/portagrav/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(!istype(tool, /obj/item/stock_parts/power_store/cell))
		return
	if(!panel_open)
		balloon_alert(user, "must open panel!")
		return ITEM_INTERACT_BLOCKING
	if(cell)
		balloon_alert(user, "already has a cell!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_FAILURE
	cell = tool
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/portagrav/should_have_node()
	return anchored

/obj/machinery/power/portagrav/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/portagrav/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(on)
		balloon_alert(user, "turn off first!")
		return
	default_unfasten_wrench(user, tool)
	if(anchored && wire_mode)
		connect_to_network()
	else
		disconnect_from_network()
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/portagrav/get_cell()
	return cell

/obj/machinery/power/portagrav/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()
	if(!panel_open || isnull(cell) || !istype(user) || user.combat_mode)
		return
	if(user.put_in_hands(cell))
		cell = null

/obj/machinery/power/portagrav/attack_hand_secondary(mob/user, list/modifiers)
	if(!can_interact(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	toggle_on(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/power/portagrav/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	visible_message(span_warning("Sparks fly out of [src]!"))
	if(user)
		balloon_alert(user, "unsafe gravity unlocked")
		user.log_message("emagged [src].", LOG_ATTACK)
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/obj/machinery/power/portagrav/proc/toggle_on(mob/user)
	if(on)
		turn_off(user)
	else
		turn_on(user)

/obj/machinery/power/portagrav/proc/turn_on(mob/user)
	if(!anchored)
		if(!isnull(user))
			balloon_alert(user, "not anchored!")
		return FALSE
	if((!wire_mode && cell?.charge < draw_per_range * range) || (wire_mode && surplus() < draw_per_range * range))
		if(!isnull(user))
			balloon_alert(user, "not enough power!")
		return FALSE
	if(!isnull(user))
		balloon_alert(user, "turned on")
	on = TRUE
	START_PROCESSING(SSmachines, src)
	gravity_field = new(src, range = src.range, gravity = grav_strength)
	update_appearance()

/obj/machinery/power/portagrav/proc/turn_off(mob/user)
	on = FALSE
	if(!isnull(user))
		balloon_alert(user, "turned off")
	STOP_PROCESSING(SSmachines, src)
	QDEL_NULL(gravity_field)
	update_appearance()

/obj/machinery/power/portagrav/process(seconds_per_tick)
	if(!on || !anchored)
		return PROCESS_KILL
	if(wire_mode)
		if(powernet && surplus() >= draw_per_range * range)
			add_load(draw_per_range * range)
		else
			turn_off()
	else
		if(!cell?.use(draw_per_range * range))
			turn_off()

/obj/machinery/power/portagrav/proc/update_field()
	if(isnull(gravity_field))
		return
	gravity_field.set_range(range)
	gravity_field.gravity_value = grav_strength
	gravity_field.recalculate_field(full_recalc = TRUE)

/obj/machinery/power/portagrav/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Portagrav", name)
		ui.open()

/obj/machinery/power/portagrav/ui_data(mob/user)
	. = list()
	if(!isnull(cell))
		.["percentage"] = (cell.charge / cell.maxcharge) * 100
	.["gravity"] = grav_strength
	.["range"] = range
	.["maxrange"] = max_range
	.["on"] = on
	.["wiremode"] = wire_mode
	.["draw"] = display_power(draw_per_range * range)

/obj/machinery/power/portagrav/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	playsound(src, 'sound/machines/terminal_button07.ogg', 45, TRUE)
	switch(action)
		if("adjust_grav")
			var/adjustment = text2num(params["adjustment"])
			if(isnull(adjustment))
				return
			var/bonus = (obj_flags & EMAGGED) ? 2 : 0
			// REPLACE 0 with NEGATIVE_GRAVITY ONCE NEGATIVE GRAVITY IS SOMETHING ACTUALLY FUNCTIONAL
			var/result = clamp(grav_strength + adjustment, 0, GRAVITY_DAMAGE_THRESHOLD - 1 + bonus)
			if(result == grav_strength)
				return
			grav_strength = result
			update_field()
			return TRUE
		if("toggle_power")
			toggle_on(usr)
			return TRUE
		if("toggle_wire")
			wire_mode = !wire_mode
			if(wire_mode && anchored)
				connect_to_network()
			else
				disconnect_from_network()
			return TRUE
		if("adjust_range")
			var/adjustment = text2num(params["adjustment"])
			if(isnull(adjustment))
				return
			var/result = clamp(range + adjustment, 0, max_range)
			if(result == range)
				return
			range = result
			update_field()
			return TRUE

/obj/machinery/power/portagrav/anchored
	anchored = TRUE
