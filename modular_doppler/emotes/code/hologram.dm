GLOBAL_LIST_EMPTY(hologram_impersonators)

/obj/machinery/holopad/set_holo(mob/living/user, obj/effect/overlay/holo_pad_hologram/holo)
	if(holo.Impersonation)
		GLOB.hologram_impersonators[user] = holo
		holo.become_hearing_sensitive() // Well, we need to show up on "get_hearers_in_view()"
	. = ..()

/obj/machinery/holopad/clear_holo(mob/living/user)
	var/obj/effect/overlay/holo_pad_hologram/hologram = GLOB.hologram_impersonators[user]
	if(hologram)
		hologram.lose_hearing_sensitivity()
		GLOB.hologram_impersonators -= user
	. = ..()
