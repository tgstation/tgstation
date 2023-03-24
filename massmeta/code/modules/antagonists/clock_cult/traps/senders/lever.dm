/obj/item/wallframe/clocktrap/lever
	name = "рычаг"
	desc = "Маленький выключатель, прикрепленный к стене."
	icon_state = "lever"
	result_path = /obj/structure/destructible/clockwork/trap/lever

/obj/structure/destructible/clockwork/trap/lever
	name = "рычаг"
	desc = "Маленький выключатель, прикрепленный к стене."
	icon_state = "lever"
	unwrench_path = /obj/item/wallframe/clocktrap/lever
	component_datum = /datum/component/clockwork_trap/lever
	max_integrity = 75
	atom_integrity = 75

/datum/component/clockwork_trap/lever
	sends_input = TRUE

/datum/component/clockwork_trap/lever/clicked(mob/user)
	trigger_connected()
	to_chat(user, span_notice("Дёргаю рычаг."))
	playsound(user, 'sound/machines/click.ogg', 50)
