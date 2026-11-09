// All religion stuff
GLOBAL_VAR(religion)
GLOBAL_VAR(deity)
GLOBAL_DATUM(religious_sect, /datum/religion_sect)

//bible
GLOBAL_VAR(bible_name)
GLOBAL_VAR(bible_icon_state)
GLOBAL_VAR(bible_inhand_icon_state)

//altar
GLOBAL_LIST_EMPTY(chaplain_altars)

//gear
GLOBAL_VAR(holy_weapon_type)
GLOBAL_VAR(holy_armor_type)

GLOBAL_LIST_INIT(prayer_type_to_font_color, list(
	DEFAULT_PRAYER = "purple",
	CULT_PRAYER = "black",
	HERETIC_PRAYER = "green",
	CHAPLAIN_PRAYER = "yellow",
	SPIRITUAL_PRAYER = "blue",
	EVIL_PRAYER = "red",
	SANTA_PRAYER = "purple",
	SANTA_NAUGHTY_PRAYER = "red",
))

GLOBAL_LIST_INIT(prayer_type_to_icon_state, list(
	DEFAULT_PRAYER = "bible",
	CULT_PRAYER = "tome",
	HERETIC_PRAYER = "necronomicon",
	CHAPLAIN_PRAYER = "kingyellow",
	SPIRITUAL_PRAYER = "holylight",
	EVIL_PRAYER = "burning",
	SANTA_PRAYER = "bible", //here just in case, we use present boxes for the icon
	SANTA_NAUGHTY_PRAYER = "burning",
))

GLOBAL_LIST_INIT(prayer_type_to_message_box, list(
	DEFAULT_PRAYER = "",
	CULT_PRAYER = "red_box",
	HERETIC_PRAYER = "green_box",
	CHAPLAIN_PRAYER = "blue_box",
	SPIRITUAL_PRAYER = "",
	EVIL_PRAYER = "red_box",
	SANTA_PRAYER = "blue_box",
	SANTA_NAUGHTY_PRAYER = "red_box",
))

/// Sets a new religious sect used by all chaplains int he round
/proc/set_new_religious_sect(path, reset_existing = FALSE)
	if(!ispath(path, /datum/religion_sect))
		message_admins("[ADMIN_LOOKUPFLW(usr)] has tried to spawn an item when selecting a sect.")
		return

	if(!isnull(GLOB.religious_sect))
		if (!reset_existing)
			return
		reset_religious_sect()

	GLOB.religious_sect = new path()
	for(var/i in GLOB.player_list)
		if(!isliving(i))
			continue
		var/mob/living/am_i_holy_living = i
		if(!am_i_holy_living.mind?.holy_role)
			continue
		GLOB.religious_sect.on_conversion(am_i_holy_living)
	SEND_GLOBAL_SIGNAL(COMSIG_RELIGIOUS_SECT_CHANGED)

/// Removes any existing religious sect from chaplains, allowing another to be selected
/proc/reset_religious_sect()
	for(var/i in GLOB.player_list)
		if(!isliving(i))
			continue
		var/mob/living/am_i_holy_living = i
		if(!am_i_holy_living.mind?.holy_role)
			continue
		GLOB.religious_sect.on_deconversion(am_i_holy_living)

	GLOB.religious_sect = null
	SEND_GLOBAL_SIGNAL(COMSIG_RELIGIOUS_SECT_RESET)
