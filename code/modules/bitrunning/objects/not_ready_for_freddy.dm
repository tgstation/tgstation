#define BITRUNNING_DOORBLOCK_RIGHT "right_door"
#define BITRUNNING_DOORBLOCK_LEFT "left_door"
#define DISPLAY_PIXEL_ALPHA 96
/datum/looping_sound/phone_ring
	mid_sounds = list('sound/weapons/ring.ogg' = 1)
	mid_length = 2 SECONDS
	volume = 100
	ignore_walls = FALSE // we dont want to ring to other bitrunners

/obj/bitrunning/animatronic_phone
	name = "red phone"
	desc = "It's ringing for you. Pick it up to begin the night."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "red_phone"
	density = FALSE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE
	var/obj/bitrunning/animatronic_controller/our_controller
	var/started_night = FALSE
	var/list/lines = list(
		"Hello, hello!",
		"I'm recording this message to help you get settled in on your first night.",
		"Welcome to the Nanotrasen Pizza Parlor, for crewmembers of all levels of boredom.",
	)
	var/current_line = 1
	var/finished_lines = FALSE
	var/speech_loop
	var/datum/looping_sound/phone_ring/phone_ring

/obj/bitrunning/animatronic_phone/Initialize(mapload)
	. = ..()
	phone_ring = new(src, TRUE)

/obj/bitrunning/animatronic_phone/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!started_night)
		started_night = TRUE
		current_line = 1
		QDEL_NULL(phone_ring)
		speech_loop = addtimer(CALLBACK(src, PROC_REF(phone_guy)), 3 SECONDS, TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME)
		our_controller.start_night()

/obj/bitrunning/animatronic_phone/proc/phone_guy()
	if(current_line > length(lines))
		deltimer(speech_loop)
		return
	say(lines[current_line])
	current_line++

/obj/machinery/light/small/dim/bitrunner_right
	cam_break_toggle = FALSE
	no_low_power = TRUE

/obj/machinery/light/small/dim/bitrunner_left
	cam_break_toggle = FALSE
	no_low_power = TRUE

/obj/machinery/door/poddoor/bitrunner_right

/obj/machinery/door/poddoor/bitrunner_left

/obj/bitrunning/door_button
	name = "Door Button"
	desc = "Shut the blast doors, for a price!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "door_off"
	icon_state = "door_off"
	var/obj/bitrunning/animatronic_controller/our_controller
	var/which_side

/obj/bitrunning/door_button/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(our_controller.power_left > 0)
		switch(which_side)
			if(BITRUNNING_DOORBLOCK_RIGHT)
				if(our_controller.right_door.density)
					our_controller.right_door.open()
				else
					our_controller.right_door.close()
			if(BITRUNNING_DOORBLOCK_LEFT)
				if(our_controller.left_door.density)
					our_controller.left_door.open()
				else
					our_controller.left_door.close()
	update_icon()

/obj/bitrunning/door_button/update_icon(updates)
	. = ..()
	if(!our_controller.power_left)
		icon_state = "door_nopower"
		return
	switch(which_side)
		if(BITRUNNING_DOORBLOCK_RIGHT)
			if(our_controller.right_door.density)
				icon_state = "door_on"
			else
				icon_state = "door_off"
		if(BITRUNNING_DOORBLOCK_LEFT)
			if(our_controller.left_door.density)
				icon_state = "door_on"
			else
				icon_state = "door_off"

/obj/bitrunning/door_button/left
	which_side = BITRUNNING_DOORBLOCK_LEFT

/obj/bitrunning/door_button/right
	which_side = BITRUNNING_DOORBLOCK_RIGHT

/obj/bitrunning/light_button
	name = "Light Button"
	desc = "Turn on some lights, for a price!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "light_off"
	icon_state = "light_off"
	var/obj/bitrunning/animatronic_controller/our_controller
	var/which_side

/obj/bitrunning/light_button/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(our_controller.power_left > 0)
		switch(which_side)
			if(BITRUNNING_DOORBLOCK_RIGHT)
				if(our_controller.right_light.on)
					our_controller.right_light.set_on(FALSE)
				else
					our_controller.right_light.set_on(TRUE)
			if(BITRUNNING_DOORBLOCK_LEFT)
				if(our_controller.left_light.on)
					our_controller.left_light.set_on(FALSE)
				else
					our_controller.left_light.set_on(TRUE)
	update_icon()

