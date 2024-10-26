// TODO: Don't use prefs when spawned via admins
/mob/living/carbon/human/Login()
	. = ..()
	AddComponent(/datum/component/examine_panel)

/datum/dna/transfer_identity(mob/living/carbon/destination, transfer_SE, transfer_species)
	if(!istype(destination))
		return
	. = ..()
	destination.AddComponent(/datum/component/examine_panel)

/mob/living/silicon
	var/flavor_text

/mob/living/silicon/Login()
	. = ..()
	if(!flavor_text)
		flavor_text = client?.prefs.read_preference(/datum/preference/text/silicon_flavor_text)
	AddComponent(/datum/component/examine_panel)

/mob/living/verb/change_flavor_text()
	set name = "Изменить описание"
	set category = "IC"

	var/new_flavor_text = tgui_input_text(usr, "Введите новое описание", "Изменение описания")
	if(new_flavor_text)
		DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(save_new_flavor_text), new_flavor_text))

/mob/living/proc/save_new_flavor_text(new_flavor_text)
	return

/mob/living/carbon/save_new_flavor_text(new_flavor_text)
	dna.features["flavor_text"] = new_flavor_text
	AddComponent(/datum/component/examine_panel)

/mob/living/silicon/save_new_flavor_text(new_flavor_text)
	flavor_text = new_flavor_text
	AddComponent(/datum/component/examine_panel)
