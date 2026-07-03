///a changeling that has lost their powers. does nothing, other than signify they suck
/datum/antagonist/fallen_changeling
	name = "\proper Падший генокрад"
	roundend_category = "Генокрады"
	antagpanel_category = "Changeling"
	pref_flag = ROLE_CHANGELING
	antag_moodlet = /datum/mood_event/fallen_changeling
	antag_hud_name = "changeling"

/datum/mood_event/fallen_changeling
	description = "Мои силы! Где мои силы?!"
	mood_change = -4
