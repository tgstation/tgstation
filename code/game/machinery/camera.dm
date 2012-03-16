
// Double clicking turfs to move to nearest camera

/turf/proc/move_camera_by_click()
	if (usr.stat)
		return ..()
	if (world.time <= usr:lastDblClick+2)
		return ..()

	//try to find the closest working camera in the same area, switch to it
	var/area/A = get_area(src)
	var/best_dist = INFINITY //infinity
	var/best_cam = null
	for(var/obj/machinery/camera/C in A)
		if(usr:network != C.network)	continue
		if(!C.status)	continue	//	ignore disabled cameras
		var/dist = get_dist(src, C)
		if(dist < best_dist)
			best_dist = dist
			best_cam = C

	if(!best_cam)
		return ..()
	usr:lastDblClick = world.time
	usr:switchCamera(best_cam)

/mob/living/silicon/ai/proc/ai_camera_list()
	set category = "AI Commands"
	set name = "Show Camera List"

	if(usr.stat == 2)
		usr << "You can't track with camera because you are dead!"
		return

	attack_ai(src)

/mob/living/silicon/ai/proc/ai_camera_track()
	set category = "AI Commands"
	set name = "Track With Camera"
	if(usr.stat == 2)
		usr << "You can't track with camera because you are dead!"
		return

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()
	for (var/mob/M in world)
		if (istype(M, /mob/new_player))
			continue //cameras can't follow people who haven't started yet DUH OR DIDN'T YOU KNOW THAT
		//Cameras can't track people wearing an agent card or a ninja hood.
		if (istype(M, /mob/living/carbon/human))
			if(istype(M:wear_id, /obj/item/weapon/card/id/syndicate))
				continue
		 	if(istype(M:head, /obj/item/clothing/head/helmet/space/space_ninja)&&!M:head:canremove)
		 		continue
		if(!istype(M.loc, /turf)) //in a closet or something, AI can't see him anyways
			continue
		var/area/wizard_station/A = locate()//So that wizards are not tracked by the AI until they leave their sanctuary. Unless they talk on radio/N
		if(M in A.contents)
			continue
		if(M.invisibility)//cloaked
			continue
		if(istype(M.loc,/obj/effect/dummy))
			continue
		else if (M == usr)
			continue
		if(M.digitalcamo)
			continue

		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = text("[] ([])", name, namecounts[name])
		else
			names.Add(name)
			namecounts[name] = 1

		creatures[name] = M

	var/target_name = input(usr, "Which creature should you track?") as null|anything in creatures

	if (!target_name)
		usr:cameraFollow = null
		return

	var/mob/target = creatures[target_name]

	ai_actual_track(target)

/mob/living/silicon/ai/proc/ai_actual_track(mob/target as mob)

	usr:cameraFollow = target
	usr << text("Now tracking [] on camera.", target.name)
	if (usr.machine == null)
		usr.machine = usr

	spawn (0)
		while (usr:cameraFollow == target)
			if (usr:cameraFollow == null)
				return
			else if (istype(target, /mob/living/carbon/human))
				if(istype(target:wear_id, /obj/item/weapon/card/id/syndicate))
					usr << "Follow camera mode terminated."
					usr:cameraFollow = null
					return
		 		if(istype(target:head, /obj/item/clothing/head/helmet/space/space_ninja)&&!target:head:canremove)
		 			usr << "Follow camera mode terminated."
					usr:cameraFollow = null
					return
				if(target.digitalcamo)
					usr << "Follow camera mode terminated."
					usr:cameraFollow = null
					return

			else if(istype(target.loc,/obj/effect/dummy))
				usr << "Follow camera mode ended."
				usr:cameraFollow = null
				return
			else if (!target || !istype(target.loc, /turf)) //in a closet
				usr << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
				sleep(40) //because we're sleeping another second after this (a few lines down)
				continue

			var/obj/machinery/camera/C = usr:current
			if ((C && istype(C, /obj/machinery/camera)) || C==null)

				var/closestDist = -1
				if (C!=null)
					if (C.status)
						closestDist = get_dist(C, target)
				//usr << text("Dist = [] for camera []", closestDist, C.name)
				var/zmatched = 0
				if (closestDist > 7 || closestDist == -1)
					//check other cameras
					var/obj/machinery/camera/closest = C
					for(var/obj/machinery/camera/C2 in world)
						if (C2.network == src.network)
							if (C2.z == target.z)
								zmatched = 1
								if (C2.status)
									var/dist = get_dist(C2, target)
									if ((dist < closestDist) || (closestDist == -1))
										closestDist = dist
										closest = C2
					//usr << text("Closest camera dist = [], for camera []", closestDist, closest.area.name)

					if (closest != C)
						usr:current = closest
						usr.reset_view(closest)
						//use_power(50)
					if (zmatched == 0)
						usr << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
						sleep(40) //because we're sleeping another second after this (a few lines down)
			else
				usr << "Follow camera mode ended."
				usr:cameraFollow = null

			sleep(10)

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for (var/i = L.len, i > 0, i--)
		for (var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if (a.c_tag_order != b.c_tag_order)
				if (a.c_tag_order > b.c_tag_order)
					L.Swap(j, j + 1)
			else
				if (sorttext(a.c_tag, b.c_tag) < 0)
					L.Swap(j, j + 1)
	return L


/mob/living/silicon/ai/attack_ai(var/mob/user as mob)
	if (user != src)
		return

	if (stat == 2)
		return

	user.machine = src

	var/list/L = list()
	for (var/obj/machinery/camera/C in world)
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in L)
		if (C.network == src.network)
			D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D

	if (!t || t == "Cancel")
		switchCamera(null)
		return 0

	var/obj/machinery/camera/C = D[t]

	switchCamera(C)

	return

