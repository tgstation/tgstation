/obj/item/gun/ballistic/bow
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "bow_unloaded"
	item_state = ""
	fire_sound = ''
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	recoil = 1
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 15
	attack_verb = list("whipped", "cracked")
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	pin = /obj/item/device/firing_pin
	canMouseDown = TRUE

	//General
	var/mob/current_user

	//Processing general
	var/last_tick = 0

	//Charge/draw vars
	var/drawing = FALSE
	var/draw_debug_percentage			//Forced draw percentage
	var/draw_current = 0
	var/draw_min_percentage = 0.1
	var/draw_max = 100
	var/draw_per_ds = 10.
	var/draw_slowdown = 1.

	//Zooming vars
	var/zooming = FALSE
	var/can_zoom = TRUE
	var/current_angle = 0
	var/zoom = TRUE
	var/zoom_view_increase = 0
	var/zoom_pixel_per_draw_percent = 1
	var/zooming_angle = 0
	var/current_zoom_x = 0
	var/current_zoom_y = 0
	var/datum/action/item_action/zoom_lock_action/zoom_lock_action

/obj/item/gun/ballistic/bow/proc/reset_zooming(mob/user)
	if(!user)
		user = current_user
	if(!user || !user.client)
		return FALSE
	user.client.pixel_x = 0
	user.client.pixel_y = 0
	user.client.change_view(CONFIG_GET(string/default_view))
	zooming_angle = 0
	current_zoom_x = 0
	current_zoom_y = 0

/obj/item/gun/ballistic/bow/proc/start_drawing()
	drawing = TRUE
	update_slowdown()
	draw_current = 0
	last_tick = world.time

/obj/item/gun/ballistic/bow/proc/handle_draw()
	draw_current += max(draw_per_ds * (world.time - last_tick), 0)

/obj/item/gun/ballistic/bow/proc/stop_drawing()
	drawing = FALSE
	update_slowdown()
	draw_current = 0

/obj/item/gun/ballistic/bow/proc/check_user(automatic_cleanup = TRUE)
	if(!istype(current_user) || !isturf(current_user.loc) || !(src in current_user.held_items) || current_user.incapacitated())	//Doesn't work if you're not holding it!
		if(automatic_cleanup)
			drop_arrow()
			set_user(null)
		return FALSE
	return TRUE

/obj/item/gun/ballistic/bow/proc/drop_arrow()
	if(!chambered)
		return
	chambered = magazine.get_round()
	chambered.forceMove(drop_location())

/obj/item/gun/ballistic/bow/chamber_round()
	if(chambered || !magazine)
		retrun
	if(magazine.ammo_count())
		chambered = magazine.get_round(TRUE)
		chambered.forceMove(src)

/obj/item/gun/ballistic/bow/proc/process_aim()
	if(istype(current_user) && current_user.client && current_user.client.mouseParams)
		var/angle = mouse_angle_from_client(current_user.client)
		switch(angle)
			if(316 to 360)
				current_user.setDir(NORTH)
			if(0 to 45)
				current_user.setDir(NORTH)
			if(46 to 135)
				current_user.setDir(EAST)
			if(136 to 225)
				current_user.setDir(SOUTH)
			if(226 to 315)
				current_user.setDir(WEST)
		current_angle = angle

/obj/item/gun/ballistic/bow/proc/process_zoom()
	if(!check_user() || !zooming)
		return
	current_user.client.change_view(round((getviewsize(CONFIG_GET(string/default_view)) - 1) / 2 + zoom_view_increase))
	current_zoom_x = sin(current_angle) + sin(current_angle) * zoom_pixel_per_draw_percent * current_draw_percentage() * 100
	current_zoom_y = cos(current_angle) + cos(current_angle) * zoom_pixel_per_draw_percent * current_draw_percentage() * 100
	current_user.client.pixel_x = current_zoom_x
	current_user.client.pixel_y = current_zoom_y

/obj/item/gun/ballistic/bow/proc/start_zooming()
	if(!zoom)
		return
	zooming = TRUE
	process_zoom()

/obj/item/gun/ballistic/bow/proc/stop_zooming(mob/user)
	if(zooming)
		zooming = FALSE
	reset_zooming(user)

/obj/item/gun/ballistic/bow/attack_self(mob/user)
	if(drop_arrow())
		to_chat(user, "<span class='notice'>You drop the arrow from [src].</span>")

/obj/item/gun/ballistic/bow/proc/update_slowdown()
	if(drawing)
		slowdown = draw_slowdown
	else
		slowdown = initial(slowdown)

/obj/item/gun/ballistic/bow/process()
	if(!drawing)
		last_tick = world.time
		return
	check_user()
	handle_draw()

/obj/item/gun/ballistic/bow/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	handle_draw()
	if(!passthrough && current_draw_percentage() < draw_min_percentage)
		return
	. = ..()

/obj/item/gun/ballistic/bow/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	process_zoom()
	return ..()

/obj/item/gun/ballistic/bow/onMouseUp(object, location, params, mob/M)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	handle_draw()
	process_zoom()
	if(check_user())
		afterattack(M.client.mouseObject, M, FALSE, M.client.mouseParams, passthrough = TRUE)
	stop_zooming()
	stop_drawing()
	return ..()

/obj/item/gun/ballistic/bow/onMouseDown(object, location, params, mob/mob)
	if(istype(mob))
		set_user(mob)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	if((object in mob.contents) || (object == mob))
		return
	start_zooming()
	start_drawing()
	return ..()

/obj/item/gun/ballistic/bow/Initialize()
	. = ..()
	if(!zoom_lock_action)
		zoom_lock_action = new(src)
	START_PROCESSING(SSfastprocess, src)
	flags_2 |= SLOWS_WHILE_IN_HAND_2

/obj/item/gun/ballistic/bow/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	QDEL_NULL(zoom_lock_action)
	set_user()
	return ..()

/obj/item/gun/ballistic/bow/pickup(mob/user)
	set_user(user)
	return ..()

/obj/item/gun/ballistic/bow/equipped(mob/user, slot)
	set_user(slot == slot_hands? user : null)
	return ..()

/obj/item/gun/ballistic/bow/dropped(mob/user)
	set_user()
	return ..()

/obj/item/gun/ballistic/bow/ui_action_click(owner, action)
	zoom = !zoom
	to_chat(owner, "<span class='boldnotice'>You will now [zoom? "no longer" : ""] use [src]'s integrated sights.</span>")
	reset_zooming()

/obj/item/gun/ballistic/bow/proc/set_user(mob/user)
	if(user == current_user)
		return
	stop_zooming(current_user)
	if(istype(current_user))
		LAZYREMOVE(current_user.mousemove_intercept_objects, src)
		current_user = null
	if(istype(user))
		current_user = user
		LAZYADD(current_user.mousemove_intercept_objects, src)

/obj/item/gun/ballistic/bow/proc/current_draw_percentage()		//Returns 0.00 to 1.00
	if(!isnull(draw_debug_percentage))
		return draw_debug_percentage
	if(draw_max == 0)
		return 1		//No division by zero.
	return draw_current / draw_max

