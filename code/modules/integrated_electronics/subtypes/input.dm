/obj/item/integrated_circuit/input
	var/can_be_asked_input = 0
	category_text = "Input"
	power_draw_per_use = 5

/obj/item/integrated_circuit/input/proc/ask_for_input(mob/user)
	return

/obj/item/integrated_circuit/input/button
	name = "button"
	desc = "This tiny button must do something, right?"
	icon_state = "button"
	complexity = 1
	can_be_asked_input = 1
	inputs = list()
	outputs = list()
	activators = list("on pressed" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH



/obj/item/integrated_circuit/input/button/ask_for_input(mob/user) //Bit misleading name for this specific use.
	to_chat(user, "<span class='notice'>You press the button labeled '[src.name]'.</span>")
	activate_pin(1)

/obj/item/integrated_circuit/input/toggle_button
	name = "toggle button"
	desc = "It toggles on, off, on, off..."
	icon_state = "toggle_button"
	complexity = 1
	can_be_asked_input = 1
	inputs = list()
	outputs = list("on" = IC_PINTYPE_BOOLEAN)
	activators = list("on toggle" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/input/toggle_button/ask_for_input(mob/user) // Ditto.
	set_pin_data(IC_OUTPUT, 1, !get_pin_data(IC_OUTPUT, 1))
	push_data()
	activate_pin(1)
	to_chat(user, "<span class='notice'>You toggle the button labeled '[src.name]' [get_pin_data(IC_OUTPUT, 1) ? "on" : "off"].</span>")

/obj/item/integrated_circuit/input/numberpad
	name = "number pad"
	desc = "This small number pad allows someone to input a number into the system."
	icon_state = "numberpad"
	complexity = 2
	can_be_asked_input = 1
	inputs = list()
	outputs = list("number entered" = IC_PINTYPE_NUMBER)
	activators = list("on entered" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4

/obj/item/integrated_circuit/input/numberpad/ask_for_input(mob/user)
	var/new_input = input(user, "Enter a number, please.","Number pad") as null|num
	if(isnum(new_input) && user.IsAdvancedToolUser())
		set_pin_data(IC_OUTPUT, 1, new_input)
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/textpad
	name = "text pad"
	desc = "This small text pad allows someone to input a string into the system."
	icon_state = "textpad"
	complexity = 2
	can_be_asked_input = 1
	inputs = list()
	outputs = list("string entered" = IC_PINTYPE_STRING)
	activators = list("on entered" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4

/obj/item/integrated_circuit/input/textpad/ask_for_input(mob/user)
	var/new_input = input(user, "Enter some words, please.","Number pad") as null|text
	if(istext(new_input) && user.IsAdvancedToolUser())
		set_pin_data(IC_OUTPUT, 1, new_input)
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/med_scanner
	name = "integrated medical analyser"
	desc = "A very small version of the common medical analyser.  This allows the machine to know how healthy someone is."
	icon_state = "medscan"
	complexity = 4
	inputs = list("\<REF\> target")
	outputs = list(
		"total health %" = IC_PINTYPE_NUMBER,
		"total missing health" = IC_PINTYPE_NUMBER
		)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_BIO = 2)
	power_draw_per_use = 40

/obj/item/integrated_circuit/input/med_scanner/do_work()
	var/mob/living/carbon/human/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living/carbon/human)
	if(!istype(H)) //Invalid input
		return
	if(H.Adjacent(get_turf(src))) // Like normal analysers, it can't be used at range.
		var/total_health = round(H.health/H.getMaxHealth(), 0.01)*100
		var/missing_health = H.getMaxHealth() - H.health

		set_pin_data(IC_OUTPUT, 1, total_health)
		set_pin_data(IC_OUTPUT, 2, missing_health)

	push_data()
	activate_pin(2)
/*
/obj/item/integrated_circuit/input/pressure_plate
	name = "pressure plate"
	desc = "Electronic plate with a scanner, that could retrieve references to things,that was put onto the machine"
	icon_state = "pressure_plate"
	complexity = 4
	inputs = list()
	outputs = list("laid" = IC_PINTYPE_REF, "removed" = IC_PINTYPE_REF)
	activators = list("laid" = IC_PINTYPE_PULSE_OUT, "removed" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_BIO = 2)
	power_draw_per_use = 40
	var/list/cont

/obj/item/integrated_circuit/input/pressure_plate/New()
	..()
	processing_objects |= src

/obj/item/integrated_circuit/input/pressure_plate/Destroy()
	processing_objects -= src

/obj/item/integrated_circuit/input/pressure_plate/process()
	var/list/newcont
	var/turf/T = get_turf(src)
	newcont = T.contents
	var/list/U = cont & newcont
	for(var/laid in U)
		if(!(laid in cont))
			var/datum/integrated_io/O = outputs[1]
			O.data = weakref(laid)
			O.push_data()
			activate_pin(1)
			break
	for(var/removed in U)
		if(!(removed in newcont))
			var/datum/integrated_io/O = outputs[2]
			O.data = weakref(removed)
			O.push_data()
			activate_pin(2)
			break
	cont = newcont

*/


/obj/item/integrated_circuit/input/adv_med_scanner
	name = "integrated advanced medical analyser"
	desc = "A very small version of the medbot's medical analyser.  This allows the machine to know how healthy someone is.  \
	This type is much more precise, allowing the machine to know much more about the target than a normal analyzer."
	icon_state = "medscan_adv"
	complexity = 12
	inputs = list("\<REF\> target")
	outputs = list(
		"total health %"		= IC_PINTYPE_NUMBER,
		"total missing health"	= IC_PINTYPE_NUMBER,
		"brute damage"			= IC_PINTYPE_NUMBER,
		"burn damage"			= IC_PINTYPE_NUMBER,
		"tox damage"			= IC_PINTYPE_NUMBER,
		"oxy damage"			= IC_PINTYPE_NUMBER,
		"clone damage"			= IC_PINTYPE_NUMBER
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3, TECH_BIO = 4)
	power_draw_per_use = 80

/obj/item/integrated_circuit/input/adv_med_scanner/do_work()
	var/mob/living/carbon/human/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living/carbon/human)
	if(!istype(H)) //Invalid input
		return
	if(H in view(get_turf(H))) // Like medbot's analyzer it can be used in range..
		var/total_health = round(H.health/H.getMaxHealth(), 0.01)*100
		var/missing_health = H.getMaxHealth() - H.health

		set_pin_data(IC_OUTPUT, 1, total_health)
		set_pin_data(IC_OUTPUT, 2, missing_health)
		set_pin_data(IC_OUTPUT, 3, H.getBruteLoss())
		set_pin_data(IC_OUTPUT, 4, H.getFireLoss())
		set_pin_data(IC_OUTPUT, 5, H.getToxLoss())
		set_pin_data(IC_OUTPUT, 6, H.getOxyLoss())
		set_pin_data(IC_OUTPUT, 7, H.getCloneLoss())

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/examiner
	name = "examiner"
	desc = "It' s a little machine vision system. It can return the name, description, distance, \
	relative coordinates, total amount of reagents, and maximum amount of reagents of the referenced object."
	icon_state = "video_camera"
	complexity = 6
	inputs = list("\<REF\> target" = IC_PINTYPE_REF)
	outputs = list(
		"name"	            	= IC_PINTYPE_STRING,
		"description"       	= IC_PINTYPE_STRING,
		"X"         			= IC_PINTYPE_NUMBER,
		"Y"			            = IC_PINTYPE_NUMBER,
		"distance"			    = IC_PINTYPE_NUMBER,
		"max reagents"			= IC_PINTYPE_NUMBER,
		"amount of reagents"    = IC_PINTYPE_NUMBER,
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT, "not scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3, TECH_BIO = 4)
	power_draw_per_use = 80

/obj/item/integrated_circuit/input/examiner/do_work()
	var/atom/movable/H = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	var/turf/T = get_turf(src)
	if(!istype(H)) //Invalid input
		return

	if(H in view(T)) // This is a camera. It can't examine thngs,that it can't see.


		set_pin_data(IC_OUTPUT, 1, H.name)
		set_pin_data(IC_OUTPUT, 2, H.desc)
		set_pin_data(IC_OUTPUT, 3, H.x-T.x)
		set_pin_data(IC_OUTPUT, 4, H.y-T.y)
		set_pin_data(IC_OUTPUT, 5, sqrt((H.x-T.x)*(H.x-T.x)+ (H.y-T.y)*(H.y-T.y)))
		var/mr = 0
		var/tr = 0
		if(H.reagents)
			mr = H.reagents.maximum_volume
			tr = H.reagents.total_volume
		set_pin_data(IC_OUTPUT, 6, mr)
		set_pin_data(IC_OUTPUT, 7, tr)
		push_data()
		activate_pin(2)
	else
		activate_pin(3)

/obj/item/integrated_circuit/input/local_locator
	name = "local locator"
	desc = "This is needed for certain devices that demand a reference for a target to act upon.  This type only locates something \
	that is holding the machine containing it."
	inputs = list()
	outputs = list("located ref")
	activators = list("locate" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 20

/obj/item/integrated_circuit/input/local_locator/do_work()
	var/datum/integrated_io/O = outputs[1]
	O.data = null
	if(assembly)
		if(istype(assembly.loc, /mob/living)) // Now check if someone's holding us.
			O.data = weakref(assembly.loc)

	O.push_data()

/obj/item/integrated_circuit/input/adjacent_locator
	name = "adjacent locator"
	desc = "This is needed for certain devices that demand a reference for a target to act upon.  This type only locates something \
	that is standing a meter away from the machine."
	extended_desc = "The first pin requires a ref to a kind of object that you want the locator to acquire.  This means that it will \
	give refs to nearby objects that are similar.  If more than one valid object is found nearby, it will choose one of them at \
	random."
	inputs = list("desired type ref")
	outputs = list("located ref")
	activators = list("locate" = IC_PINTYPE_PULSE_IN,"found" = IC_PINTYPE_PULSE_OUT,
		"not found" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30

/obj/item/integrated_circuit/input/adjacent_locator/do_work()
	var/datum/integrated_io/I = inputs[1]
	var/datum/integrated_io/O = outputs[1]
	O.data = null

	if(!isweakref(I.data))
		return
	var/atom/A = I.data.resolve()
	if(!A)
		return
	var/desired_type = A.type

	var/list/nearby_things = range(1, get_turf(src))
	var/list/valid_things = list()
	for(var/atom/thing in nearby_things)
		if(thing.type != desired_type)
			continue
		valid_things.Add(thing)
	if(valid_things.len)
		O.data = weakref(pick(valid_things))
		activate_pin(2)
	else
		activate_pin(3)
	O.push_data()
/*
/obj/item/integrated_circuit/input/advanced_locator_list
	complexity = 6
	name = "list advanced locator"
	desc = "This is needed for certain devices that demand a reference for a target to act upon.  This type locates something \
	that is standing in given radius up to 8 meters"
	extended_desc = "The first pin requires list a kinds of object that you want the locator to acquire. If  This means that it will \
	give refs to nearby objects that are similar. It will locate objects by given names,refs and description,given in list. If more than one valid object is found nearby,\
	 it will choose one of them at 	random.The second pin is a radius"
	inputs = list("desired type ref" = IC_PINTYPE_LIST, "radius" = IC_PINTYPE_NUMBER)
	outputs = list("located ref")
	activators = list("locate" = IC_PINTYPE_PULSE_IN,"found" = IC_PINTYPE_PULSE_OUT,"not found" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30
	var/radius = 1

/obj/item/integrated_circuit/input/advanced_locator_list/on_data_written()
	var/rad = get_pin_data(IC_INPUT, 2)

	if(isnum(rad))
		rad = Clamp(rad, 0, 8)
		radius = rad

/obj/item/integrated_circuit/input/advanced_locator_list/do_work()
    var/datum/integrated_io/I = inputs[1]
    var/datum/integrated_io/O = outputs[1]
    O.data = null
    var/turf/T = get_turf(src)
    var/list/nearby_things = range(radius, T) & view(T)
    var/list/valid_things = list()
    var/list/GI = list()
    GI = I
    for(var/datum/integrated_io/G in GI)
        if(isweakref(G.data))
            var/atom/A = G.data.resolve()
            var/desired_type = A.type
            for(var/atom/thing in nearby_things)
                if(thing.type != desired_type)
                    continue
                valid_things.Add(thing)
        else if(istext(G.data))
            var/DT = G.data
            for(var/atom/thing in nearby_things)
                if(findtext(addtext(thing.name," ",thing.desc), DT, 1, 0) )
                    valid_things.Add(thing)
    if(valid_things.len)
        O.data = weakref(pick(valid_things))
        O.push_data()
        activate_pin(2)
    else
        O.push_data()
        activate_pin(3)
*/
/obj/item/integrated_circuit/input/advanced_locator
	complexity = 6
	name = "advanced locator"
	desc = "This is needed for certain devices that demand a reference for a target to act upon. This type locates something \
	that is standing in given radius up to 8 meters"
	extended_desc = "The first pin requires a ref to a kind of object that you want the locator to acquire. If  This means that it will \
	give refs to nearby objects that are similar. If this pin is string, locator will search\
	 item by matching desired text in name + description. If more than one valid object is found nearby, it will choose one of them at \
	random. The second pin is a radius."
	inputs = list("desired type" = IC_PINTYPE_ANY, "radius" = IC_PINTYPE_NUMBER)
	outputs = list("located ref")
	activators = list("locate" = IC_PINTYPE_PULSE_IN,"found" = IC_PINTYPE_PULSE_OUT,"not found" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30
	var/radius = 1

/obj/item/integrated_circuit/input/advanced_locator/on_data_written()
	var/rad = get_pin_data(IC_INPUT, 2)
	if(isnum(rad))
		rad = Clamp(rad, 0, 8)
		radius = rad

/obj/item/integrated_circuit/input/advanced_locator/do_work()
	var/datum/integrated_io/I = inputs[1]
	var/datum/integrated_io/O = outputs[1]
	O.data = null
	var/turf/T = get_turf(src)
	var/list/nearby_things = range(radius, T) & view(T)
	var/list/valid_things = list()
	if(isweakref(I.data))
		var/atom/A = I.data.resolve()
		var/desired_type = A.type
		if(desired_type)
			for(var/atom/thing in nearby_things)
				if(thing.type == desired_type)
					valid_things.Add(thing)
	else if(istext(I.data))
		var/DT = I.data
		for(var/atom/thing in nearby_things)
			if(findtext(addtext(thing.name," ",thing.desc), DT, 1, 0) )
				valid_things.Add(thing)
	if(valid_things.len)
		O.data = weakref(pick(valid_things))
		O.push_data()
		activate_pin(2)
	else
		O.push_data()
		activate_pin(3)





/obj/item/integrated_circuit/input/signaler
	name = "integrated signaler"
	desc = "Signals from a signaler can be received with this, allowing for remote control.  Additionally, it can send signals as well."
	extended_desc = "When a signal is received from another signaler, the 'on signal received' activator pin will be pulsed.  \
	The two input pins are to configure the integrated signaler's settings.  Note that the frequency should not have a decimal in it.  \
	Meaning the default frequency is expressed as 1457, not 145.7.  To send a signal, pulse the 'send signal' activator pin."
	icon_state = "signal"
	complexity = 4
	inputs = list("frequency" = IC_PINTYPE_NUMBER,"code" = IC_PINTYPE_NUMBER)
	outputs = list()
	activators = list(
		"send signal" = IC_PINTYPE_PULSE_IN,
		"on signal sent" = IC_PINTYPE_PULSE_OUT,
		"on signal received" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_MAGNET = 2)
	power_draw_idle = 5
	power_draw_per_use = 40

	var/frequency = 1457
	var/code = 30
	var/datum/radio_frequency/radio_connection

/obj/item/integrated_circuit/input/signaler/initialize()
	..()
	set_frequency(frequency)
	// Set the pins so when someone sees them, they won't show as null
	set_pin_data(IC_INPUT, 1, frequency)
	set_pin_data(IC_INPUT, 2, code)

/obj/item/integrated_circuit/input/signaler/Destroy()
	if(radio_controller)
		SSradio.remove_object(src,frequency)

	frequency = 0
	return ..()

/obj/item/integrated_circuit/input/signaler/on_data_written()
	var/new_freq = get_pin_data(IC_INPUT, 1)
	var/new_code = get_pin_data(IC_INPUT, 2)
	if(isnum(new_freq) && new_freq > 0)
		set_frequency(new_freq)
	if(isnum(new_code))
		code = new_code


/obj/item/integrated_circuit/input/signaler/do_work() // Sends a signal.
	if(!radio_connection)
		return

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"
	radio_connection.post_signal(src, signal)

	activate_pin(2)

/obj/item/integrated_circuit/input/signaler/proc/set_frequency(new_frequency)
	if(!frequency)
		return
	if(!radio_controller)
		sleep(20)
	if(!radio_controller)
		return
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, GLOB.RADIO_CHAT)

/obj/item/integrated_circuit/input/signaler/receive_signal(datum/signal/signal)
	var/new_code = get_pin_data(IC_INPUT, 2)
	var/code = 0

	if(isnum(new_code))
		code = new_code
	if(!signal)
		return 0
	if(signal.encryption != code)
		return 0
	if(signal.source == src) // Don't trigger ourselves.
		return 0

	activate_pin(3)

	for(var/mob/O in hearers(1, get_turf(src)))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)

/obj/item/integrated_circuit/input/EPv2
	name = "\improper EPv2 circuit"
	desc = "Enables the sending and receiving of messages on the Exonet with the EPv2 protocol."
	extended_desc = "An EPv2 address is a string with the format of XXXX:XXXX:XXXX:XXXX.  Data can be send or received using the \
	second pin on each side, with additonal data reserved for the third pin.  When a message is received, the second activaiton pin \
	will pulse whatever's connected to it.  Pulsing the first activation pin will send a message."
	icon_state = "signal"
	complexity = 4
	inputs = list(
		"target EPv2 address"	= IC_PINTYPE_STRING,
		"data to send"			= IC_PINTYPE_STRING,
		"secondary text"		= IC_PINTYPE_STRING
		)
	outputs = list(
		"address received"			= IC_PINTYPE_STRING,
		"data received"				= IC_PINTYPE_STRING,
		"secondary text received"	= IC_PINTYPE_STRING
		)
	activators = list("send data" = IC_PINTYPE_PULSE_IN, "on data received" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_MAGNET = 2, TECH_BLUESPACE = 2)
	power_draw_per_use = 50
	var/datum/exonet_protocol/exonet = null

/obj/item/integrated_circuit/input/EPv2/New()
	..()
	exonet = new(src)
	exonet.make_address("EPv2_circuit-\ref[src]")
	desc += "<br>This circuit's EPv2 address is: [exonet.address]"

/obj/item/integrated_circuit/input/EPv2/Destroy()
	if(exonet)
		exonet.remove_address()
		qdel(exonet)
		exonet = null
	return ..()

/obj/item/integrated_circuit/input/EPv2/do_work()
	var/target_address = get_pin_data(IC_INPUT, 1)
	var/message = get_pin_data(IC_INPUT, 2)
	var/text = get_pin_data(IC_INPUT, 3)

	if(target_address && istext(target_address))
		exonet.send_message(target_address, message, text)

/obj/item/integrated_circuit/input/receive_exonet_message(var/atom/origin_atom, var/origin_address, var/message, var/text)
	set_pin_data(IC_OUTPUT, 1, origin_address)
	set_pin_data(IC_OUTPUT, 2, message)
	set_pin_data(IC_OUTPUT, 3, text)

	push_data()
	activate_pin(2)

//This circuit gives information on where the machine is.
/obj/item/integrated_circuit/input/gps
	name = "global positioning system"
	desc = "This allows you to easily know the position of a machine containing this device."
	extended_desc = "The GPS's coordinates it gives is absolute, not relative."
	icon_state = "gps"
	complexity = 4
	inputs = list()
	outputs = list("X"= IC_PINTYPE_NUMBER, "Y" = IC_PINTYPE_NUMBER)
	activators = list("get coordinates" = IC_PINTYPE_PULSE_IN, "on get coordinates" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30

/obj/item/integrated_circuit/input/gps/do_work()
	var/turf/T = get_turf(src)

	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	if(!T)
		return

	set_pin_data(IC_OUTPUT, 1, T.x)
	set_pin_data(IC_OUTPUT, 2, T.y)

	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/input/microphone
	name = "microphone"
	desc = "Useful for spying on people or for voice activated machines."
	extended_desc = "This will automatically translate most languages it hears to Galactic Common.  \
	The first activation pin is always pulsed when the circuit hears someone talk, while the second one \
	is only triggered if it hears someone speaking a language other than Galactic Common."
	icon_state = "recorder"
	complexity = 8
	inputs = list()
	outputs = list(
	"speaker" = IC_PINTYPE_STRING,
	"message" = IC_PINTYPE_STRING
	)
	activators = list("on message received" = IC_PINTYPE_PULSE_IN, "on translation" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 15

/obj/item/integrated_circuit/input/microphone/New()
	..()
	listening_objects |= src

/obj/item/integrated_circuit/input/microphone/Destroy()
	listening_objects -= src
	return ..()

/obj/item/integrated_circuit/input/microphone/hear_talk(mob/living/M, msg, var/verb="says", datum/language/speaking=null)
	var/translated = FALSE
	if(M && msg)
		if(speaking)
			if(!speaking.machine_understands)
				msg = speaking.scramble(msg)
			if(!istype(speaking, /datum/language/common))
				translated = TRUE
		set_pin_data(IC_OUTPUT, 1, M.GetVoice())
		set_pin_data(IC_OUTPUT, 2, msg)

	push_data()
	activate_pin(1)
	if(translated)
		activate_pin(2)



/obj/item/integrated_circuit/input/sensor
	name = "sensor"
	desc = "Scans and obtains a reference for any objects or persons near you.  All you need to do is shove the machine in their face."
	extended_desc = "If 'ignore storage' pin is set to true, the sensor will disregard scanning various storage containers such as backpacks."
	icon_state = "recorder"
	complexity = 12
	inputs = list("ignore storage" = IC_PINTYPE_BOOLEAN)
	outputs = list("scanned" = IC_PINTYPE_REF)
	activators = list("on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 120

/obj/item/integrated_circuit/input/sensor/proc/scan(var/atom/A)
	var/ignore_bags = get_pin_data(IC_INPUT, 1)
	if(ignore_bags)
		if(istype(A, /obj/item/weapon/storage))
			return FALSE

	set_pin_data(IC_OUTPUT, 1, weakref(A))
	push_data()
	activate_pin(1)
	return TRUE

/obj/item/integrated_circuit/input/internalbm
	name = "internal battery monitor"
	desc = "This monitors the charge level of an internal battery."
	icon_state = "internalbm"
	extended_desc = "This circuit will give you values of charge, max charge and percentage of the internal battery on demand."
	w_class = WEIGHT_CLASS_TINY
	complexity = 1
	inputs = list()
	outputs = list(
		"cell charge" = IC_PINTYPE_NUMBER,
		"max charge" = IC_PINTYPE_NUMBER,
		"percentage" = IC_PINTYPE_NUMBER,
		"refference to assembly" = IC_PINTYPE_REF
		)
	activators = list("read" = IC_PINTYPE_PULSE_IN, "on read" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 4, TECH_DATA = 4, TECH_POWER = 4, TECH_MAGNET = 3)
	power_draw_per_use = 1

/obj/item/integrated_circuit/input/internalbm/do_work()
	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, null)
	set_pin_data(IC_OUTPUT, 4, weakref(assembly))
	if(assembly)
		if(assembly.battery)

			set_pin_data(IC_OUTPUT, 1, assembly.battery.charge)
			set_pin_data(IC_OUTPUT, 2, assembly.battery.maxcharge)
			set_pin_data(IC_OUTPUT, 3, 100*assembly.battery.charge/assembly.battery.maxcharge)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/externalbm
	name = "external battery monitor"
	desc = "This can help to watch battery state of any device in view"
	icon_state = "externalbm"
	extended_desc = "This circuit will give you values of charge, max charge and percentage of any device or battery in view"
	w_class = WEIGHT_CLASS_TINY
	complexity = 2
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"cell charge" = IC_PINTYPE_NUMBER,
		"max charge" = IC_PINTYPE_NUMBER,
		"percentage" = IC_PINTYPE_NUMBER
		)
	activators = list("read" = IC_PINTYPE_PULSE_IN, "on read" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 4, TECH_DATA = 4, TECH_POWER = 4, TECH_MAGNET = 3)
	power_draw_per_use = 1

/obj/item/integrated_circuit/input/externalbm/do_work()

	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, null)
	if(AM)


		var/obj/item/stock_parts/cell/cell = null
		if(istype(AM, /obj/item/stock_parts/cell)) // Is this already a cell?
			cell = AM
		else // If not, maybe there's a cell inside it?
			for(var/obj/item/stock_parts/cell/C in AM.contents)
				if(C) // Find one cell to charge.
					cell = C
					break
		if(cell)

			var/turf/A = get_turf(src)
			if(AM in view(A))
				push_data()
				set_pin_data(IC_OUTPUT, 1, cell.charge)
				set_pin_data(IC_OUTPUT, 2, cell.maxcharge)
				set_pin_data(IC_OUTPUT, 3, cell.percent())
	push_data()
	activate_pin(2)