/obj/machinery/camera/emp_act(severity)
	if(prob(100/(hardened + severity)))
		icon_state = "cameraemp"
		network = null                   //Not the best way but it will do. I think.
		spawn(900)
			network = initial(network)
			icon_state = initial(icon_state)
		for(var/mob/living/silicon/ai/O in world)
			if (O.current == src)
				O.cancel_camera()
				O << "Your connection to the camera has been lost."
		for(var/mob/O in world)
			if (istype(O.machine, /obj/machinery/computer/security))
				var/obj/machinery/computer/security/S = O.machine
				if (S.current == src)
					O.machine = null
					S.current = null
					O.reset_view(null)
					O << "The screen bursts into static."
		..()

/obj/machinery/camera/emp_proof/emp_act(severity)
	return

/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/blob_act()
	return

/obj/machinery/camera/attack_ai(var/mob/living/silicon/ai/user as mob)
	if (!istype(user))
		return
	if (src.network != user.network || !(src.status))
		return
	user.current = src
	user.reset_view(src)

/obj/machinery/camera/attackby(W as obj, user as mob)
	..()
	if (istype(W, /obj/item/weapon/wirecutters))
		deactivate(user)
	else if (istype(W, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/X = W
		user << "You hold a paper up to the camera ..."
		for(var/mob/living/silicon/ai/O in world)
			//if (O.current == src)
			O << "[user] holds a paper up to one of your cameras ..."
			O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", X.name, X.info), text("window=[]", X.name))
		for(var/mob/O in world)
			if (istype(O.machine, /obj/machinery/computer/security))
				var/obj/machinery/computer/security/S = O.machine
				if (S.current == src)
					O << "[user] holds a paper up to one of the cameras ..."
					O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", X.name, X.info), text("window=[]", X.name))
	else if (istype(W, /obj/item/weapon/wrench)) //Adding dismantlable cameras to go with the constructable ones. --NEO
		if(src.status)
			user << "\red You can't dismantle a camera while it is active."
		else
			user << "\blue Dismantling camera..."
			if(do_after(user, 20))
				var/obj/item/weapon/chem_grenade/case = new /obj/item/weapon/chem_grenade(src.loc)
				case.name = "Camera Assembly"
				case.icon = 'monitors.dmi'
//JESUS WHAT THE FUCK EVERYTHING TO DO WITH CAMERAS IS TERRIBLE FUCK
				case.icon_state = "cameracase"
				case.path = 2
				case.state = 5
				case.circuit = new /obj/item/device/multitool
				if (istype(src, /obj/machinery/camera/motion))
					case.motion = 1
				del(src)
	else if (istype(W, /obj/item/weapon/camera_bug))
		if (!src.status)
			user << "\blue Camera non-functional"
			return
		if (src.bugged)
			user << "\blue Camera bug removed."
			src.bugged = 0
		else
			user << "\blue Camera bugged."
			src.bugged = 1
	else if(istype(W, /obj/item/weapon/melee/energy/blade))//Putting it here last since it's a special case. I wonder if there is a better way to do these than type casting.
		deactivate(user,2)//Here so that you can disconnect anyone viewing the camera, regardless if it's on or off.
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, loc)
		spark_system.start()
		playsound(loc, 'blade1.ogg', 50, 1)
		playsound(loc, "sparks", 50, 1)

		var/obj/item/weapon/chem_grenade/case = new /obj/item/weapon/chem_grenade(loc)
		case.name = "Camera Assembly"
		case.icon = 'monitors.dmi'
		case.icon_state = "cameracase"
		case.path = 2
		case.state = 5
		case.circuit = new /obj/item/device/multitool
		if (istype(src, /obj/machinery/camera/motion))
			case.motion = 1

		for(var/mob/O in viewers(user, 3))
			O.show_message(text("\blue The camera has been sliced apart by [] with an energy blade!", user), 1, text("\red You hear metal being sliced and sparks flying."), 2)
		del(src)
	return

/obj/machinery/camera/proc/deactivate(user as mob, var/choice = 1)
	if(choice==1)
		status = !( src.status )
		if (!(src.status))
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] has deactivated []!", user, src), 1)
				playsound(src.loc, 'Wirecutter.ogg', 100, 1)
			icon_state = "camera1"
			add_hiddenprint(user)
		else
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] has reactivated []!", user, src), 1)
				playsound(src.loc, 'Wirecutter.ogg', 100, 1)
			icon_state = "camera"
			add_hiddenprint(user)
	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/living/silicon/ai/O in world)
		if (O.current == src)
			O.cancel_camera()
			O << "Your connection to the camera has been lost."
	for(var/mob/O in world)
		if (istype(O.machine, /obj/machinery/computer/security))
			var/obj/machinery/computer/security/S = O.machine
			if (S.current == src)
				O.machine = null
				S.current = null
				O.reset_view(null)
				O << "The screen bursts into static."

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)

	for(var/obj/machinery/camera/C in oview(M))
		if(C.status)	// check if camera disabled
			return C
			break

	return null
