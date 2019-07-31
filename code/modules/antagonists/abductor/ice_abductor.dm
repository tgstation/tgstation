/obj/iced_abductor
	icon = 'icons/effects/freeze.dmi'
	icon_state =  "ice_ayy"
	name = "Mysterious block of Ice"
	desc = "A shadowy figure lies in this sturdy-looking block of ice. Who knows where it came from?"
	density = TRUE

/obj/iced_abductor/Destroy()
	var/turf/T = get_turf(src)
	var/obj/effect/mob_spawn/human/abductor/A = new(T)

