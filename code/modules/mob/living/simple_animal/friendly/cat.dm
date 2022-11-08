//Cat
/mob/living/simple_animal/pet/cat
	name = "cat"
	desc = "Kitty!!"
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows.", "mews.")
	emote_see = list("shakes their head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	minbodytemp = 200
	maxbodytemp = 400
	unsuitable_atmos_damage = 0.5
	animal_species = /mob/living/simple_animal/pet/cat
	childtype = list(/mob/living/simple_animal/pet/cat/kitten = 1)
	butcher_results = list(/obj/item/food/meat/slab = 1, /obj/item/organ/internal/ears/cat = 1, /obj/item/organ/external/tail/cat = 1, /obj/item/stack/sheet/animalhide/cat = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	var/mob/living/basic/mouse/movement_target
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_type = "cat"
	can_be_held = TRUE
	held_state = "cat2"
	///only for attacking rats
	melee_damage_upper = 6
	melee_damage_lower = 4
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW

	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/pet/cat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "purrs!")
	add_verb(src, /mob/living/proc/toggle_resting)
	add_cell_sample()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/pet/cat/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CAT, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)


/mob/living/simple_animal/pet/cat/space
	name = "space cat"
	desc = "They're a cat... in space!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	held_state = "spacecat"

/mob/living/simple_animal/pet/cat/breadcat
	name = "bread cat"
	desc = "They're a cat... with a bread!"
	icon_state = "breadcat"
	icon_living = "breadcat"
	icon_dead = "breadcat_dead"
	collar_type = null
	held_state = "breadcat"
	butcher_results = list(/obj/item/food/meat/slab = 2, /obj/item/organ/internal/ears/cat = 1, /obj/item/organ/external/tail/cat = 1, /obj/item/food/breadslice/plain = 1)

/mob/living/simple_animal/pet/cat/breadcat/add_cell_sample()
	return

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

/mob/living/simple_animal/pet/cat/original/add_cell_sample()
	return
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
	var/static/cats_deployed = 0
	var/memory_saved = FALSE
	held_state = "cat"

/mob/living/simple_animal/pet/cat/runtime/Initialize(mapload)
	if(prob(5))
		icon_state = "original"
		icon_living = "original"
		icon_dead = "original_dead"
	Read_Memory()
	. = ..()

/mob/living/simple_animal/pet/cat/runtime/Life(delta_time = SSMOBS_DT, times_fired)
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

/mob/living/simple_animal/pet/cat/runtime/Write_Memory(dead, gibbed)
	. = ..()
	if(!.)
		return
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


/mob/living/simple_animal/pet/cat/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	if (resting)
		icon_state = "[icon_living]_rest"
		collar_type = "[initial(collar_type)]_rest"
	else
		icon_state = "[icon_living]"
		collar_type = "[initial(collar_type)]"
	regenerate_icons()


