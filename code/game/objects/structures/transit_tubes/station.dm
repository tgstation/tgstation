
// A place where tube pods stop, and people can get in or out.
// Mappers: use "Generate Instances from Directions" for this
//  one.


/obj/structure/transit_tube/station
	name = "station tube station"
	icon_state = "closed_station0"
	exit_delay = 1
	enter_delay = 2
	tube_construction = /obj/structure/c_transit_tube/station
	var/open_status = STATION_TUBE_CLOSED
	var/pod_moving = 0
	var/cooldown_delay = 50
	var/launch_cooldown = 0
	var/reverse_launch = 0
	var/base_icon = "station0"
	var/boarding_dir //from which direction you can board the tube

	var/const/OPEN_DURATION = 6
	var/const/CLOSE_DURATION = 6

/obj/structure/transit_tube/station/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/structure/transit_tube/station/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return 1

/obj/structure/transit_tube/station/CollidedWith(atom/movable/AM)
	if(!pod_moving && open_status == STATION_TUBE_OPEN && ismob(AM) && AM.dir == boarding_dir)
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(!pod.moving)
				AM.forceMove(pod)
				pod.update_icon()
				return


//pod insertion
/obj/structure/transit_tube/station/MouseDrop_T(obj/structure/c_transit_tube_pod/R, mob/user)
	if(!user.canmove || user.stat || user.restrained())
		return
	if (!istype(R) || get_dist(user, src) > 1 || get_dist(src,R) > 1)
		return
	for(var/obj/structure/transit_tube_pod/pod in loc)
		return //no fun allowed
	var/obj/structure/transit_tube_pod/TP = new(loc)
	R.transfer_fingerprints_to(TP)
	TP.add_fingerprint(user)
	TP.setDir(turn(src.dir, -90))
	user.visible_message("[user] inserts [R].", "<span class='notice'>You insert [R].</span>")
	qdel(R)


/obj/structure/transit_tube/station/attack_hand(mob/user)
	if(!pod_moving)
		if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
			if(open_status == STATION_TUBE_OPEN)
				var/mob/living/GM = user.pulling
				if(user.grab_state >= GRAB_AGGRESSIVE)
					if(GM.buckled || GM.has_buckled_mobs())
						to_chat(user, "<span class='warning'>[GM] is attached to something!</span>")
						return
					for(var/obj/structure/transit_tube_pod/pod in loc)
						pod.visible_message("<span class='warning'>[user] starts putting [GM] into the [pod]!</span>")
						if(do_after(user, 15, target = src))
							if(open_status == STATION_TUBE_OPEN && GM && user.grab_state >= GRAB_AGGRESSIVE && user.pulling == GM && !GM.buckled && !GM.has_buckled_mobs())
								GM.Knockdown(100)
								src.CollidedWith(GM)
						break
		else
			for(var/obj/structure/transit_tube_pod/pod in loc)
				if(!pod.moving && (pod.dir in tube_dirs))
					if(open_status == STATION_TUBE_CLOSED)
						open_animation()

					else if(open_status == STATION_TUBE_OPEN)
						if(pod.contents.len && user.loc != pod)
							user.visible_message("[user] starts emptying [pod]'s contents onto the floor.", "<span class='notice'>You start emptying [pod]'s contents onto the floor...</span>")
							if(do_after(user, 10, target = src)) //So it doesn't default to close_animation() on fail
								if(pod && pod.loc == loc)
									for(var/atom/movable/AM in pod)
										AM.forceMove(get_turf(user))

						else
							close_animation()
				break


/obj/structure/transit_tube/station/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/crowbar))
		for(var/obj/structure/transit_tube_pod/P in loc)
			P.deconstruct(FALSE, user)
	else
		return ..()

/obj/structure/transit_tube/station/proc/open_animation()
	if(open_status == STATION_TUBE_CLOSED)
		icon_state = "opening_[base_icon]"
		open_status = STATION_TUBE_OPENING
		spawn(OPEN_DURATION)
			if(open_status == STATION_TUBE_OPENING)
				icon_state = "open_[base_icon]"
				open_status = STATION_TUBE_OPEN


/obj/structure/transit_tube/station/proc/close_animation()
	if(open_status == STATION_TUBE_OPEN)
		icon_state = "closing_[base_icon]"
		open_status = STATION_TUBE_CLOSING
		spawn(CLOSE_DURATION)
			if(open_status == STATION_TUBE_CLOSING)
				icon_state = "closed_[base_icon]"
				open_status = STATION_TUBE_CLOSED


/obj/structure/transit_tube/station/proc/launch_pod()
	if(launch_cooldown >= world.time)
		return
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving)
			pod_moving = 1
			close_animation()
			sleep(CLOSE_DURATION + 2)
			if(open_status == STATION_TUBE_CLOSED && pod && pod.loc == loc)
				pod.follow_tube()
			pod_moving = 0
			return 1
	return 0

/obj/structure/transit_tube/station/process()
	if(!pod_moving)
		launch_pod()

/obj/structure/transit_tube/station/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	pod_moving = 1
	spawn(5)
		if(reverse_launch)
			pod.setDir(tube_dirs[1]) //turning the pod around for next launch.
		launch_cooldown = world.time + cooldown_delay
		open_animation()
		sleep(OPEN_DURATION + 2)
		pod_moving = 0
		if(!QDELETED(pod))
			var/datum/gas_mixture/floor_mixture = loc.return_air()
			floor_mixture.archive()
			pod.air_contents.archive()
			pod.air_contents.share(floor_mixture, 1) //mix the pod's gas mixture with the tile it's on
			air_update_turf()

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
	boarding_dir = turn(dir, 180)


/obj/structure/transit_tube/station/flipped
	icon_state = "closed_station1"
	base_icon = "station1"
	tube_construction = /obj/structure/c_transit_tube/station/flipped

/obj/structure/transit_tube/station/flipped/init_tube_dirs()
	..()
	boarding_dir = dir


// Stations which will send the tube in the opposite direction after their stop.
/obj/structure/transit_tube/station/reverse
	tube_construction = /obj/structure/c_transit_tube/station/reverse
	reverse_launch = 1
	icon_state = "closed_terminus0"
	base_icon = "terminus0"

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
	boarding_dir = turn(dir, 180)

/obj/structure/transit_tube/station/reverse/flipped
	icon_state = "closed_terminus1"
	base_icon = "terminus1"
	tube_construction = /obj/structure/c_transit_tube/station/reverse/flipped

/obj/structure/transit_tube/station/reverse/flipped/init_tube_dirs()
	..()
	boarding_dir = dir

