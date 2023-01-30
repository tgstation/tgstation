#define PDA_THEME_CAT "ntos_cat"
#define PDA_THEME_LIGHT_MODE "ntos_lightmode"
#define PDA_THEME_SPOOKY "ntos_eldritch"

/datum/computer_file/program/maintenance/theme
	filename = "theme"
	filedesc = "Theme holder"
	extended_desc = "Holds a theme you can add to your Modular PC to set in the Themify application. Makes the application use more space"
	size = 2

	///The type of theme we have
	var/theme_type

/datum/computer_file/program/maintenance/theme/New()
	. = ..()
	filename = "[theme_type] NtOS theme"

/datum/computer_file/program/maintenance/theme/can_store_file(obj/item/modular_computer/potential_host)
	. = ..()
	if(!.)
		return FALSE
	var/datum/computer_file/program/themeify/theme_app = locate() in potential_host.stored_files
	//no theme app, no themes!
	if(!theme_app)
		return FALSE
	//don't get the same one twice
	if(theme_app.imported_themes.Find(theme_type))
		return FALSE
	return TRUE

///Called post-installation of an application in a computer, after 'computer' var is set.
/datum/computer_file/program/maintenance/theme/on_install()
	//add the theme to the computer and increase its size to match
	var/datum/computer_file/program/themeify/theme_app = locate() in computer.stored_files
	if(theme_app)
		theme_app.imported_themes += theme_type
		theme_app.size += size
		qdel(src)

/datum/computer_file/program/maintenance/theme/cat
	theme_type = PDA_THEME_CAT

/datum/computer_file/program/maintenance/theme/lightmode
	theme_type = PDA_THEME_LIGHT_MODE

/datum/computer_file/program/maintenance/theme/spooky
	theme_type = PDA_THEME_SPOOKY

#undef PDA_THEME_CAT
#undef PDA_THEME_LIGHT_MODE
#undef PDA_THEME_SPOOKY
