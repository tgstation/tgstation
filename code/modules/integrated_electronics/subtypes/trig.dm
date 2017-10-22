//These circuits do not-so-simple math.
/obj/item/integrated_circuit/trig
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
	category_text = "Trig"
	extended_desc = "Input and output are in degrees."
	power_draw_per_use = 1 // Still cheap math.

// Sine //

/obj/item/integrated_circuit/trig/sine
	name = "sin circuit"
	desc = "Has nothing to do with evil, unless you consider trigonometry to be evil.  Outputs the sine of A."
	icon_state = "sine"
	inputs = list("A" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/trig/sine/do_work()
	pull_data()
	var/result = null
	var/A = get_pin_data(IC_INPUT, 1)
	if(!isnull(A))
		result = sin(A)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// Cosine //

/obj/item/integrated_circuit/trig/cosine
	name = "cos circuit"
	desc = "Outputs the cosine of A."
	icon_state = "cosine"
	inputs = list("A" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/trig/cosine/do_work()
	pull_data()
	var/result = null
	var/A = get_pin_data(IC_INPUT, 1)
	if(!isnull(A))
		result = cos(A)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// Tangent //

/obj/item/integrated_circuit/trig/tangent
	name = "tan circuit"
	desc = "Outputs the tangent of A.  Guaranteed to not go on a tangent about its existance."
	icon_state = "tangent"
	inputs = list("A" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/trig/tangent/do_work()
	pull_data()
	var/result = null
	var/A = get_pin_data(IC_INPUT, 1)
	if(!isnull(A))
		result = Tan(A)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

// Cosecant //

/obj/item/integrated_circuit/trig/cosecant
	name = "csc circuit"
	desc = "Outputs the cosecant of A."
	icon_state = "cosecant"
	inputs = list("A" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/trig/cosecant/do_work()
	pull_data()
	var/result = null
	var/A = get_pin_data(IC_INPUT, 1)
	if(!isnull(A))
		result = Csc(A)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)


// Secant //

/obj/item/integrated_circuit/trig/secant
	name = "sec circuit"
	desc = "Outputs the secant of A.  Has nothing to do with the security department."
	icon_state = "secant"
	inputs = list("A" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/trig/secant/do_work()
	pull_data()
	var/result = null
	var/A = get_pin_data(IC_INPUT, 1)
	if(!isnull(A))
		result = Sec(A)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)


// Cotangent //

/obj/item/integrated_circuit/trig/cotangent
	name = "cot circuit"
	desc = "Outputs the cotangent of A."
	icon_state = "cotangent"
	inputs = list("A" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/trig/cotangent/do_work()
	pull_data()
	var/result = null
	var/A = get_pin_data(IC_INPUT, 1)
	if(!isnull(A))
		result = Cot(A)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)