#define OPEN_DURATION 6
#define CLOSE_DURATION 6

// A place where tube pods stop, and people can get in or out.
// Mappers: use "Generate Instances from Directions" for this
// one.


/obj/structure/transit_tube/station
	name = "station tube station"
	icon_state = "closed_station0"
	base_icon_state = "station0"
	desc = "The lynchpin of the transit system."
	exit_delay = 1
	enter_delay = 2
	tube_construction = /obj/structure/c_transit_tube/station

	var/open_status = STATION_TUBE_CLOSED
	var/pod_moving = FALSE
	var/cooldown_delay = 50
	var/launch_cooldown = 0
	var/reverse_launch = FALSE
	var/boarding_dir //from which direction you can board the tube

/obj/structure/transit_tube/station/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/transit_tube/station/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return TRUE

/obj/structure/transit_tube/station/Bumped(atom/movable/AM)
	if(!pod_moving && open_status == STATION_TUBE_OPEN && ismob(AM) && AM.dir == boarding_dir)
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(!pod.moving)
				AM.forceMove(pod)
				pod.update_appearance()
				return

//pod insertion
/obj/structure/transit_tube/station/mouse_drop_receive(obj/structure/c_transit_tube_pod/R, mob/user, params)
	if (!istype(R) || get_dist(user, src) > 1 || get_dist(src, R) > 1)
		return
	for(var/obj/structure/transit_tube_pod/pod in loc)
		return //no fun allowed
	var/obj/structure/transit_tube_pod/TP = new(loc)
	R.transfer_fingerprints_to(TP)
	TP.add_fingerprint(user)
	TP.setDir(turn(src.dir, -90))
	user.visible_message(span_notice("[user] inserts [R]."), span_notice("You insert [R]."))
	qdel(R)


/obj/structure/transit_tube/station/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!pod_moving)
		if(user.pulling && isliving(user.pulling))
			if(open_status == STATION_TUBE_OPEN)
				var/mob/living/GM = user.pulling
				if(user.grab_state >= GRAB_AGGRESSIVE)
					if(GM.buckled || GM.has_buckled_mobs())
						to_chat(user, span_warning("[GM] is attached to something!"))
						return
					for(var/obj/structure/transit_tube_pod/pod in loc)
						pod.visible_message(span_warning("[user] starts putting [GM] into the [pod]!"))
						if(do_after(user, 1.5 SECONDS, target = src))
							if(open_status == STATION_TUBE_OPEN && GM && user.grab_state >= GRAB_AGGRESSIVE && user.pulling == GM && !GM.buckled && !GM.has_buckled_mobs())
								GM.Paralyze(100)
								src.Bumped(GM)
						break
		else
			for(var/obj/structure/transit_tube_pod/pod in loc)
				if(!pod.moving && (pod.dir in tube_dirs))
					if(open_status == STATION_TUBE_CLOSED)
						open_animation()

					else if(open_status == STATION_TUBE_OPEN)
						if(pod.contents.len && user.loc != pod)
							user.visible_message(span_notice("[user] starts emptying [pod]'s contents onto the floor."), span_notice("You start emptying [pod]'s contents onto the floor..."))
							if(do_after(user, 1 SECONDS, target = src)) //So it doesn't default to close_animation() on fail
								if(pod && pod.loc == loc)
									for(var/atom/movable/AM in pod)
										AM.forceMove(get_turf(user))

						else
							close_animation()
				break


/obj/structure/transit_tube/station/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(W.tool_behaviour == TOOL_CROWBAR)
		for(var/obj/structure/transit_tube_pod/P in loc)
			P.deconstruct(FALSE, user)
	else
		return ..()

/obj/structure/transit_tube/station/proc/open_animation()
	if(open_status == STATION_TUBE_CLOSED)
		icon_state = "opening_[base_icon_state]"
		open_status = STATION_TUBE_OPENING
		addtimer(CALLBACK(src, PROC_REF(finish_animation)), OPEN_DURATION)