/obj/bitrunning/light_button/update_icon(updates)
	. = ..()
	if(!our_controller.power_left)
		icon_state = "light_nopower"
		return
	switch(which_side)
		if(BITRUNNING_DOORBLOCK_RIGHT)
			if(our_controller.right_light.on)
				icon_state = "light_on"
			else
				icon_state = "light_off"
		if(BITRUNNING_DOORBLOCK_LEFT)
			if(our_controller.left_light.on)
				icon_state = "light_on"
			else
				icon_state = "light_off"


/obj/bitrunning/light_button/left
	which_side = BITRUNNING_DOORBLOCK_LEFT

/obj/bitrunning/light_button/right
	which_side = BITRUNNING_DOORBLOCK_RIGHT

/obj/machinery/computer/security/bitrunner
	var/shut_down = FALSE

/obj/machinery/computer/security/bitrunner/ui_interact(mob/user, datum/tgui/ui)
	if(!shut_down)
		. = ..()

/obj/machinery/digital_clock/bitrunner
	var/obj/bitrunning/animatronic_controller/my_controller

/obj/machinery/digital_clock/bitrunner/update_time()
	if(!my_controller || !my_controller.power_left)
		return // lol no power
	var/return_overlays = list()

	var/mutable_appearance/minute_one_overlay = mutable_appearance('icons/obj/machines/digital_clock.dmi', "+0")
	var/mutable_appearance/minute_one_e = emissive_appearance('icons/obj/machines/digital_clock.dmi', "+0", src, alpha = DISPLAY_PIXEL_ALPHA)
	minute_one_overlay.pixel_w = 0
	minute_one_e.pixel_w = 0
	return_overlays += minute_one_overlay
	return_overlays += minute_one_e

	var/mutable_appearance/minute_tenth_overlay = mutable_appearance('icons/obj/machines/digital_clock.dmi', "+0")
	var/mutable_appearance/minute_tenth_e = emissive_appearance('icons/obj/machines/digital_clock.dmi', "+0", src, alpha = DISPLAY_PIXEL_ALPHA)
	minute_tenth_overlay.pixel_w = -4
	minute_tenth_e.pixel_w = -4
	return_overlays += minute_tenth_overlay
	return_overlays += minute_tenth_e

	var/mutable_appearance/separator = mutable_appearance('icons/obj/machines/digital_clock.dmi', "+separator")
	var/mutable_appearance/separator_e = emissive_appearance('icons/obj/machines/digital_clock.dmi', "+separator", src, alpha = DISPLAY_PIXEL_ALPHA)
	return_overlays += separator
	return_overlays += separator_e

	var/hours_render = my_controller.minutes_passed == 0 ? 2 : my_controller.minutes_passed
	var/mutable_appearance/hour_one_overlay = mutable_appearance('icons/obj/machines/digital_clock.dmi', "+[hours_render]")
	var/mutable_appearance/hour_one_e = emissive_appearance('icons/obj/machines/digital_clock.dmi', "+[hours_render]", src, alpha = DISPLAY_PIXEL_ALPHA)
	hour_one_overlay.pixel_w = -10
	hour_one_e.pixel_w = -10
	return_overlays += hour_one_overlay
	return_overlays += hour_one_e
	var/subhours_render = my_controller.minutes_passed == 0 ? 1 : 0
	var/mutable_appearance/hour_tenth_overlay = mutable_appearance('icons/obj/machines/digital_clock.dmi', "+[subhours_render]")
	var/mutable_appearance/hour_tenth_e = emissive_appearance('icons/obj/machines/digital_clock.dmi', "+[subhours_render]", src, alpha = DISPLAY_PIXEL_ALPHA)
	hour_tenth_overlay.pixel_w = -14
	hour_tenth_e.pixel_w = -14
	return_overlays += hour_tenth_overlay
	return_overlays += hour_tenth_e

	return return_overlays

/obj/machinery/digital_clock/bitrunner_power
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "power_base"
	var/obj/bitrunning/animatronic_controller/my_controller

