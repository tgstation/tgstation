/datum/preferences/proc/hippie_pref_load(savefile/S)
	S["feature_moth_wings"]		>> features["moth_wings"]
	features["moth_wings"] 	= sanitize_inlist(features["moth_wings"], GLOB.moth_wings_list)

/datum/preferences/proc/hippie_pref_save(savefile/S)
	S["feature_moth_wings"]		<< features["moth_wings"]