/obj/item/mcobject/messaging/or
	name = "OR component"
	base_icon_state = "comp_or"
	icon_state = "comp_or"

/obj/item/mcobject/messaging/or/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("input 1", _fire)
	MC_ADD_INPUT("input 2", _fire)
	MC_ADD_INPUT("input 3", _fire)
	MC_ADD_INPUT("input 4", _fire)
	MC_ADD_INPUT("input 5", _fire)
	MC_ADD_INPUT("input 6", _fire)
	MC_ADD_INPUT("input 7", _fire)
	MC_ADD_INPUT("input 8", _fire)
	MC_ADD_INPUT("input 9", _fire)
	MC_ADD_INPUT("input 10", _fire)
	MC_ADD_TRIGGER

/obj/item/mcobject/messaging/or/proc/_fire(datum/mcmessage/input)
	if(input.cmd == trigger)
		fire(stored_message, input)
