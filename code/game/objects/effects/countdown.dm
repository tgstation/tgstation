/obj/effect/countdown
	name = "countdown"
	desc = "We're leaving together\n\
		But still it's farewell\n\
		And maybe we'll come back\n\
		To earth, who can tell?"

	var/displayed_text
	var/atom/attached_to
	color = "#ff0000"
	var/text_size = 4
	var/started = FALSE
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	layer = GHOST_LAYER

/obj/effect/countdown/New(atom/A)
	. = ..()
	attach(A)

/obj/effect/countdown/examine(mob/user)
	. = ..()
	to_chat(user, "This countdown is displaying: [displayed_text]")

/obj/effect/countdown/proc/attach(atom/A)
	attached_to = A
	loc = get_turf(A)

/obj/effect/countdown/proc/start()
	if(!started)
		START_PROCESSING(SSfastprocess, src)
		started = TRUE

/obj/effect/countdown/proc/stop()
	if(started)
		maptext = null
		STOP_PROCESSING(SSfastprocess, src)
		started = FALSE

/obj/effect/countdown/proc/get_value()
	// Get the value from our atom
	return

/obj/effect/countdown/process()
	if(!attached_to || QDELETED(attached_to))
		qdel(src)
	forceMove(get_turf(attached_to))
	var/new_val = get_value()
	if(new_val == displayed_text)
		return
	displayed_text = new_val

	if(displayed_text)
		maptext = "<font size = [text_size]>[displayed_text]</font>"
	else
		maptext = null

/obj/effect/countdown/Destroy()
	attached_to = null
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/effect/countdown/ex_act(severity, target) //immune to explosions
	return

/obj/effect/countdown/syndicatebomb
	name = "syndicate bomb countdown"

/obj/effect/countdown/syndicatebomb/get_value()
	var/obj/machinery/syndicatebomb/S = attached_to
	if(!istype(S))
		return
	else if(S.active)
		return S.seconds_remaining()

/obj/effect/countdown/nuclearbomb
	name = "nuclear bomb countdown"
	color = "#81FF14"

/obj/effect/countdown/nuclearbomb/get_value()
	var/obj/machinery/nuclearbomb/N = attached_to
	if(!istype(N))
		return
	else if(N.timing)
		return round(N.get_time_left(), 1)

/obj/effect/countdown/clonepod
	name = "cloning pod countdown"
	color = "#0C479D"
	text_size = 1

/obj/effect/countdown/clonepod/get_value()
	var/obj/machinery/clonepod/C = attached_to
	if(!istype(C))
		return
	else if(C.occupant)
		var/completion = round(C.get_completion())
		return completion

/obj/effect/countdown/dominator
	name = "dominator countdown"
	text_size = 1
	color = "#ff00ff" // Overwritten when the dominator starts

/obj/effect/countdown/dominator/get_value()
	var/obj/machinery/dominator/D = attached_to
	if(!istype(D))
		return
	else if(D.gang && D.gang.is_dominating)
		var/timer = D.gang.domination_time_remaining()
		return timer
	else
		return "OFFLINE"

/obj/effect/countdown/clockworkgate
	name = "gateway countdown"
	text_size = 1
	color = "#BE8700"
	layer = POINT_LAYER

/obj/effect/countdown/clockworkgate/get_value()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = attached_to
	if(!istype(G))
		return
	else if(G.obj_integrity && !G.purpose_fulfilled)
		return "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'>[G.get_arrival_text(FALSE)]</div>"

/obj/effect/countdown/supermatter
	name = "supermatter damage"
	text_size = 1
	color = "#ED84F4"

/obj/effect/countdown/supermatter/get_value()
	var/obj/machinery/power/supermatter_shard/S = attached_to
	if(!istype(S))
		return
	return "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'>[round((S.damage / S.explosion_point) * 100)]</div>"

/obj/effect/countdown/transformer
	name = "transformer countdown"
	color = "#4C5866"

/obj/effect/countdown/transformer/get_value()
	var/obj/machinery/transformer/T = attached_to
	if(!istype(T))
		return
	else if(T.cooldown)
		var/seconds_left = max(0, (T.cooldown_timer - world.time) / 10)
		return "[round(seconds_left)]"

/obj/effect/countdown/doomsday
	name = "doomsday countdown"
	text_size = 3

/obj/effect/countdown/doomsday/get_value()
	var/obj/machinery/doomsday_device/DD = attached_to
	if(!istype(DD))
		return
	else if(DD.timing)
		return "<div align='center' valign='middle' style='position:relative; top:0px; left:0px'>[DD.seconds_remaining()]</div>"

/obj/effect/countdown/anomaly
	name = "anomaly countdown"

/obj/effect/countdown/anomaly/get_value()
	var/obj/effect/anomaly/A = attached_to
	if(!istype(A))
		return
	else
		var/time_left = max(0, (A.death_time - world.time) / 10)
		return round(time_left)
