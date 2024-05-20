/// Actual volume is REAGENTS_BASE_VOLUME plus REAGENTS_BASE_VOLUME * rating for each matterbin
#define REAGENTS_BASE_VOLUME 100

/obj/machinery/smoke_machine
	name = "smoke machine"
	desc = "A machine with a centrifuge installed into it. It produces smoke with any reagents you put into the machine."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "smoke0"
	base_icon_state = "smoke"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/smoke_machine
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_REQUIRES_ANCHORED
	processing_flags = START_PROCESSING_MANUALLY

	///Divided against the amount of smoke to produce. Higher values equals lesser amount of reagents consumed to create smoke
	var/efficiency = 20
	///Is this machine on or off
	var/on = FALSE
	///Higher values mean larger smoke pufs but also more power & reagents consumed
	var/setting = 1
	///Max setting acheived from upgraded capacitors
	var/max_range = 3

/// A factory which produces clouds of smoke for the smoke machine.
/datum/effect_system/fluid_spread/smoke/chem/smoke_machine
	effect_type = /obj/effect/particle_effect/fluid/smoke/chem/smoke_machine

/// Smoke which is produced by the smoke machine. Slightly transparent and does not block line of sight.
/obj/effect/particle_effect/fluid/smoke/chem/smoke_machine
	opacity = FALSE
	alpha = 100

/datum/effect_system/fluid_spread/smoke/chem/smoke_machine/set_up(range = 1, amount = DIAMOND_AREA(range), atom/holder, atom/location, datum/reagents/carry, efficiency = 10, silent = FALSE)
	src.holder = holder
	src.location = get_turf(location)
	src.amount = amount
	if(carry)
		carry.copy_to(chemholder, 20)
		carry.remove_all(amount / efficiency)

/obj/machinery/smoke_machine/Initialize(mapload)
	create_reagents(REAGENTS_BASE_VOLUME, INJECTABLE)

	. = ..()

	AddComponent(/datum/component/plumbing/simple_demand)
	AddComponent(/datum/component/simple_rotation)

	register_context()

/obj/machinery/smoke_machine/on_deconstruction(disassembled)
	reagents.expose(loc, TOUCH)
	reagents.clear_reagents()

/obj/machinery/smoke_machine/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(is_reagent_container(held_item) && held_item.is_open_container())
		context[SCREENTIP_CONTEXT_LMB] = "Inject reagents"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Una" : "A"]nchor"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/smoke_machine/examine(mob/user)
	. = ..()

	. += span_notice("Reagent capacity <b>[reagents.total_volume]/[reagents.maximum_volume]</b>.")
	. += span_notice("Operating at <b>[round((efficiency / 26) * 100)]%</b> efficiency.")

	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart.")

	if(anchored)
		. += span_notice("It can be [EXAMINE_HINT("wrenched")] loose.")
	else
		. += span_warning("It needs to be [EXAMINE_HINT("anchored")] in place to work.")

/obj/machinery/smoke_machine/update_icon_state()
	if(!is_operational || !on || !reagents.total_volume)
		icon_state = "[base_icon_state]0[panel_open ? "-o" : ""]"
		return ..()

	icon_state = "[base_icon_state]1"
	return ..()

/obj/machinery/smoke_machine/RefreshParts()
	. = ..()

	//new capacity to store reagents from matter bins
	var/new_volume = REAGENTS_BASE_VOLUME
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		new_volume += REAGENTS_BASE_VOLUME * matter_bin.tier
	reagents.maximum_volume = new_volume

	//new efficiency from capacitors
	efficiency = 18
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		efficiency += 2 * capacitor.tier

	//new maximum range from servos
	max_range = 1
	for(var/datum/stock_part/servo/servo in component_parts)
		max_range += servo.tier
	max_range = max(3, max_range)

/obj/machinery/smoke_machine/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(user.combat_mode || tool.item_flags & ABSTRACT || tool.flags_1 & HOLOGRAM_1 || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return ITEM_INTERACT_SKIP_TO_ATTACK

	//transfer reagents from an open container into machine
	if(is_reagent_container(tool) && tool.is_open_container())
		var/obj/item/reagent_containers/RC = tool
		var/units = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this, transferred_by = user)
		if(units)
			to_chat(user, span_notice("You transfer [units] units of the solution to [src]."))
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

/obj/machinery/smoke_machine/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(on)
		balloon_alert(user, "turn off first!")
		return

	if(default_unfasten_wrench(user, tool, time = 4 SECONDS) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/smoke_machine/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(on)
		balloon_alert(user, "turn off first!")
		return

	if(default_deconstruction_screwdriver(user, "smoke0-o", "smoke0", tool))
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/smoke_machine/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(on)
		balloon_alert(user, "turn off first!")
		return

	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/smoke_machine/process()
	if(!reagents.total_volume || !anchored || !on || !is_operational)
		on = FALSE
		update_appearance(UPDATE_ICON_STATE)
		return PROCESS_KILL

	var/turf/location = get_turf(src)
	if(!(locate(/obj/effect/particle_effect/fluid/smoke) in location))
		var/datum/effect_system/fluid_spread/smoke/chem/smoke_machine/smoke = new()
		smoke.set_up(setting * 3, holder = src, location = location, carry = reagents, efficiency = efficiency)
		smoke.start()
		use_energy(active_power_usage * (setting / max_range))
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/smoke_machine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmokeMachine", name)
		ui.open()

/obj/machinery/smoke_machine/ui_data(mob/user)
	. = list()

	var/list/tank_data = list()
	tank_data["maxVolume"] = reagents.maximum_volume
	tank_data["currentVolume"] = round(reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
	var/list/tankContents = list()
	for(var/datum/reagent/reagent in reagents.reagent_list)
		tankContents += list(list("name" = reagent.name, "volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING)))
	tank_data["contents"] = tankContents
	.["tank"] = tank_data

	.["active"] = on
	.["setting"] = setting
	.["maxSetting"] = max_range

/obj/machinery/smoke_machine/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("purge")
			reagents.clear_reagents()
			update_appearance(UPDATE_ICON_STATE)
			return TRUE

		if("setting")
			var/amount = params["amount"]
			if(isnull(amount))
				return FALSE

			amount = text2num(amount)
			if(isnull(amount))
				return FALSE

			if(amount in 1 to max_range)
				setting = amount
				return TRUE

		if("power")
			on = !on
			if(on && reagents.total_volume)
				var/mob/user = ui.user
				var/list/english_list = english_list(reagents.reagent_list)
				message_admins("[ADMIN_LOOKUPFLW(user)] activated a smoke machine that contains [english_list] at [ADMIN_VERBOSEJMP(src)].")
				user.log_message("activated a smoke machine that contains [english_list]", LOG_GAME)
				log_combat(user, src, "has activated [src] which contains [english_list] at [AREACOORD(src)].")
				begin_processing()
			else
				on = FALSE
				end_processing()
			update_appearance(UPDATE_ICON_STATE)
			return TRUE

#undef REAGENTS_BASE_VOLUME
