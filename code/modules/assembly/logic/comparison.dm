//////////////////////////Comparison circuit////////////////////////
// * When pulsed, check FIRST connected assembly. If the condition is TRUE, emit a pulse to the SECOND connected assembly. If the condition is false, emit a pulse to the THIRD connected assembly.
//
// * get pulse: check condition. If true, send pulse to all outputs

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
	Math circuit: VALUE = result of the specified math operation<BR>
	Proximity sensor: VALUE = remaining time (in seconds)<BR>
	Timer: VALUE = remaining time (in seconds)<BR>

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

	var/value_to_check = A.get_value()

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
