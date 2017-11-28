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
	to_chat(user, "<span class='notice'>You press the button labeled '[src]'.</span>")
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
	to_chat(user, "<span class='notice'>You toggle the button labeled '[src]' [get_pin_data(IC_OUTPUT, 1) ? "on" : "off"].</span>")

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
	var/new_input = stripped_input(user, "Enter some words, please.","Number pad")
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

/obj/item/integrated_circuit/input/plant_scanner
	name = "integrated plant analyzer"
	desc = "A very small version of the plant analyser.  This allows the machine to know all valuable params of plants in trays.  \
			it can't scan seeds and fruits.only plants."
	icon_state = "medscan_adv"
	complexity = 12
	inputs = list("\<REF\> target")
	outputs = list(
		"plant type"		= IC_PINTYPE_STRING,
		"age"		= IC_PINTYPE_NUMBER,
		"potency"	= IC_PINTYPE_NUMBER,
		"yield"			= IC_PINTYPE_NUMBER,
		"Maturation speed"			= IC_PINTYPE_NUMBER,
		"Production speed"			= IC_PINTYPE_NUMBER,
		"Endurance"			= IC_PINTYPE_NUMBER,
		"Lifespan"			= IC_PINTYPE_NUMBER,
		"Weed Growth Rate"		= IC_PINTYPE_NUMBER,
		"Weed Vulnerability"	= IC_PINTYPE_NUMBER,
		"Weed level"			= IC_PINTYPE_NUMBER,
		"Pest level"			= IC_PINTYPE_NUMBER,
		"Toxicity level"			= IC_PINTYPE_NUMBER,
		"Water level"			= IC_PINTYPE_NUMBER,
		"Nutrition level"			= IC_PINTYPE_NUMBER,
		"harvest"			= IC_PINTYPE_NUMBER,
		"dead"			= IC_PINTYPE_NUMBER    ,
		"plant health"			= IC_PINTYPE_NUMBER
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 10

/obj/item/integrated_circuit/input/plant_scanner/do_work()
	var/obj/machinery/hydroponics/H = get_pin_data_as_type(IC_INPUT, 1, /obj/machinery/hydroponics)
	if(!istype(H)) //Invalid input
		return
	for(var/i=1, i<=outputs.len, i++)
		set_pin_data(IC_OUTPUT, i, null)
	if(H in view(get_turf(H))) // Like medbot's analyzer it can be used in range..
		if(H.myseed)
			set_pin_data(IC_OUTPUT, 1, H.myseed.plantname)
			set_pin_data(IC_OUTPUT, 2, H.age)
			set_pin_data(IC_OUTPUT, 3, H.myseed.potency)
			set_pin_data(IC_OUTPUT, 4, H.myseed.yield)
			set_pin_data(IC_OUTPUT, 5, H.myseed.maturation)
			set_pin_data(IC_OUTPUT, 6, H.myseed.production)
			set_pin_data(IC_OUTPUT, 7, H.myseed.endurance)
			set_pin_data(IC_OUTPUT, 8, H.myseed.lifespan)
			set_pin_data(IC_OUTPUT, 9, H.myseed.weed_rate)
			set_pin_data(IC_OUTPUT, 10, H.myseed.weed_chance)
		set_pin_data(IC_OUTPUT, 11, H.weedlevel)
		set_pin_data(IC_OUTPUT, 12, H.pestlevel)
		set_pin_data(IC_OUTPUT, 13, H.toxic)
		set_pin_data(IC_OUTPUT, 14, H.waterlevel)
		set_pin_data(IC_OUTPUT, 15, H.nutrilevel)
		set_pin_data(IC_OUTPUT, 16, H.harvest)
		set_pin_data(IC_OUTPUT, 17, H.dead)
		set_pin_data(IC_OUTPUT, 18, H.plant_health)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/gene_scanner
	name = "gene scanner"
	desc = "This circuit will scan plant for traits and reagent genes."
	extended_desc = "This allows the machine to scan plants in trays for reagent and trait genes.  \
			it can't scan seeds and fruits.only plants."
	inputs = list(
		"\<REF\> target" = IC_PINTYPE_REF
	)
	outputs = list(
		"traits" = IC_PINTYPE_LIST,
		"reagents" = IC_PINTYPE_LIST
	)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	icon_state = "medscan_adv"
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/input/gene_scanner/do_work()
	var/list/gtraits = list()
	var/list/greagents = list()
	var/obj/machinery/hydroponics/H = get_pin_data_as_type(IC_INPUT, 1, /obj/machinery/hydroponics)
	if(!istype(H)) //Invalid input
		return
	for(var/i=1, i<=outputs.len, i++)
		set_pin_data(IC_OUTPUT, i, null)
	if(H in view(get_turf(H))) // Like medbot's analyzer it can be used in range..
		if(H.myseed)
			for(var/datum/plant_gene/reagent/G in H.myseed.genes)
				greagents.Add(G.get_name())

			for(var/datum/plant_gene/trait/G in H.myseed.genes)
				gtraits.Add(G.get_name())

	set_pin_data(IC_OUTPUT, 1, gtraits)
	set_pin_data(IC_OUTPUT, 2, greagents)
	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/input/examiner
	name = "examiner"
	desc = "It' s a little machine vision system. It can return the name, description, distance, \
	relative coordinates, total amount of reagents, maximum amount of reagents, density and opacity of the referenced object."
	icon_state = "video_camera"
	complexity = 6
	inputs = list(
		"target" = IC_PINTYPE_REF
		)
	outputs = list(
		"name"	            	= IC_PINTYPE_STRING,
		"description"       	= IC_PINTYPE_STRING,
		"X"         			= IC_PINTYPE_NUMBER,
		"Y"			            = IC_PINTYPE_NUMBER,
		"distance"			    = IC_PINTYPE_NUMBER,
		"max reagents"			= IC_PINTYPE_NUMBER,
		"amount of reagents"    = IC_PINTYPE_NUMBER,
		"density"    			= IC_PINTYPE_BOOLEAN,
		"opacity"    			= IC_PINTYPE_BOOLEAN,
		)
	activators = list(
		"scan" = IC_PINTYPE_PULSE_IN,
		"on scanned" = IC_PINTYPE_PULSE_OUT,
		"not scanned" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_RESEARCH
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
		set_pin_data(IC_OUTPUT, 8, H.density)
		set_pin_data(IC_OUTPUT, 9, H.opacity)
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
			O.data = WEAKREF(assembly.loc)

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
		O.data = WEAKREF(pick(valid_things))
		activate_pin(2)
	else
		activate_pin(3)
	O.push_data()

/obj/item/integrated_circuit/input/advanced_locator_list
	complexity = 6
	name = "list advanced locator"
	desc = "This is needed for certain devices that demand list of names for a targets to act upon.  This type locates something \
	that is standing in given radius up to 8 meters"
	extended_desc = "The first pin requires list a kinds of object that you want the locator to acquire. If  This means that it will \
	give refs to nearby objects that are similar. It will locate objects by given names and description,given in list. It will give list of all found objects.\
	.The second pin is a radius"
	inputs = list("desired type ref" = IC_PINTYPE_LIST, "radius" = IC_PINTYPE_NUMBER)
	outputs = list("located ref" = IC_PINTYPE_LIST)
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
	var/list/nearby_things = view(radius,T)
	var/list/valid_things = list()
	var/list/GI = list()
	GI = I.data
	for(var/G in GI)
		if(isweakref(G))									//It should search by refs. But don't want.will fix it later.
			var/datum/integrated_io/G1
			G1.data = G
			var/atom/A = G1.data.resolve()
			var/desired_type = A.type
			for(var/atom/thing in nearby_things)
				if(thing.type != desired_type)
					continue
				valid_things.Add(WEAKREF(thing))
		else if(istext(G))
			for(var/atom/thing in nearby_things)
				if(findtext(addtext(thing.name," ",thing.desc), G, 1, 0) )
					valid_things.Add(WEAKREF(thing))
	if(valid_things.len)
		O.data = valid_things
		O.push_data()
		activate_pin(2)
	else
		O.push_data()
		activate_pin(3)

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
	var/list/nearby_things =  view(radius,T)
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
		O.data = WEAKREF(pick(valid_things))
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
	power_draw_idle = 5
	power_draw_per_use = 40

	var/frequency = 1457
	var/code = 30
	var/datum/radio_frequency/radio_connection

/obj/item/integrated_circuit/input/signaler/Initialize()
	..()
	spawn(40)
		set_frequency(frequency)
		// Set the pins so when someone sees them, they won't show as null
		set_pin_data(IC_INPUT, 1, frequency)
		set_pin_data(IC_INPUT, 2, code)

/obj/item/integrated_circuit/input/signaler/Destroy()
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
	if(!SSradio)
		sleep(20)
	if(!SSradio)
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
		audible_message("[icon2html(src, hearers(src))] *beep* *beep*", null, 1)

/obj/item/integrated_circuit/input/ntnet_packet
	name = "NTNet networking circuit"
	desc = "Enables the sending and receiving of messages on NTNet with packet data protocol."
	extended_desc = "Data can be send or received using the \
	second pin on each side, with additonal data reserved for the third pin.  When a message is received, the second activation pin \
	will pulse whatever's connected to it.  Pulsing the first activation pin will send a message."
	icon_state = "signal"
	complexity = 4
	inputs = list(
		"target NTNet address"	= IC_PINTYPE_STRING,
		"data to send"			= IC_PINTYPE_STRING,
		"secondary text"		= IC_PINTYPE_STRING,
		"passkey"				= IC_PINTYPE_STRING,							//No this isn't a real passkey encryption scheme but that's why you keep your nodes secure so no one can find it out!
		)
	outputs = list(
		"address received"			= IC_PINTYPE_STRING,
		"data received"				= IC_PINTYPE_STRING,
		"secondary text received"	= IC_PINTYPE_STRING,
		"passkey"				= IC_PINTYPE_STRING
		)
	activators = list("send data" = IC_PINTYPE_PULSE_IN, "on data received" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 50
	var/datum/ntnet_connection/exonet = null

/obj/item/integrated_circuit/input/ntnet_packet/Initialize()
	. = ..()
	var/datum/component/ntnet_interface/net = LoadComponent(/datum/component/ntnet_interface)
	desc += "<br>This circuit's NTNet hardware address is: [net.hardware_id]"

/obj/item/integrated_circuit/input/ntnet_packet/do_work()
	var/target_address = get_pin_data(IC_INPUT, 1)
	var/message = get_pin_data(IC_INPUT, 2)
	var/text = get_pin_data(IC_INPUT, 3)
	var/key = get_pin_data(IC_INPUT, 4)

	var/datum/netdata/data = new
	data.recipient_ids += target_address
	data.plaintext_data = message
	data.plaintext_data_secondary = text
	data.plaintext_passkey = key
	ntnet_send(data)

/obj/item/integrated_circuit/input/ntnet_recieve(datum/netdata/data)
	set_pin_data(IC_OUTPUT, 1, length(data.recipient_ids) >= 1? data.recipient_ids[1] : null)
	set_pin_data(IC_OUTPUT, 2, data.plaintext_data)
	set_pin_data(IC_OUTPUT, 3, data.plaintext_data_secondary)
	set_pin_data(IC_OUTPUT, 4, data.plaintext_passkey)

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
	outputs = list("X"= IC_PINTYPE_NUMBER, "Y" = IC_PINTYPE_NUMBER, "Z" = IC_PINTYPE_NUMBER)
	activators = list("get coordinates" = IC_PINTYPE_PULSE_IN, "on get coordinates" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30

/obj/item/integrated_circuit/input/gps/do_work()
	var/turf/T = get_turf(src)

	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, null)
	if(!T)
		return

	set_pin_data(IC_OUTPUT, 1, T.x)
	set_pin_data(IC_OUTPUT, 2, T.y)
	set_pin_data(IC_OUTPUT, 3, T.z)

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
	flags_1 = CONDUCT_1 | HEAR_1
	outputs = list(
	"speaker" = IC_PINTYPE_STRING,
	"message" = IC_PINTYPE_STRING
	)
	activators = list("on message received" = IC_PINTYPE_PULSE_OUT, "on translation" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 5

/obj/item/integrated_circuit/input/microphone/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, message_mode)
	var/translated = FALSE
	if(speaker && message)
		if(raw_message)
			if(message_langs != get_default_language())
				translated = TRUE
		set_pin_data(IC_OUTPUT, 1, speaker.GetVoice())
		set_pin_data(IC_OUTPUT, 2, raw_message)

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
		if(istype(A, /obj/item/storage))
			return FALSE

	set_pin_data(IC_OUTPUT, 1, WEAKREF(A))
	push_data()
	activate_pin(1)
	return TRUE

/obj/item/integrated_circuit/input/sensor/ranged
	name = "ranged sensor"
	desc = "Scans and obtains a reference for any objects or persons in range.  All you need to do is point the machine towards target."
	extended_desc = "If 'ignore storage' pin is set to true, the sensor will disregard scanning various storage containers such as backpacks."
	icon_state = "recorder"
	complexity = 36
	inputs = list("ignore storage" = IC_PINTYPE_BOOLEAN)
	outputs = list("scanned" = IC_PINTYPE_REF)
	activators = list("on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 120

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
	power_draw_per_use = 1

/obj/item/integrated_circuit/input/internalbm/do_work()
	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, null)
	set_pin_data(IC_OUTPUT, 4, WEAKREF(assembly))
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
	power_draw_per_use = 1

/obj/item/integrated_circuit/input/externalbm/do_work()

	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, null)
	if(AM)
		var/obj/item/stock_parts/cell/C = AM.get_cell()
		if(C)
			var/turf/A = get_turf(src)
			if(get_turf(AM) in view(A))
				set_pin_data(IC_OUTPUT, 1, C.charge)
				set_pin_data(IC_OUTPUT, 2, C.maxcharge)
				set_pin_data(IC_OUTPUT, 3, C.percent())
	activate_pin(2)
	push_data()
	return
