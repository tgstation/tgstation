TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, toggleeatingnoise)()
	set name = "Toggle Eating Noises"
	set category = "Preferences"
	set desc = "Hear Eating noises"
	usr.client.prefs.cit_toggles ^= EATING_NOISES
	usr.client.prefs.save_preferences()
	usr.stop_sound_channel(CHANNEL_PRED)
	to_chat(usr, "You will [(usr.client.prefs.cit_toggles & EATING_NOISES) ? "now" : "no longer"] hear eating noises.")
/datum/verbs/menu/Settings/Sound/toggleeatingnoise/Get_checked(client/C)
	return C.prefs.cit_toggles & EATING_NOISES


TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, toggledigestionnoise)()
	set name = "Toggle Digestion Noises"
	set category = "Preferences"
	set desc = "Hear digestive noises"
	usr.client.prefs.cit_toggles ^= DIGESTION_NOISES
	usr.client.prefs.save_preferences()
	usr.stop_sound_channel(CHANNEL_DIGEST)
	to_chat(usr, "You will [(usr.client.prefs.cit_toggles & DIGESTION_NOISES) ? "now" : "no longer"] hear digestion noises.")
/datum/verbs/menu/Settings/Sound/toggledigestionnoise/Get_checked(client/C)
	return C.prefs.cit_toggles & DIGESTION_NOISES

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings/Sound, togglehoundsleeper)()
	set name = "Allow/Deny Hound Sleeper"
	set category = "Preferences"
	set desc = "Allow MediHound Sleepers"
	usr.client.prefs.cit_toggles ^= MEDIHOUND_SLEEPER
	usr.client.prefs.save_preferences()
	if(usr.client.prefs.cit_toggles & MEDIHOUND_SLEEPER)
		to_chat(usr, "You will now allow MediHounds to place you in their sleeper.")
	else
		to_chat(usr, "You will no longer allow MediHounds to place you in their sleeper.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle MediHound Sleeper", "[usr.client.prefs.cit_toggles & MEDIHOUND_SLEEPER ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/verbs/menu/Settings/Sound/togglehoundsleeper/Get_checked(client/C)
	return C.prefs.cit_toggles & MEDIHOUND_SLEEPER