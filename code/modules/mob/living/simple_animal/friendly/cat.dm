//Cat
///How long of not seeing the currently hunted food before we give up on finding it :(
#define CAT_MUNCHY_FRUSTRATE_TIME	1 MINUTES
///How long we wait after giving up some food (whether we ate it or gave up) before trying again
#define CAT_MUNCHY_BREAK_TIME	2 MINUTES

/mob/living/simple_animal/pet/cat
	name = "cat"
	desc = "Kitty!!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	gender = MALE
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows.", "mews.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	minbodytemp = 200
	maxbodytemp = 400
	unsuitable_atmos_damage = 1
	animal_species = /mob/living/simple_animal/pet/cat
	childtype = list(/mob/living/simple_animal/pet/cat/kitten)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	///Limits how often cats can spam chasing mice.
	var/emote_cooldown = 0
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_type = "cat"
	can_be_held = TRUE
	held_state = "cat2"
	pet_bonus = TRUE
	pet_bonus_emote = "purrs!"

	footstep_type = FOOTSTEP_MOB_CLAW
	///if there's a can of opened catfood we're hunting after
	var/atom/current_catnip
	//var/obj/item/reagent_containers/food/snacks/canned/catfood/current_catnip
	///how long it takes before we give up on ever reaching the promised snack
	COOLDOWN_DECLARE(munchy_frustration)
	///if we just gave up on some food (either we ate it or we gave up on it), take a break from searching again
	COOLDOWN_DECLARE(munchy_break)

/mob/living/simple_animal/pet/cat/Initialize()
	. = ..()
	verbs += /mob/living/proc/lay_down

/mob/living/simple_animal/pet/cat/Destroy()
	. = ..()
	current_catnip = null

/mob/living/simple_animal/pet/cat/update_mobility()
	..()
	if(client && stat != DEAD)
		if (resting)
			icon_state = "[icon_living]_rest"
			collar_type = "[initial(collar_type)]_rest"
		else
			icon_state = "[icon_living]"
			collar_type = "[initial(collar_type)]"
	regenerate_icons()

/mob/living/simple_animal/pet/cat/space
	name = "space cat"
	desc = "It's a cat... in space!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	held_state = "spacecat"

/mob/living/simple_animal/pet/cat/original
	name = "Batsy"
	desc = "The product of alien DNA and bored geneticists."
	gender = FEMALE
	icon_state = "original"
	icon_living = "original"
	icon_dead = "original_dead"
	collar_type = null
	unique_pet = TRUE
	held_state = "original"

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww."
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_type = "kitten"

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/pet/cat/runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/list/family = list()//var restored from savefile, has count of each child type
	var/list/children = list()//Actual mob instances of children
	var/cats_deployed = 0
	var/memory_saved = FALSE
	held_state = "cat"

/mob/living/simple_animal/pet/cat/runtime/Initialize()
	if(prob(5))
		icon_state = "original"
		icon_living = "original"
		icon_dead = "original_dead"
	Read_Memory()
	. = ..()

/mob/living/simple_animal/pet/cat/runtime/Life()
	if(!cats_deployed && SSticker.current_state >= GAME_STATE_SETTING_UP)
		Deploy_The_Cats()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory()
		memory_saved = TRUE
	..()

/mob/living/simple_animal/pet/cat/runtime/make_babies()
	var/mob/baby = ..()
	if(baby)
		children += baby
		return baby

/mob/living/simple_animal/pet/cat/runtime/death()
	if(!memory_saved)
		Write_Memory(TRUE)
	..()

