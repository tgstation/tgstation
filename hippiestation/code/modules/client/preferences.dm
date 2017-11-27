/datum/preferences
	features = list("mcolor" = "FFF", "tail_lizard" = "Smooth", "tail_human" = "None", "snout" = "Round", "horns" = "None", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None", "legs" = "Normal Legs", "moth_wings" = "Plain")

/datum/preferences/proc/add_hippie_choices(dat)
	if("moth_wings" in pref_species.mutant_bodyparts)
		dat += "<td valign='top' width='7%'>"

		dat += "<h3>Moth wings</h3>"

		dat += "<a href='?_src_=prefs;preference=moth_wings;task=input'>[features["moth_wings"]]</a><BR>"

		dat += "</td>"
	return dat

/datum/preferences/proc/process_hippie_link(mob/user, list/href_list)
	if((href_list["task"] == "input") && (href_list["preference"] == "moth_wings"))
		var/new_moth_wings
		new_moth_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.moth_wings_list
		if(new_moth_wings)
			features["moth_wings"] = new_moth_wings