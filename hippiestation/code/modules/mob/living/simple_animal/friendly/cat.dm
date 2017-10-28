/mob/living/simple_animal/pet/cat/Runtime
	var/emagged = FALSE

/mob/living/simple_animal/pet/cat/Runtime/emag_act(mob/user)
	if(emagged)
		return
	if(stat)
		return
	emagged = TRUE
	playsound(src, 'sound/magic/lightning_chargeup.ogg', 50, 0)
	audible_message("<span class='boldwarning'>Runtime begins sparking, emitting a frightening electric crackle!</span>")
	addtimer(CALLBACK(src, .proc/catscreech), 95)

/mob/living/simple_animal/pet/cat/Runtime/proc/catscreech()
	playsound(src, 'hippiestation/sound/voice/scream_cat.ogg', 75, 1) //REE
	SpinAnimation(500,1)
	animate(src, transform = matrix()*1.5, time = 5)
	addtimer(CALLBACK(src, .proc/catsplode), 5) //comedic timing

/mob/living/simple_animal/pet/cat/Runtime/proc/catsplode()
	playsound(src, 'sound/magic/disintegrate.ogg', 50, 1)
	do_sparks(8, FALSE, loc)
	explosion(loc, 0, 2, 4, flame_range = 6)
	visible_message("<span class='arning'>Runtime has encountered a fatal error.</span>")
	gib()