/obj/structure/transit_tube/station/proc/finish_animation()
	switch(open_status)
		if(STATION_TUBE_OPENING)
			icon_state = "open_[base_icon_state]"
			open_status = STATION_TUBE_OPEN
			for(var/obj/structure/transit_tube_pod/pod in loc)
				for(var/thing in pod)
					if(ismob(thing))
						var/mob/mob_content = thing
						if(mob_content.client && mob_content.stat < UNCONSCIOUS)
							continue // Let the mobs with clients decide what they want to do themselves.
					var/atom/movable/movable_content = thing
					movable_content.forceMove(loc) //Everything else is moved out of.
		if(STATION_TUBE_CLOSING)
			icon_state = "closed_[base_icon_state]"
			open_status = STATION_TUBE_CLOSED

/obj/structure/transit_tube/station/proc/close_animation()
	if(open_status == STATION_TUBE_OPEN)
		icon_state = "closing_[base_icon_state]"
		open_status = STATION_TUBE_CLOSING
		addtimer(CALLBACK(src, PROC_REF(finish_animation)), CLOSE_DURATION)

/obj/structure/transit_tube/station/proc/launch_pod()
	if(launch_cooldown >= world.time)
		return
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving)
			pod_moving = TRUE
			close_animation()
			sleep(CLOSE_DURATION + 2)
			if(open_status == STATION_TUBE_CLOSED && pod && pod.loc == loc)
				pod.follow_tube(src)
			pod_moving = FALSE
			return TRUE
	return FALSE

/obj/structure/transit_tube/station/process()
	if(!pod_moving)
		launch_pod()

/obj/structure/transit_tube/station/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	pod_moving = TRUE
	addtimer(CALLBACK(src, PROC_REF(start_stopped), pod), 0.5 SECONDS)

/obj/structure/transit_tube/station/proc/start_stopped(obj/structure/transit_tube_pod/pod)
	if(QDELETED(pod))
		return
	if(reverse_launch)
		pod.setDir(tube_dirs[1]) //turning the pod around for next launch.
	launch_cooldown = world.time + cooldown_delay
	open_animation()
	addtimer(CALLBACK(src, PROC_REF(finish_stopped), pod), OPEN_DURATION + 2)

/obj/structure/transit_tube/station/proc/finish_stopped(obj/structure/transit_tube_pod/pod)
	pod_moving = FALSE
	if(QDELETED(pod))
		return
	var/datum/gas_mixture/floor_mixture = loc.return_air()
	if(pod.air_contents.equalize(floor_mixture)) //equalize the pod's mix with the tile it's on
		air_update_turf(FALSE, FALSE)

/obj/structure/transit_tube/station/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(EAST, WEST)
		if(SOUTH)
			tube_dirs = list(EAST, WEST)
		if(EAST)
			tube_dirs = list(NORTH, SOUTH)
		if(WEST)
			tube_dirs = list(NORTH, SOUTH)
	boarding_dir = REVERSE_DIR(dir)


/obj/structure/transit_tube/station/flipped
	icon_state = "closed_station1"
	base_icon_state = "station1"
	tube_construction = /obj/structure/c_transit_tube/station/flipped

/obj/structure/transit_tube/station/flipped/init_tube_dirs()
	..()
	boarding_dir = dir


// Stations which will send the tube in the opposite direction after their stop.
/obj/structure/transit_tube/station/reverse
	tube_construction = /obj/structure/c_transit_tube/station/reverse
	reverse_launch = TRUE
	icon_state = "closed_terminus0"
	base_icon_state = "terminus0"

/obj/structure/transit_tube/station/reverse/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(EAST)
		if(SOUTH)
			tube_dirs = list(WEST)
		if(EAST)
			tube_dirs = list(SOUTH)
		if(WEST)
			tube_dirs = list(NORTH)
	boarding_dir = REVERSE_DIR(dir)

