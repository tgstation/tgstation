/obj/effect/countdown
	name = "countdown"
	desc = "We're leaving together\n\
		But still it's farewell\n\
		And maybe we'll come back\n\
		To earth, who can tell?"

	var/displayed_text
	var/atom/attached_to
	var/text_color = "#ff0000"
	var/text_size = 4
	var/started = FALSE
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	layer = GHOST_LAYER

/obj/effect/countdown/New(atom/A)
	. = ..()
	attach(A)

/obj/effect/countdown/proc/attach(atom/A)
	attached_to = A
	loc = get_turf(A)

/obj/effect/countdown/proc/start()
	if(!started)
		START_PROCESSING(SSfastprocess, src)
		started = TRUE

/obj/effect/countdown/proc/stop()
	if(started)
		overlays.Cut()
		STOP_PROCESSING(SSfastprocess, src)
		started = FALSE

/obj/effect/countdown/proc/get_value()
	// Get the value from our atom
	return

/obj/effect/countdown/process()
	if(!attached_to || qdeleted(attached_to))
		qdel(src)
	forceMove(get_turf(attached_to))
	var/new_val = get_value()
	if(new_val == displayed_text)
		return
	displayed_text = new_val

	if(displayed_text)
		var/image/text_image = new(loc = src)
		//text_image.maptext = "<font size=[text_size]>[new_val]</font>"
		text_image.maptext = "<font size = [text_size]>[displayed_text]</font>"
		text_image.color = text_color

		overlays.Cut()
		overlays += text_image
	else
		overlays.Cut()

/obj/effect/countdown/Destroy()
	attached_to = null
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/effect/countdown/syndicatebomb
	name = "syndicate bomb countdown"

/obj/effect/countdown/syndicatebomb/get_value()
	var/obj/machinery/syndicatebomb/S = attached_to
	if(!istype(S))
		return
	else if(S.active)
		return S.timer

/obj/effect/countdown/nuclearbomb
	name = "nuclear bomb countdown"
	text_color = "#81FF14"

/obj/effect/countdown/nuclearbomb/get_value()
	var/obj/machinery/nuclearbomb/N = attached_to
	if(!istype(N))
		return
	else if(N.timing)
		return N.timeleft

/obj/effect/countdown/clonepod
	name = "cloning pod countdown"
	text_color = "#0C479D"
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
	text_color = "#ff00ff" // Overwritten when the dominator starts

/obj/effect/countdown/dominator/get_value()
	var/obj/machinery/dominator/D = attached_to
	if(!istype(D))
		return
	else if(D.gang && D.gang.dom_timer)
		var/timer = D.gang.dom_timer
		return timer

/obj/effect/countdown/clockworkgate
	name = "gateway countdown"
	text_size = 1
	text_color = "#BE8700"
	layer = POINT_LAYER

/obj/effect/countdown/clockworkgate/get_value()
	var/obj/structure/clockwork/massive/celestial_gateway/G = attached_to
	if(!istype(G))
		return
	else if(G.health && !G.purpose_fulfilled)
		return "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'>[GATEWAY_RATVAR_ARRIVAL - G.progress_in_seconds]</div>"
