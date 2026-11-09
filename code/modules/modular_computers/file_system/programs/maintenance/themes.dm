/// PDA themes that you can find in maintenance. Once installed by a player, it'll become available to them on future rounds as well.
/datum/computer_file/program/maintenance/theme
	filename = "theme"
	filedesc = "Theme holder"
	extended_desc = "Holds a theme you can add to your Modular PC to set in the Themify application. Makes the application use more space"
	size = 2
	abstract_type = /datum/computer_file/program/maintenance/theme

	///The type of theme we have
	var/theme_name
	///The Database ID of the theme. It's important that non-abstract types have it set.
	var/theme_id
	///The icon file for this theme
	var/icon_file = PDA_THEMES_PROGRESS_SET
	///The icon_state for this theme to show in the progress score tab
	var/icon = ""

/datum/computer_file/program/maintenance/theme/New()
	. = ..()
	filename = "[theme_name] Theme"

/datum/computer_file/program/maintenance/theme/can_store_file(obj/item/modular_computer/potential_host)
	. = ..()
	if(!.)
		return FALSE
	var/datum/computer_file/program/themeify/theme_app = locate() in potential_host.stored_files
	//no theme app, no themes!
	if(!theme_app)
		return FALSE
	//don't get the same one twice
	if(LAZYFIND(theme_app.imported_themes, theme_name))
		return FALSE
	return TRUE

///Called post-installation of an application in a computer, after 'computer' var is set.
/datum/computer_file/program/maintenance/theme/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing, mob/user)
	SHOULD_CALL_PARENT(FALSE)
	//add the theme to the computer and increase its size to match
	var/datum/computer_file/program/themeify/theme_app = locate() in computer.stored_files
	if(!theme_app)
		return
	LAZYADD(theme_app.imported_themes, theme_name)
	theme_app.size += size
	user?.client?.give_award(/datum/award/score/progress/pda_themes, user, theme_id, theme_name)
	qdel(src)

/datum/computer_file/program/maintenance/theme/cat
	theme_name = PDA_THEME_CAT_NAME
	theme_id = PDA_THEME_ID_CAT
	icon = "cat"

/datum/computer_file/program/maintenance/theme/lightmode
	theme_name = PDA_THEME_LIGHT_MODE_NAME
	theme_id = PDA_THEME_ID_LIGHT_MODE
	icon = "light_mode"

/datum/computer_file/program/maintenance/theme/spooky
	theme_name = PDA_THEME_SPOOKY_NAME
	theme_id = PDA_THEME_ID_SPOOKY
	icon = "eldritch"

/datum/computer_file/program/maintenance/theme/hacker
	theme_name = PDA_THEME_HACKERMAN_NAME
	theme_id = PDA_THEME_ID_HACKERMAN
	icon = "hacker"

/datum/computer_file/program/maintenance/theme/roulette
	theme_name = PDA_THEME_ROULETTE_NAME
	theme_id = PDA_THEME_ID_ROULETTE
	icon = "roulette"

/datum/computer_file/program/maintenance/theme/alien
	theme_name = PDA_THEME_ABDUCTOR_NAME
	theme_id = PDA_THEME_ID_ABDUCTOR
	icon = "alien"
