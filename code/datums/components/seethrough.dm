///A component that lets you turn an object invisible when you're standing on certain relative turfs to it, like behind a tree
/datum/component/seethrough
	///List of lists that represent relative coordinates to the source atom
	var/list/relative_turf_coords
	///A list of turfs on which we make ourself transparent
	var/list/watched_turfs
	///Associate list, with client = trickery_image. Track which client is being tricked with which image
	var/list/tricked_mobs = list()

	///Which alpha do we animate towards?
	var/target_alpha
	///How long our fase in/out takes
	var/animation_time
	///After we somehow moved (because ss13 is godless and does not respect anything), how long do we need to stand still to feel safe to setup our "behind" area again
	var/perimeter_reset_timer
	///Does this object let clicks from players its transparent to pass through it
	var/clickthrough

///see_through_map is a define pointing to a specific map. It's basically defining the area which is considered behind. See see_through_maps.dm for a list of maps
/datum/component/seethrough/Initialize(see_through_map = SEE_THROUGH_MAP_DEFAULT, target_alpha = 100, animation_time = 0.5 SECONDS, perimeter_reset_timer = 2 SECONDS, clickthrough = TRUE)
	. = ..()

	relative_turf_coords = GLOB.see_through_maps[see_through_map]

	if(!isatom(parent) || !LAZYLEN(relative_turf_coords))
		return COMPONENT_INCOMPATIBLE

	relative_turf_coords = GLOB.see_through_maps[see_through_map]
	src.relative_turf_coords = relative_turf_coords
	src.target_alpha = target_alpha
	src.animation_time = animation_time
	src.perimeter_reset_timer = perimeter_reset_timer
	src.clickthrough = clickthrough

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(dismantle_perimeter))

	setup_perimeter(parent)

///Loop through a list with relative coordinate lists to mark those tiles and hide our parent when someone enters those tiles
/datum/component/seethrough/proc/setup_perimeter(atom/parent)
	watched_turfs = list()

	for(var/list/coordinates as anything in relative_turf_coords)
		var/turf/target = TURF_FROM_COORDS_LIST(list(parent.x + coordinates[1], parent.y + coordinates[2], parent.z + coordinates[3]))

		if(isnull(target))
			continue

		RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
		RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

		watched_turfs.Add(target)

///Someone entered one of our tiles, so sent an override overlay and a cute animation to make us fade out a bit
/datum/component/seethrough/proc/on_entered(atom/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(!ismob(entered))
		return

	var/mob/mob = entered

	if(!mob.client)
		RegisterSignal(mob, COMSIG_MOB_LOGIN, PROC_REF(trick_mob))
		return

	if(mob in tricked_mobs)
		return

	trick_mob(mob)

///Remove the screen object and make us appear solid to the client again
/datum/component/seethrough/proc/on_exited(atom/source, atom/movable/exited, direction)
	SIGNAL_HANDLER

	if(!ismob(exited))
		return

	var/mob/mob = exited

	if(!mob.client)
		UnregisterSignal(mob, COMSIG_MOB_LOGIN)
		return

	var/turf/moving_to = get_turf(exited)
	if(moving_to in watched_turfs)
		return

	//Check if we're being 'tricked'
	if(mob in tricked_mobs)
		var/image/trickery_image = tricked_mobs[mob]
		animate(trickery_image, alpha = 255, time = animation_time)
		tricked_mobs.Remove(mob)
		UnregisterSignal(mob, COMSIG_MOB_LOGOUT)

		//after playing the fade-in animation, remove the screen obj
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/seethrough,clear_image), trickery_image, mob.client), animation_time)

///Apply the trickery image and animation
/datum/component/seethrough/proc/trick_mob(mob/fool)
	var/datum/hud/our_hud = fool.hud_used
	for(var/atom/movable/screen/plane_master/seethrough in our_hud.get_true_plane_masters(SEETHROUGH_PLANE))
		seethrough.unhide_plane(fool)

	var/atom/atom_parent = parent
	var/image/user_overlay = new(atom_parent)
	user_overlay.loc = atom_parent
	user_overlay.override = TRUE

	if(clickthrough)
		//Special plane so we can click through the overlay
		SET_PLANE_EXPLICIT(user_overlay, SEETHROUGH_PLANE, atom_parent)

	//These are inherited, but we already use the atom's loc so we end up at double the pixel offset
	user_overlay.pixel_x = 0
	user_overlay.pixel_y = 0

	fool.client.images += user_overlay

	animate(user_overlay, alpha = target_alpha, time = animation_time)

	tricked_mobs[fool] = user_overlay
	RegisterSignal(fool, COMSIG_MOB_LOGOUT, PROC_REF(on_client_disconnect))


///Unrout ourselves after we somehow moved, and start a timer so we can re-restablish our behind area after standing still for a bit
/datum/component/seethrough/proc/dismantle_perimeter()
	SIGNAL_HANDLER

	for(var/turf in watched_turfs)
		UnregisterSignal(turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))

	watched_turfs = null
	clear_all_images()

	//Timer override, so if our atom keeps moving the timer is reset until they stop for X time
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/seethrough,setup_perimeter), parent), perimeter_reset_timer, TIMER_OVERRIDE | TIMER_UNIQUE)

///Remove a screen image from a client
/datum/component/seethrough/proc/clear_image(image/removee, client/remove_from)
	remove_from?.images -= removee //player could've logged out during the animation, so check just in case

/datum/component/seethrough/proc/clear_all_images()
	for(var/mob/fool in tricked_mobs)
		var/image/trickery_image = tricked_mobs[fool]
		fool.client?.images -= trickery_image
		UnregisterSignal(fool, COMSIG_MOB_LOGOUT)
		var/datum/hud/our_hud = fool.hud_used

		for(var/atom/movable/screen/plane_master/seethrough in our_hud.get_true_plane_masters(SEETHROUGH_PLANE))
			seethrough.hide_plane(fool)

	tricked_mobs.Cut()

///Image is removed when they log out because client gets deleted, so drop the mob reference
/datum/component/seethrough/proc/on_client_disconnect(mob/fool)
	SIGNAL_HANDLER

	tricked_mobs.Remove(fool)
	UnregisterSignal(fool, COMSIG_MOB_LOGOUT)
	RegisterSignal(fool, COMSIG_MOB_LOGIN, PROC_REF(trick_mob))
	var/datum/hud/our_hud = fool.hud_used
	for(var/atom/movable/screen/plane_master/seethrough in our_hud.get_true_plane_masters(SEETHROUGH_PLANE))
		seethrough.hide_plane(fool)