/obj/machinery/digital_clock/bitrunner_power/update_time()
	if(!my_controller || !my_controller.power_left)
		return // lol no power
	var/return_overlays = list()

	var/mutable_appearance/percent_symbol = mutable_appearance('icons/obj/machines/bitrunning.dmi', "percent")
	var/mutable_appearance/percent_symbol_e = emissive_appearance('icons/obj/machines/bitrunning.dmi', "percent", src, alpha = DISPLAY_PIXEL_ALPHA)
	return_overlays += percent_symbol
	return_overlays += percent_symbol_e

	var/first_digit_string = "[my_controller.power_left]"
	if(my_controller.power_left >= 100)
		first_digit_string = first_digit_string[3]
	else if (my_controller.power_left >= 10)
		first_digit_string = first_digit_string[2]
	var/mutable_appearance/first_digit = mutable_appearance('icons/obj/machines/bitrunning.dmi', "+[first_digit_string]")
	var/mutable_appearance/first_digit_e = emissive_appearance('icons/obj/machines/bitrunning.dmi', "+[first_digit_string]", src, alpha = DISPLAY_PIXEL_ALPHA)
	first_digit.pixel_w = -7
	first_digit_e.pixel_w = -7
	return_overlays += first_digit
	return_overlays += first_digit_e

	if(my_controller.power_left >= 100)
		first_digit_string = "[my_controller.power_left]"
		var/mutable_appearance/hundredth_digit = mutable_appearance('icons/obj/machines/bitrunning.dmi', "+1")
		var/mutable_appearance/hundredth_digit_e = emissive_appearance('icons/obj/machines/bitrunning.dmi', "+1", src, alpha = DISPLAY_PIXEL_ALPHA)
		hundredth_digit.pixel_w = -16
		hundredth_digit_e.pixel_w = -16
		return_overlays += hundredth_digit
		return_overlays += hundredth_digit_e
		var/mutable_appearance/tenth_digit = mutable_appearance('icons/obj/machines/bitrunning.dmi', "+[first_digit_string[2]]")
		var/mutable_appearance/tenth_digit_e = emissive_appearance('icons/obj/machines/bitrunning.dmi', "+[first_digit_string[2]]", src, alpha = DISPLAY_PIXEL_ALPHA)
		tenth_digit.pixel_w = -12
		tenth_digit_e.pixel_w = -12
		return_overlays += tenth_digit
		return_overlays += tenth_digit_e

	else if(my_controller.power_left >= 10)
		first_digit_string = "[my_controller.power_left]"
		var/mutable_appearance/tenth_digit = mutable_appearance('icons/obj/machines/bitrunning.dmi', "+[first_digit_string[1]]")
		var/mutable_appearance/tenth_digit_e = emissive_appearance('icons/obj/machines/bitrunning.dmi', "+[first_digit_string[1]]", src, alpha = DISPLAY_PIXEL_ALPHA)
		tenth_digit.pixel_w = -12
		tenth_digit_e.pixel_w = -12
		return_overlays += tenth_digit
		return_overlays += tenth_digit_e


	if(my_controller.active_drains)
		var/mutable_appearance/power_usage = mutable_appearance('icons/obj/machines/bitrunning.dmi', "powerbar_[my_controller.active_drains]")
		var/mutable_appearance/power_usage_e = emissive_appearance('icons/obj/machines/bitrunning.dmi', "powerbar_[my_controller.active_drains]", src, alpha = DISPLAY_PIXEL_ALPHA)
		return_overlays += power_usage
		return_overlays += power_usage_e

	return return_overlays

/obj/bitrunning/animatronic_controller
	name = "Animatronic Controller"
	desc = "If you can see this, file a bug report."
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "animatronic_controller"
	icon_state = "animatronic_controller"
	alpha = 0
	mouse_opacity = 0
	density = FALSE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE
	var/power_left = 100
	var/obj/machinery/computer/security/bitrunner/camera_console
	var/obj/bitrunning/animatronic_phone/our_phone
	var/list/ai_levels = list(
		/obj/bitrunning/animatronic/standard = 0,
		/obj/bitrunning/animatronic/janitor = 0,
		/obj/bitrunning/animatronic/engineering = 0,
		/obj/bitrunning/animatronic/security = 0
	)
	var/list/starting_ai_levels = list(
		/obj/bitrunning/animatronic/standard = 0,
		/obj/bitrunning/animatronic/janitor = 0,
		/obj/bitrunning/animatronic/engineering = 0,
		/obj/bitrunning/animatronic/security = 0
	)
	var/list/animatronics = list()
	var/list/pathfinding_nodes = list()
	var/security_attacks = 0
	var/minutes_passed = 0
	var/movement_process_timer
	var/six_minute_timer
	var/power_drain_timer
	var/every_minute_timer
	var/active_drains = 0
	var/obj/machinery/door/poddoor/left_door
	var/obj/machinery/door/poddoor/right_door
	var/obj/machinery/light/small/dim/left_light
	var/obj/machinery/light/small/dim/right_light
	var/obj/machinery/digital_clock/bitrunner/my_clock
	var/obj/machinery/digital_clock/bitrunner_power/my_power

