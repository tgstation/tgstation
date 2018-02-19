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

/mob/living/simple_animal/pet/cat/clown
	name = "Honkers"
	desc = "A goofy little clown cat."
	var/emagged = FALSE
	icon = 'hippiestation/icons/mob/pets.dmi'
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	var/static/meows = list("hippiestation/sound/creatures/clownCatHonk.ogg", "hippiestation/sound/creatures/clownCatHonk2.ogg","hippiestation/sound/creatures/clownCatHonk3.ogg")
	speak = list("Meow!", "Honk!", "Haaaa....", "Hink!")
	speak_chance = 15
	emote_see = list("shakes its head.", "shivers.", "does a gag.", "clowns around.")

/mob/living/simple_animal/pet/cat/clown/handle_automated_speech(override)
	if(override || prob(speak_chance))
		visible_message("[name] lets out a honk!")
		playsound(src, pick(meows), 100)

/mob/living/simple_animal/pet/cat/clown/emag_act(mob/user)
	emagged = TRUE
	do_sparks(8, FALSE, loc)
		
/mob/living/simple_animal/pet/cat/clown/Move(atom/newloc, direct)
	..()
	if(emagged && prob(5))
		visible_message("[name] pukes up a banana hairball!")
		playsound(get_turf(src), 'sound/effects/splat.ogg', 200, 1)
		new /obj/item/grown/bananapeel(get_turf(src))	
