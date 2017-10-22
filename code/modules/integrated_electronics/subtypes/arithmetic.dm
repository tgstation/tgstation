//These circuits do simple math.
/obj/item/integrated_circuit/arithmetic
	complexity = 1
	inputs = list(
		"A" = IC_PINTYPE_NUMBER,
		"B" = IC_PINTYPE_NUMBER,
		"C" = IC_PINTYPE_NUMBER,
		"D" = IC_PINTYPE_NUMBER,
		"E" = IC_PINTYPE_NUMBER,
		"F" = IC_PINTYPE_NUMBER,
		"G" = IC_PINTYPE_NUMBER,
		"H" = IC_PINTYPE_NUMBER
		)
	outputs = list("result" = IC_PINTYPE_NUMBER)
	activators = list("compute" = IC_PINTYPE_PULSE_IN, "on computed" = IC_PINTYPE_PULSE_OUT)
	category_text = "Arithmetic"
	power_draw_per_use = 5 // Math is pretty cheap.

// +Adding+ //

/obj/item/integrated_circuit/arithmetic/addition
	name = "addition circuit"
	desc = "This circuit can add numbers together."
	extended_desc = "The order that the calculation goes is;<br>\
	result = ((((A + B) + C) + D) ... ) and so on, until all pins have been added.  \
	Null pins are ignored."
	icon_state = "addition"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/addition/do_work()
	var/result = 0
	for(var/datum/integrated_io/I in inputs)
		I.pull_data()
		if(isnum(I.data))
			result = result + I.data

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// -Subtracting- //

/obj/item/integrated_circuit/arithmetic/subtraction
	name = "subtraction circuit"
	desc = "This circuit can subtract numbers."
	extended_desc = "The order that the calculation goes is;<br>\
	result = ((((A - B) - C) - D) ... ) and so on, until all pins have been subtracted.  \
	Null pins are ignored.  Pin A <b>must</b> be a number or the circuit will not function."
	icon_state = "subtraction"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/subtraction/do_work()
	var/datum/integrated_io/A = inputs[1]
	if(!isnum(A.data))
		return
	var/result = A.data

	for(var/datum/integrated_io/I in inputs)
		if(I == A)
			continue
		I.pull_data()
		if(isnum(I.data))
			result = result - I.data

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// *Multiply* //

/obj/item/integrated_circuit/arithmetic/multiplication
	name = "multiplication circuit"
	desc = "This circuit can multiply numbers."
	extended_desc = "The order that the calculation goes is;<br>\
	result = ((((A * B) * C) * D) ... ) and so on, until all pins have been multiplied.  \
	Null pins are ignored.  Pin A <b>must</b> be a number or the circuit will not function."
	icon_state = "multiplication"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH


/obj/item/integrated_circuit/arithmetic/multiplication/do_work()
	var/datum/integrated_io/A = inputs[1]
	if(!isnum(A.data))
		return
	var/result = A.data
	for(var/datum/integrated_io/I in inputs)
		if(I == A)
			continue
		I.pull_data()
		if(isnum(I.data))
			result = result * I.data

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// /Division/  //

/obj/item/integrated_circuit/arithmetic/division
	name = "division circuit"
	desc = "This circuit can divide numbers, just don't think about trying to divide by zero!"
	extended_desc = "The order that the calculation goes is;<br>\
	result = ((((A / B) / C) / D) ... ) and so on, until all pins have been divided.  \
	Null pins, and pins containing 0, are ignored.  Pin A <b>must</b> be a number or the circuit will not function."
	icon_state = "division"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/division/do_work()
	var/datum/integrated_io/A = inputs[1]
	if(!isnum(A.data))
		return
	var/result = A.data

	for(var/datum/integrated_io/I in inputs)
		if(I == A)
			continue
		I.pull_data()
		if(isnum(I.data) && I.data != 0) //No runtimes here.
			result = result / I.data

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

//^ Exponent ^//

