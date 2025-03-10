/datum/hallucination/bolts
	random_hallucination_weight = 7
	hallucination_tier = HALLUCINATION_TIER_COMMON
	/// A list of weakrefs to airlocks we bolt down around us
	var/list/datum/weakref/airlocks_to_hit
	/// A list of weakrefs to fake lock hallucinations we've created
	var/list/datum/weakref/locks
	/// A number relating to the number of ssfastprocessing ticks (x 10) until the next action
	var/next_action = 0
	/// Whether we're currently locking, or unlocking
	var/locking = TRUE

/datum/hallucination/bolts/start()
	var/door_number = rand(0, 4) //if 0, we bolt all visible doors
	feedback_details += "Door amount: [door_number]"

	for(var/obj/machinery/door/airlock/nearby_airlock in view(hallucinator))
		if(LAZYLEN(airlocks_to_hit) > door_number && door_number > 0)
			break
		if(!nearby_airlock.density)
			continue
		LAZYADD(airlocks_to_hit, WEAKREF(nearby_airlock))

	if(!LAZYLEN(airlocks_to_hit)) // Not an airlock in sight
		return FALSE

	START_PROCESSING(SSfastprocess, src)
	return TRUE

/datum/hallucination/bolts/process(seconds_per_tick)
	if(QDELETED(src))
		return

	next_action -= (seconds_per_tick * 10)
	if(next_action > 0)
		return

	if(locking)
		var/datum/weakref/next_airlock = pop(airlocks_to_hit)
		var/obj/machinery/door/airlock/to_lock = next_airlock?.resolve()
		if(to_lock)
			var/obj/effect/client_image_holder/hallucination/fake_door_lock/lock = new(to_lock.loc, hallucinator, src, to_lock)
			LAZYADD(locks, WEAKREF(lock))

		if(!LAZYLEN(airlocks_to_hit))
			locking = FALSE
			next_action = 100
			return

	else
		var/datum/weakref/next_unlock = popleft(locks)
		var/obj/effect/client_image_holder/hallucination/fake_door_lock/to_unlock = next_unlock?.resolve()
		if(to_unlock)
			to_unlock.unlock()

		else
			// All unlocked, qdel time
			qdel(src)
			return

	next_action = rand(4, 12)

/datum/hallucination/bolts/Destroy()
	// Clean up any locks we happen to have remaining on qdel.
	// Hypothetically this shouldn't delete anything. But just in case.
	for(var/datum/weakref/leftover_lock_ref as anything in locks)
		var/obj/effect/client_image_holder/hallucination/fake_door_lock/leftover_lock = leftover_lock_ref.resolve()
		if(!QDELETED(leftover_lock))
			qdel(leftover_lock)

	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/client_image_holder/hallucination/fake_door_lock
	layer = CLOSED_DOOR_LAYER + 1 //for Bump priority
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	/// The real airlock we're fake bolting down.
	var/obj/machinery/door/airlock/airlock

/obj/effect/client_image_holder/hallucination/fake_door_lock/Initialize(mapload, list/mobs_which_see_us, datum/hallucination/parent, obj/machinery/door/airlock/airlock)
	if(!airlock)
		stack_trace("[type] was created somewhere without an associated airlock.")
		return INITIALIZE_HINT_QDEL

	src.airlock = airlock
	RegisterSignal(airlock, COMSIG_QDELETING, PROC_REF(on_airlock_deleted))
	// We need to grab these for our image before we run our parent's parent initialize
	src.image_icon = airlock.overlays_file
	src.image_state = "lights_[AIRLOCK_LIGHT_BOLTS]"

	return ..()

/obj/effect/client_image_holder/hallucination/fake_door_lock/Destroy(force)
	UnregisterSignal(airlock, COMSIG_QDELETING)
	airlock = null
	return ..()

/obj/effect/client_image_holder/hallucination/fake_door_lock/generate_image()
	var/image/created = ..()
	created.layer = airlock.layer + 0.1
	return created

/obj/effect/client_image_holder/hallucination/fake_door_lock/show_image_to(mob/show_to)
	. = ..()
	show_to.playsound_local(get_turf(src), 'sound/machines/airlock/boltsdown.ogg', 30, FALSE, 3)

/obj/effect/client_image_holder/hallucination/fake_door_lock/hide_image_from(mob/show_to)
	. = ..()
	show_to.playsound_local(get_turf(src), 'sound/machines/airlock/boltsup.ogg', 30, FALSE, 3)

/obj/effect/client_image_holder/hallucination/fake_door_lock/proc/on_airlock_deleted(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/obj/effect/client_image_holder/hallucination/fake_door_lock/proc/unlock()
	for(var/mob/seer as anything in who_sees_us)
		hide_image_from(seer)

	shown_image = null
	qdel(src)

/obj/effect/client_image_holder/hallucination/fake_door_lock/CanAllowThrough(atom/movable/mover, border_dir)
	if((mover in who_sees_us) && airlock.density)
		return FALSE

	return ..()
