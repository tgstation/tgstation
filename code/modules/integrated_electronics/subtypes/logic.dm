/obj/item/integrated_circuit/logic
	name = "logic gate"
	desc = "This tiny chip will decide for you!"
	extended_desc = "Logic circuits will treat a null, 0, and a \"\" string value as FALSE and anything else as TRUE."
	complexity = 1
	outputs = list("result" = IC_PINTYPE_BOOLEAN)
	activators = list("compare" = IC_PINTYPE_PULSE_IN)
	category_text = "Logic"
	power_draw_per_use = 1

/obj/item/integrated_circuit/logic/do_work()
	push_data()

/obj/item/integrated_circuit/logic/binary
	inputs = list("A" = IC_PINTYPE_ANY,"B" = IC_PINTYPE_ANY)
	activators = list("compare" = IC_PINTYPE_PULSE_IN, "on true result" = IC_PINTYPE_PULSE_OUT, "on false result" = IC_PINTYPE_PULSE_OUT)

/obj/item/integrated_circuit/logic/binary/do_work()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	var/datum/integrated_io/O = outputs[1]
	O.data = do_compare(A, B) ? TRUE : FALSE

	if(get_pin_data(IC_OUTPUT, 1))
		activate_pin(2)
	else
		activate_pin(3)
	..()

/obj/item/integrated_circuit/logic/binary/proc/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return FALSE

