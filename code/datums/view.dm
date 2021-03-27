//This is intended to be a full wrapper. DO NOT directly modify its values
///Container for client viewsize
/datum/view_data
	var/width = 0
	var/height = 0
	var/default = ""
	var/is_suppressed = FALSE
	var/client/chief = null

/datum/view_data/New(client/owner, view_string)
	default = view_string
	chief = owner
	apply()

/datum/view_data/proc/setDefault(string)
	default = string
	apply()

/datum/view_data/proc/safeApplyFormat()
	if(isZooming())
		assertFormat()
		return
	resetFormat()

/datum/view_data/proc/assertFormat()//T-Pose
	winset(chief, "mapwindow.map", "zoom=0")

/datum/view_data/proc/resetFormat()//Cuck
	winset(chief, "mapwindow.map", "zoom=[chief.prefs.pixel_size]")

/datum/view_data/proc/setZoomMode()
	winset(chief, "mapwindow.map", "zoom-mode=[chief.prefs.scaling_method]")

/datum/view_data/proc/isZooming()
	return (width || height)

/datum/view_data/proc/resetToDefault()
	width = 0
	height = 0
	apply()

/datum/view_data/proc/add(toAdd)
	width += toAdd
	height += toAdd
	apply()

/datum/view_data/proc/addTo(toAdd)
	var/list/shitcode = getviewsize(toAdd)
	width += shitcode[1]
	height += shitcode[2]
	apply()

/datum/view_data/proc/setTo(toAdd)
	var/list/shitcode = getviewsize(toAdd)  //Backward compatability to account
	width = shitcode[1] //for a change in how sizes get calculated. we used to include world.view in
	height = shitcode[2] //this, but it was jank, so I had to move it
	apply()

/datum/view_data/proc/setBoth(wid, hei)
	width = wid
	height = hei
	apply()

/datum/view_data/proc/setWidth(wid)
	width = wid
	apply()

/datum/view_data/proc/setHeight(hei)
	width = hei
	apply()

/datum/view_data/proc/addToWidth(toAdd)
	width += toAdd
	apply()

/datum/view_data/proc/addToHeight(screen, toAdd)
	height += toAdd
	apply()

/datum/view_data/proc/apply()
	chief.change_view(getView())
	safeApplyFormat()

/datum/view_data/proc/supress()
	is_suppressed = TRUE
	apply()

/datum/view_data/proc/unsupress()
	is_suppressed = FALSE
	apply()

/datum/view_data/proc/getView()
	var/list/temp = getviewsize(default)
	if(is_suppressed)
		return "[temp[1]]x[temp[2]]"
	return "[width + temp[1]]x[height + temp[2]]"

/datum/view_data/proc/zoomIn()
	resetToDefault()
	animate(chief, pixel_x = 0, pixel_y = 0, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)

/datum/view_data/proc/zoomOut(radius = 0, offset = 0, direction = FALSE)
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
