//Maximum disposal rate
#define MAX_DISPOSAL_RATE 15

/obj/machinery/plumbing/disposer
	name = "chemical disposer"
	desc = "Breaks down chemicals and annihilates them."
	icon_state = "disposal"
	base_icon_state = "disposal"
	pass_flags_self = PASSMACHINE | LETPASSTHROW // Small

	///Reagents to remove per second
	var/disposal_rate = 5

/obj/machinery/plumbing/disposer/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, layer)
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
	icon_state = "[base_icon_state][is_operational && anchored && reagents.total_volume ? "_working" : ""]"
	return ..()

/obj/machinery/plumbing/disposer/on_set_is_operational(old_value)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/disposer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(. == ITEM_INTERACT_SUCCESS)
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/disposer/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/new_volume = tgui_input_number(user, "Enter new disposal rate", "Disposal rate", disposal_rate, MAX_DISPOSAL_RATE, initial(disposal_rate))
	if(!new_volume || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	disposal_rate = new_volume

/obj/machinery/plumbing/disposer/process(seconds_per_tick)
	if(!is_operational || !reagents.total_volume)
		return
	reagents.remove_all(disposal_rate * seconds_per_tick)
	use_energy((disposal_rate / MAX_DISPOSAL_RATE) * active_power_usage * seconds_per_tick)

#undef MAX_DISPOSAL_RATE