/obj/item/integrated_circuit/logic/binary/proc/comparable(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return (isnum(A.data) && isnum(B.data)) || (istext(A.data) && istext(B.data))

/obj/item/integrated_circuit/logic/unary
	inputs = list("A" = IC_PINTYPE_ANY)
	activators = list("compare" = IC_PINTYPE_PULSE_IN, "on compare" = IC_PINTYPE_PULSE_OUT)

/obj/item/integrated_circuit/logic/unary/do_work()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/O = outputs[1]
	O.data = do_check(A) ? TRUE : FALSE
	..()
	activate_pin(2)

/obj/item/integrated_circuit/logic/unary/proc/do_check(var/datum/integrated_io/A)
	return FALSE

/obj/item/integrated_circuit/logic/binary/equals
	name = "equal gate"
	desc = "This gate compares two values, and outputs TRUE if both are the same."
	icon_state = "equal"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/equals/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data == B.data

/obj/item/integrated_circuit/logic/binary/jklatch
	name = "JK latch"
	desc = "This gate is a synchronized JK latch."
	icon_state = "jklatch"
	inputs = list("J" = IC_PINTYPE_ANY,"K" = IC_PINTYPE_ANY)
	outputs = list("Q" = IC_PINTYPE_BOOLEAN,"!Q" = IC_PINTYPE_BOOLEAN)
	activators = list("pulse in C" = IC_PINTYPE_PULSE_IN, "pulse out Q" = IC_PINTYPE_PULSE_OUT, "pulse out !Q" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/lstate=FALSE

/obj/item/integrated_circuit/logic/binary/jklatch/do_work()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	var/datum/integrated_io/O = outputs[1]
	var/datum/integrated_io/Q = outputs[2]
	if(A.data)
		if(B.data)
			lstate=!lstate
		else
			lstate = TRUE
	else
		if(B.data)
			lstate=FALSE
	O.data = lstate ? TRUE : FALSE
	Q.data = !lstate ? TRUE : FALSE
	if(get_pin_data(IC_OUTPUT, 1))
		activate_pin(2)
	else
		activate_pin(3)
	push_data()

/obj/item/integrated_circuit/logic/binary/rslatch
	name = "RS latch"
	desc = "This gate is a synchronized RS latch. If both R and S are true, its state will not change."
	icon_state = "sr_nor"
	inputs = list("S" = IC_PINTYPE_ANY,"R" = IC_PINTYPE_ANY)
	outputs = list("Q" = IC_PINTYPE_BOOLEAN,"!Q" = IC_PINTYPE_BOOLEAN)
	activators = list("pulse in C" = IC_PINTYPE_PULSE_IN, "pulse out Q" = IC_PINTYPE_PULSE_OUT, "pulse out !Q" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/lstate=FALSE

/obj/item/integrated_circuit/logic/binary/rslatch/do_work()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	var/datum/integrated_io/O = outputs[1]
	var/datum/integrated_io/Q = outputs[2]
	if(A.data)
		if(!B.data)
			lstate=TRUE
	else
		if(B.data)
			lstate=FALSE
	O.data = lstate ? TRUE : FALSE
	Q.data = !lstate ? TRUE : FALSE
	if(get_pin_data(IC_OUTPUT, 1))
		activate_pin(2)
	else
		activate_pin(3)
	push_data()

/obj/item/integrated_circuit/logic/binary/gdlatch
	name = "gated D latch"
	desc = "This gate is a synchronized gated D latch."
	icon_state = "gated_d"
	inputs = list("D" = IC_PINTYPE_ANY,"E" = IC_PINTYPE_ANY)
	outputs = list("Q" = IC_PINTYPE_BOOLEAN,"!Q" = IC_PINTYPE_BOOLEAN)
	activators = list("pulse in C" = IC_PINTYPE_PULSE_IN, "pulse out Q" = IC_PINTYPE_PULSE_OUT, "pulse out !Q" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/lstate=FALSE

/obj/item/integrated_circuit/logic/binary/gdlatch/do_work()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	var/datum/integrated_io/O = outputs[1]
	var/datum/integrated_io/Q = outputs[2]
	if(B.data)
		if(A.data)
			lstate=TRUE
		else
			lstate=FALSE

	O.data = lstate ? TRUE : FALSE
	Q.data = !lstate ? TRUE : FALSE
	if(get_pin_data(IC_OUTPUT, 1))
		activate_pin(2)
	else
		activate_pin(3)
	push_data()

/obj/item/integrated_circuit/logic/binary/not_equals
	name = "not equal gate"
	desc = "This gate compares two values, and outputs TRUE if both are different."
	icon_state = "not_equal"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/not_equals/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data != B.data

/obj/item/integrated_circuit/logic/binary/and
	name = "and gate"
	desc = "This gate will output TRUE if both inputs evaluate to true."
	icon_state = "and"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/and/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data && B.data

/obj/item/integrated_circuit/logic/binary/or
	name = "or gate"
	desc = "This gate will output TRUE if one of the inputs evaluate to true."
	icon_state = "or"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/or/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data || B.data

/obj/item/integrated_circuit/logic/binary/less_than
	name = "less than gate"
	desc = "This will output TRUE if the first input is less than the second input."
	icon_state = "less_than"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/less_than/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	if(comparable(A, B))
		return A.data < B.data

/obj/item/integrated_circuit/logic/binary/less_than_or_equal
	name = "less than or equal gate"
	desc = "This will output TRUE if the first input is less than, or equal to the second input."
	icon_state = "less_than_or_equal"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/less_than_or_equal/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	if(comparable(A, B))
		return A.data <= B.data

/obj/item/integrated_circuit/logic/binary/greater_than
	name = "greater than gate"
	desc = "This will output TRUE if the first input is greater than the second input."
	icon_state = "greater_than"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/greater_than/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	if(comparable(A, B))
		return A.data > B.data

/obj/item/integrated_circuit/logic/binary/greater_than_or_equal
	name = "greater than or equal gate"
	desc = "This will output TRUE if the first input is greater than, or equal to the second input."
	icon_state = "greater_than_or_equal"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/greater_than_or_equal/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	if(comparable(A, B))
		return A.data >= B.data

/obj/item/integrated_circuit/logic/unary/not
	name = "not gate"
	desc = "This gate inverts what's fed into it."
	icon_state = "not"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	activators = list("invert" = IC_PINTYPE_PULSE_IN, "on inverted" = IC_PINTYPE_PULSE_OUT)

/obj/item/integrated_circuit/logic/unary/not/do_check(var/datum/integrated_io/A)
	return !A.data
