//////////////////////////Addition circuit////////////////////////
// * When pulsed, increase counter by 1. When counter reaches a specified value, reset it to 0 and emit a pulse.

// * get_value: returns counter

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

	if(++pulse_counter >= limit)
		pulse_counter = 0
		pulse()

	src.updateUsrDialog()

/obj/item/device/assembly/addition/get_value()
	return pulse_counter

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
// * When pulsed, randomly picks n assemblies connected to it and sends a pulse to them. Also generates a random number from 0 to n.

// * get_value: returns last generated number

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

	last_value = rand(0, output_number)
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

/obj/item/device/assembly/randomizer/get_value()
	return last_value

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

	if(!is_type_in_list(A, allowed_assemblies)) return 0

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

//////////////////////////Math circuit////////////////////////
// * Autism
// * Only works in assembly frames. Performs one of the following operations between all variables/constants: ADD, SUBTRACT, MULTIPLY, DIVIDE, POWER, AVERAGE, MIN, MAX and trigonometric functions
// * Supports any amount of variable (= assembly) and constant (= number) values.
// * AVERAGE operator returns the average value of all values. AVERAGE x y z q = (x+y+z+q)/4
// * MIN and MAX operators return the smallest and the biggest values, respectively. MIN 5 1 4 = 1
// * Order of operations is always left to right. 2 POWER 2 POWER 4 = (2^2)^4 = 256
// * Invalid operations (division by zero) return 0. Come at me you math nerds

// * get_value(): returns result of the calculation

var/global/math_circuit_operations_list = list("ADD", "SUBTRACT", "MULTIPLY", "DIVIDE", "POWER", "AVERAGE", "MIN", "MAX", "SIN", "COS", "ASIN", "ACOS", "TG", "COTG")

#define VALUE(a) (isnum(a) ? a : a.get_value())

/obj/item/device/assembly/math
	name = "math circuit"

	desc = "A tiny circuit intended for use in assembly frames. It performs simple math operations like addition, multiplication, and powers."
	icon_state = "circuit_math"
	starting_materials = list(MAT_IRON = 200, MAT_GLASS = 75)
	w_type = RECYK_ELECTRONIC

	origin_tech = "programming=2"

	//wires = WIRE_PULSE | WIRE_RECEIVE

	var/list/obj/item/device/assembly/values = list()
	var/operation = "ADD"

/obj/item/device/assembly/math/interact(mob/user as mob)
	var/dat = ""

	dat += "<tt>Math circuit</tt> <small>\[<a href='?src=\ref[src];help=1'>?</a>\]</small><BR><BR>"

	dat += "<b>VALUE</b> = "

	var/operation_sign = ","

	var/last_written_value = values.len //Index of the value that is written last in the interface. Default of values.len means that ALL values are written. Setting it to 1 will cause only the first value to be shown

	switch(operation)
		if("AVERAGE")	dat += "AVERAGE of "
		if("MIN")		dat += "SMALLEST VALUE from "
		if("MAX")		dat += "LARGEST VALUE from "

		if("SIN")		dat += "SIN of "
		if("COS")		dat += "COS of "
		if("ASIN")		dat += "ARCSIN of "
		if("ACOS")		dat += "ARCCOS of "
		if("TG")		dat += "TANGENT of "
		if("COTG")		dat += "COTANGENT of "

		if("ADD")		operation_sign = "+"
		if("SUBTRACT")	operation_sign = "-"
		if("MULTIPLY")	operation_sign = "*"
		if("DIVIDE")	operation_sign = "/"
		if("POWER")		operation_sign = "^"

	if(operation in list("SIN","COS","ASIN","ACOS","TG","COTG"))
		last_written_value = 1 //Only the first value is processed when using the functions above

	if(values.len)
		for(var/i = 1 to last_written_value)
			var/A = values[i]

			dat += "<a href='?src=\ref[src];change_value=[i]'><b>[A]</b></a>"

			if(i < last_written_value)
				dat += operation_sign //If we're writing the last value, skip the sign (to avoid the extra sign at the end, like VALUE == 6 + 12 + 51 +)

	dat += "<BR>"
	dat += "<p><a href='?src=\ref[src];add_const=1'>Add constant</a></p>"
	dat += "<p>Operation: <a href='?src=\ref[src];change_operation=1'>[operation]</a></p>"
	dat += "<p><a href='?src=\ref[src];output_value=1'>Output value</a></p><BR>"
	dat += "All operations are done left-to-right. All trigonometric functions use degrees."

	var/datum/browser/popup = new(user, "circuit3", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "circuit3")

	return

