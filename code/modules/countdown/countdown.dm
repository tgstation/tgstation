/obj/effect/countdown
	name = "countdown"
	desc = "We're leaving together\n\
		But still it's farewell\n\
		And maybe we'll come back\n\
		To earth, who can tell?"

	var/last_displayed
	var/atom/attached_to
	var/text_color = "#ff0000"
	invisibility = INVISIBILITY_OBSERVER
	layer = GHOST_LAYER
	alpha = 100

/obj/effect/countdown/New(atom/A)
	. = ..()
	attach(A)

/obj/effect/countdown/proc/attach(atom/A)
	attached_to = A
	loc = get_turf(A)
	SSfastprocess.processing |= src

/obj/effect/countdown/proc/get_value()
	// Get the value from our atom
	return

/obj/effect/countdown/process()
	if(!attached_to || qdeleted(attached_to))
		qdel(src)
	var/new_val = get_value()
	if(new_val == last_displayed)
		return
	last_displayed = new_val
	if(new_val)
		var/image/text_image = new(loc = src)
		text_image.maptext = "<font size=4>[new_val]</font>"
		text_image.color = text_color

		overlays.Cut()
		overlays += text_image
	else
		overlays.Cut()

/obj/effect/countdown/Destroy()
	attached_to = null
	SSfastprocess.processing -= src
	. = ..()

/obj/effect/countdown/syndicatebomb/get_value()
	var/obj/machinery/syndicatebomb/S = attached_to
	if(!istype(S))
		return
	else if(S.active)
		return S.timer