/mob/living/simple_animal/pet/cat/Life(delta_time = SSMOBS_DT, times_fired)
	if(!stat && !buckled && !client)
		if(DT_PROB(0.5, delta_time))
			manual_emote(pick("stretches out for a belly rub.", "wags [p_their()] tail.", "lies down."))
			set_resting(TRUE)
		else if(DT_PROB(0.5, delta_time))
			manual_emote(pick("sits down.", "crouches on [p_their()] hind legs.", "looks alert."))
			set_resting(TRUE)
			icon_state = "[icon_living]_sit"
			collar_type = "[initial(collar_type)]_sit"
		else if(DT_PROB(0.5, delta_time))
			if (resting)
				manual_emote(pick("gets up and meows.", "walks around.", "stops resting."))
				set_resting(FALSE)
			else
				manual_emote(pick("grooms [p_their()] fur.", "twitches [p_their()] whiskers.", "shakes out [p_their()] coat."))

	//MICE! RATS! OH MY!
	if((src.loc) && isturf(src.loc))
		if(!stat && !resting && !buckled)
			//Targeting anything in the rat faction nearby
			for(var/mob/living/M in view(1,src))
				if(!M.stat && Adjacent(M))
					if (FACTION_RAT in M.faction)
						//Jerry can never catch Tom snowflaking
						if(istype(M, /mob/living/basic/mouse/brown/tom) && inept_hunter)
							if(COOLDOWN_FINISHED(src, emote_cooldown))
								visible_message(span_warning("[src] chases [M] around, to no avail!"))
								step(M, pick(GLOB.cardinals))
								COOLDOWN_START(src, emote_cooldown, 1 MINUTES)
							break
						//Mouse splatting
						if(ismouse(M))
							manual_emote("splats \the [M]!")
							var/mob/living/basic/mouse/snack = M
							snack.splat()
							movement_target = null
							stop_automated_movement = 0
							break
						//Rat scratching, or anything else that could be in the rat faction
						M.attack_animal(src)
			for(var/obj/item/toy/cattoy/T in view(1,src))
				if (T.cooldown < (world.time - 400))
					manual_emote("bats \the [T] around with \his paw!")
					T.cooldown = world.time

	..()

	make_babies()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			SSmove_manager.stop_looping(src)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				//Targeting mice and mobs in the rat faction
				for(var/mob/living/target in oview(src,3))
					if(isturf(target.loc) && !target.stat)
						if(FACTION_RAT in target.faction)
							movement_target = target
							break
			if(movement_target)
				stop_automated_movement = 1
				SSmove_manager.move_to(src, movement_target, 0, 3)

/mob/living/simple_animal/pet/cat/jerry //Holy shit we left jerry on donut ~ Arcane ~Fikou
	name = "Jerry"
	desc = "Tom is VERY amused."
	inept_hunter = TRUE
	gender = MALE

/mob/living/simple_animal/pet/cat/cak //I told you I'd do it, Remie
	name = "Keeki"
	desc = "She is a cat made out of cake."
	icon_state = "cak"
	icon_living = "cak"
	icon_dead = "cak_dead"
	health = 50
	maxHealth = 50
	gender = FEMALE
	harm_intent_damage = 10
	butcher_results = list(/obj/item/organ/internal/brain = 1, /obj/item/organ/internal/heart = 1, /obj/item/food/cakeslice/birthday = 3,  \
	/obj/item/food/meat/slab = 2)
	response_harm_continuous = "takes a bite out of"
	response_harm_simple = "take a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	death_message = "loses her false life and collapses!"
	death_sound = SFX_BODYFALL
	held_state = "cak"

/mob/living/simple_animal/pet/cat/cak/add_cell_sample()
	return

/mob/living/simple_animal/pet/cat/cak/CheckParts(list/parts)
	..()
	var/obj/item/organ/internal/brain/candidate = locate(/obj/item/organ/internal/brain) in contents
	if(!candidate || !candidate.brainmob || !candidate.brainmob.mind)
		return
	candidate.brainmob.mind.transfer_to(src)
	to_chat(src, "[span_boldbig("You are a cak!")]<b> You're a harmless cat/cake hybrid that everyone loves. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. You should go around and bring happiness and \
	free cake to the station!</b>")
	var/default_name = "Keeki"
	var/new_name = sanitize_name(reject_bad_text(tgui_input_text(src, "You are the [name]. Would you like to change your name to something else?", "Name change", default_name, MAX_NAME_LEN)), cap_after_symbols = FALSE)
	if(new_name)
		to_chat(src, span_notice("Your name is now <b>[new_name]</b>!"))
		name = new_name

/mob/living/simple_animal/pet/cat/cak/Life(delta_time = SSMOBS_DT, times_fired)
	..()
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-4 * delta_time) //Fast life regen
	for(var/obj/item/food/donut/D in range(1, src)) //Frosts nearby donuts!
		if(!D.is_decorated)
			D.decorate_donut()

/mob/living/simple_animal/pet/cat/cak/attack_hand(mob/living/user, list/modifiers)
	..()
	if(user.combat_mode && user.reagents && !stat)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)
