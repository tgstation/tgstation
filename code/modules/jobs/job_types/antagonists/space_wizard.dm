/datum/job/space_wizard
	title = ROLE_WIZARD
	faction = ROLE_WIZARD
	tgui_icon = FA_ICON_MAGIC

/datum/job/space_wizard/get_roundstart_spawn_point()
	return pick(GLOB.wizardstart)

/datum/job/space_wizard/get_latejoin_spawn_point()
	return pick(GLOB.wizardstart)
