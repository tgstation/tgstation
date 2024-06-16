/proc/create_portal_pair(turf/source, turf/destination, _lifespan = 300, accuracy = 0, newtype = /obj/effect/portal)
	if(!istype(source) || !istype(destination))
		return
	var/turf/actual_destination = get_teleport_turf(destination, accuracy)
	var/obj/effect/portal/P1 = new newtype(source, _lifespan, null, FALSE, null)
	var/obj/effect/portal/P2 = new newtype(actual_destination, _lifespan, P1, TRUE, null)
	if(!istype(P1) || !istype(P2))
		return
	playsound(P1, SFX_PORTAL_CREATED, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(P2, SFX_PORTAL_CREATED, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	P1.link_portal(P2)
	P1.hardlinked = TRUE
	return list(P1, P2)

/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "portal"
	anchored = TRUE
	density = TRUE // dense for receiving bumbs
	layer = HIGH_OBJ_LAYER
	light_system = COMPLEX_LIGHT
	light_range = 3
	light_power = 1
	light_on = TRUE
	light_color = COLOR_BLUE_LIGHT
	/// Are mechs able to enter this portal?
	var/mech_sized = FALSE
	/// A reference to another "linked" destination portal
	var/obj/effect/portal/linked
	/// Requires a linked portal at all times. Destroy if there's no linked portal, if there is destroy it when this one is deleted.
	var/hardlinked = TRUE
	/// What teleport channel does this portal use?
	var/teleport_channel = TELEPORT_CHANNEL_BLUESPACE
	/// For when a portal needs a hard target and isn't to be linked.
	var/turf/hard_target
	/// Do we teleport anchored objects?
	var/allow_anchored = FALSE
	/// What precision value do we pass to do_teleport (how far from the target destination we will pop out at).
	var/innate_accuracy_penalty = 0
	/// Used to track how often sparks should be output. Might want to turn this into a cooldown.
	var/last_effect = 0
	/// Does this portal bypass teleport restrictions? like TRAIT_NO_TELEPORT and NOTELEPORT flags.
	var/force_teleport = FALSE
	/// Does this portal create spark effect when teleporting?
	var/sparkless = TRUE
	/// If FALSE, the wibble filter will not be applied to this portal (only a visual effect).
	var/wibbles = TRUE

/obj/effect/portal/anom
	name = "wormhole"
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "anom"
	layer = RIPPLE_LAYER
	plane = ABOVE_GAME_PLANE
	mech_sized = TRUE
	teleport_channel = TELEPORT_CHANNEL_WORMHOLE
	light_on = FALSE
	wibbles = FALSE

/obj/effect/portal/Move(newloc)
	for(var/T in newloc)
		if(istype(T, /obj/effect/portal))
			return FALSE
	return ..()

// Prevents portals spawned by jaunter/handtele from floating into space when relocated to an adjacent tile.
/obj/effect/portal/newtonian_move(direction, instant = FALSE, start_delay = 0)
	return TRUE

/obj/effect/portal/attackby(obj/item/W, mob/user, params)
	if(user && Adjacent(user))
		teleport(user)
		return TRUE

/obj/effect/portal/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(HAS_TRAIT(mover, TRAIT_NO_TELEPORT) && !force_teleport)
		return TRUE

/obj/effect/portal/Bumped(atom/movable/bumper)
	teleport(bumper)

/obj/effect/portal/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(Adjacent(user))
		teleport(user)


/obj/effect/portal/attack_robot(mob/living/user)
	if(Adjacent(user))
		teleport(user)

/obj/effect/portal/Initialize(mapload, _lifespan = 0, obj/effect/portal/_linked, automatic_link = FALSE, turf/hard_target_override)
	. = ..()
	GLOB.portals += src
	if(!istype(_linked) && automatic_link)
		. = INITIALIZE_HINT_QDEL
		CRASH("Somebody fucked up.")
	if(_lifespan > 0)
		addtimer(src, PROC_REF(expire), _lifespan, TIMER_DELETE_ME)
	link_portal(_linked)
	hardlinked = automatic_link
	if(isturf(hard_target_override))
		hard_target = hard_target_override
	if(wibbles)
		apply_wibbly_filters(src)

/obj/effect/portal/proc/expire()
	playsound(loc, SFX_PORTAL_CLOSE, 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
	qdel(src)

/obj/effect/portal/singularity_pull()
	return

/obj/effect/portal/singularity_act()
	return

/obj/effect/portal/proc/link_portal(obj/effect/portal/newlink)
	linked = newlink

/obj/effect/portal/Destroy()
	GLOB.portals -= src
	if(hardlinked && !QDELETED(linked))
		QDEL_NULL(linked)
	else
		linked = null
	return ..()

/obj/effect/portal/attack_ghost(mob/dead/observer/O)
	if(!teleport(O, TRUE))
		return ..()

/obj/effect/portal/proc/teleport(atom/movable/M, force = FALSE)
	if(!force && (!istype(M) || iseffect(M) || (ismecha(M) && !mech_sized) || (!isobj(M) && !ismob(M)))) //Things that shouldn't teleport.
		return
	var/turf/real_target = get_link_target_turf()
	if(!istype(real_target))
		return FALSE
	if(!force && (!ismecha(M) && !isprojectile(M) && M.anchored && !allow_anchored))
		return
	var/no_effect = FALSE
	if(last_effect == world.time || sparkless)
		no_effect = TRUE
	else
		last_effect = world.time
	var/turf/start_turf = get_turf(M)
	if(do_teleport(M, real_target, innate_accuracy_penalty, no_effects = no_effect, channel = teleport_channel, forced = force_teleport))
		if(isprojectile(M))
			var/obj/projectile/P = M
			P.ignore_source_check = TRUE
		new /obj/effect/temp_visual/portal_animation(start_turf, src, M)
		playsound(start_turf, SFX_PORTAL_ENTER, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		playsound(real_target, SFX_PORTAL_ENTER, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return TRUE
	return FALSE

/obj/effect/portal/proc/get_link_target_turf()
	var/turf/real_target
	if(!istype(linked) || QDELETED(linked))
		if(hardlinked)
			qdel(src)
		if(!istype(hard_target) || QDELETED(hard_target))
			hard_target = null
			return
		else
			real_target = hard_target
			linked = null
	else
		real_target = get_turf(linked)
	return real_target

/obj/effect/portal/permanent
	name = "permanent portal"
	desc = "An unwavering portal that will never fade."
	hardlinked = FALSE // dont qdel my portal nerd
	force_teleport = TRUE // force teleports because they're a mapmaker tool
	var/id // var edit or set id in map editor

/obj/effect/portal/permanent/proc/set_linked()
	if(!id)
		return
	for(var/obj/effect/portal/permanent/P in GLOB.portals - src)
		if(P.id == id)
			P.linked = src
			linked = P
			break

/obj/effect/portal/permanent/teleport(atom/movable/M, force = FALSE)
	set_linked() // update portal links
	. = ..()

/obj/effect/portal/permanent/one_way // doesn't have a return portal, can have multiple exits, /obj/effect/landmark/portal_exit to mark them
	name = "one-way portal"
	desc = "You get the feeling that this might not be the safest thing you've ever done."

/obj/effect/portal/permanent/one_way/set_linked()
	if(!id)
		return
	var/list/possible_turfs = list()
	for(var/obj/effect/landmark/portal_exit/PE in GLOB.landmarks_list)
		if(PE.id == id)
			var/turf/T = get_turf(PE)
			if(T)
				possible_turfs |= T
	if(possible_turfs.len)
		hard_target = pick(possible_turfs)

/obj/effect/portal/permanent/one_way/one_use
	name = "one-use portal"
	desc = "This is probably the worst decision you'll ever make in your life."

/obj/effect/portal/permanent/one_way/one_use/teleport(atom/movable/M, force = FALSE)
	. = ..()
	if (. && !isdead(M))
		expire()

/**
 * Animation used for transitioning atoms which are teleporting somewhere via a portal
 *
 * To use, pass it the atom doing the teleporting and the atom that is being teleported in init.
 */
/obj/effect/temp_visual/portal_animation
	duration = 0.25 SECONDS

/obj/effect/temp_visual/portal_animation/Initialize(mapload, atom/portal, atom/movable/teleporting)
	. = ..()
	if(isnull(portal) || isnull(teleporting))
		return

	appearance = teleporting.appearance
	dir = teleporting.dir
	layer = portal.layer + 0.01
	alpha = teleporting.alpha
	animate(src, pixel_x = (portal.x * 32) - (x * 32), pixel_y = (portal.y * 32) - (y * 32), alpha = 0, time = duration)