/obj/structure/transit_tube/station/reverse/flipped
	icon_state = "closed_terminus1"
	base_icon_state = "terminus1"
	tube_construction = /obj/structure/c_transit_tube/station/reverse/flipped

/obj/structure/transit_tube/station/reverse/flipped/init_tube_dirs()
	..()
	boarding_dir = dir

//special dispenser station, it creates a pod for you to enter when you bump into it.

/obj/structure/transit_tube/station/dispenser
	name = "station tube pod dispenser"
	icon_state = "open_dispenser0"
	desc = "The lynchpin of a GOOD transit system."
	enter_delay = 1
	tube_construction = /obj/structure/c_transit_tube/station/dispenser
	base_icon_state = "dispenser0"
	open_status = STATION_TUBE_OPEN
	COOLDOWN_DECLARE(freight_output)
	COOLDOWN_DECLARE(freight_message)

/obj/structure/transit_tube/station/dispenser/close_animation()
	return

/obj/structure/transit_tube/station/dispenser/launch_pod()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving)
			pod_moving = TRUE
			pod.follow_tube(src)
			pod_moving = FALSE
			return TRUE
	return FALSE

/obj/structure/transit_tube/station/dispenser/examine(mob/user)
	. = ..()
	. += span_notice("This station will create a pod for you to ride, no need to wait for one.")

/obj/structure/transit_tube/station/dispenser/Bumped(atom/movable/AM)
	if(!(istype(AM) && AM.dir == boarding_dir) || AM.anchored)
		return
	if(!isliving(AM))
		if(!COOLDOWN_FINISHED(src, freight_output))
			if(COOLDOWN_FINISHED(src, freight_message))
				AM.visible_message(span_notice("Freight pod dispenser is recharging. Please wait."))
				COOLDOWN_START(src, freight_message, 10 SECONDS)
			return
		COOLDOWN_START(src, freight_output, 2 SECONDS)

	var/obj/structure/transit_tube_pod/dispensed/pod = new(loc)
	AM.visible_message(span_notice("[pod] forms around [AM]."), span_notice("[pod] materializes around you."))
	playsound(src, 'sound/items/weapons/emitter2.ogg', 50, TRUE)
	pod.setDir(turn(src.dir, -90))
	AM.forceMove(pod)
	pod.update_appearance()
	launch_pod()

/obj/structure/transit_tube/station/dispenser/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
	qdel(pod)

/obj/structure/transit_tube/station/dispenser/flipped
	icon_state = "open_dispenser1"
	base_icon_state = "dispenser1"
	tube_construction = /obj/structure/c_transit_tube/station/dispenser/flipped

/obj/structure/transit_tube/station/dispenser/flipped/init_tube_dirs()
	..()
	boarding_dir = dir


/obj/structure/transit_tube/station/dispenser/reverse
	tube_construction = /obj/structure/c_transit_tube/station/dispenser/reverse
	reverse_launch = TRUE
	icon_state = "open_terminusdispenser0"
	base_icon_state = "terminusdispenser0"

/obj/structure/transit_tube/station/dispenser/reverse/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(EAST)
		if(SOUTH)
			tube_dirs = list(WEST)
		if(EAST)
			tube_dirs = list(SOUTH)
		if(WEST)
			tube_dirs = list(NORTH)
	boarding_dir = REVERSE_DIR(dir)

/obj/structure/transit_tube/station/dispenser/reverse/flipped
	icon_state = "open_terminusdispenser1"
	base_icon_state = "terminusdispenser1"
	tube_construction = /obj/structure/c_transit_tube/station/dispenser/reverse/flipped

/obj/structure/transit_tube/station/dispenser/reverse/flipped/init_tube_dirs()
	..()
	boarding_dir = dir

#undef OPEN_DURATION
#undef CLOSE_DURATION
