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
	visible_message("<span class='warning'>Runtime has encountered a fatal error.</span>")
	gib()

/mob/living/simple_animal/pet/cat/clown
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/clothing/mask/gas/clown_hat = 1, /mob/living/simple_animal/hostile/retaliate/clown = 3)
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
	..()
	if(override || prob(speak_chance))
		visible_message("[name] lets out a honk!")
		playsound(src, pick(meows), 100)

/mob/living/simple_animal/pet/cat/clown/emag_act(mob/user)
	if(emagged == FALSE)
		emagged = TRUE
		do_sparks(8, FALSE, loc)

/mob/living/simple_animal/pet/cat/clown/Move(atom/newloc, direct)
	..()
	if(emagged)
		if(prob(5) && stat != DEAD)
			visible_message("[name] pukes up a banana hairball!")
			playsound(get_turf(src), 'sound/effects/splat.ogg', 100, 1)
			new /obj/item/grown/bananapeel(get_turf(src))
			new /obj/effect/decal/cleanable/vomit(get_turf(src))

/mob/living/simple_animal/pet/cat/mime
	name = "Silent Meow"
	desc = "An invisible cat, he speaks with his paws."
	icon = 'hippiestation/icons/mob/pets.dmi'
	icon_state = "catmime"
	icon_living = "catmime"
	icon_dead = "catmime_dead"
	var/static/meows = list("hippiestation/sound/creatures/mimeCatScream.ogg", "hippiestation/sound/creatures/mimeCatScream2.ogg")
	var/emag_scream_initial = "hippiestation/sound/creatures/mimeCatInitialScream.ogg"
	emote_see = list("shakes its head.", "shivers.", "pretends to pull a rope.", "acts as if trapped in an invisible box.", "swats at an invisible string.")

/mob/living/simple_animal/pet/cat/mime/emag_act(mob/user)
	var/mob/living/carbon/C = user
	playsound(loc, emag_scream_initial, 100)
	do_sparks(8, FALSE, loc)
	visible_message("<span class='narsie'>[src] has broken his vow of silence!</span>")
	var/mob/living/simple_animal/hostile/feral_cat/feral_mime_cat/K = new /mob/living/simple_animal/hostile/feral_cat/feral_mime_cat(get_turf(src))
	K.faction |= "[REF(C)]"
	qdel(src)
