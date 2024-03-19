/datum/storage/proc/attempt_compression(atom/source, mob/user, obj/item/compression_kit/kit)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(source, TRAIT_BYPASS_COMPRESS_CHECK))
		to_chat(user, span_warning("You can't make [source] any smaller without compromising its storage functions!"))
		return (COMPONENT_STOP_COMPRESSION | COMPONENT_HANDLED_MESSAGE)