/mob/living/simple_animal/pet/cat/runtime/proc/Read_Memory()
	if(fexists("data/npc_saves/Runtime.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
		S["family"] >> family
		fdel("data/npc_saves/Runtime.sav")
	else
		var/json_file = file("data/npc_saves/Runtime.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		family = json["family"]
	if(isnull(family))
		family = list()

/mob/living/simple_animal/pet/cat/runtime/proc/Write_Memory(dead)
	var/json_file = file("data/npc_saves/Runtime.json")
	var/list/file_data = list()
	family = list()
	if(!dead)
		for(var/mob/living/simple_animal/pet/cat/kitten/C in children)
			if(istype(C,type) || C.stat || !C.z || (C.flags_1 & HOLOGRAM_1))
				continue
			if(C.type in family)
				family[C.type] += 1
			else
				family[C.type] = 1
	file_data["family"] = family
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/simple_animal/pet/cat/runtime/proc/Deploy_The_Cats()
	cats_deployed = 1
	for(var/cat_type in family)
		if(family[cat_type] > 0)
			for(var/i in 1 to min(family[cat_type],100)) //Limits to about 500 cats, you wouldn't think this would be needed (BUT IT IS)
				new cat_type(loc)

/mob/living/simple_animal/pet/cat/_proc
	name = "Proc"
	gender = MALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/cat/Life()
	if(stat || buckled)
		return ..()

	if(!client)
		if(current_catnip)
			seek_current_catnip()
			return ..() // no running away or making babies while you're eating, that'd be gross
		else
			auto_emote()

	//MICE!
	if(isturf(loc) && !resting)
		hunt_mice()

	..()
	make_babies()

	if(resting)
		return

	turns_since_scan++
	if(turns_since_scan <= 5)
		return

	walk_to(src,0)
	turns_since_scan = 0
	if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
		movement_target = null
		stop_automated_movement = FALSE
	if( !movement_target || !(movement_target.loc in oview(src, 3)) )
		movement_target = null
		stop_automated_movement = FALSE
		for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
			if(isturf(snack.loc) && !snack.stat)
				movement_target = snack
				break
	if(movement_target)
		stop_automated_movement = TRUE
		walk_to(src,movement_target,0,3)

///Somehow, whether by our frustration, the can ceasing to exist (including being finished off), or whatever, we have decided we don't want that food anymore, so we scrub references on both sides (as needed)
/mob/living/simple_animal/pet/cat/proc/give_up_current_catnip()
	testing("gave up current_catnip")
	if(!current_catnip)
		return
	current_catnip = null
	COOLDOWN_RESET(src, munchy_frustration)
	COOLDOWN_START(src, munchy_break, CAT_MUNCHY_BREAK_TIME)

/**
  * This proc handles all the behavior with chasing after canned catfood. Yum!
  *
  *	Basically, we run after wherever our food is, then we either meow at/rub up against whoever's holding it if it's a carbon, or we try eating the food. If we don't get near the food after a long delay, we give up and look for other food
  */
/mob/living/simple_animal/pet/cat/proc/seek_current_catnip()
	//if we're not at our current_catnip, try running to them
	if(!Adjacent(get_turf(current_catnip)))
		// check if we've given up on these food
		if(COOLDOWN_FINISHED(src, munchy_frustration))
			give_up_current_catnip()
			return
		set_resting(FALSE)
		walk_to(src, get_turf(current_catnip), 0, rand(15,25) * 0.1)
	else
		COOLDOWN_START(src, munchy_frustration, CAT_MUNCHY_FRUSTRATE_TIME) // restart

	var/atom/catnip_holder = current_catnip.loc
	// beg for food
	if(!isturf(catnip_holder))
		var/soundpath
		if(!Adjacent(catnip_holder))
			visible_message("<b>[src]</b> meows at [catnip_holder]!", vision_distance=COMBAT_MESSAGE_RANGE)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(src), pick('sound/effects/meow1.ogg', 'sound/effects/meow2.ogg'), 50, TRUE), rand(0, 10)) // 0-1 seconds, so there's some variation
		else
			switch(rand(1,3))
				if(1)
					visible_message("<b>[src]</b> meows [pick("directly", "defiantly", "hungrily", "tiredly")] at [catnip_holder]!", vision_distance=COMBAT_MESSAGE_RANGE)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(src), pick('sound/effects/meow1.ogg', 'sound/effects/meow2.ogg'), 50, TRUE), rand(0, 10))
				if(2)
					visible_message("<b>[src]</b> rubs up against [catnip_holder]!", vision_distance=COMBAT_MESSAGE_RANGE)
					new /obj/effect/temp_visual/heart(loc)
				if(3)
					visible_message("<b>[src]</b> stares expectantly at [catnip_holder]!", vision_distance=COMBAT_MESSAGE_RANGE)
					face_atom(catnip_holder)

	else if(Adjacent(current_catnip))
		var/obj/item/reagent_containers/food/snacks/actual_food = current_catnip
		set_resting(TRUE)
		// if it's on the ground and is food, eat!!!
		if(istype(actual_food) && actual_food.reagents?.total_volume)
			playsound(get_turf(src), pick('sound/effects/cat_feed1.ogg','sound/effects/cat_feed2.ogg','sound/effects/cat_feed3.ogg'), 80, TRUE, -2)
			if(prob(50))
				visible_message("<b>[src]</b> quietly nibbles away at [actual_food].", vision_distance=COMBAT_MESSAGE_RANGE)
			// fake eating the food
			actual_food.reagents.remove_any(1)
			actual_food.bitecount++
			actual_food.On_Consume(src)
		// else just meow at it
		else
			visible_message("<b>[src]</b> meows [pick("directly", "defiantly", "suspiciously", "tiredly")] at [current_catnip]!", vision_distance=COMBAT_MESSAGE_RANGE)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(src), pick('sound/effects/meow1.ogg', 'sound/effects/meow2.ogg'), 50, TRUE), rand(0, 10))

