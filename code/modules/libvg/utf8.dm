#define LIBVG(function, arguments...) call("./libvg.[world.system_type == UNIX ? "so" : "dll"]", function)(arguments)
GLOBAL_VAR_INIT(libvg_loaded, FALSE)


// Note about encodings:
//  Encodings are passed by number as it's simplest to do it like this (citation needed)
//  This may cause some confusion with what codes correspond how.
//
// 874 and 1250-1258 are Windows CodePage encodings. The number corresponds to the CodePage.
// 2312 is gb2312 (Chinese)
/proc/_determine_encoding(var/mob_or_client)
	. = CONFIG_GET(string/goonchat_encoding)
	if (istype(mob_or_client, /client))
		var/client/C = mob_or_client
		. = C.encoding

	else if (ismob(mob_or_client))
		var/mob/M = mob_or_client
		if (M.client)
			. = M.client.encoding


/proc/to_utf8(var/message, var/mob_or_client)
	return LIBVG("to_utf8", _determine_encoding(mob_or_client), message)

// Converts a byte string to a UTF-8 string, sanitizes it and caps the length.
/proc/utf8_sanitize(var/message, var/mob_or_client, var/length)
	return LIBVG("utf8_sanitize", _determine_encoding(mob_or_client), message, num2text(length))

// Get the length (Unicode Scalars) of a UTF-8 string.
/proc/utf8_len(var/message)
	return text2num(LIBVG("utf8_len", message))

/proc/utf8_byte_len(var/a)
	return length(a)

/proc/utf8_find(var/haystack, var/needle, var/start=1, var/end=0)
	return text2num(LIBVG("utf8_find", haystack, needle, "[start]", "[end]"))

/proc/utf8_copy(var/text, var/start=1, var/end=0)
	return LIBVG("utf8_copy", text, "[start]", "[end]")

/proc/utf8_replace(var/text, var/from, var/to_, var/start=1, var/end=0)
	return LIBVG("utf8_replace", text, from, to_, "[start]", "[end]")

/proc/utf8_index(var/text, var/index)
	return LIBVG("utf8_index", text, "[index]")

/proc/utf8_uppercase(var/text)
	return LIBVG("utf8_uppercase", text)

/proc/utf8_lowercase(var/text)
	return LIBVG("utf8_lowercase", text)

// Removes non-7-bit ASCII characters.
// Useful for things which BYOND touches itself like object names.
/proc/strict_ascii(var/text)
	return LIBVG("strict_ascii", text)

/proc/utf8_capitalize(var/text)
	return utf8_uppercase(utf8_index(text, 1)) + utf8_copy(text, 2)

/proc/utf8_reverse(var/text)
	return LIBVG("utf8_reverse", text)

/proc/utf8_leftpad(var/text, var/count, var/with=" ")
	return LIBVG("utf8_leftpad", text, "[count]", with)

/proc/utf8_is_whitespace(var/text)
	return text2num(LIBVG("utf8_is_whitespace", text))

/proc/utf8_trim(var/text)
	return LIBVG("utf8_trim", text)