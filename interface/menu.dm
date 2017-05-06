/*
/datum/menu/Example/verb/Example()
	set name = "" //if this starts with @ the verb is not created and name becomes the command to invoke.
	set desc = "" //desc is the text given to this entry in the menu
	//You can not use src in these verbs. It will be the menu at compile time, but the client at runtime.
*/

GLOBAL_LIST_EMPTY(menulist)

/world/proc/load_menu()
	for (var/typepath in subtypesof(/datum/menu))
		new typepath()

/datum/menu
	var/name
	var/list/children
	var/datum/menu/myparent
	var/list/verblist
	var/checkbox = CHECKBOX_NONE //checkbox type.
	var/default //default checked type.
	//Set to true to append our children to our parent,
	//Rather then add us as a node (used for having more then one checkgroups in the same menu)
	var/abstract = FALSE

/datum/menu/New()
	var/ourentry = GLOB.menulist[type]
	children = list()
	verblist = list()
	if (ourentry)
		if (islist(ourentry)) //some of our childern already loaded
			Add_children(ourentry)
		else
			stack_trace("Menu item double load: [type]")
			qdel(src)
			return

	GLOB.menulist[type] = src

	Load_verbs(type, typesof("[type]/verb"))

	var/datum/menu/parent = GLOB.menulist[parent_type]
	if (!parent)
		GLOB.menulist[parent_type] = list(src)
	else if (islist(parent))
		parent += src
	else
		parent.Add_children(list(src))

/datum/menu/proc/Set_parent(datum/menu/parent)
	myparent = parent
	if (abstract)
		myparent.Add_children(children)
		var/list/verblistoftypes = list()
		for(var/thing in verblist)
			LAZYADD(verblistoftypes[verblist[thing]], thing)

		for(var/verbparenttype in verblistoftypes)
			myparent.Load_verbs(verbparenttype, verblistoftypes[verbparenttype])

/datum/menu/proc/Add_children(list/kids)
	if (abstract && myparent)
		myparent.Add_children(kids)
		return

	for(var/thing in kids)
		var/datum/menu/menuitem = thing
		menuitem.Set_parent(src)
		if (!menuitem.abstract)
			children += menuitem

/datum/menu/proc/Load_verbs(verb_parent_type, list/verbs)
	if (abstract && myparent)
		myparent.Load_verbs(verb_parent_type, verbs)
		return

	for (var/verbpath in verbs)
		verblist[verbpath] = verb_parent_type

/datum/menu/proc/Generate_list(client/C)
	. = list()
	if (length(children))
		for (var/thing in children)
			var/datum/menu/child = thing
			var/list/childlist = child.Generate_list(C)
			if (childlist)
				var/childname = "[child]"
				if (childname == "[child.type]")
					var/list/tree = splittext(childname, "/")
					childname = tree[tree.len]
				.[child.type] = "parent=[url_encode(type)];name=[url_encode(childname)]"
				. += childlist



	for (var/thing in verblist)
		var/atom/verb/verbpath = thing
		if (!verbpath)
			stack_trace("Bad VERB in [type] verblist: [english_list(verblist)]")
		var/list/entry = list()
		entry["parent"] = "[type]"
		entry["name"] = verbpath.desc
		if (copytext(verbpath.name,1,2) == "@")
			entry["command"] = copytext(verbpath.name,2)
		else
			entry["command"] = replacetext(verbpath.name, " ", "-")
		var/datum/menu/verb_true_parent = GLOB.menulist[verblist[verbpath]]
		var/true_checkbox = verb_true_parent.checkbox
		if (true_checkbox != CHECKBOX_NONE)
			var/checkedverb = verb_true_parent.Get_checked(C)
			if (true_checkbox == CHECKBOX_GROUP)
				if (verbpath == checkedverb)
					entry["is-checked"] = TRUE
				else
					entry["is-checked"] = FALSE
			else if (true_checkbox == CHECKBOX_TOGGLE)
				entry["is-checked"] = checkedverb

			entry["command"] = ".updatemenuchecked \"[verb_true_parent.type]\" \"[verbpath]\"\n[entry["command"]]"
			entry["can-check"] = TRUE
			entry["group"] = "[verb_true_parent.type]"
		.[verbpath] = list2params(entry)

/datum/menu/proc/Get_checked(client/C)
	return C.prefs.menuoptions[type] || default || FALSE

/datum/menu/proc/Load_checked(client/C) //Loads the checked menu item into a new client. Used by icon menus to invoke the checked item.
	return

/datum/menu/proc/Set_checked(client/C, verbpath)
	if (checkbox == CHECKBOX_GROUP)
		C.prefs.menuoptions[type] = verbpath
		C.prefs.save_preferences()
	else if (checkbox == CHECKBOX_TOGGLE)
		var/checked = Get_checked(C)
		C.prefs.menuoptions[type] = !checked
		C.prefs.save_preferences()
		winset(C, "[verbpath]", "is-checked = [!checked]")

/client/verb/updatemenuchecked(menutype as text, verbpath as text)
	set name = ".updatemenuchecked"
	menutype = text2path(menutype)
	verbpath = text2path(verbpath)
	if (!menutype || !verbpath)
		return
	var/datum/menu/M = GLOB.menulist[menutype]
	if (!M)
		return
	if (!(verbpath in typesof("[menutype]/verb")))
		return
	M.Set_checked(src, verbpath)


/datum/menu/Icon/Load_checked(client/C) //So we can be lazy, we invoke the "checked" menu item on menu load.
	var/atom/verb/verbpath = Get_checked(C)
	if (!verbpath || !(verbpath in typesof("[type]/verb")))
		return
	if (copytext(verbpath.name,1,2) == "@")
		winset(C, null, "command = [copytext(verbpath.name,2)]")
	else
		winset(C, null, "command = [replacetext(verbpath.name, " ", "-")]")

/datum/menu/Icon/Size
	checkbox = CHECKBOX_GROUP
	default = /datum/menu/Icon/Size/verb/iconstretchtofit

/datum/menu/Icon/Size/verb/iconstretchtofit()
	set name = "@.winset \"mapwindow.map.icon-size=0\""
	set desc = "&Auto (stretch-to-fit)"

/datum/menu/Icon/Size/verb/icon96()
	set name = "@.winset \"mapwindow.map.icon-size=96\""
	set desc = "&96x96 (3x)"

/datum/menu/Icon/Size/verb/icon64()
	set name = "@.winset \"mapwindow.map.icon-size=64\""
	set desc = "&64x64 (2x)"

/datum/menu/Icon/Size/verb/icon48()
	set name = "@.winset \"mapwindow.map.icon-size=48\""
	set desc = "&48x48 (1.5x)"

/datum/menu/Icon/Size/verb/icon32()
	set name = "@.winset \"mapwindow.map.icon-size=32\""
	set desc = "&32x32 (1x)"


/datum/menu/Icon/Scaling
	checkbox = CHECKBOX_GROUP
	name = "Scaling Mode"
	default = /datum/menu/Icon/Scaling/verb/NN

/datum/menu/Icon/Scaling/verb/NN()
	set name = "@.winset \"mapwindow.map.zoom-mode=distort\""
	set desc = "Nearest Neighbor"

/datum/menu/Icon/Scaling/verb/PS()
	set name = "@.winset \"mapwindow.map.zoom-mode=normal\""
	set desc = "Point Sampling"

/datum/menu/Icon/Scaling/verb/BL()
	set name = "@.winset \"mapwindow.map.zoom-mode=blur\""
	set desc = "Bilinear"

