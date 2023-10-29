/atom/movable/screen/plane_master/runechat
	name = "Runechat"
	documentation = "Holds runechat images, that text that pops up when someone say something. Uses a dropshadow to well, look nice."
	plane = RUNECHAT_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/runechat/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	remove_filter("AO")
	if(istype(mymob) && mymob.canon_client?.prefs?.read_preference(/datum/preference/toggle/ambient_occlusion))
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/balloon_chat
	name = "Balloon chat"
	documentation = "Holds ballon chat images, those little text bars that pop up for a second when you do some things. NOT runechat."
	plane = BALLOON_CHAT_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
