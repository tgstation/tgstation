/obj/item/mcobject/messaging/clock
	name = "clock component"
	base_icon_state = "comp_arith"
	icon_state = "comp_arith"

/obj/item/mcobject/messaging/clock/Initialize(mapload)
	. = ..()
	configs -= MC_CFG_OUTPUT_MESSAGE
	MC_ADD_INPUT("send", send)

/obj/item/mcobject/messaging/clock/proc/send(datum/mcmessage/input)
	fire(stationtime2text(), input)
