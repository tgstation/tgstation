/datum/disease/proc/update_global_log()
	if ("[uniqueID]-[subID]" in GLOB.inspectable_diseases)
		return
	GLOB.inspectable_diseases["[uniqueID]-[subID]"] = Copy()

/datum/disease/proc/clean_global_log()
	var/ID = "[uniqueID]-[subID]"
	if (ID in GLOB.virusDB)
		return

	for (var/mob/living/L in GLOB.mob_list)
		if(!length(L.diseases))
			continue
		for(var/datum/disease/advanced/D as anything in L.diseases)
			if (ID == "[D.uniqueID]-[D.subID]")
				return

	for (var/obj/item/I in GLOB.infected_items)
		for(var/datum/disease/advanced/D as anything in I.viruses)
			if (ID == "[D.uniqueID]-[D.subID]")
				return

	var/dishes = 0
	for (var/obj/item/weapon/virusdish/dish in GLOB.virusdishes)
		if (dish.contained_virus)
			if (ID == "[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]")
				dishes++
				if (dishes > 1)//counting the dish we're in currently
					return
	//If a pathogen that isn't in the database mutates, we check whether it infected anything, and remove it from the disease list if it didn't
	//so we don't clog up the Diseases Panel with irrelevant mutations
	GLOB.inspectable_diseases -= ID

/datum/disease/advanced/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("","------")
	VV_DROPDOWN_OPTION(VV_HK_VIEW_DISEASE_DATA, "View Disease Data")

/datum/disease/advanced/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_VIEW_DISEASE_DATA])
		create_disease_info_pane(usr)

/datum/disease/advanced/proc/create_disease_info_pane(mob/user)
	var/datum/browser/popup = new(user, "\ref[src]", "GNAv3 [form] #[uniqueID]-[subID]", 600, 500, src)
	var/content = get_info()
	content += "<BR><b>LOGS</b></BR>"
	content += log
	popup.set_content(content)
	popup.open()