/obj/item/device/assembly/math/Topic(href, href_list)
	if(..()) return

	if(href_list["output_value"])
		to_chat(usr, "<span class='info'>Result: [get_value()]</span>")
		return

	if(href_list["add_const"])
		spawn()
			var/choice = input(usr, "Please enter the constant's value:", "\The [src]") as null|num

			if(isnull(choice)) return
			if(..()) return

			values += choice
			to_chat(usr, "<span class='info'>Added new constant value <b>[choice]</b> to \the [src].</span>")

			attack_self(usr)
		return

	if(href_list["change_operation"])
		spawn()
			var/choice = input(usr, "Current operation is [operation]. Please select a new operation:", "\The [src]") as null|anything in math_circuit_operations_list

			if(isnull(choice)) return
			if(..()) return

			to_chat(usr, "<span class='info'>Changed operation from [operation] to [choice].</span>")
			operation = choice

			attack_self(usr)
		return

	if(href_list["change_value"])
		var/id = text2num(href_list["change_value"])

		if(id > values.len) return

		var/changed_value = values[id]

		if(isnum(changed_value)) //Constant
			spawn()
				var/choice = input(usr, "Please enter the constant ([changed_value])'s new value. Leave blank to delete the constant from \the [src]'s memory.", "\The [src]", changed_value) as null|num

				if(id > values.len) return
				if(values[id] != changed_value) return
				if(..()) return

				if(isnull(choice)) //Not number
					to_chat(usr, "<span class='info'>Removed the constant [values[id]].")
					values.Remove(changed_value)
				else //Wrote a number - change it
					to_chat(usr, "<span class='info'>Changed the constant [values[id]] to [choice].</span>")
					values[id] = choice

				attack_self(usr)

/obj/item/device/assembly/math/get_value()
	if(!values.len) return 0

	if(values.len == 1)
		var/obj/item/device/assembly/a = values[1]
		return VALUE(a)

	switch(operation)
		if("AVERAGE")
			. = 0

			for(var/number in values) //Add all values in the list together
				var/obj/item/device/assembly/a = number
				. += VALUE(a)

			. = . / values.len //Divide the resulting value by the length of the list
		if("MIN") //Return minimum value
			var/list/L = list()
			for(var/number in values)
				var/obj/item/device/assembly/a = number
				L += VALUE(a)

			. = min(L)
		if("MAX") //Return maximum value
			var/list/L = list()
			for(var/number in values)
				var/obj/item/device/assembly/a = number
				L += VALUE(a)

			. = max(L)

		if("COS")
			var/obj/item/device/assembly/a = values[1]
			. = cos(VALUE(a))
		if("SIN")
			var/obj/item/device/assembly/a = values[1]
			. = sin(VALUE(a))
		if("TG")
			var/obj/item/device/assembly/a = values[1]

			if(cos(VALUE(a)) == 0) return 0 //Avoid division by 0

			. = sin(VALUE(a)) / cos(VALUE(a))
		if("COTG")
			var/obj/item/device/assembly/a = values[1]

			if(sin(VALUE(a)) == 0) return 0 //Avoid division by 0

			. = cos(VALUE(a)) / sin(VALUE(a))
		if("ACOS")
			var/obj/item/device/assembly/a = values[1]
			. = arccos(VALUE(a))
		if("ASIN")
			var/obj/item/device/assembly/a = values[1]
			. = arcsin(VALUE(a))

		else

			var/obj/item/device/assembly/a = values[1]
			. = VALUE(a)

			for(var/i = 2 to values.len)
				var/number = values[i]

				if(istype(number, /obj/item/device/assembly))
					var/obj/item/device/assembly/A = number

					number = A.get_value()

				switch(operation)
					if("ADD")
						. += number
					if("SUBTRACT")
						. -= number
					if("MULTIPLY")
						. *= number
					if("DIVIDE")
						if(number == 0) return 0

						. /= number
					if("POWER")
						if(. < 0)
							if(number != round(number)) //No fractions in the exponent if value is negative
								return 0

						. = . ** number

	. = round(. , 0.00001) //Round to 5 decimal places (prevent shit like cos(90) = 6.12323e-017)

/obj/item/device/assembly/math/connected(var/obj/item/device/assembly/A, in_frame)
	..()

	if(istype(A, /obj/item/device/assembly/math))
		var/obj/item/device/assembly/math/M = A

		if(src in M.values)
			return //No infinite loops

	values |= A

/obj/item/device/assembly/math/disconnected(var/obj/item/device/assembly/A, in_frame)
	..()
	values.Remove(A)
