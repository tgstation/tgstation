//This is intended to be a full wrapper. DO NOT directly modify its values
///Container for client viewsize
/datum/view_data
	/// Width offset to apply to the default view string if we're not suppressed for some reason
	var/width = 0
	/// Height offset to apply to the default view string, see above
	var/height = 0
	/// This client's current "default" view, in the format "WidthxHeight"
	/// We add/remove from this when we want to change their window size
	var/default = ""
	/// This client's current zoom level, if it's not being suppressed
	/// If it's 0, we autoscale to the size of the window. Otherwise it's treated as the ratio between
	/// the pixels on the map and output pixels. Only looks proper nice in increments of whole numbers (iirc)
	/// Stored here so other parts of the code have a non blocking way of getting a user's functional zoom
	var/zoom = 0
	/// If the view is currently being suppressed by some other "monitor"
	/// For when you want to own the client's eye without fucking with their viewport
	/// Doesn't make sense for a binocoler to effect your view in a camera console
	var/is_suppressed = FALSE
	/// The client that owns this view packet
	var/client/chief = null

/datum/view_data/New(client/owner, view_string)
	default = view_string
	chief = owner
	apply()

/datum/view_data/Destroy()
	chief = null
	return ..()

/datum/view_data/proc/setDefault(string)
	default = string
	apply()

/datum/view_data/proc/afterViewChange()
	if(isZooming())
		assertFormat()
	else
		resetFormat()
	if(chief?.mob)
		SEND_SIGNAL(chief.mob, COMSIG_VIEWDATA_UPDATE, getView())

/datum/view_data/proc/assertFormat()//T-Pose
	winset(chief, "mapwindow.map", "zoom=0")
	zoom = 0

/datum/view_data/proc/resetFormat()//Cuck
	zoom = chief?.prefs.read_preference(/datum/preference/numeric/pixel_size)
	winset(chief, "mapwindow.map", "zoom=[zoom]")
	chief?.attempt_auto_fit_viewport() // If you change zoom mode, fit the viewport

/datum/view_data/proc/setZoomMode()
	winset(chief, "mapwindow.map", "zoom-mode=[chief?.prefs.read_preference(/datum/preference/choiced/scaling_method)]")

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
	var/list/shitcode = getviewsize(toAdd)  //Backward compatibility to account
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
	chief?.change_view(getView())
	afterViewChange()

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
		animate(chief, pixel_x = ICON_SIZE_X*_x, pixel_y = ICON_SIZE_Y*_y, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)
	//Ready for this one?
	setTo(radius)

/proc/getScreenSize(widescreen)
	if(widescreen)
		return CONFIG_GET(string/default_view)
	return CONFIG_GET(string/default_view_square)
