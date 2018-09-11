//These circuits convert one variable to another.
/obj/item/integrated_circuit/converter
	complexity = 2
	inputs = list("input")
	outputs = list("output")
	activators = list("convert" = IC_PINTYPE_PULSE_IN, "on convert" = IC_PINTYPE_PULSE_OUT)
	category_text = "Converter"
	power_draw_per_use = 10

/obj/item/integrated_circuit/converter/num2text
	name = "number to string"
	desc = "This circuit can convert a number variable into a string."
	extended_desc = "Because of circuit limitations, null/false variables will output a '0' string."
	icon_state = "num-string"
	inputs = list("input" = IC_PINTYPE_NUMBER)
	outputs = list("output" = IC_PINTYPE_STRING)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/num2text/do_work()
	var/result = null
	pull_data()
	var/incoming = get_pin_data(IC_INPUT, 1)
	if(!isnull(incoming))
		result = num2text(incoming)
	else if(!incoming)
		result = "0"

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/text2num
	name = "string to number"
	desc = "This circuit can convert a string variable into a number."
	icon_state = "string-num"
	inputs = list("input" = IC_PINTYPE_STRING)
	outputs = list("output" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/text2num/do_work()
	var/result = null
	pull_data()
	var/incoming = get_pin_data(IC_INPUT, 1)
	if(!isnull(incoming))
		result = text2num(incoming)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/ref2text
	name = "reference to string"
	desc = "This circuit can convert a reference to something else to a string, specifically the name of that reference."
	icon_state = "ref-string"
	inputs = list("input" = IC_PINTYPE_REF)
	outputs = list("output" = IC_PINTYPE_STRING)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/ref2text/do_work()
	var/result = null
	pull_data()
	var/atom/A = get_pin_data(IC_INPUT, 1)
	if(A && istype(A))
		result = A.name

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/refcode
	name = "reference encoder"
	desc = "This circuit can encode a reference into a string, which can then be read by a reference decoder circuit."
	icon_state = "ref-string"
	inputs = list("input" = IC_PINTYPE_REF)
	outputs = list("output" = IC_PINTYPE_STRING)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/refcode/do_work()
	var/result = null
	pull_data()
	var/atom/A = get_pin_data(IC_INPUT, 1)
	if(A && istype(A))
		result = strtohex(XorEncrypt(REF(A), SScircuit.cipherkey))

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/refdecode
	name = "reference decoder"
	desc = "This circuit can convert an encoded reference to an actual reference."
	icon_state = "ref-string"
	inputs = list("input" = IC_PINTYPE_STRING)
	outputs = list("output" = IC_PINTYPE_REF)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/dec

/obj/item/integrated_circuit/converter/refdecode/do_work()
	pull_data()
	dec = XorEncrypt(hextostr(get_pin_data(IC_INPUT, 1), TRUE), SScircuit.cipherkey)
	set_pin_data(IC_OUTPUT, 1, WEAKREF(locate(dec)))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/lowercase
	name = "lowercase string converter"
	desc = "this circuit will cause a string to come out in all lowercase."
	icon_state = "lowercase"
	inputs = list("input" = IC_PINTYPE_STRING)
	outputs = list("output" = IC_PINTYPE_STRING)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/lowercase/do_work()
	var/result = null
	pull_data()
	var/incoming = get_pin_data(IC_INPUT, 1)
	if(!isnull(incoming))
		result = lowertext(incoming)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/uppercase
	name = "uppercase string converter"
	desc = "THIS WILL CAUSE A STRING TO COME OUT IN ALL UPPERCASE."
	icon_state = "uppercase"
	inputs = list("input" = IC_PINTYPE_STRING)
	outputs = list("output" = IC_PINTYPE_STRING)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/uppercase/do_work()
	var/result = null
	pull_data()
	var/incoming = get_pin_data(IC_INPUT, 1)
	if(!isnull(incoming))
		result = uppertext(incoming)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/concatenator
	name = "concatenator"
	desc = "This can join up to 8 strings together to get one big string."
	complexity = 4
	inputs = list()
	outputs = list("result" = IC_PINTYPE_STRING)
	activators = list("concatenate" = IC_PINTYPE_PULSE_IN, "on concatenated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/number_of_pins = 8

/obj/item/integrated_circuit/converter/concatenator/Initialize()
	for(var/i = 1 to number_of_pins)
		inputs["input [i]"] = IC_PINTYPE_STRING
	. = ..()

/obj/item/integrated_circuit/converter/concatenator/do_work()
	var/result = null
	for(var/k in 1 to inputs.len)
		var/I = get_pin_data(IC_INPUT, k)
		if(!isnull(I))
			result = result + I

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/concatenator/small
	name = "small concatenator"
	desc = "This can join up to 4 strings together to get one big string."
	complexity = 2
	number_of_pins = 4

/obj/item/integrated_circuit/converter/concatenator/large
	name = "large concatenator"
	desc = "This can join up to 16 strings together to get one very big string."
	complexity = 6
	number_of_pins = 16

/obj/item/integrated_circuit/converter/separator
	name = "separator"
	desc = "This splits a single string into two at the relative split point."
	extended_desc = "This circuit splits a given string into two, based on the string and the index value. \
	The index splits the string <b>after</b> the given index, including spaces. So 'a person' with an index of '3' \
	will split into 'a p' and 'erson'."
	icon_state = "split"
	complexity = 4
	inputs = list(
		"string to split" = IC_PINTYPE_STRING,
		"index" = IC_PINTYPE_NUMBER,
		)
	outputs = list(
		"before split" = IC_PINTYPE_STRING,
		"after split" = IC_PINTYPE_STRING
		)
	activators = list("separate" = IC_PINTYPE_PULSE_IN, "on separated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/separator/do_work()
	var/text = get_pin_data(IC_INPUT, 1)
	var/index = get_pin_data(IC_INPUT, 2)

	var/split = min(index+1, length(text))

	var/before_text = copytext(text, 1, split)
	var/after_text = copytext(text, split, 0)

	set_pin_data(IC_OUTPUT, 1, before_text)
	set_pin_data(IC_OUTPUT, 2, after_text)
	push_data()

	activate_pin(2)

/obj/item/integrated_circuit/converter/indexer
	name = "indexer"
	desc = "This circuit takes a string and an index value, then returns the character found at in the string at the given index."
	extended_desc = "Make sure the index is not longer or shorter than the string length. If you don't, the circuit will return empty."
	icon_state = "split"
	complexity = 4
	inputs = list(
		"string to index" = IC_PINTYPE_STRING,
		"index" = IC_PINTYPE_NUMBER,
		)
	outputs = list(
		"found character" = IC_PINTYPE_STRING
		)
	activators = list("index" = IC_PINTYPE_PULSE_IN, "on indexed" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/indexer/do_work()
	var/strin = get_pin_data(IC_INPUT, 1)
	var/ind = get_pin_data(IC_INPUT, 2)
	if(ind > 0 && ind <= length(strin))
		set_pin_data(IC_OUTPUT, 1, strin[ind])
	else
		set_pin_data(IC_OUTPUT, 1, "")
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/findstring
	name = "find text"
	desc = "This outputs the position of the sample in the string, or returns 0."
	extended_desc = "The first pin is the string to be examined. The second pin is the sample to be found. \
	For example, inputting 'my wife has caught on fire' with 'has' as the sample will give you position 9. \
	This circuit isn't case sensitive, and it does not ignore spaces."
	complexity = 4
	inputs = list(
		"string" = IC_PINTYPE_STRING,
		"sample" = IC_PINTYPE_STRING,
		)
	outputs = list(
		"position" = IC_PINTYPE_NUMBER
		)
	activators = list("search" = IC_PINTYPE_PULSE_IN, "after search" = IC_PINTYPE_PULSE_OUT, "found" = IC_PINTYPE_PULSE_OUT, "not found" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH



/obj/item/integrated_circuit/converter/findstring/do_work()
	var/position = findtext(get_pin_data(IC_INPUT, 1),get_pin_data(IC_INPUT, 2))

	set_pin_data(IC_OUTPUT, 1, position)
	push_data()

	activate_pin(2)
	if(position)
		activate_pin(3)
	else
		activate_pin(4)

/obj/item/integrated_circuit/converter/stringlength
	name = "get length"
	desc = "This circuit will return the number of characters in a string."
	complexity = 1
	inputs = list(
		"string" = IC_PINTYPE_STRING
		)
	outputs = list(
		"length" = IC_PINTYPE_NUMBER
		)
	activators = list("get length" = IC_PINTYPE_PULSE_IN, "on acquisition" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/stringlength/do_work()
	set_pin_data(IC_OUTPUT, 1, length(get_pin_data(IC_INPUT, 1)))
	push_data()

	activate_pin(2)

/obj/item/integrated_circuit/converter/exploders
	name = "string exploder"
	desc = "This splits a single string into a list of strings."
	extended_desc = "This circuit splits a given string into a list of strings based on the string and given delimiter. \
	For example, 'eat this burger' will be converted to list('eat','this','burger'). Leave the delimiter null to get a list \
	of every individual character."
	icon_state = "split"
	complexity = 4
	inputs = list(
		"string to split" = IC_PINTYPE_STRING,
		"delimiter" = IC_PINTYPE_STRING,
		)
	outputs = list(
		"list" = IC_PINTYPE_LIST
		)
	activators = list("separate" = IC_PINTYPE_PULSE_IN, "on separated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/exploders/do_work()
	var/strin = get_pin_data(IC_INPUT, 1)
	var/delimiter = get_pin_data(IC_INPUT, 2)
	if(delimiter == null)
		set_pin_data(IC_OUTPUT, 1, string2charlist(strin))
	else
		set_pin_data(IC_OUTPUT, 1, splittext(strin, delimiter))
	push_data()

	activate_pin(2)

/obj/item/integrated_circuit/converter/radians2degrees
	name = "radians to degrees converter"
	desc = "Converts radians to degrees."
	inputs = list("radian" = IC_PINTYPE_NUMBER)
	outputs = list("degrees" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/radians2degrees/do_work()
	var/result = null
	pull_data()
	var/incoming = get_pin_data(IC_INPUT, 1)
	if(!isnull(incoming))
		result = TODEGREES(incoming)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/degrees2radians
	name = "degrees to radians converter"
	desc = "Converts degrees to radians."
	inputs = list("degrees" = IC_PINTYPE_NUMBER)
	outputs = list("radians" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/degrees2radians/do_work()
	var/result = null
	pull_data()
	var/incoming = get_pin_data(IC_INPUT, 1)
	if(!isnull(incoming))
		result = TORADIANS(incoming)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/converter/abs_to_rel_coords
	name = "abs to rel coordinate converter"
	desc = "Easily convert absolute coordinates to relative coordinates with this."
	extended_desc = "Keep in mind that both sets of input coordinates should be absolute."
	complexity = 1
	inputs = list(
		"X1" = IC_PINTYPE_NUMBER,
		"Y1" = IC_PINTYPE_NUMBER,
		"X2" = IC_PINTYPE_NUMBER,
		"Y2" = IC_PINTYPE_NUMBER
		)
	outputs = list(
		"X" = IC_PINTYPE_NUMBER,
		"Y" = IC_PINTYPE_NUMBER
		)
	activators = list("compute rel coordinates" = IC_PINTYPE_PULSE_IN, "on convert" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/abs_to_rel_coords/do_work()
	var/x1 = get_pin_data(IC_INPUT, 1)
	var/y1 = get_pin_data(IC_INPUT, 2)

	var/x2 = get_pin_data(IC_INPUT, 3)
	var/y2 = get_pin_data(IC_INPUT, 4)

	if(!isnull(x1) && !isnull(y1) && !isnull(x2) && !isnull(y2))
		set_pin_data(IC_OUTPUT, 1, x1 - x2)
		set_pin_data(IC_OUTPUT, 2, y1 - y2)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/rel_to_abs_coords
	name = "rel to abs coordinate converter"
	desc = "Convert relative coordinates to absolute coordinates with this."
	extended_desc = "Keep in mind that only one set of input coordinates should be absolute, and the other relative. \
	The output coordinates will be the absolute form of the input relative coordinates."
	complexity = 1
	inputs = list(
		"X1" = IC_PINTYPE_NUMBER,
		"Y1" = IC_PINTYPE_NUMBER,
		"X2" = IC_PINTYPE_NUMBER,
		"Y2" = IC_PINTYPE_NUMBER
		)
	outputs = list(
		"X" = IC_PINTYPE_NUMBER,
		"Y" = IC_PINTYPE_NUMBER
		)
	activators = list("compute abs coordinates" = IC_PINTYPE_PULSE_IN, "on convert" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/abs_to_rel_coords/do_work()
	var/x1 = get_pin_data(IC_INPUT, 1)
	var/y1 = get_pin_data(IC_INPUT, 2)

	var/x2 = get_pin_data(IC_INPUT, 3)
	var/y2 = get_pin_data(IC_INPUT, 4)

	if(!isnull(x1) && !isnull(y1) && !isnull(x2) && !isnull(y2))
		set_pin_data(IC_OUTPUT, 1, x1 + x2)
		set_pin_data(IC_OUTPUT, 2, y1 + y2)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/adv_rel_to_abs_coords
	name = "advanced rel to abs coordinate converter"
	desc = "Easily convert relative coordinates to absolute coordinates with this."
	extended_desc = "This circuit only requires a single set of relative inputs to output absolute coordinates."
	complexity = 2
	inputs = list(
		"X" = IC_PINTYPE_NUMBER,
		"Y" = IC_PINTYPE_NUMBER,
		)
	outputs = list(
		"X" = IC_PINTYPE_NUMBER,
		"Y" = IC_PINTYPE_NUMBER
		)
	activators = list("compute abs coordinates" = IC_PINTYPE_PULSE_IN, "on convert" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/abs_to_rel_coords/do_work()
	var/turf/T = get_turf(src)

	if(!T)
		return

	var/x1 = get_pin_data(IC_INPUT, 1)
	var/y1 = get_pin_data(IC_INPUT, 2)

	if(!isnull(x1) && !isnull(y1))
		set_pin_data(IC_OUTPUT, 1, T.x + x1)
		set_pin_data(IC_OUTPUT, 2, T.y + y1)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/hsv2hex
	name = "hsv to hexadecimal"
	desc = "This circuit can convert a HSV (Hue, Saturation, and Value) color to a Hexadecimal RGB color."
	extended_desc = "The first pin controls tint (0-359), the second pin controls how intense the tint is (0-255), and the third controls how bright the tint is (0 for black, 127 for normal, 255 for white)."
	icon_state = "hsv-hex"
	inputs = list(
		"hue" = IC_PINTYPE_NUMBER,
		"saturation" = IC_PINTYPE_NUMBER,
		"value" = IC_PINTYPE_NUMBER
	)
	outputs = list("hexadecimal rgb" = IC_PINTYPE_COLOR)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/hsv2hex/do_work()
	var/result = null
	pull_data()
	var/hue = get_pin_data(IC_INPUT, 1)
	var/saturation = get_pin_data(IC_INPUT, 2)
	var/value = get_pin_data(IC_INPUT, 3)
	if(isnum(hue)&&isnum(saturation)&&isnum(value))
		result = HSVtoRGB(hsv(AngleToHue(hue),saturation,value))

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/converter/rgb2hex
	name = "rgb to hexadecimal"
	desc = "This circuit can convert a RGB (Red, Green, Blue) color to a Hexadecimal RGB color."
	extended_desc = "The first pin controls red amount, the second pin controls green amount, and the third controls blue amount. They all go from 0-255."
	icon_state = "rgb-hex"
	inputs = list(
		"red" = IC_PINTYPE_NUMBER,
		"green" = IC_PINTYPE_NUMBER,
		"blue" = IC_PINTYPE_NUMBER
	)
	outputs = list("hexadecimal rgb" = IC_PINTYPE_COLOR)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/rgb2hex/do_work()
	var/result = null
	pull_data()
	var/red = get_pin_data(IC_INPUT, 1)
	var/green = get_pin_data(IC_INPUT, 2)
	var/blue = get_pin_data(IC_INPUT, 3)
	if(isnum(red)&&isnum(green)&&isnum(blue))
		result = rgb(red,green,blue)

	set_pin_data(IC_OUTPUT, 1, result)
	push_data()
	activate_pin(2)