/obj/bitrunning/animatronic_controller/proc/start_night()
	power_left = 100
	minutes_passed = 0
	security_attacks = 0
	ai_levels = starting_ai_levels
	camera_console.shut_down = FALSE
	camera_console.set_is_operational(TRUE)
	left_door.set_is_operational(TRUE)
	right_door.set_is_operational(TRUE)
	left_door.open(TRUE)
	right_door.open(TRUE)
	left_light.set_on(FALSE)
	right_light.set_on(FALSE)
	my_clock.set_light(0)
	my_clock.update_icon()
	my_power.set_light(0)
	my_power.update_icon()
	for(var/obj/bitrunning/animatronic/robot in animatronics)
		robot.forceMove(get_turf(robot.starting_node))
		robot.setDir(robot.starting_node.dir)
		robot.current_node = robot.starting_node
	movement_process_timer = addtimer(CALLBACK(src, PROC_REF(movement_tick)), 5 SECONDS, TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME)
	every_minute_timer = addtimer(CALLBACK(src, PROC_REF(minute_tick)), 1 MINUTES, TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME)
	six_minute_timer = addtimer(CALLBACK(src, PROC_REF(victory)), 6 MINUTES, TIMER_STOPPABLE | TIMER_DELETE_ME)
	power_drain_timer = addtimer(CALLBACK(src, PROC_REF(drain_power)), 9.6 SECONDS, TIMER_STOPPABLE | TIMER_DELETE_ME)

/obj/bitrunning/animatronic_controller/proc/minute_tick()
	minutes_passed++
	switch(minutes_passed)
		if(2)
			ai_levels[/obj/bitrunning/animatronic/janitor] += 1
		if(3)
			ai_levels[/obj/bitrunning/animatronic/janitor] += 1
			ai_levels[/obj/bitrunning/animatronic/engineering] += 1
			ai_levels[/obj/bitrunning/animatronic/security] += 1
		if(4)
			ai_levels[/obj/bitrunning/animatronic/janitor] += 1
			ai_levels[/obj/bitrunning/animatronic/engineering] += 1
			ai_levels[/obj/bitrunning/animatronic/security] += 1
	my_clock.update_icon()

/obj/bitrunning/animatronic_controller/proc/movement_tick()
	for(var/obj/bitrunning/animatronic/robot in animatronics)
		var/movement_roll = rand(1,20)
		if(ai_levels[robot.type] >= movement_roll)
			if(!robot.can_move(src))
				continue
			var/chosen_node = pick(robot.current_node.possible_movement_nodes)
			var/obj/bitrunning/animatronic_movement_node/next_node = pathfinding_nodes[chosen_node]
			var/blocked = FALSE
			if(next_node.kill_node)
				if(next_node.blocking_door == BITRUNNING_DOORBLOCK_RIGHT && right_door.density)
					blocked = TRUE
				else if(next_node.blocking_door == BITRUNNING_DOORBLOCK_LEFT && left_door.density)
					blocked = TRUE
				if(!blocked)
					you_failed(robot)
					break
				else
					next_node = pathfinding_nodes[next_node.failure_reset_id]
			robot.forceMove(get_turf(next_node))
			robot.setDir(next_node.dir)
			robot.on_move(blocked, src)
			robot.current_node = next_node

