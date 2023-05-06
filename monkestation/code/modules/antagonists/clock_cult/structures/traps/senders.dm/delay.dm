/obj/item/wallframe/clocktrap/delay
	name = "clockwork timer"
	desc = "A small, detached timer."
	icon_state = "delayer"
	result_path = /obj/structure/destructible/clockwork/trap/delay
	clockwork_desc = "A device that can be attached to walls. When input is received, it will send an output signal a configurable (with multitool) time later."


/obj/structure/destructible/clockwork/trap/delay
	name = "clockwork timer"
	desc = "A small timer attatched to the wall."
	icon_state = "delayer"
	component_datum = /datum/component/clockwork_trap/delay
	unwrench_path = /obj/item/wallframe/clocktrap/delay
	max_integrity = 15
	clockwork_desc = "When input is received, it will send an output signal a configurable (with multitool) amount of time later."
	/// How much time the signal is delayed
	var/delay_time = 1 SECONDS


/obj/structure/destructible/clockwork/trap/delay/multitool_act(mob/living/user, obj/item/tool)
	delay_time = tgui_input_number(user, "Input delay time", "Clockwork Timer", 1 SECONDS, 120 SECONDS, 1 SECONDS)
	return TRUE


/datum/component/clockwork_trap/delay
	takes_input = TRUE
	sends_input = TRUE
	/// If the trap is active or not
	var/active = FALSE


/datum/component/clockwork_trap/delay/trigger()
	if(!..() || active)
		return

	active = TRUE
	flick("delayer_active", parent)

	var/obj/structure/destructible/clockwork/trap/delay/parent_delayer = parent
	addtimer(CALLBACK(src, PROC_REF(finish)), parent_delayer.delay_time)


/// Finish the delay, trigger any traps
/datum/component/clockwork_trap/delay/proc/finish()
	active = FALSE
	trigger_connected()
