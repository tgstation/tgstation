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

/obj/item/integrated_circuit/converter/rel_to_abs_coords/do_work()
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

/obj/item/integrated_circuit/converter/adv_rel_to_abs_coords/do_work()
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


// - hsv to rgb - //
/obj/item/integrated_circuit/converter/hsv2rgb
	name = "hsv to rgb"
	desc = "This circuit can convert a HSV (Hue, Saturation, and Value) color to a RGB (red, blue and green) color."
	extended_desc = "The first pin controls tint (0-359), the second pin controls how intense the tint is (0-255), and the third controls how bright the tint is (0 for black, 127 for normal, 255 for white)."
	icon_state = "hsv-hex"
	inputs = list(
		"hue" = IC_PINTYPE_NUMBER,
		"saturation" = IC_PINTYPE_NUMBER,
		"value" = IC_PINTYPE_NUMBER
	)
	outputs = list(
		"red" = IC_PINTYPE_NUMBER,
		"green" = IC_PINTYPE_NUMBER,
		"blue" = IC_PINTYPE_NUMBER
	)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
/obj/item/integrated_circuit/converter/hsv2rgb/do_work()
	var/hue = get_pin_data(IC_INPUT, 1)
	var/sat = get_pin_data(IC_INPUT, 2)
	var/val = get_pin_data(IC_INPUT, 3)
	if(!hue || !sat || !val)
		set_pin_data(IC_OUTPUT, 1, 0)
		set_pin_data(IC_OUTPUT, 2, 0)
		set_pin_data(IC_OUTPUT, 3, 0)
	else
		var/list/RGB = ReadRGB(HSVtoRGB(hsv(hue,sat,val)))
	
		set_pin_data(IC_OUTPUT, 1, RGB[1])
		set_pin_data(IC_OUTPUT, 2, RGB[2])
		set_pin_data(IC_OUTPUT, 3, RGB[3])
	push_data()
	activate_pin(2)


// - rgb to hsv - //
/obj/item/integrated_circuit/converter/rgb2hsv
	name = "rgb to hsv"
	desc = "This circuit can convert a RGB (Red, Blue, and Green) color to a HSV (Hue, Saturation and Value) color."
	extended_desc = "All values for the RGB colors are situated between 0 and 255."
	icon_state = "hsv-hex"
	inputs = list(
		"red" = IC_PINTYPE_NUMBER,
		"green" = IC_PINTYPE_NUMBER,
		"blue" = IC_PINTYPE_NUMBER
	)
	outputs = list(
		"hue" = IC_PINTYPE_NUMBER,
		"saturation" = IC_PINTYPE_NUMBER,
		"value" = IC_PINTYPE_NUMBER
	)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/rgb2hsv/do_work()
	var/red = get_pin_data(IC_INPUT, 1)
	var/blue = get_pin_data(IC_INPUT, 2)
	var/green = get_pin_data(IC_INPUT, 3)
	if(!red || !blue || !green)
		set_pin_data(IC_OUTPUT, 1, 0)
		set_pin_data(IC_OUTPUT, 2, 0)
		set_pin_data(IC_OUTPUT, 3, 0)
	else
		var/list/HSV = ReadHSV(RGBtoHSV(rgb(red,blue,green)))
	
		set_pin_data(IC_OUTPUT, 1, HSV[1])
		set_pin_data(IC_OUTPUT, 2, HSV[2])
		set_pin_data(IC_OUTPUT, 3, HSV[3])
	push_data()
	activate_pin(2)


// - hexadecimal to hsv - //
/obj/item/integrated_circuit/converter/hex2hsv
	name = "hexadecimal to hsv"
	desc = "This circuit can convert a Hexadecimal RGB color into a HSV (Hue, Saturation and Value) color."
	extended_desc = "Hexadecimal colors follow the format #RRBBGG, RR being the red value, BB the blue value and GG the green value. They are written in hexadecimal, giving each color a value from 0 (00) to 255 (FF)."
	icon_state = "hsv-hex"
	inputs = list("hexadecimal rgb" = IC_PINTYPE_COLOR)
	outputs = list(
		"hue" = IC_PINTYPE_NUMBER,
		"saturation" = IC_PINTYPE_NUMBER,
		"value" = IC_PINTYPE_NUMBER
	)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/hex2hsv/do_work()
	pull_data()
	var/rgb = get_pin_data(IC_INPUT, 1)
	if(!rgb)
		set_pin_data(IC_OUTPUT, 1, 0)
		set_pin_data(IC_OUTPUT, 2, 0)
		set_pin_data(IC_OUTPUT, 3, 0)
		return
	else
		var/list/hsv = ReadHSV(RGBtoHSV(rgb))
		set_pin_data(IC_OUTPUT, 1, hsv[1])
		set_pin_data(IC_OUTPUT, 2, hsv[2])
		set_pin_data(IC_OUTPUT, 3, hsv[3])
	push_data()
	activate_pin(2)


// - hex 2 rgb - //
/obj/item/integrated_circuit/converter/hex2rgb
	name = "hexadecimal to rgb"
	desc = "This circuit can convert a Hexadecimal RGB color into a RGB (Red, Blue and Green color."
	extended_desc = "Hexadecimal colors follow the format #RRBBGG, RR being the red value, BB the blue value and GG the green value. They are written in hexadecimal, giving each color a value from 0 (00) to 255 (FF)."
	icon_state = "hsv-hex"
	inputs = list("hexadecimal rgb" = IC_PINTYPE_COLOR)
	outputs = list(
		"red" = IC_PINTYPE_NUMBER,
		"green" = IC_PINTYPE_NUMBER,
		"blue" = IC_PINTYPE_NUMBER
	)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/converter/hex2rgb/do_work()
	var/rgb = get_pin_data(IC_INPUT, 1)
	if(!rgb)
		set_pin_data(IC_OUTPUT, 1, 0)
		set_pin_data(IC_OUTPUT, 2, 0)
		set_pin_data(IC_OUTPUT, 3, 0)
	else
		var/list/RGB = ReadRGB(rgb)
	
		set_pin_data(IC_OUTPUT, 1, RGB[1])
		set_pin_data(IC_OUTPUT, 2, RGB[2])
		set_pin_data(IC_OUTPUT, 3, RGB[3])

	push_data()
	activate_pin(2)