/obj/bitrunning/animatronic_controller/proc/drain_power()
	power_left--
	active_drains = 0
	if(power_left <= 0)
		power_outage()
		return
	var/default_timer = 9.6 SECONDS
	if(left_door.density)
		default_timer *= 0.5
		active_drains++
	if(right_door.density)
		default_timer *= 0.5
		active_drains++
	if(length(camera_console.concurrent_users))
		default_timer *= 0.5
		active_drains++
	if(left_light.on)
		default_timer *= 0.5
		active_drains++
	if(right_light.on)
		default_timer *= 0.5
		active_drains++
	my_power.update_icon()
	deltimer(power_drain_timer)
	power_drain_timer = addtimer(CALLBACK(src, PROC_REF(drain_power)), default_timer, TIMER_STOPPABLE | TIMER_DELETE_ME)

/obj/bitrunning/animatronic_controller/proc/power_outage()
	deltimer(power_drain_timer)
	SStgui.close_uis(camera_console)
	camera_console.set_is_operational(FALSE)
	camera_console.shut_down = TRUE
	left_door.set_is_operational(FALSE)
	right_door.set_is_operational(FALSE)
	left_door.open(TRUE)
	right_door.open(TRUE)
	left_light.set_on(FALSE)
	right_light.set_on(FALSE)
	my_clock.update_icon()
	my_power.update_icon()

/obj/bitrunning/animatronic_controller/proc/victory()
	deltimer(movement_process_timer)
	deltimer(six_minute_timer)
	deltimer(power_drain_timer)
	deltimer(every_minute_timer)
	SStgui.close_uis(camera_console)
	minutes_passed = 6
	my_clock.update_icon() // show me that 6 AM
	playsound(src, 'sound/misc/announce.ogg', 100, FALSE)
	our_phone.say("Congratulations on making it through the night! Here's your nightly bonus.")
	new /obj/structure/closet/crate/secure/bitrunning/encrypted(get_turf(src))

/obj/bitrunning/animatronic_controller/proc/you_failed(obj/bitrunning/animatronic/killer_robot)
	deltimer(movement_process_timer)
	deltimer(six_minute_timer)
	deltimer(power_drain_timer)
	deltimer(every_minute_timer)
	SStgui.close_uis(camera_console)
	for(var/mob/markiplier in range(3, get_turf(src)))
		if(markiplier.client)
			var/image/jumpscare = image(icon = killer_robot.icon, loc = markiplier, icon_state = killer_robot.icon_state, dir = SOUTH)
			jumpscare.transform = jumpscare.transform.Scale(16, 16)
			SET_PLANE(jumpscare, ABOVE_HUD_PLANE, markiplier)
			markiplier.client.images += jumpscare
			jumpscare.Shake(5, 5, 2 SECONDS)
			markiplier.playsound_local(get_turf(src), 'sound/effects/explosion1.ogg', 100, FALSE)
			addtimer(CALLBACK(src, PROC_REF(delete_jumpscare), markiplier, jumpscare), 2 SECONDS, TIMER_DELETE_ME | TIMER_CLIENT_TIME)
		markiplier.emote("scream")
	our_phone.started_night = FALSE
	our_phone.phone_ring = new(our_phone, TRUE)

/obj/bitrunning/animatronic_controller/proc/delete_jumpscare(mob/markiplier, image/jumpscare)
	markiplier?.client?.images -= jumpscare
	qdel(jumpscare)

/obj/bitrunning/animatronic
	name = "Frederick Fastbearington"
	desc = "Was that the debug of '87???"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "frederick"
	icon_state = "frederick"
	density = TRUE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE
	var/obj/bitrunning/animatronic_movement_node/starting_node
	var/obj/bitrunning/animatronic_movement_node/current_node

/obj/bitrunning/animatronic/proc/on_move(blocked, obj/bitrunning/animatronic_controller/animatronic_controller_used)
	return

/obj/bitrunning/animatronic/proc/can_move(obj/bitrunning/animatronic_controller/animatronic_controller_used)
	return TRUE

/obj/bitrunning/animatronic/standard
	name = "Standard Cyborg"
	desc = "The most famous cast member of the Nanotrasen Cyborg Band! He may not work the station anymore, but he loves to entertain bored crewmembers! \
	Are you ready for Standard Cyborg?"

/obj/bitrunning/animatronic/standard/on_move(blocked, obj/bitrunning/animatronic_controller/animatronic_controller_used)
	playsound(animatronic_controller_used, 'sound/voice/insane_low_laugh.ogg', 100, vary = TRUE)

/obj/bitrunning/animatronic/janitor
	name = "Janitor Cyborg"
	icon_state = "bannie"
	desc = "Working hard to keep the pizza parlor clean, the Janitor Cyborg never misses a spill, and will always be there for you on a predictable basis!"

