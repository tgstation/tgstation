/obj/structure/closet
	var/list/togglelock_sound = list(
		'modular_bandastation/aesthetics_sounds/sound/lock_1.ogg',
		'modular_bandastation/aesthetics_sounds/sound/lock_2.ogg',
		'modular_bandastation/aesthetics_sounds/sound/lock_3.ogg'
	)

/obj/structure/closet/secure_closet/togglelock(mob/living/user, silent)
	var/temp_locked = locked
	. = ..()
	if(temp_locked != locked)
		playsound(loc, pick(togglelock_sound), 10, TRUE, -3)

/obj/structure/closet/crate/secure/togglelock(mob/living/user, silent)
	var/temp_locked = locked
	. = ..()
	if(temp_locked != locked)
		playsound(loc, pick(togglelock_sound), 10, TRUE, -3)
