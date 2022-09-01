///A component that lets you turn an object invisible when you're standing on certain relative turfs to it, like behind a tree
/datum/component/seethrough
	///List of lists that represent relative coordinates to the source atom
	var/list/relative_turf_coords
	///A list of turfs on which we make ourself transparent
	var/list/watched_turfs
	///Associate list, with client = trickery_image. Track which client is being tricked with which image
	var/list/tricked_clients = list()

	///Which alpha do we animate towards?
	var/target_alpha
	///How long our fase in/out takes
	var/animation_time

///Pass a list with lists of coordinates. There's a few templates in seethrough.dm.
/datum/component/seethrough/Initialize(list/relative_turf_coords, target_alpha = 100, animation_time = 0.5 SECONDS)
	. = ..()

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.relative_turf_coords = relative_turf_coords
	src.target_alpha = target_alpha
	src.animation_time = animation_time

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/DismantlePerimeter)

	SetupPerimeter(parent)

///Loop through a list with relative coordinate lists to mark those tiles and hide our parent when someone enters those tiles
/datum/component/seethrough/proc/SetupPerimeter(atom/parent)
	watched_turfs = list()

	for(var/list/coordinates as anything in relative_turf_coords)
		var/turf/target = TURF_FROM_COORDS_LIST(list(parent.x + coordinates[1], parent.y + coordinates[2], parent.z + coordinates[3]))

		if(isnull(target))
			continue

		RegisterSignal(target, COMSIG_ATOM_ENTERED, .proc/ObscureTo)
		RegisterSignal(target, COMSIG_ATOM_EXITED, .proc/ExposeTo)

		watched_turfs.Add(target)

///Someone entered one of our tiles, so sent an override overlay and a cute animation to make us fade out a bit
/datum/component/seethrough/proc/ObscureTo(atom/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(!ismob(entered))
		return

	var/mob/mob = entered

	if(!mob.client)
		return

	if(mob.client in tricked_clients)
		return

	var/image/user_overlay = new(parent)
	user_overlay.loc = parent
	user_overlay.override = TRUE

	//These are inherited, but we already use the atom's loc so we end up at double the pixel offset
	user_overlay.pixel_x = 0
	user_overlay.pixel_y = 0

	mob.client.images += user_overlay

	animate(user_overlay, alpha = target_alpha, time = animation_time)

	tricked_clients[mob.client] = user_overlay

///Remove the screen object and make us appear solid to the client again
/datum/component/seethrough/proc/ExposeTo(atom/source, atom/movable/exited, direction)
	SIGNAL_HANDLER

	if(!ismob(exited))
		return

	var/mob/mob = exited

	if(!mob.client)
		return

	var/turf/moving_to = get_turf(exited)
	if(moving_to in watched_turfs)
		return

	//Check if we're being 'tricked'
	if(tricked_clients.Find(mob.client))
		animate(tricked_clients[mob.client], alpha = 255, time = animation_time)
		tricked_clients.Remove(mob.client)

		//after playing the fade-in animation, remove the screen obj
		addtimer(CALLBACK(src, /datum/component/seethrough.proc/ClearImage, tricked_clients[mob.client], mob.client), animation_time)

///Unrout ourselves
/datum/component/seethrough/proc/DismantlePerimeter()
	SIGNAL_HANDLER

	for(var/turf in watched_turfs)
		UnregisterSignal(turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))

	watched_turfs = null

///Remove a screen object from a client
/datum/component/seethrough/proc/ClearImage(image/removee, client/remove_from)
	remove_from.images -= removee

