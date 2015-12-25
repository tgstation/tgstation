//////////////////////////Addition circuit////////////////////////
// * When pulsed, increase counter by 1. When counter reaches a specified value, reset it to 0 and emit a pulse.

/obj/item/device/assembly/addition
	name = "addition circuit"

	desc = "A tiny circuit intended for use in assembly frames. When it receives a signal, its counter is increased by 1. When its counter reaches a set value, this circuit emits a pulse."
	icon_state = "circuit_+"
	starting_materials = list(MAT_IRON = 100, MAT_GLASS = 25)
	w_type = RECYK_ELECTRONIC

	origin_tech = "programming=1"

	wires = WIRE_PULSE | WIRE_RECEIVE

	var/pulse_counter = 0
	var/limit = 1 //When the pulse counter reaches this value, emit a signal.

	accessible_values = list("Counter" = "pulse_counter;number",\
		"Limit" = "limit;number")

/obj/item/device/assembly/addition/activate()
	if(!..()) return 0

	if(++pulse_counter >= limit)
		pulse_counter = 0
		pulse()

	src.updateUsrDialog()

#define add_counter_href(amount) "<a href='?src=\ref[src];add_counter=[amount]'>"
#define sub_counter_href(amount) "<a href='?src=\ref[src];sub_counter=[amount]'>"

#define add_limit_href(amount) "<a href='?src=\ref[src];add_limit=[amount]'>"
#define sub_limit_href(amount) "<a href='?src=\ref[src];sub_limit=[amount]'>"

/obj/item/device/assembly/addition/interact(mob/user as mob)
	var/dat = ""

	dat += "<tt>Addition circuit</tt><BR><BR>"
	dat += "Counter: [sub_counter_href(10)]--</a> | [sub_counter_href(1)]-</a>  | <b>[pulse_counter]</b> | [add_counter_href(1)]+</a> | [add_counter_href(10)]++</a><BR>"
	dat += "Limit: [sub_limit_href(10)]--</a> | [sub_limit_href(1)]-</a>  | <b>[limit]</b> | [add_limit_href(1)]+</a> | [add_limit_href(10)]++</a><BR>"

	var/datum/browser/popup = new(user, "circuit1", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "circuit1")

	return

/obj/item/device/assembly/addition/Topic(href, href_list)
	if(..()) return

	if(href_list["sub_counter"])
		pulse_counter = max(pulse_counter - text2num(href_list["sub_counter"]), 0)
	if(href_list["add_counter"])
		pulse_counter+= text2num(href_list["add_counter"])

	if(href_list["sub_limit"])
		limit = max(limit - text2num(href_list["sub_limit"]), 0)
	if(href_list["add_limit"])
		limit+= text2num(href_list["add_limit"])

	if(usr)
		attack_self(usr)

#undef add_counter_href
#undef sub_counter_href
#undef add_limit_href
#undef sub_limit_href