/datum/preferences
	features = list("mcolor" = "FFF", "tail_lizard" = "Smooth", "tail_human" = "None", "snout" = "Round", "horns" = "None", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None", "legs" = "Normal Legs", "moth_wings" = "Plain")
	var/gear_points = 5
	var/list/gear_categories
	var/list/chosen_gear
	var/datum/gear_category/gear_tab

/datum/preferences/New(client/C)
	..()
	LAZYINITLIST(chosen_gear)
	for(var/i in subtypesof(/datum/gear_category))
		LAZYADD(gear_categories, new i)//i did it this way so they only get generated once, theorically, at roundstart,or whenever prefs get created

/datum/preferences/proc/add_hippie_choices(dat)
	if("moth_wings" in pref_species.mutant_bodyparts)
		dat += "<td valign='top' width='7%'>"

		dat += "<h3>Moth wings</h3>"

		dat += "<a href='?_src_=prefs;preference=moth_wings;task=input'>[features["moth_wings"]]</a><BR>"

		dat += "</td>"
	return dat

/datum/preferences/proc/process_hippie_link(mob/user, list/href_list)
	if(href_list["task"] == "input")
		if(href_list["preference"] == "moth_wings")
			var/new_moth_wings
			new_moth_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.moth_wings_list
			if(new_moth_wings)
				features["moth_wings"] = new_moth_wings
	if(href_list["preference"] == "gear")
		if(href_list["clear_loadout"])
			LAZYCLEARLIST(chosen_gear)
			save_preferences()
		if(href_list["select_category"])
			for(var/i in gear_categories)
				var/datum/gear_category/category = i
				var/the_path = text2path(href_list["select_category"])
				if(!the_path)
					return
				if(istype(category, the_path))
					gear_tab = i
		if(href_list["toggle_gear_path"])
			var/datum/gear/G = text2path(href_list["toggle_gear_path"])
			if(!G)
				return
			if(is_type_in_ref_list(G, gear_tab.gear_list))//just to be sure you're not being a cunt and trying to exploit me
				var/toggle = text2num(href_list["toggle_gear"])
				if(!toggle && (G in chosen_gear))//toggling off and the item effectively is in chosen gear)
					LAZYREMOVE(chosen_gear, G)
					gear_points += initial(G.cost)
				else if(toggle && (!(is_type_in_ref_list(G, chosen_gear))))
					if(gear_points >= initial(G.cost))
						LAZYADD(chosen_gear, G)
						gear_points -= initial(G.cost)

/datum/preferences/proc/hippie_dat_replace(current_tab)
	//This proc is for menus other than game pref and char pref
	. = "<center>"

	. += "<a href='?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Character Settings</a> "
	. += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>Game Preferences</a>"
	. += "<a href='?_src_=prefs;preference=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>Loadout</a>"

	if(!path)
		. += "<div class='notice'>Please create an account to save your preferences</div>"

	. += "</center>"

	. += "<HR>"
	if(current_tab == 2)
		if(!gear_tab)
			gear_tab = gear_categories[1]
		. += "<table align='center' width='100%'>"
		. += "<tr><td colspan=4><center><b><font color='[gear_points == 0 ? "#E67300" : "#3366CC"]'>[gear_points]</font> loadout points remaining.</b> \[<a href='?_src_=prefs;preference=gear;clear_loadout=1'>Clear Loadout</a>\]</center></td></tr>"
		. += "<tr><td colspan=4><center><b>"
		var/firstcat = TRUE
		for(var/i in gear_categories)
			var/datum/gear_category/category = i
			if(firstcat)
				firstcat = FALSE
			else
				. += " |"
			if(category.id == gear_tab.id)
				. += " <span class='linkOn'>[category.id]</span> "
			else
				. += " <a href='?_src_=prefs;preference=gear;select_category=[category.type]'>[category.id]</a> "
		. += "</b></center></td></tr>"
		. += "<tr><td colspan=4><hr></td></tr>"
		. += "<tr><td colspan=4><b><center>[gear_tab.id]</center></b></td></tr>"
		. += "<tr><td colspan=4><hr></td></tr>"
		. += "<tr style='vertical-align:top;'><td width=15%><b>Name</b></td>"
		. += "<td width=5% style='vertical-align:top'><b>Cost</b></td>"
		. += "<td><font size=2><b>Restrictions</b></font></td>"
		. += "<td><font size=2><b>Description</b></font></td></tr>"
		for(var/j in gear_tab.gear_list)
			var/datum/gear/gear = j
			var/class_link = ""
			if(gear.type in chosen_gear)
				class_link = "class='linkOn' href='?_src_=prefs;preference=gear;toggle_gear_path=[gear.type];toggle_gear=0'"
			else if(gear_points <= 0)
				class_link = "class='linkOff'"
			else
				class_link = "href='?_src_=prefs;preference=gear;toggle_gear_path=[gear.type];toggle_gear=1'"
			. += "<tr style='vertical-align:top;'><td width=15%><a style='white-space:normal;' [class_link]>[gear.name]</a></td>"
			. += "<td width = 5% style='vertical-align:top'>[gear.cost]</td><td>"
			if(islist(gear.locked_to_roles))
				if(gear.locked_to_roles.len)
					. += "<font size=2>"
					for(var/role in gear.locked_to_roles)
						. += role + " "
					. += "</font>"
			. += "</td><td><font size=2><i>[gear.description]</i></font></td></tr>"
		. += "</table>"
