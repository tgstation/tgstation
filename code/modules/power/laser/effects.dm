
/obj/effect/overlay/temp/PTL
	icon = 'icons/effects/beam.dmi'

/obj/effect/overlay/temp/PTL/tracer
	name = "laser tracer"
	desc = "Why are you staring at this? RUN!"
	icon_state = "ptl_tracer"
	duration = 30

/obj/effect/overlay/temp/PTL/pulse
	name = "pulse laser"
	desc = "If you are seeing this you are most likely about to get vaporized..."
	icon_state = "ptl_pulse"
	duration = 30

/obj/effect/overlay/temp/PTL/continuous
	name = "transmission laser"
	desc = "If this is inside the station somehow you've got a lot more to worry about than a few burns."	//OH GOD THE STATION'S BEING CUT IN HALF
	icon_state = "ptl_continuous"
	duration = 20

/obj/effect/overlay/temp/PTL/New(time)
	if(isnum(time))
		duration = time
	..()