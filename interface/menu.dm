/*
/datum/menu/Example/verb/Example()
	set name = "" //if this starts with @ the verb is not created and name becomes the command to invoke.
	set desc = "" //desc is the text given to this entry in the menu
	//I should note, in these verbs, src will be unusable
*/

var/list/menulist = list()
/datum/menu
	var/name
	var/list/children
	var/datum/menu/myparent
	var/list/verblist
	var/checkbox = CHECKBOX_NONE //checkbox type.

	//Set to true to append our children to our parent,
	//Rather then add us as a node (used for having more then one checkgroups in the same menu)
	var/abstract = FALSE

/datum/menu/New()
	var/ourentry = menulist[type]
	children = list()
	verblist = list()
	if (islist(ourentry)) //some of our childern already loaded
		Add_children(ourentry)

	menulist[type] = src

	Load_verbs(type, typesof("[type]/verb"))

	var/datum/menu/parent = menulist[parent_type]
	if (!parent)
		menulist[parent_type] = list(src)
	else if (islist(parent))
		parent += src
	else
		parent.Add_children(src)

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

/datum/menu/proc/Load_verbs(verb_parent_type, var/list/verbs)
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
		var/list/entry = list()
		entry["parent"] = "[type]"
		entry["name"] = verbpath.desc
		if (copytext(verbpath.name,1,2) == "@")
			entry["command"] = copytext(verbpath.name,2)
		else
			entry["command"] = replacetext(verbpath.name, " ", "-")
		var/datum/menu/verb_true_parent = menulist[verblist[verbpath]]
		var/true_checkbox = verb_true_parent.checkbox
		if (true_checkbox != CHECKBOX_NONE)
			var/checkedverb = verb_true_parent.Get_checked(C)
			if (checkbox == CHECKBOX_GROUP)
				if (verbpath == checkedverb)
					entry["is-checked"] = TRUE
				else
					entry["is-checked"] = FALSE
			else if (checkbox == CHECKBOX_TOGGLE)
				entry["is-checked"] = checkedverb

			entry["command"] = ".updatemenuchecked \"[verb_true_parent.type]\" \"[verbpath]\"\n[entry["command"]]"
			entry["can-check"] = TRUE
			entry["group"] = "[verb_true_parent.type]"
		.[verbpath] = list2params(entry)

/datum/menu/proc/Get_checked(client/C)
	return C.prefs.menuoptions[type]

/datum/menu/proc/Load_checked(client/C) //So programmers can be lazy, we invoke the "checked" menu item on menu load.
	var/atom/verb/verbpath = Get_checked(C)
	if (!verbpath || !(verbpath in typesof("[type]/verb")))
		return
	if (copytext(verbpath.name,1,2) == "@")
		winset(C, null, "command = [copytext(verbpath.name,2)]")
	else
		winset(C, null, "command = [replacetext(verbpath.name, " ", "-")]")

/datum/menu/proc/Set_checked(client/C, verbpath)
	if (checkbox == CHECKBOX_GROUP)
		C.prefs.menuoptions[src.type] = verbpath
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
	var/datum/menu/M = menulist[menutype]
	if (!M)
		return
	if (!(verbpath in typesof("[menutype]/verb")))
		return
	M.Set_checked(src, verbpath)


/datum/menu/Icon/Size
	checkbox = CHECKBOX_GROUP

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

/datum/menu/Icon/Scaling/verb/icon64()
	set name = "@.winset \"mapwindow.map.zoom-mode=distort\""
	set desc = "Nearest Neighbor"

/datum/menu/Icon/Scaling/verb/icon48()
	set name = "@.winset \"mapwindow.map.zoom-mode=normal\""
	set desc = "Point Sampling"

/datum/menu/Icon/Scaling/verb/icon32()
	set name = "@.winset \"mapwindow.map.zoom-mode=blur\""
	set desc = "Bilinear"