/obj/bitrunning/animatronic/engineering
	name = "Engineering Cyborg"
	icon_state = "cheeka"
	desc = "The Engineering Cyborg keeps this pizza place ship-shape and ready to serve patrons, along with using their welder to cook our famous welding fuel pizza!"

/obj/bitrunning/animatronic/security
	name = "Security Cyborg"
	icon_state = "fawxie"
	desc = "After their retirement from the station, the Security Cyborg now keeps the peace at the pizza parlor and makes sure diners are happy and safe!"

/obj/bitrunning/animatronic/security/can_move(obj/bitrunning/animatronic_controller/animatronic_controller_used)
	if(current_node.node_id != "stage3_security") // still on stage, we can camera stall him
		if(length(animatronic_controller_used.camera_console.concurrent_users) && animatronic_controller_used.camera_console.active_camera && animatronic_controller_used.camera_console.active_camera.c_tag == "Security Cove")
			return FALSE // keeping an eye on the Security Cyborg keeps him contained, unless he's already escaped
	return TRUE

/obj/bitrunning/animatronic/security/on_move(blocked, obj/bitrunning/animatronic_controller/animatronic_controller_used)
	if(blocked)
		animatronic_controller_used.power_left -= 1 + (animatronic_controller_used.security_attacks * 5)
		animatronic_controller_used.security_attacks++
		if(animatronic_controller_used.power_left <= 0)
			animatronic_controller_used.power_left = 0
			animatronic_controller_used.power_outage()
		animatronic_controller_used.my_power.update_icon()
		playsound(animatronic_controller_used.left_door, 'sound/items/gas_tank_drop.ogg', 125, FALSE)

/obj/bitrunning/animatronic_movement_node
	name = "Animatronic Pathfinding Node"
	desc = "If you can see this, file a bug report!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "animatronic_node"
	icon_state = "animatronic_node"
	mouse_opacity = 0
	density = FALSE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE
	var/node_id
	var/list/possible_movement_nodes = list()
	var/kill_node = FALSE
	var/failure_reset_id
	var/blocking_door

/obj/bitrunning/animatronic_movement_node/Initialize(mapload)
	. = ..()
	alpha = 0

/obj/bitrunning/animatronic_movement_node/standard
	name = "Standard Cyborg Pathfinding Node"
	color = "#A52A2A"

/obj/bitrunning/animatronic_movement_node/standard/stage
	node_id = "stage_standard"
	possible_movement_nodes = list("tables_standard")

/obj/bitrunning/animatronic_movement_node/standard/tables
	node_id = "tables_standard"
	possible_movement_nodes = list("bathroom_standard")

/obj/bitrunning/animatronic_movement_node/standard/bathroom
	node_id = "bathroom_standard"
	possible_movement_nodes = list("kitchen_standard")

/obj/bitrunning/animatronic_movement_node/standard/kitchen
	node_id = "kitchen_standard"
	possible_movement_nodes = list("hallway_standard")

/obj/bitrunning/animatronic_movement_node/standard/hallway
	node_id = "hallway_standard"
	possible_movement_nodes = list("door_standard")

/obj/bitrunning/animatronic_movement_node/standard/door
	node_id = "door_standard"
	possible_movement_nodes = list("kills_you_standard")

/obj/bitrunning/animatronic_movement_node/standard/kills_you
	node_id = "kills_you_standard"
	kill_node = TRUE
	blocking_door = BITRUNNING_DOORBLOCK_RIGHT
	failure_reset_id = "hallway_standard"

/obj/bitrunning/animatronic_movement_node/security
	name = "Security Cyborg Pathfinding Node"
	color = "#FF0000"

/obj/bitrunning/animatronic_movement_node/security/stage1
	node_id = "stage1_security"
	possible_movement_nodes = list("stage2_security")

/obj/bitrunning/animatronic_movement_node/security/stage2
	node_id = "stage2_security"
	possible_movement_nodes = list("stage3_security")

/obj/bitrunning/animatronic_movement_node/security/stage3
	node_id = "stage3_security"
	possible_movement_nodes = list("kills_you_security")

/obj/bitrunning/animatronic_movement_node/security/kills_you
	node_id = "kills_you_security"
	kill_node = TRUE
	blocking_door = BITRUNNING_DOORBLOCK_LEFT
	failure_reset_id = "stage1_security"

