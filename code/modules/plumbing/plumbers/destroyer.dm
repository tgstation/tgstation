//Maximum disposal rate
#define MAX_DISPOSAL_RATE 25

/obj/machinery/plumbing/disposer
	name = "chemical disposer"
	desc = "Breaks down chemicals and annihilates them."
	icon_state = "disposal"
	base_icon_state = "disposal"
	pass_flags_self = PASSMACHINE | LETPASSTHROW // Small
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 4

	///Reagents to remove per second
	var/disposal_rate = 5
	///Is this machine switched on
	var/on = FALSE

/obj/machinery/plumbing/disposer/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand/disposer, layer)
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(update))

/obj/machinery/plumbing/disposer/examine(mob/user)
	. = ..()
	. += span_notice("It is disposing [disposal_rate]u reagents per second.")
	. += span_notice("Use hand to change disposal rate.")

/obj/machinery/plumbing/disposer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Set transfer rate"
		return CONTEXTUAL_SCREENTIP_SET

	return ..()

/obj/machinery/plumbing/disposer/proc/update()
	SIGNAL_HANDLER

	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/disposer/update_icon_state()
	icon_state = "[base_icon_state][is_operational && anchored && on && reagents.total_volume ? "_working" : ""]"
	return ..()

/obj/machinery/plumbing/disposer/on_set_is_operational(old_value)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/disposer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(. == ITEM_INTERACT_SUCCESS)
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/disposer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDisposer", name)
		ui.open()

/obj/machinery/plumbing/disposer/ui_static_data(mob/user)
	return list(
		max_volume = MAX_DISPOSAL_RATE
	)

/obj/machinery/plumbing/disposer/ui_data(mob/user)
	return list(
		enabled = on,
		disposal_rate = disposal_rate
	)

/obj/machinery/plumbing/disposer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_power")
			on = !on
			update_appearance(UPDATE_ICON_STATE)
			return TRUE

		if("change_volume")
			var/num = text2num(params["volume"])
			if(!isnum(num))
				return FALSE

			disposal_rate = round(clamp(num, 0.1, MAX_DISPOSAL_RATE), CHEMICAL_VOLUME_ROUNDING)
			return TRUE

/obj/machinery/plumbing/disposer/process(seconds_per_tick)
	if(!is_operational || !reagents.total_volume || !on)
		return
	reagents.remove_all(disposal_rate * seconds_per_tick)
	use_energy((disposal_rate / MAX_DISPOSAL_RATE) * active_power_usage * seconds_per_tick)

#undef MAX_DISPOSAL_RATE
