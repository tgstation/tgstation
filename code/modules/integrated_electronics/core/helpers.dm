/obj/item/integrated_circuit/proc/setup_io(var/list/io_list, var/io_type, var/list/io_default_list)
	var/list/io_list_copy = io_list.Copy()
	io_list.Cut()
	var/i = 0
	for(var/io_entry in io_list_copy)
		var/default_data = null
		var/io_type_override = null
		// Override the default data.
		if(io_default_list && io_default_list.len) // List containing special pin types that need to be added.
			default_data = io_default_list["[i]"] // This is deliberately text because the index is a number in text form.
		// Override the pin type.
		if(io_list_copy[io_entry])
			io_type_override = io_list_copy[io_entry]

		if(io_type_override)
	//		world << "io_type_override is now [io_type_override] on [src]."
			io_list.Add(new io_type_override(src, io_entry, default_data))
		else
			io_list.Add(new io_type(src, io_entry, default_data))

/obj/item/integrated_circuit/proc/set_pin_data(var/pin_type, var/pin_number, var/new_data)
	var/datum/integrated_io/pin = get_pin_ref(pin_type, pin_number)
	return pin.write_data_to_pin(new_data)

/obj/item/integrated_circuit/proc/get_pin_data(var/pin_type, var/pin_number)
	var/datum/integrated_io/pin = get_pin_ref(pin_type, pin_number)
	return pin.get_data()

/obj/item/integrated_circuit/proc/get_pin_data_as_type(var/pin_type, var/pin_number, var/as_type)
	var/datum/integrated_io/pin = get_pin_ref(pin_type, pin_number)
	return pin.data_as_type(as_type)

/obj/item/integrated_circuit/proc/activate_pin(var/pin_number)
	var/datum/integrated_io/activate/A = activators[pin_number]
	A.push_data()

/datum/integrated_io/proc/get_data()
	if(isnull(data))
		return
	if(isweakref(data))
		return data.resolve()
	return data

/obj/item/integrated_circuit/proc/get_pin_ref(var/pin_type, var/pin_number)
	switch(pin_type)
		if(IC_INPUT)
			if(pin_number > inputs.len)
				return null
			return inputs[pin_number]
		if(IC_OUTPUT)
			if(pin_number > outputs.len)
				return null
			return outputs[pin_number]
		if(IC_ACTIVATOR)
			if(pin_number > activators.len)
				return null
			return activators[pin_number]
	return null

/obj/item/integrated_circuit/proc/handle_wire(var/datum/integrated_io/pin, var/obj/item/device/integrated_electronics/tool)
	if(istype(tool, /obj/item/device/integrated_electronics/wirer))
		var/obj/item/device/integrated_electronics/wirer/wirer = tool
		if(pin)
			wirer.wire(pin, usr)
			return 1

	else if(istype(tool, /obj/item/device/integrated_electronics/debugger))
		var/obj/item/device/integrated_electronics/debugger/debugger = tool
		if(pin)
			debugger.write_data(pin, usr)
			return 1
	return 0

/obj/item/integrated_circuit/proc/asc2b64(var/S)
    var/list/b64 = list(
    					"A"=0,"B"=1,"C"=2,"D"=3,
    					"E"=4,"F"=5,"G"=6,"H"=7,
    					"I"=8,"J"=9,"K"=10,"L"=11,
    					"M"=12,"N"=13,"O"=14,"P"=15,
    					"Q"=16,"R"=17,"S"=18,"T"=19,
    					"U"=20,"V"=21,"W"=22,"X"=23,
    					"Y"=24,"Z"=25,"a"=26,"b"=27,
    					"c"=28,"d"=29,"e"=30,"f"=31,
    					"g"=32,"h"=33,"i"=34,"j"=35,
    					"k"=36,"l"=37,"m"=38,"n"=39,
    					"o"=40,"p"=41,"q"=42,"r"=43,
    					"s"=44,"t"=45,"u"=46,"v"=47,
    					"w"=48,"x"=49,"y"=50,"z"=51,
    					"0"=52,"1"=53,"2"=54,"3"=55,
    					"4"=56,"5"=57,"6"=58,"7"=59,
    					"8"=60,"9"=61,","=62,"."=63
    					)
    var/ls = lentext(S)
    var/c
    var/sb1
    var/sb2
    var/sb3
    var/cb1
    var/cb2
    var/cb3
    var/cb4
    var/i=1
    while(i <= ls)
        sb1=text2ascii(S,i)
        sb2=text2ascii(S,i+1)
        sb3=text2ascii(S,i+2)
        cb1 = (sb1 & 252)>>2
        cb2 = ((sb1 & 3)<<6 | (sb2 & 240)>>2)>>2
        cb3 = (sb2 & 15)<<2 | (sb3 & 192)>>6
        cb4 = (sb3 & 63)
        c=c+b64[cb1+1]+b64[cb2+1]+b64[cb3+1]+b64[cb4+1]
        i=i+3
    return c

/obj/item/integrated_circuit/proc/b642asc(var/S)
	var/list/b64 = list("A"=1,"B"=2,"C"=3,"D"=4,"E"=5,"F"=6,"G"=7,"H"=8,"I"=9,"J"=10,"K"=11,"L"=12,"M"=13,"N"=14,"O"=15,"P"=16,"Q"=17,"R"=18,
	"S"=19,"T"=20,"U"=21,"V"=22,"W"=23,"X"=24,"Y"=25,"Z"=26,"a"=27,"b"=28,"c"=29,"d"=30,"e"=31,"f"=32,"g"=33,"h"=34,"i"=35,"j"=36,"k"=37,"l"=38,"m"=39,"n"=40,"o"=41,
	"p"=42,"q"=43,"r"=44,"s"=45,"t"=46,"u"=47,"v"=48,"w"=49,"x"=50,"y"=51,"z"=52,"0"=53,"1"=54,"2"=55,"3"=56,"4"=57,"5"=58,"6"=59,"7"=60,"8"=61,"9"=62,","=63,"."=64)
	var/ls = lentext(S)
	var/c=""
	var/sb1=0
	var/sb2=0
	var/sb3=0
	var/cb1=0
	var/cb2=0
	var/cb3=0
	var/cb4=0
	var/i=1
	while(i<=ls)
		cb1=b64[copytext(S,i,i+1)]-1
		cb2=b64[copytext(S,i+1,i+2)]-1
		cb3=b64[copytext(S,i+2,i+3)]-1
		cb4=b64[copytext(S,i+3,i+4)]-1
		sb1=cb1<<2 | (cb2 & 48)>>4
		sb2=(cb2 & 15) <<4 | (cb3 & 60)>>2
		sb3=(cb3 & 3)<<6 | cb4
		c=c+ascii2text(sb1)+ascii2text(sb2)+ascii2text(sb3)
		i=i+4
	return c