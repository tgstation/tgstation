//This is intended to be a full wrapper. DO NOT directly modify its values
///Container for client viewsize
/datum/viewData
	var/width = 0
	var/height = 0
	var/default = ""
	var/client/chief = null

/datum/viewData/New(client/owner, view_string)
	setAsString(view_string)
	default = view_string
	chief = owner
	apply()

/datum/viewData/proc/setDefault(string)
	default = string

/datum/viewData/proc/resetToDefault()
	setAsString(default)

/datum/viewData/proc/setAsString(string)
	var/list/temp = splittext(string, "x")
	width = text2num(temp[1])
	height = text2num(temp[2])
	apply()

/datum/viewData/proc/getView()
	return "[width]x[height]"

/datum/viewData/proc/add(toAdd)
	width += toAdd
	height += toAdd
	apply()

/datum/viewData/proc/setTo(toAdd)
	var/list/shitcode = getviewsize(toAdd)
	width = shitcode[1]
	height = shitcode[2]
	apply()

/datum/viewData/proc/setBoth(wid, hei)
	width = wid
	height = hei
	apply()

/datum/viewData/proc/setWidth(wid)
	width = wid
	apply()

/datum/viewData/proc/setHeight(hei)
	width = hei
	apply()

/datum/viewData/proc/addToWidth(toAdd)
	width += toAdd
	apply()

/datum/viewData/proc/addToHeight(screen, toAdd)
	height += toAdd
	apply()

/datum/viewData/proc/apply()
	chief.change_view(getView())

/proc/getScreenSize(widescreen)
	if(widescreen)
		return CONFIG_GET(string/default_view)
	return CONFIG_GET(string/default_view_square)
