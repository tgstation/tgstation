/obj/item/hourglass
	name = "hourglass"
	desc = "Nanotrasen patented gravity invariant hourglass. Guaranteed to flow perfectly under any conditions."
	var/obj/effect/countdown/hourglass/countdown
	var/time = 1 MINUTES
	var/finish_time //So countdown doesn't need to fiddle with timers
	var/timing_id	//if present we're timing
	var/hand_activated = TRUE
	icon = 'icons/obj/hourglass.dmi'
	icon_state = "hourglass_idle"

/obj/item/hourglass/Initialize(mapload)
	. = ..()
	countdown = new(src)

/obj/item/hourglass/attack_self(mob/user)
	. = ..()
	if(hand_activated)
		toggle(user)

/obj/item/hourglass/proc/toggle(mob/user)
	if(!timing_id)
		to_chat(user,"You flip the [src]")
		start()
		//fancy flip
		var/old_transform = transform
		animate(src,time = 1, transform = turn(old_transform, 90))
		animate(time = 1, transform = turn(old_transform, 180))
		animate(time = 0,transform = old_transform)
	else
		to_chat(user,"You stop the [src].") //Sand magically flows back because that's more convinient to use.
		stop()

/obj/item/hourglass/update_icon()
	if(timing_id)
		icon_state = "hourglass_active"
	else
		icon_state = "hourglass_idle"

/obj/item/hourglass/proc/start()
	finish_time = world.time + time
	timing_id = addtimer(CALLBACK(src, .proc/finish), time, TIMER_STOPPABLE)
	countdown.start()
	update_icon()

/obj/item/hourglass/proc/stop()
	if(timing_id)
		deltimer(timing_id)
		timing_id = null
	countdown.stop()
	finish_time = null
	update_icon()

/obj/item/hourglass/proc/finish()
	visible_message("[src] stops.")
	stop()

/obj/item/hourglass/Destroy()
	QDEL_NULL(countdown)
	. = ..()

//Admin events zone.
/obj/item/hourglass/admin
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	hand_activated = FALSE

/obj/item/hourglass/admin/attack_hand(mob/user)
	. = ..()
	if(user.client && user.client.holder)
		toggle(user)

/obj/item/hourglass/admin/attack_ghost(mob/user)
	if(user.client && user.client.holder)
		toggle(user)