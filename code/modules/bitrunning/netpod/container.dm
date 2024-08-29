/obj/machinery/netpod/Exited(atom/movable/gone, direction)
	. = ..()
	if(!state_open && gone == occupant)
		container_resist_act(gone)


/obj/machinery/netpod/relaymove(mob/living/user, direction)
	if(!state_open)
		container_resist_act(user)


/obj/machinery/netpod/container_resist_act(mob/living/user)
	if(!trapped)
		user.visible_message(span_notice("[occupant] emerges from [src]!"),
			span_notice("You climb out of [src]!"),
			span_notice("With a hiss, you hear a machine opening."))
		open_machine()
		return
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(carbon_user.handcuffed)
			balloon_alert(carbon_user, "can't pull the lever!")
			return
		balloon_alert(carbon_user, "pulling escape lever")
		carbon_user.changeNext_move(CLICK_CD_BREAKOUT)
		carbon_user.last_special = world.time + CLICK_CD_BREAKOUT
		addtimer(CALLBACK(src, PROC_REF(check_if_shake)), 1 SECONDS)
		if(do_after(carbon_user, breakout_time, target = src, hidden = FALSE))
			user.visible_message(span_notice("[occupant] emerges from [src]!"),
				span_notice("You climb out of [src]!"),
				span_notice("With a hiss, you hear a machine opening."))
			open_machine()

/obj/machinery/netpod/proc/check_if_shake()
	var/next_check_time = 1 SECONDS
	var/shake_duration =  0.3 SECONDS

	for(var/mob/living/mob in contents)
		if(DOING_INTERACTION_WITH_TARGET(mob, src))
			Shake(2, 1, shake_duration, shake_interval = 0.1 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(check_if_shake)), next_check_time)
			return TRUE
	return FALSE

/obj/machinery/netpod/open_machine(drop = TRUE, density_to_set = FALSE)
	playsound(src, 'sound/machines/tramopen.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_opening", src)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_OPENED)
	update_use_power(IDLE_POWER_USE)

	return ..()


/obj/machinery/netpod/close_machine(mob/user, density_to_set = TRUE)
	if(!state_open || panel_open || !is_operational || !iscarbon(user))
		return

	playsound(src, 'sound/machines/tramclose.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_closing", src)
	..()

	enter_matrix()


/obj/machinery/netpod/default_pry_open(obj/item/crowbar, mob/living/pryer)
	if(isnull(occupant) || !iscarbon(occupant))
		if(!state_open)
			if(panel_open)
				return FALSE
			open_machine()
		else
			shut_pod()

		return TRUE

	pryer.visible_message(
		span_danger("[pryer] starts prying open [src]!"),
		span_notice("You start to pry open [src]."),
		span_notice("You hear loud prying on metal.")
	)
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_CROWBAR_ALERT, pryer)

	if(do_after(pryer, 15 SECONDS, src))
		if(!state_open)
			sever_connection()
			open_machine()

	return TRUE


/// Closes the machine without shoving in an occupant
/obj/machinery/netpod/proc/shut_pod()
	state_open = FALSE
	playsound(src, 'sound/machines/tramclose.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_closing", src)
	set_density(TRUE)

	update_appearance()
