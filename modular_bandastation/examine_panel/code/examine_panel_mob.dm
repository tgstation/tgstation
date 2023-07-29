// TODO: Don't use prefs when spawned via admins
/mob/living/carbon/human/Login()
	. = ..()
	AddComponent(/datum/component/examine_panel, use_prefs = TRUE)

/mob/living/silicon/Login()
	. = ..()
	AddComponent(/datum/component/examine_panel, use_prefs = TRUE)

/mob/living/verb/change_flavor_text()
	set name = "Change flavor text"
	set category = "IC"

	var/datum/component/examine_panel/examine_panel = GetComponent(/datum/component/examine_panel)
	if(!examine_panel)
		examine_panel = AddComponent(/datum/component/examine_panel)
	var/new_flavor_text = tgui_input_text(usr, "Enter new flavor text", "Changing Flavor Text", examine_panel.flavor_text)
	if(new_flavor_text)
		examine_panel.flavor_text = new_flavor_text
