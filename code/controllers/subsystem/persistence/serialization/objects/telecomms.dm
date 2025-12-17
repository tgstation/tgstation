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

/obj/machinery/telecomms/get_custom_save_vars(save_flags=ALL)
	. = ..()
	if(!length(links))
		return
	var/list/autolinked_machines = list()
	for(var/obj/machinery/telecomms/machine as anything in links)
		autolinked_machines |= machine.id
	.[NAMEOF(src, autolinkers)] = autolinked_machines


