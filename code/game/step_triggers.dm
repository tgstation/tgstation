/* Simple object type, calls a proc when "stepped" on by something */

/obj/step_trigger
	var/affect_ghosts = 0
	var/stopper = 1 // stops throwers
	invisibility = 101 // nope cant see this shit
	anchored = 1

/obj/step_trigger/proc/Trigger(var/atom/movable/A)
	return 0

/obj/step_trigger/HasEntered(H as mob|obj)
	..()
	if(!H)
		return
	if(istype(H, /mob/dead/observer) && !affect_ghosts)
		return
	Trigger(H)



/* Tosses things in a certain direction */

/obj/step_trigger/thrower
	var/direction = SOUTH // the direction of throw
	var/tiles = 3	// if 0: forever until atom hits a stopper
	var/immobilize = 1 // if nonzero: prevents mobs from moving while they're being flung
	var/speed = 1	// delay of movement
	var/facedir = 0 // if 1: atom faces the direction of movement
	var/nostop = 0 // if 1: will only be stopped by teleporters
	var/list/affecting = list()

	Trigger(var/atom/movable/A)
		var/curtiles = 0
		var/stopthrow = 0
		for(var/obj/step_trigger/thrower/T in orange(2, src))
			if(A in T.affecting)
				return

		if(ismob(A))
			var/mob/M = A
			if(immobilize)
				M.canmove = 0

		affecting.Add(A)
		while(A && !stopthrow)
			if(tiles)
				if(curtiles >= tiles)
					break
			if(A.z != src.z)
				break

			curtiles++

			sleep(speed)

			// Calculate if we should stop the process
			if(!nostop)
				for(var/obj/step_trigger/T in get_step(A, direction))
					if(T.stopper && T != src)
						stopthrow = 1
			else
				for(var/obj/step_trigger/teleporter/T in get_step(A, direction))
					if(T.stopper)
						stopthrow = 1

			if(A)
				var/predir = A.dir
				step(A, direction)
				if(!facedir)
					A.dir = predir



		affecting.Remove(A)

		if(ismob(A))
			var/mob/M = A
			if(immobilize)
				M.canmove = 1

/* Stops things thrown by a thrower, doesn't do anything */

/obj/step_trigger/stopper

/* Instant teleporter */

/obj/step_trigger/teleporter
	var/teleport_x = 0	// teleportation coordinates (if one is null, then no teleport!)
	var/teleport_y = 0
	var/teleport_z = 0

	Trigger(var/atom/movable/A)
		if(teleport_x && teleport_y && teleport_z)

			A.x = teleport_x
			A.y = teleport_y
			A.z = teleport_z

/* Random teleporter, teleports atoms to locations ranging from teleport_x - teleport_x_offset, etc */

/obj/step_trigger/teleporter/random
	var/teleport_x_offset = 0
	var/teleport_y_offset = 0
	var/teleport_z_offset = 0

	Trigger(var/atom/movable/A)
		if(teleport_x && teleport_y && teleport_z)
			if(teleport_x_offset && teleport_y_offset && teleport_z_offset)

				A.x = rand(teleport_x, teleport_x_offset)
				A.y = rand(teleport_y, teleport_y_offset)
				A.z = rand(teleport_z, teleport_z_offset)

