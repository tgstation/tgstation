/* Airlock Hallucinations
 *
 * Contains:
 * Nearby airlocks being bolted
 * Nearby airlocks being unbolted
 */

/datum/hallucination/bolts
	var/list/airlocks_to_hit
	var/list/locks
	var/next_action = 0
	var/locking = TRUE

/datum/hallucination/bolts/New(mob/living/carbon/C, forced, door_number)
	set waitfor = FALSE
	..()
	if(!door_number)
		door_number = rand(0,4) //if 0 bolts all visible doors
	var/count = 0
	feedback_details += "Door amount: [door_number]"

	for(var/obj/machinery/door/airlock/A in range(7, target))
		if(count>door_number && door_number>0)
			break
		if(!A.density)
			continue
		count++
		LAZYADD(airlocks_to_hit, A)

	if(!LAZYLEN(airlocks_to_hit)) //no valid airlocks in sight
		qdel(src)
		return

	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/bolts/process(delta_time)
	next_action -= (delta_time * 10)
	if (next_action > 0)
		return

	if (locking)
		var/atom/next_airlock = pop(airlocks_to_hit)
		if (next_airlock)
			var/obj/effect/hallucination/fake_door_lock/lock = new(get_turf(next_airlock))
			lock.target = target
			lock.airlock = next_airlock
			LAZYADD(locks, lock)

		if (!LAZYLEN(airlocks_to_hit))
			locking = FALSE
			next_action = 10 SECONDS
			return
	else
		var/obj/effect/hallucination/fake_door_lock/next_unlock = popleft(locks)
		if (next_unlock)
			next_unlock.unlock()
		else
			qdel(src)
			return

	next_action = rand(4, 12)

/datum/hallucination/bolts/Destroy()
	. = ..()
	QDEL_LIST(locks)
	STOP_PROCESSING(SSfastprocess, src)

/obj/effect/hallucination/fake_door_lock
	layer = CLOSED_DOOR_LAYER + 1 //for Bump priority
	plane = GAME_PLANE
	var/image/bolt_light
	var/obj/machinery/door/airlock/airlock

/obj/effect/hallucination/fake_door_lock/proc/lock()
	bolt_light = image(airlock.overlays_file, get_turf(airlock), "lights_bolts",layer=airlock.layer+0.1)
	if(target.client)
		target.client.images |= bolt_light
		target.playsound_local(get_turf(airlock), 'sound/machines/boltsdown.ogg',30,0,3)

/obj/effect/hallucination/fake_door_lock/proc/unlock()
	if(target.client)
		target.client.images.Remove(bolt_light)
		target.playsound_local(get_turf(airlock), 'sound/machines/boltsup.ogg',30,0,3)
	qdel(src)

/obj/effect/hallucination/fake_door_lock/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == target && airlock.density)
		return FALSE

