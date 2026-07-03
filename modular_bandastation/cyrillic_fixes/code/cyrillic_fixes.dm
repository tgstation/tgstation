GLOBAL_LIST_INIT(ru_key_to_en_key, list(
	"й" = "q", "ц" = "w", "у" = "e", "к" = "r", "е" = "t", "н" = "y", "г" = "u", "ш" = "i", "щ" = "o", "з" = "p", "х" = "\[", "ъ" = "]",
	"ф" = "a", "ы" = "s", "в" = "d", "а" = "f", "п" = "g", "р" = "h", "о" = "j", "л" = "k", "д" = "l", "ж" = ";", "э" = "'",
	"я" = "z", "ч" = "x", "с" = "c", "м" = "v", "и" = "b", "т" = "n", "ь" = "m", "б" = ",", "ю" = "."
))

/proc/convert_ru_key_to_en_key(_key)
	var/new_key = LOWER_TEXT(_key)
	new_key = GLOB.ru_key_to_en_key[new_key]
	if(!new_key)
		return _key
	return uppertext(new_key)

#define MAX_HOTKEY_SLOTS 3

/datum/preference_middleware/keybindings/set_keybindings(list/params, mob/user)
	var/keybind_name = params["keybind_name"]

	if (isnull(GLOB.keybindings_by_name[keybind_name]))
		return FALSE

	var/list/raw_hotkeys = params["hotkeys"]
	if (!istype(raw_hotkeys))
		return FALSE

	if (raw_hotkeys.len > MAX_HOTKEY_SLOTS)
		return FALSE

	// There's no optimal, easy way to check if something is an array
	// and not an object in BYOND, so just sanitize it to make sure.
	var/list/hotkeys = list()
	for (var/hotkey in raw_hotkeys)
		if (!istext(hotkey))
			return FALSE

		// Fairly arbitrary number, it's just so you don't save enormous fake keybinds.
		if (length(hotkey) > 100)
			return FALSE

		hotkeys += convert_ru_key_to_en_key(hotkey)

	preferences.key_bindings[keybind_name] = hotkeys
	preferences.key_bindings_by_key = preferences.get_key_bindings_by_key(preferences.key_bindings)

	user.client.update_special_keybinds()

	return TRUE

#undef MAX_HOTKEY_SLOTS

/datum/tgui_input_keycombo/set_entry(entry)
	entry = convert_ru_key_to_en_key(entry) || entry
	. = ..()
