//This is intended to be a full wrapper. DO NOT directly modify its values
///Container for client viewsize
/datum/viewData
	var/width = 0
	var/height = 0
	var/default = ""
	var/client/chief = null

/datum/viewData/New(client/owner, view_string)
	default = view_string
	chief = owner
	apply()

/datum/viewData/proc/setDefault(string)
	default = string
	apply()

/datum/viewData/proc/resetToDefault()
	width = 0
	height = 0
	apply()

/datum/viewData/proc/add(toAdd)
	width += toAdd
	height += toAdd
	apply()

/datum/viewData/proc/addTo(toAdd)
	var/list/shitcode = getviewsize(toAdd)
	width += shitcode[1]
	height += shitcode[2]
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

/datum/viewData/proc/getView()
	var/list/temp = getviewsize(default)
	return "[width + temp[1]]x[height + temp[2]]"

/datum/viewData/proc/zoomIn()
	resetToDefault()
	animate(chief, pixel_x = 0, pixel_y = 0, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)

/datum/viewData/proc/zoomOut(radius = 0, offset = 0, direction = FALSE)
	if(direction)
		var/_x = 0
		var/_y = 0
		switch(direction)
			if(NORTH)
				_y = offset
			if(EAST)
				_x = offset
			if(SOUTH)
				_y = -offset
			if(WEST)
				_x = -offset
		animate(chief, pixel_x = world.icon_size*_x, pixel_y = world.icon_size*_y, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)
	//Ready for this one?
	setTo(radius)

/proc/getScreenSize(widescreen)
	if(widescreen)
		return CONFIG_GET(string/default_view)
	return CONFIG_GET(string/default_view_square)
