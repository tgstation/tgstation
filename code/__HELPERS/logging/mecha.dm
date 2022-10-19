/// Logging for mech actions
/proc/log_mecha(text)
	if (CONFIG_GET(flag/log_mecha))
		WRITE_LOG(GLOB.world_mecha_log, "MECHA: [text]")

/// Logging for equipment installed in a mecha
/obj/item/mecha_parts/mecha_equipment/log_message(message, message_type = LOG_MECHA, color = null, log_globally)
	if(chassis)
		return chassis.log_message("ATTACHMENT: [src] [message]", message_type, color)
	return ..()
