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
	var/last_value = 0

/obj/item/device/assembly/randomizer/activate() //Simple stuff - when pulsed, emit a pulse. The assembly frame will handle the next part
	if(!..()) return 0

	last_value = rand(0, output_number-1)
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

//////////////////////////Comparison circuit////////////////////////
// * When pulsed, check FIRST connected assembly. If the condition is TRUE, emit a pulse to the SECOND connected assembly. If the condition is false, emit a pulse to the THIRD connected assembly.
//

/obj/item/device/assembly/comparison
	name = "comparison circuit"

	desc = "A tiny circuit intended for use in assembly frames. When it receives a signal, it checks the first assembly connected to it. If the condition is true, it emits a pulse to the second connected assembly. Otherwise, it emits a pulse to the third connected assembly."
	icon_state = "circuit_="
	starting_materials = list(MAT_IRON = 100, MAT_GLASS = 25)
	w_type = RECYK_ELECTRONIC

	origin_tech = "programming=1"

	wires = WIRE_PULSE | WIRE_RECEIVE

	var/check_type = "EQUAL TO"
	var/check_against = 1

	var/list/allowed_assemblies = list(/obj/item/device/assembly/addition, /obj/item/device/assembly/randomizer, /obj/item/device/assembly/prox_sensor, /obj/item/device/assembly/timer)

/obj/item/device/assembly/comparison/activate()
	if(!..()) return 0

	pulse() //

/obj/item/device/assembly/comparison/interact(mob/user as mob)
	var/dat = ""

	dat += "<tt>Comparison circuit</tt> <small>\[<a href='?src=\ref[src];help=1'>?</a>\]</small><BR><BR>"

	dat += {"CONDITON:<br>
	<b>VALUE</b> is <b><a href='?src=\ref[src];change_check_type=1'>[check_type]</a></b> <b><a href='?src=\ref[src];change_check_value=1'>[check_against]</a></b><BR>"}

	var/datum/browser/popup = new(user, "circuit2", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "circuit2")

	return

/obj/item/device/assembly/comparison/Topic(href, href_list)
	if(..()) return

	if(href_list["help"])
		to_chat(usr, "<span class='info'>List of compactible assemblies:</span>")
		to_chat(usr, {"
	<span class='info'>Addition circuit: VALUE = counter's value<BR>
	Randomizer circuit: VALUE = last generated number<BR>
	Proximity sensor: VALUE = remaining time (in seconds)<BR>
	Timer: VALUE = remaining time (in seconds)</span><BR>

	The first connected assembly is checked. If the condition is true, the second connected assembly is pulsed. Otherwise, the third connected assembly is pulsed. At least two assemblies must be connected for this circuit to work; third one is optional and any assembly beyond the third is redundant."})
		return

	if(href_list["change_check_type"])
		var/choice = input(usr, "Select a new check type for \the [src].", "[src]") as null|anything in list("EQUAL TO", "LESS THAN", "MORE THAN", "LESS THAN OR EQUAL TO", "MORE THAN OR EQUAL TO", "NOT EQUAL TO")

		if(!choice) choice = 0
		if(!Adjacent(usr)) return
		var/mob/living/L = usr
		if(L && L.isUnconscious()) return

		to_chat(usr, "<span class='info'>You change the check from [check_type] to [choice].</span>")

		check_type = choice

	if(href_list["change_check_value"])
		var/choice = input(usr, "Select a new check value for \the [src].", "[src]") as null|num

		if(!choice) return
		if(!Adjacent(usr)) return
		var/mob/living/L = usr
		if(L && L.isUnconscious()) return

		to_chat(usr, "<span class='info'>You change the check value from [check_against] to [choice].</span>")

		check_against = choice

	if(usr)
		attack_self(usr)

/obj/item/device/assembly/comparison/send_pulses_to_list(var/list/L) //The assembly frame will give us a list of devices to forward a pulse to.
	if(!L) return

	if(L.len < 2) return //If there's only ONE assembly in the list, don't bother at all.

	var/obj/item/device/assembly/check = L[1] //First assembly is checked for condition

	var/obj/item/device/assembly/on_true = L[2] //Second assembly is pulsed if condition = true

	var/obj/item/device/assembly/on_false //Third assembly is optional, and is pulsed if condition = false
	if(L.len >= 3)
		on_false = L[3]

	if(try_condition(check))
		on_true.pulsed()
	else if(on_false)
		on_false.pulsed()

/obj/item/device/assembly/comparison/proc/try_condition(var/obj/item/device/assembly/A)
	if(!A) return 0

	if(!is_type_in_list(A, allowed_assemblies)) return 0

	var/value_to_check

	if(istype(A, /obj/item/device/assembly/timer))
		var/obj/item/device/assembly/timer/AS = A
		value_to_check = AS.time
	else if(istype(A, /obj/item/device/assembly/prox_sensor))
		var/obj/item/device/assembly/prox_sensor/AS = A
		value_to_check = AS.time
	else if(istype(A, /obj/item/device/assembly/addition))
		var/obj/item/device/assembly/addition/AS = A
		value_to_check = AS.pulse_counter
	else if(istype(A, /obj/item/device/assembly/randomizer))
		var/obj/item/device/assembly/randomizer/AS = A
		value_to_check = AS.last_value

	switch(check_type)
		if("EQUAL TO")
			return (value_to_check == check_against)
		if("LESS THAN")
			return (value_to_check < check_against)
		if("MORE THAN")
			return (value_to_check > check_against)
		if("LESS THAN OR EQUAL TO")
			return (value_to_check <= check_against)
		if("MORE THAN OR EQUAL TO")
			return (value_to_check >= check_against)
		if("NOT EQUAL TO")
			return (value_to_check != check_against)
		else
			return 0