/obj/item/integrated_circuit/arithmetic/exponent
	name = "exponent circuit"
	desc = "Outputs A to the power of B."
	icon_state = "exponent"
	inputs = list("A" = IC_PINTYPE_NUMBER, "B" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/exponent/do_work()
	var/result = 0
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	if(isnum(A.data) && isnum(B.data))
		result = A.data ** B.data

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// +-Sign-+ //

/obj/item/integrated_circuit/arithmetic/sign
	name = "sign circuit"
	desc = "This will say if a number is positive, negative, or zero."
	extended_desc = "Will output 1, -1, or 0, depending on if A is a postive number, a negative number, or zero, respectively."
	icon_state = "sign"
	inputs = list("A" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/sign/do_work()
	var/result = 0
	var/datum/integrated_io/A = inputs[1]
	if(isnum(A.data))
		if(A.data > 0)
			result = 1
		else if (A.data < 0)
			result = -1
		else
			result = 0

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// Round //

/obj/item/integrated_circuit/arithmetic/round
	name = "round circuit"
	desc = "Rounds A to the nearest B multiple of A."
	extended_desc = "If B is not given a number, it will output the floor of A instead."
	icon_state = "round"
	inputs = list("A" = IC_PINTYPE_NUMBER, "B" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/round/do_work()
	var/result = 0
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	if(isnum(A.data))
		if(isnum(B.data) && B.data != 0)
			result = round(A.data, B.data)
		else
			result = round(A.data)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)


// Absolute //

/obj/item/integrated_circuit/arithmetic/absolute
	name = "absolute circuit"
	desc = "This outputs a non-negative version of the number you put in.  This may also be thought of as its distance from zero."
	icon_state = "absolute"
	inputs = list("A" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/absolute/do_work()
	var/result = 0
	for(var/datum/integrated_io/I in inputs)
		I.pull_data()
		if(isnum(I.data))
			result = abs(I.data)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// Averaging //

/obj/item/integrated_circuit/arithmetic/average
	name = "average circuit"
	desc = "This circuit is of average quality, however it will compute the average for numbers you give it."
	extended_desc = "Note that null pins are ignored, where as a pin containing 0 is included in the averaging calculation."
	icon_state = "average"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/average/do_work()
	var/result = 0
	var/inputs_used = 0
	for(var/datum/integrated_io/I in inputs)
		I.pull_data()
		if(isnum(I.data))
			inputs_used++
			result = result + I.data

	if(inputs_used)
		result = result / inputs_used

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// Pi, because why the hell not? //
/obj/item/integrated_circuit/arithmetic/pi
	name = "pi constant circuit"
	desc = "Not recommended for cooking.  Outputs '3.14159' when it receives a pulse."
	icon_state = "pi"
	inputs = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/pi/do_work()
	set_pin_data(IC_OUTPUT, 1, 3.14159)
	push_data()
	activate_pin(2)

// Random //
/obj/item/integrated_circuit/arithmetic/random
	name = "random number generator circuit"
	desc = "This gives a random (integer) number between values A and B inclusive."
	extended_desc = "'Inclusive' means that the upper bound is included in the range of numbers, e.g. L = 1 and H = 3 will allow \
	for outputs of 1, 2, or 3.  H being the higher number is not <i>strictly</i> required."
	icon_state = "random"
	inputs = list("L" = IC_PINTYPE_NUMBER,"H" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/random/do_work()
	var/result = 0
	var/L = get_pin_data(IC_INPUT, 1)
	var/H = get_pin_data(IC_INPUT, 2)

	if(isnum(L) && isnum(H))
		result = rand(L, H)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// Square Root //

/obj/item/integrated_circuit/arithmetic/square_root
	name = "square root circuit"
	desc = "This outputs the square root of a number you put in."
	icon_state = "square_root"
	inputs = list("A" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/square_root/do_work()
	var/result = 0
	for(var/datum/integrated_io/I in inputs)
		I.pull_data()
		if(isnum(I.data))
			result = sqrt(I.data)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// % Modulo % //

/obj/item/integrated_circuit/arithmetic/modulo
	name = "modulo circuit"
	desc = "Gets the remainder of A / B."
	icon_state = "modulo"
	inputs = list("A" = IC_PINTYPE_NUMBER, "B" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/arithmetic/modulo/do_work()
	var/result = 0
	var/A = get_pin_data(IC_INPUT, 1)
	var/B = get_pin_data(IC_INPUT, 2)
	if(isnum(A) && isnum(B) && B != 0)
		result = A % B

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

