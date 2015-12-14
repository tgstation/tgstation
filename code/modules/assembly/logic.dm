//////////////////////////Addition circuit////////////////////////
// * When pulsed, increase counter by 1. When counter reaches a set value, reset it to 0 and emit a pulse.

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

/obj/item/device/assembly/addition/activate()
	if(!..()) return 0

	pulse_counter++
	if(pulse_counter >= limit)
		pulse()
		pulse_counter = 0

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

//////////////////////////Random number generator circuit////////////////////////
// * When pulsed, randomly picks n assemblies connected to it and sends a pulse to them
//

/obj/item/device/assembly/randomizer
	name = "randomizer circuit"
	short_name = "randomizer"

	desc = "A tiny circuit intended for use in assembly frames. When it receives a pulse, it randomly selects a set amount of devices connected to it, and emits a pulse to them."
	icon_state = "circuit_rng"
	starting_materials = list(MAT_IRON = 100, MAT_GLASS = 25)
	w_type = RECYK_ELECTRONIC

	origin_tech = "programming=1"

	wires = WIRE_PULSE | WIRE_RECEIVE

	var/output_number = 1 //How many assemblies are randomly chosen

/obj/item/device/assembly/randomizer/activate() //Simple stuff - when pulsed, emit a pulse. The assembly frame will handle the next part
	if(!..()) return 0

	pulse()

/obj/item/device/assembly/randomizer/interact(mob/user)
	var/new_output_num = input(user, "How many devices should \the [src] randomly select?", "[src]", output_number) as null|num

	if(!Adjacent(user) || user.isUnconscious()) //sanity 101
		return

	output_number = Clamp(new_output_num, 1, 512)
	to_chat(user, "<span class='info'>Number of outputs set to [output_number].</span>")

/obj/item/device/assembly/randomizer/send_pulses_to_list(var/list/L) //The assembly frame will give us a list of devices to forward a pulse to.
	if(!L || !L.len) return

	var/list/AS = L.Copy() //Copy the list, since we're going to remove stuff from it

	for(var/i = 0 to output_number-1)
		var/obj/item/device/assembly/A = pick(AS) //Pick a random assembly, remove it from the list and pulse it

		AS.Remove(A)
		A.pulsed()

		if(!AS.len) break
