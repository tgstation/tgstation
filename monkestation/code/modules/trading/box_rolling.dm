/atom/movable/screen/fullscreen/lootbox_overlay
	icon =  'goon/icons/effects/320x320.dmi'
	icon_state = "lootb0"
	screen_loc = "CENTER-3, CENTER-3"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	plane = HUD_PLANE
	show_when_dead = TRUE

/atom/movable/screen/fullscreen/lootbox_overlay/sparks
	icon_state = "sparks"
	layer = FULLSCREEN_LAYER + 0.2

/atom/movable/screen/fullscreen/lootbox_overlay/background
	icon_state = "background"
	layer = FULLSCREEN_LAYER + 0.1

/atom/movable/screen/fullscreen/lootbox_overlay/item_preview
	icon_state = "nuthin" // we set this ourselves
	layer = FULLSCREEN_LAYER + 0.3
	screen_loc = "CENTER+1:35, CENTER+2"

/atom/movable/screen/fullscreen/lootbox_overlay/duplicate
	icon_state = "duplicate"
	layer = FULLSCREEN_LAYER + 0.4
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/fullscreen/lootbox_overlay/main
	///have we already opened? prevents spam clicks
	var/opened = FALSE
	///are we a guarenteed roll for lootboxes.
	var/guarentee_unusual = FALSE

/atom/movable/screen/fullscreen/lootbox_overlay/main/guaranteed
	guarentee_unusual = TRUE

/atom/movable/screen/fullscreen/lootbox_overlay/main/Click(location, control, params)
	if(opened)
		return
	opened = TRUE
	playsound(usr, pick('goon/sounds/misc/openlootcrate.ogg', 'goon/sounds/misc/openlootcrate2.ogg'), 100, 0)
	icon_state = "lootb2"
	flick("lootb1", src)
	addtimer(CALLBACK(src, PROC_REF(after_open), usr), 2 SECONDS)

/atom/movable/screen/fullscreen/lootbox_overlay/main/proc/after_open(mob/user)
	if(!user) // uh
		return

	//now we add
	user.overlay_fullscreen("lb_spark", /atom/movable/screen/fullscreen/lootbox_overlay/sparks)
	user.overlay_fullscreen("lb_bg", /atom/movable/screen/fullscreen/lootbox_overlay/background)
	var/atom/movable/screen/fullscreen/lootbox_overlay/item_preview/preview = user.overlay_fullscreen("lb_preview", /atom/movable/screen/fullscreen/lootbox_overlay/item_preview)

	var/type_rolled
	if(!guarentee_unusual)
		type_rolled = rand(1, 100)
	else
		type_rolled = 1

	var/type_string
	switch(type_rolled)
		if(1)
			type_string = "Unusual"
		if(2 to 3)
			type_string = "High Tier"
		if(4 to 8)
			type_string = "Medium Tier"
		if(9 to 15)
			type_string = "Low Tier"
		else
			type_string = "Loadout Item"

	var/obj/item/rolled_item = return_rolled(type_string, user)
	preview.icon_state = rolled_item.icon_state
	preview.icon =  rolled_item.icon
	preview.appearance = rolled_item.appearance
	preview.scale_to(10, 10)
	user.reload_fullscreen()
	preview.plane = ABOVE_HUD_PLANE

	maptext = "[rolled_item.name]"
	maptext_width = 360
	maptext_x += 120 - length(rolled_item.name)
	maptext_y += 60
	if(user.client)
		message_admins("[user.client.ckey] opened a lootbox and recieved [rolled_item.name]!")
		logger.Log(LOG_CATEGORY_META, "[user.client.ckey] opened a lootbox and recieved [rolled_item.name]!", list("currency_left" = user.client.prefs.metacoins))
	preview.filters += filter(type = "drop_shadow", x = 0, y = 0, size= 5, offset = 0, color = "#F0CA85")
	if(type_string == "Unusual")
		to_chat(world, span_boldannounce("[user] has unboxed an [rolled_item.name]!"))
		if(isliving(user) && !user.put_in_hands(rolled_item))
			rolled_item.forceMove(get_turf(user))

	addtimer(CALLBACK(src, PROC_REF(cleanup), user), 3 SECONDS)

/atom/movable/screen/fullscreen/lootbox_overlay/main/proc/cleanup(mob/user)
	if(!user)
		return
	user.clear_fullscreen("lb_spark", 1 SECONDS)
	user.clear_fullscreen("lb_bg", 1 SECONDS)
	user.clear_fullscreen("lb_preview", 1 SECONDS)
	user.clear_fullscreen("lb_main", 1 SECONDS)
	user.clear_fullscreen("lb_duplicate", 1 SECONDS)
	qdel(src)


/proc/testing_trigger_lootbox(mob/user = usr)
	if(!user || !user.client)
		return

	user.overlay_fullscreen("lb_main", /atom/movable/screen/fullscreen/lootbox_overlay/main/guaranteed)

/mob/proc/trigger_lootbox_on_self()
	src.overlay_fullscreen("lb_main", /atom/movable/screen/fullscreen/lootbox_overlay/main)

/obj/item/lootbox
	name = "lootbox"
	icon = 'goon/icons/obj/large_storage.dmi'
	icon_state = "attachecase-old"

/obj/item/lootbox/attack_self(mob/user, modifiers)
	. = ..()
	user.trigger_lootbox_on_self()
	qdel(src)
