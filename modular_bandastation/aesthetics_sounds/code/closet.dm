/obj/structure/closet
	var/list/togglelock_sounds = list(
		'modular_bandastation/aesthetics_sounds/sound/lock_1.ogg',
		'modular_bandastation/aesthetics_sounds/sound/lock_2.ogg',
		'modular_bandastation/aesthetics_sounds/sound/lock_3.ogg'
	)

/obj/structure/closet/play_closet_lock_sound()
	playsound(loc, pick(togglelock_sounds), 10, TRUE, -3)
