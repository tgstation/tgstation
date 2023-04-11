/obj/item/mcobject/messaging/wifi_split
	name = "array access component"
	base_icon_state = "comp_split"
	icon_state = "comp_split"

/obj/item/mcobject/messaging/wifi_split/Initialize(mapload)
	. = ..()
	MC_ADD_TRIGGER
	MC_ADD_INPUT("split", split)

/obj/item/mcobject/messaging/wifi_split/proc/split(datum/mcmessage/input)
	var/list/data = params2list(input.cmd)
	if(!length(data))
		return

	var/out = data[trigger]
	if(!out)
		return

	fire(out, input)