///Same mice hunting behavior as before, just sectioned off from [/mob/living/simple_animal/pet/cat/proc/Life]
/mob/living/simple_animal/pet/cat/proc/hunt_mice()
	for(var/mob/living/simple_animal/mouse/M in view(1,src))
		if(istype(M, /mob/living/simple_animal/mouse/brown/tom) && (name == "Jerry")) //Turns out there's no jerry subtype.
			if (emote_cooldown < (world.time - 600))
				visible_message("<span class='warning'>[src] chases [M] around, to no avail!</span>")
				step(M, pick(GLOB.cardinals))
				emote_cooldown = world.time
			break
		if(!M.stat && Adjacent(M))
			manual_emote("splats \the [M]!")
			M.splat()
			movement_target = null
			stop_automated_movement = 0
			break
	for(var/obj/item/toy/cattoy/T in view(1,src))
		if (T.cooldown < (world.time - 400))
			manual_emote("bats \the [T] around with its paw!")
			T.cooldown = world.time

///Same emote as before, just sectioned off from [/mob/living/simple_animal/pet/cat/proc/Life]
/mob/living/simple_animal/pet/cat/proc/auto_emote()
	if(prob(1))
		manual_emote(pick("stretches out for a belly rub.", "wags its tail.", "lies down."))
		set_resting(TRUE)
	else if (prob(1))
		manual_emote(pick("sits down.", "crouches on its hind legs.", "looks alert."))
		set_resting(TRUE)
	else if (prob(1))
		if (resting)
			manual_emote(pick("gets up and meows.", "walks around.", "stops resting."))
			set_resting(FALSE)
		else
			manual_emote(pick("grooms its fur.", "twitches its whiskers.", "shakes out its coat."))

/mob/living/simple_animal/pet/cat/cak //I told you I'd do it, Remie
	name = "Keeki"
	desc = "It's a cat made out of cake."
	icon_state = "cak"
	icon_living = "cak"
	icon_dead = "cak_dead"
	health = 50
	maxHealth = 50
	gender = FEMALE
	harm_intent_damage = 10
	butcher_results = list(/obj/item/organ/brain = 1, /obj/item/organ/heart = 1, /obj/item/reagent_containers/food/snacks/cakeslice/birthday = 3,  \
	/obj/item/reagent_containers/food/snacks/meat/slab = 2)
	response_harm_continuous = "takes a bite out of"
	response_harm_simple = "take a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	deathmessage = "loses its false life and collapses!"
	deathsound = "bodyfall"
	held_state = "cak"

/mob/living/simple_animal/pet/cat/cak/CheckParts(list/parts)
	..()
	var/obj/item/organ/brain/B = locate(/obj/item/organ/brain) in contents
	if(!B || !B.brainmob || !B.brainmob.mind)
		return
	B.brainmob.mind.transfer_to(src)
	to_chat(src, "<span class='big bold'>You are a cak!</span><b> You're a harmless cat/cake hybrid that everyone loves. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. You should go around and bring happiness and \
	free cake to the station!</b>")
	var/new_name = stripped_input(src, "Enter your name, or press \"Cancel\" to stick with Keeki.", "Name Change")
	if(new_name)
		to_chat(src, "<span class='notice'>Your name is now <b>\"new_name\"</b>!</span>")
		name = new_name

/mob/living/simple_animal/pet/cat/cak/Life()
	..()
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-8) //Fast life regen
	for(var/obj/item/reagent_containers/food/snacks/donut/D in range(1, src)) //Frosts nearby donuts!
		if(!D.is_decorated)
			D.decorate_donut()

/mob/living/simple_animal/pet/cat/cak/attack_hand(mob/living/L)
	..()
	if(L.a_intent == INTENT_HARM && L.reagents && !stat)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)

#undef CAT_MUNCHY_FRUSTRATE_TIME
#undef CAT_MUNCHY_BREAK_TIME
