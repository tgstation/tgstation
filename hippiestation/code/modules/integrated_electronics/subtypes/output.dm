//Text to radio
//Outputs a simple string into radio (good to couple with the interceptor)
//Input:
//Text: the actual string to output
//Frequency: what channel to output in. This is a STRING, not a number, due to how comms work. It has to be the frequency without the dot, aka for common you need to put "1459"
/obj/item/integrated_circuit/output/text_to_radio
	name = "text-to-radio circuit"
	desc = "Takes any string as an input and will make the device output it in the radio with the frequency chosen as input."
	extended_desc = "Similar to the text-to-speech circuit, except the fact that the text is converted into a subspace signal and broadcasted to the desired frequency, or 1459 as default.\
					The frequency is a number, and doesn't need the dot. Example: Common frequency is 145.9, so the result is 1459 as a number. Accepted frequencies are from 144.1 to 148.9."
	icon_state = "speaker"
	complexity = 15
	inputs = list("text" = IC_PINTYPE_STRING, "frequency" = IC_PINTYPE_NUMBER)
	outputs = list("encryption keys" = IC_PINTYPE_LIST)
	activators = list("broadcast" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 100
	cooldown_per_use = 0.1
	var/list/whitelisted_freqs = list() // special freqs can be used by inserting encryption keys
	var/list/encryption_keys = list()
	var/obj/item/device/radio/headset/integrated/radio

/obj/item/integrated_circuit/output/text_to_radio/Initialize()
	..()
	radio = new(src)
	radio.frequency = FREQ_COMMON
	GLOB.ic_speakers += src

/obj/item/integrated_circuit/output/text_to_radio/Destroy()
	qdel(radio)
	GLOB.ic_speakers -= src
	..()

/obj/item/integrated_circuit/output/text_to_radio/on_data_written()
	var/freq = get_pin_data(IC_INPUT, 2)
	if(!(freq in whitelisted_freqs))
		freq = sanitize_frequency(get_pin_data(IC_INPUT, 2), radio.freerange)
	radio.set_frequency(freq)

/obj/item/integrated_circuit/output/text_to_radio/do_work()
	text = get_pin_data(IC_INPUT, 1)
	if(!isnull(text))
		var/atom/movable/A = get_object()
		radio.talk_into(A, text, , get_spans())

/obj/item/integrated_circuit/output/text_to_radio/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/device/encryptionkey))
		user.transferItemToLoc(O,src)
		encryption_keys += O
		recalculate_channels()
		to_chat(user, "<span class='notice'>You slide \the [O] inside the circuit.</span>")
	else
		..()

/obj/item/integrated_circuit/output/text_to_radio/proc/recalculate_channels()
	whitelisted_freqs.Cut()
	set_pin_data(IC_INPUT, 2, 1459)
	radio.set_frequency(FREQ_COMMON) //reset it
	var/list/weakreffd_ekeys = list()
	for(var/o in encryption_keys)
		var/obj/item/device/encryptionkey/K = o
		weakreffd_ekeys += WEAKREF(K)
		for(var/i in K.channels)
			whitelisted_freqs |= GLOB.radiochannels[i]
	set_pin_data(IC_OUTPUT, 1, weakreffd_ekeys)


/obj/item/integrated_circuit/output/text_to_radio/attack_self(mob/user)
	if(encryption_keys.len)
		for(var/i in encryption_keys)
			var/obj/O = i
			O.forceMove(drop_location())
		encryption_keys.Cut()
		set_pin_data(IC_OUTPUT, 1, WEAKREF(null))
		to_chat(user, "<span class='notice'>You slide the encryption keys out of the circuit.</span>")
		recalculate_channels()
	else
		to_chat(user, "<span class='notice'>There are no encryption keys to remove from the mechanism.</span>")

/obj/item/device/radio/headset/integrated