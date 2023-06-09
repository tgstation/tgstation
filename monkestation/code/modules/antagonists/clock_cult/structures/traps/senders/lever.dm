/obj/item/wallframe/clocktrap/lever
	name = "switch"
	desc = "A small switch attatched to the wall."
	icon_state = "lever"
	result_path = /obj/structure/destructible/clockwork/trap/lever
	clockwork_desc = "A device that can be attached to walls to allow you to send a signal to linked traps."


/obj/structure/destructible/clockwork/trap/lever
	name = "switch"
	desc = "A small switch attatched to the wall."
	icon_state = "lever"
	unwrench_path = /obj/item/wallframe/clocktrap/lever
	component_datum = /datum/component/clockwork_trap/lever
	max_integrity = 75
	clockwork_desc = "A device allows you to send a signal to linked traps."


/datum/component/clockwork_trap/lever
	sends_input = TRUE


/datum/component/clockwork_trap/lever/attack_hand(mob/user)
	trigger_connected()
	to_chat(user, span_notice("You activate the switch."))
	playsound(user, 'sound/machines/click.ogg', 50)
