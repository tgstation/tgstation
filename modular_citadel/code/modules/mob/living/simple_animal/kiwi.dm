/mob/living/simple_animal/kiwi
	name = "space kiwi"
	desc = "Exposure to low gravity made them grow larger."
	gender = FEMALE
	icon = 'modular_citadel/icons/mob/kiwi.dmi'
	icon_state = "kiwi"
	icon_living = "kiwi"
	icon_dead = "dead"
	speak = list("Chirp!","Cheep cheep chirp!!","Cheep.")
	speak_emote = list("chirps","trills")
	emote_hear = list("chirps.")
	emote_see = list("pecks at the ground.","jumps in place.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3)
	var/egg_type = /obj/item/reagent_containers/food/snacks/egg/kiwiEgg
	var/food_type = /obj/item/reagent_containers/food/snacks/grown/wheat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 25
	maxHealth = 25
	ventcrawler = VENTCRAWLER_ALWAYS
	var/eggsleft = 0
	var/eggsFertile = TRUE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	var/list/feedMessages = list("It chirps happily.","It chirps happily.")
	var/list/layMessage = list("lays an egg.","squats down and croons.","begins making a huge racket.","begins chirping raucously.")
	gold_core_spawnable = FRIENDLY_SPAWN
	var/static/kiwi_count = 0

/mob/living/simple_animal/kiwi/Destroy()
	--kiwi_count
	return ..()


/mob/living/simple_animal/kiwi/Initialize()
	. = ..()
	++kiwi_count


/mob/living/simple_animal/kiwi/Life()
	. =..()
	if(!.)
		return
	if((!stat && prob(3) && eggsleft > 0) && egg_type)
		visible_message("[src] [pick(layMessage)]")
		eggsleft--
		var/obj/item/E = new egg_type(get_turf(src))
		E.pixel_x = rand(-6,6)
		E.pixel_y = rand(-6,6)
		if(eggsFertile)
			if(kiwi_count < MAX_CHICKENS && prob(25))
				START_PROCESSING(SSobj, E)

/obj/item/reagent_containers/food/snacks/egg/kiwiEgg/process()
	if(isturf(loc))
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/simple_animal/babyKiwi(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)


/mob/living/simple_animal/kiwi/attackby(obj/item/O, mob/user, params)
	if(istype(O, food_type)) //feedin' dem kiwis
		if(!stat && eggsleft < 8)
			var/feedmsg = "[user] feeds [O] to [name]! [pick(feedMessages)]"
			user.visible_message(feedmsg)
			qdel(O)
			eggsleft += rand(1, 4)
		else
			to_chat(user, "<span class='warning'>[name] doesn't seem hungry!</span>")
	else
		..()


/mob/living/simple_animal/babyKiwi
	name = "baby space kiwi"
	desc = "So huggable."
	icon = 'modular_citadel/icons/mob/kiwi.dmi'
	icon_state = "babyKiwi"
	icon_living = "babyKiwi"
	icon_dead = "deadBaby"
	icon_gib = "chick_gib"
	gender = FEMALE
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("chirps")
	emote_hear = list("chirps.")
	emote_see = list("pecks at the ground.","Happily bounces in place.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 10
	maxHealth = 10
	ventcrawler = VENTCRAWLER_ALWAYS
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/babyKiwi/Initialize()
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/babyKiwi/Life()
	. =..()
	if(!.)
		return
	if(!stat && !ckey)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			new /mob/living/simple_animal/kiwi(src.loc)
			qdel(src)


/obj/item/reagent_containers/food/snacks/egg/kiwiEgg
	name = "kiwi egg"
	icon = 'modular_citadel/icons/mob/kiwi.dmi'
	desc = "A slightly bigger egg!"
	icon_state = "egg"

