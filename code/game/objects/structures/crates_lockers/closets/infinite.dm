/obj/structure/closet/infinite
	name = "infinite closet"
	desc = "It's closets, all the way down."
	var/replicating_type
	var/stop_replicating_at = 4
	var/auto_close_time = 15 SECONDS // Set to 0 to disable auto-closing.

/obj/structure/closet/infinite/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/closet/infinite/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/closet/infinite/process()
	if(!replicating_type)
		if(!length(contents))
			return
		else
			replicating_type = contents[1].type

	if(replicating_type && !opened && (length(contents) < stop_replicating_at))
		new replicating_type(src)

/obj/structure/closet/infinite/after_close(mob/living/user, force)
	. = ..()
	if(auto_close_time)
		addtimer(CALLBACK(src, PROC_REF(close_on_my_own)), auto_close_time, TIMER_OVERRIDE | TIMER_UNIQUE)

/obj/structure/closet/infinite/proc/close_on_my_own()
	if(close())
		visible_message(span_notice("\The [src] closes on its own."))