/obj/bitrunning/animatronic_movement_node/janitor
	name = "Janitor Cyborg Pathfinding Node"
	color = "#41218d"

/obj/bitrunning/animatronic_movement_node/janitor/stage
	node_id = "stage_janitor"
	possible_movement_nodes = list("tables1_janitor", "arcade1_janitor")

/obj/bitrunning/animatronic_movement_node/janitor/tables1
	node_id = "tables1_janitor"
	possible_movement_nodes = list("arcade1_janitor", "tables2_janitor")

/obj/bitrunning/animatronic_movement_node/janitor/tables2
	node_id = "tables2_janitor"
	possible_movement_nodes = list("hallway1_janitor")

/obj/bitrunning/animatronic_movement_node/janitor/arcade1
	node_id = "arcade1_janitor"
	possible_movement_nodes = list("tables1_janitor", "arcade2_janitor", "hallway1_janitor")

/obj/bitrunning/animatronic_movement_node/janitor/arcade2
	node_id = "arcade2_janitor"
	possible_movement_nodes = list("arcade1_janitor")

/obj/bitrunning/animatronic_movement_node/janitor/hallway1
	node_id = "hallway1_janitor"
	possible_movement_nodes = list("storage_janitor", "hallway2_janitor")

/obj/bitrunning/animatronic_movement_node/janitor/hallway2
	node_id = "hallway2_janitor"
	possible_movement_nodes = list("storage_janitor", "door_janitor")

/obj/bitrunning/animatronic_movement_node/janitor/storage
	node_id = "storage_janitor"
	possible_movement_nodes = list("hallway1_janitor", "hallway2_janitor", "door_janitor")

/obj/bitrunning/animatronic_movement_node/janitor/door
	node_id = "door_janitor"
	possible_movement_nodes = list("kills_you_janitor")

/obj/bitrunning/animatronic_movement_node/janitor/kills_you
	node_id = "kills_you_janitor"
	kill_node = TRUE
	blocking_door = BITRUNNING_DOORBLOCK_LEFT
	failure_reset_id = "tables1_janitor"

/obj/bitrunning/animatronic_movement_node/engineering
	name = "Engineering Cyborg Pathfinding Node"
	color = "#ff7b00"

/obj/bitrunning/animatronic_movement_node/engineering/stage
	node_id = "stage_engineering"
	possible_movement_nodes = list("tables1_engineering")

/obj/bitrunning/animatronic_movement_node/engineering/tables1
	node_id = "tables1_engineering"
	possible_movement_nodes = list("tables1_engineering", "bathroom1_engineering", "tables2_engineering")

/obj/bitrunning/animatronic_movement_node/engineering/tables2
	node_id = "tables2_engineering"
	possible_movement_nodes = list("tables1_engineering", "hallway1_engineering")

/obj/bitrunning/animatronic_movement_node/engineering/bathroom1
	node_id = "bathroom1_engineering"
	possible_movement_nodes = list("bathroom2_engineering", "kitchen_engineering", "hallway1_engineering")

/obj/bitrunning/animatronic_movement_node/engineering/bathroom2
	node_id = "bathroom2_engineering"
	possible_movement_nodes = list("bathroom1_engineering")

/obj/bitrunning/animatronic_movement_node/engineering/kitchen
	node_id = "kitchen_engineering"
	possible_movement_nodes = list("hallway1_engineering", "bathroom1_engineering")

/obj/bitrunning/animatronic_movement_node/engineering/hallway1
	node_id = "hallway1_engineering"
	possible_movement_nodes = list("hallway2_engineering", "tables2_engineering")

/obj/bitrunning/animatronic_movement_node/engineering/hallway2
	node_id = "hallway2_engineering"
	possible_movement_nodes = list("hallway1_engineering", "window_engineering")

/obj/bitrunning/animatronic_movement_node/engineering/window
	node_id = "window_engineering"
	possible_movement_nodes = list("kills_you_engineering")

/obj/bitrunning/animatronic_movement_node/engineering/kills_you
	node_id = "kills_you_engineering"
	kill_node = TRUE
	blocking_door = BITRUNNING_DOORBLOCK_RIGHT
	failure_reset_id = "hallway1_engineering"
