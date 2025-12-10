/obj/item/radio/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, unscrewed)
	. += NAMEOF(src, use_command)
	. += NAMEOF(src, channels)
	. += NAMEOF(src, special_channels)
	. += NAMEOF(src, on)
	. += NAMEOF(src, frequency)
	. += NAMEOF(src, broadcasting)
	. += NAMEOF(src, listening)
	return .

/obj/item/radio/get_custom_save_vars(save_flags=ALL)
	. = ..()
	if(ispath(keyslot))
		.[NAMEOF(src, keyslot)] = keyslot
	else if(istype(keyslot))
		.[NAMEOF(src, keyslot)] = keyslot.type
	return .

/obj/item/radio/headset/get_custom_save_vars(save_flags=ALL)
	. = ..()
	if(ispath(keyslot2))
		.[NAMEOF(src, keyslot2)] = keyslot2
	else if(istype(keyslot2))
		.[NAMEOF(src, keyslot2)] = keyslot2.type
	return .

/obj/machinery/telecomms/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, on)
	. += NAMEOF(src, toggled)
	. += NAMEOF(src, network)
	. += NAMEOF(src, id)
	. += NAMEOF(src, freq_listening)
	return .

/obj/machinery/telecomms/message_server/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, decryptkey)
	. += NAMEOF(src, calibrating)

/obj/machinery/telecomms/server/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, frequency_infos)

/obj/machinery/telecomms/bus/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, change_frequency)

/// buses and hubs link to multiple machines

/obj/machinery/telecomms/hub/get_custom_save_vars(save_flags=ALL)
	. = ..()
	var/list/autolinked_machines
	for(var/obj/machinery/telecomms/machine in links)
		LAZYADD(autolinked_machines, machine.id)

	if(autolinked_machines)
		.[NAMEOF(src, autolinkers)] = autolinked_machines
	return .

/obj/machinery/telecomms/bus/get_custom_save_vars(save_flags=ALL)
	. = ..()
	var/list/autolinked_machines
	for(var/obj/machinery/telecomms/machine in links)
		LAZYADD(autolinked_machines, machine.id)

	if(autolinked_machines)
		.[NAMEOF(src, autolinkers)] = autolinked_machines
	return .

/// these are isolated and use the autolinker as their own id for other machines to connect to

/obj/machinery/telecomms/broadcaster/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, autolinkers)] = list(id)
	return .

/obj/machinery/telecomms/processor/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, autolinkers)] = list(id)
	return .

/obj/machinery/telecomms/receiver/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, autolinkers)] = list(id)
	return .

/obj/machinery/telecomms/relay/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, autolinkers)] = list(id)
	return .

/obj/machinery/telecomms/message_server/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, autolinkers)] = list(id)
	return .

/obj/machinery/telecomms/server/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, autolinkers)] = list(id)
	return .



