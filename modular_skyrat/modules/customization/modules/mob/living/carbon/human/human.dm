/mob/living/carbon/human/Topic(href, href_list)
	. = ..()
	if(href_list["lookup_info"])
		switch(href_list["lookup_info"])
			if("flavor_text")
				if(length(dna.features["flavor_text"]))
					var/datum/browser/popup = new(usr, "[name]'s flavor text", "[name]'s Flavor Text", 500, 200)
					popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s flavor text", replacetext(dna.features["flavor_text"], "\n", "<BR>")))
					popup.open()
					return

			if("general_record")
				if(client && usr.client.holder)
					var/datum/browser/popup = new(usr, "[name]'s gen rec", "[name]'s General Record", 500, 200)
					popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s general record", replacetext(client.prefs.general_record, "\n", "<BR>")))
					popup.open()
					return

			if("security_record")
				if(client && usr.client.holder)
					var/datum/browser/popup = new(usr, "[name]'s sec rec", "[name]'s Security Record", 500, 200)
					popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s security record", replacetext(client.prefs.security_record, "\n", "<BR>")))
					popup.open()
					return

			if("medical_record")
				if(client && usr.client.holder)
					var/datum/browser/popup = new(usr, "[name]'s med rec", "[name]'s Medical Record", 500, 200)
					popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s medical record", replacetext(client.prefs.medical_record, "\n", "<BR>")))
					popup.open()
					return

			if("background_info")
				if(client && usr.client.holder)
					var/datum/browser/popup = new(usr, "[name]'s flav bg", "[name]'s Background", 500, 200)
					popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s background flavor", replacetext(client.prefs.background_info, "\n", "<BR>")))
					popup.open()
					return

			if("exploitable_info")
				if(client && usr.client.holder)
					var/datum/browser/popup = new(usr, "[name]'s exp info", "[name]'s Exploitable Info", 500, 200)
					popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s exploitable information", replacetext(client.prefs.exploitable_info, "\n", "<BR>")))
					popup.open()
					return

/mob/living/carbon/human/species/synthliz
	race = /datum/species/robotic/synthliz

/mob/living/carbon/human/species/vox
	race = /datum/species/vox

/mob/living/carbon/human/species/ipc
	race = /datum/species/robotic/ipc

/mob/living/carbon/human/species/mammal
	race = /datum/species/mammal

/mob/living/carbon/human/species/podweak
	race = /datum/species/pod/podweak

/mob/living/carbon/human/species/xeno
	race = /datum/species/xeno

/mob/living/carbon/human/species/dwarf
	race = /datum/species/dwarf

/mob/living/carbon/human/species/roundstartslime
	race = /datum/species/jelly/roundstartslime

/mob/living/carbon/human/verb/toggle_undies()
	set category = "IC"
	set name = "Toggle underwear visibility"
	set desc = "Allows you to toggle which underwear should show or be hidden. Obscures your ERP zones."

	if(stat != CONSCIOUS)
		to_chat(usr, "<span class='warning'>You can't toggle underwear visibility right now...</span>")
		return

	var/underwear_button = underwear_visibility & UNDERWEAR_HIDE_UNDIES ? "Show underwear" : "Hide underwear"
	var/undershirt_button = underwear_visibility & UNDERWEAR_HIDE_SHIRT ? "Show shirt" : "Hide shirt"
	var/socks_button = underwear_visibility & UNDERWEAR_HIDE_SOCKS ? "Show socks" : "Hide socks"
	var/list/choice_list = list("[underwear_button]" = 1,"[undershirt_button]" = 2,"[socks_button]" = 3,"Show all" = 4, "Hide all" = 5)
	var/picked_visibility = input(src, "Choose visibility setting", "Show/Hide underwear") as null|anything in choice_list
	if(picked_visibility)
		var/picked_choice = choice_list[picked_visibility]
		switch(picked_choice)
			if(1)
				underwear_visibility ^= UNDERWEAR_HIDE_UNDIES
			if(2)
				underwear_visibility ^= UNDERWEAR_HIDE_SHIRT
			if(3)
				underwear_visibility ^= UNDERWEAR_HIDE_SOCKS
			if(4)
				underwear_visibility = NONE
			if(5)
				underwear_visibility = UNDERWEAR_HIDE_UNDIES | UNDERWEAR_HIDE_SHIRT | UNDERWEAR_HIDE_SOCKS
		update_body()
	return

/mob/living/carbon/human/revive(full_heal = 0, admin_revive = 0)
	if(..())
		if(dna && dna.species)
			dna.species.spec_revival(src)
