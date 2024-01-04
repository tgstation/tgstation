/// Logging for mech actions
/proc/log_mecha(text, list/data)
	logger.Log(LOG_CATEGORY_MECHA, text, data)

/// Logging for equipment installed in a mecha
/obj/item/mecha_parts/mecha_equipment/log_message(message, message_type = LOG_MECHA, color = null, log_globally, list/data)
	if(chassis)
		return chassis.log_message("ATTACHMENT: [src] [message]", message_type, color)
	return ..()
