/proc/test_generate_botany_wiki()
	var/datum/wiki_template/botany/new_botany = new
	return new_botany.generate_output(/datum/hydroponics/plant_mutation/life_weed)

GLOBAL_VAR_INIT(botany_wiki, "")
/proc/generate_botany_wiki_templates()
	var/mega_string = ""
	var/datum/wiki_template/botany/new_botany = new
	for(var/datum/hydroponics/plant_mutation/listed_mutation as anything in (subtypesof(/datum/hydroponics/plant_mutation) - typesof(/datum/hydroponics/plant_mutation/infusion)))
		mega_string += "[new_botany.generate_output(listed_mutation)] \n"

	GLOB.botany_wiki = mega_string
	return mega_string
