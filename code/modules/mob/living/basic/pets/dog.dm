//Dogs.

// Add 'walkies' as valid input
/datum/pet_command/follow/dog
	speech_commands = list("heel", "follow", "walkies")

// Add 'good dog' as valid input
/datum/pet_command/good_boy/dog
	speech_commands = list("good dog")

// Set correct attack behaviour
/datum/pet_command/point_targetting/attack/dog
	attack_behaviour = /datum/ai_behavior/basic_melee_attack/dog

/datum/pet_command/point_targetting/attack/dog/set_command_active(mob/living/parent, mob/living/commander)
	. = ..()
	parent.ai_controller.set_blackboard_key(BB_DOG_HARASS_HARM, TRUE)

/mob/living/basic/pet/dog
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	speak_emote = list("barks", "woofs")
	faction = list(FACTION_NEUTRAL)
	can_be_held = TRUE
	ai_controller = /datum/ai_controller/basic_controller/dog
	// The dog attack pet command can raise melee attack above 0
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	/// Instructions you can give to dogs
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/good_boy/dog,
		/datum/pet_command/follow/dog,
		/datum/pet_command/point_targetting/attack/dog,
		/datum/pet_command/point_targetting/fetch,
		/datum/pet_command/play_dead,
	)

/mob/living/basic/pet/dog/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "woofs happily!")
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/unfriend_attacker, untamed_reaction = "%SOURCE% fixes %TARGET% with a look of betrayal.")
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/meat/slab/human/mutant/skeleton, /obj/item/stack/sheet/bone), tame_chance = 30, bonus_tame_chance = 15, after_tame = CALLBACK(src, PROC_REF(tamed)), unique = FALSE)
	AddComponent(/datum/component/obeys_commands, pet_commands)

/mob/living/basic/pet/dog/proc/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("YAP", "Woof!", "Bark!", "AUUUUUU"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/proc/tamed(mob/living/tamer)
	visible_message(span_notice("[src] licks at [tamer] in a friendly manner!"))

//Corgis and pugs are now under one dog subtype

/mob/living/basic/pet/dog/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "They're a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	held_state = "corgi"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 3, /obj/item/stack/sheet/animalhide/corgi = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "corgi"
	ai_controller = /datum/ai_controller/basic_controller/dog/corgi
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	/// Access card for Ian.
	var/obj/item/card/id/access_card = null
	var/shaved = FALSE
	var/nofur = FALSE //Corgis that have risen past the material plane of existence.
	/// Is this corgi physically slow due to age, etc?
	var/is_slow = FALSE

/mob/living/basic/pet/dog/corgi/examine(mob/user)
	. = ..()
	if(access_card)
		. += "There appears to be [icon2html(access_card, user)] \a [access_card] pinned to [p_them()]."

/mob/living/basic/pet/dog/corgi/Destroy()
	QDEL_NULL(inventory_head)
	QDEL_NULL(inventory_back)
	QDEL_NULL(access_card)
	return ..()

/mob/living/basic/pet/dog/corgi/gib()
	if(inventory_head)
		inventory_head.forceMove(drop_location())
		inventory_head = null
	if(inventory_back)
		inventory_back.forceMove(drop_location())
		inventory_back = null
	if(access_card)
		access_card.forceMove(drop_location())
		access_card = null
	return ..()

/mob/living/basic/pet/dog/corgi/deadchat_plays(mode = ANARCHY_MODE, cooldown = 12 SECONDS)
	. = AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(
		"speak" = CALLBACK(src, PROC_REF(bork)),
		"wear_hat" = CALLBACK(src, PROC_REF(find_new_hat)),
		"drop_hat" = CALLBACK(src, PROC_REF(drop_hat)),
		"spin" = CALLBACK(src, TYPE_PROC_REF(/mob, emote), "spin")), cooldown, CALLBACK(src, PROC_REF(stop_deadchat_plays)))

	if(. == COMPONENT_INCOMPATIBLE)
		return

	// Stop all automated behavior.
	QDEL_NULL(ai_controller)

///Deadchat bark.
/mob/living/basic/pet/dog/corgi/proc/bork()
	var/emote = pick("barks!", "woofs!", "yaps.","pants.")

	manual_emote(emote)

///Deadchat plays command that picks a new hat for Ian.
/mob/living/basic/pet/dog/corgi/proc/find_new_hat()
	if(!isturf(loc))
		return
	var/list/possible_headwear = list()
	for(var/obj/item/item in loc)
		if(ispath(item.dog_fashion, /datum/dog_fashion/head))
			possible_headwear += item
	if(!length(possible_headwear))
		for(var/obj/item/item in orange(1))
			if(ispath(item.dog_fashion, /datum/dog_fashion/head) && CanReach(item))
				possible_headwear += item
	if(!length(possible_headwear))
		return
	if(inventory_head)
		inventory_head.forceMove(drop_location())
		inventory_head = null
	place_on_head(pick(possible_headwear))
	visible_message(span_notice("[src] puts [inventory_head] on [p_their()] own head, somehow."))

///Deadchat plays command that drops the current hat off Ian.
/mob/living/basic/pet/dog/corgi/proc/drop_hat()
	if(!inventory_head)
		return
	visible_message(span_notice("[src] vigorously shakes [p_their()] head, dropping [inventory_head] to the ground."))
	inventory_head.forceMove(drop_location())
	inventory_head = null
	update_corgi_fluff()
	regenerate_icons()

///Turn AI back on.
/mob/living/basic/pet/dog/corgi/proc/stop_deadchat_plays()
	var/controller_type = initial(ai_controller)
	ai_controller = new controller_type(src)
	ai_controller?.set_blackboard_key(BB_DOG_IS_SLOW, is_slow)

/mob/living/basic/pet/dog/corgi/handle_atom_del(atom/A)
	if(A == inventory_head)
		inventory_head = null
		update_corgi_fluff()
		regenerate_icons()
	if(A == inventory_back)
		inventory_back = null
		update_corgi_fluff()
		regenerate_icons()
	return ..()

/mob/living/basic/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "They're a pug."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/food/meat/slab/pug = 3)
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "pug"
	held_state = "pug"

/mob/living/basic/pet/dog/pug/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/swabable, CELL_LINE_TABLE_PUG, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/pet/dog/pug/mcgriff
	name = "McGriff"
	desc = "This dog can tell something smells around here, and that something is CRIME!"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier
	name = "\improper bull terrier"
	real_name = "bull terrier"
	desc = "They're a bull terrier."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "bullterrier"
	icon_living = "bullterrier"
	icon_dead = "bullterrier_dead"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 3) // Would feel redundant to add more new dog meats.
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "bullterrier"
	held_state = "bullterrier"

/mob/living/basic/pet/dog/corgi/exoticcorgi
	name = "Exotic Corgi"
	desc = "As cute as they are colorful!"
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "corgigrey"
	icon_living = "corgigrey"
	icon_dead = "corgigrey_dead"
	nofur = TRUE

/mob/living/basic/pet/dog/Initialize(mapload)
	. = ..()
	var/dog_area = get_area(src)
	for(var/obj/structure/bed/dogbed/D in dog_area)
		if(D.update_owner(src)) //No muscling in on my turf you fucking parrot
			break

/mob/living/basic/pet/dog/corgi/Initialize(mapload)
	. = ..()
	regenerate_icons()
	AddElement(/datum/element/strippable, GLOB.strippable_corgi_items)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CORGI, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	RegisterSignal(src, COMSIG_MOB_TRIED_ACCESS, PROC_REF(on_tried_access))

/**
 * Handler for COMSIG_MOB_TRIED_ACCESS
 */
/mob/living/basic/pet/dog/corgi/proc/on_tried_access(mob/accessor, obj/locked_thing)
	SIGNAL_HANDLER

	return locked_thing?.check_access(access_card) ? ACCESS_ALLOWED : ACCESS_DISALLOWED

/mob/living/basic/pet/dog/corgi/exoticcorgi/Initialize(mapload)
		. = ..()
		var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
		add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/basic/pet/dog/corgi/death(gibbed)
	..(gibbed)
	regenerate_icons()

GLOBAL_LIST_INIT(strippable_corgi_items, create_strippable_list(list(
	/datum/strippable_item/corgi_head,
	/datum/strippable_item/corgi_back,
	/datum/strippable_item/pet_collar,
	/datum/strippable_item/corgi_id,
)))

/datum/strippable_item/corgi_head
	key = STRIPPABLE_ITEM_HEAD

/datum/strippable_item/corgi_head/get_item(atom/source)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	return corgi_source.inventory_head

/datum/strippable_item/corgi_head/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	corgi_source.place_on_head(equipping, user)

/datum/strippable_item/corgi_head/finish_unequip(atom/source, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	user.put_in_hands(corgi_source.inventory_head)
	corgi_source.inventory_head = null
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()

/datum/strippable_item/pet_collar
	key = STRIPPABLE_ITEM_PET_COLLAR

/datum/strippable_item/pet_collar/get_item(atom/source)
	var/mob/living/basic/pet/pet_source = source
	if (!istype(pet_source))
		return

	return pet_source.collar

/datum/strippable_item/pet_collar/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if (!istype(equipping, /obj/item/clothing/neck/petcollar))
		to_chat(user, span_warning("That's not a collar."))
		return FALSE

	return TRUE

/datum/strippable_item/pet_collar/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/basic/pet/pet_source = source
	if (!istype(pet_source))
		return

	pet_source.add_collar(equipping, user)

/datum/strippable_item/pet_collar/finish_unequip(atom/source, mob/user)
	var/mob/living/basic/pet/pet_source = source
	if (!istype(pet_source))
		return

	var/obj/collar = pet_source.remove_collar(user.drop_location())
	user.put_in_hands(collar)

/datum/strippable_item/corgi_back
	key = STRIPPABLE_ITEM_BACK

/datum/strippable_item/corgi_back/get_item(atom/source)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	return corgi_source.inventory_back

/datum/strippable_item/corgi_back/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if (!ispath(equipping.dog_fashion, /datum/dog_fashion/back))
		to_chat(user, span_warning("You set [equipping] on [source]'s back, but it falls off!"))
		equipping.forceMove(source.drop_location())
		if (prob(25))
			step_rand(equipping)
		dance_rotate(source, set_original_dir = TRUE)

		return FALSE

	return TRUE

/datum/strippable_item/corgi_back/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	equipping.forceMove(corgi_source)
	corgi_source.inventory_back = equipping
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()

/datum/strippable_item/corgi_back/finish_unequip(atom/source, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	user.put_in_hands(corgi_source.inventory_back)
	corgi_source.inventory_back = null
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()

/datum/strippable_item/corgi_id
	key = STRIPPABLE_ITEM_ID

/datum/strippable_item/corgi_id/get_item(atom/source)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	return corgi_source.access_card

/datum/strippable_item/corgi_id/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if (!isidcard(equipping))
		to_chat(user, span_warning("You can't pin [equipping] to [source]!"))
		return FALSE

	return TRUE

/datum/strippable_item/corgi_id/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	equipping.forceMove(source)
	corgi_source.access_card = equipping

/datum/strippable_item/corgi_id/finish_unequip(atom/source, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	user.put_in_hands(corgi_source.access_card)
	corgi_source.access_card = null
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()

/mob/living/basic/pet/dog/corgi/getarmor(def_zone, type)
	var/armorval = 0

	if(def_zone)
		if(def_zone == BODY_ZONE_HEAD)
			if(inventory_head)
				armorval = inventory_head.get_armor_rating(type)
		else
			if(inventory_back)
				armorval = inventory_back.get_armor_rating(type)
		return armorval
	else
		if(inventory_head)
			armorval += inventory_head.get_armor_rating(type)
		if(inventory_back)
			armorval += inventory_back.get_armor_rating(type)
	return armorval*0.5

/mob/living/basic/pet/dog/corgi/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/razor))
		if (shaved)
			to_chat(user, span_warning("You can't shave this corgi, [p_they()] has already been shaved!"))
			return
		if (nofur)
			to_chat(user, span_warning("You can't shave this corgi, [p_they()] [p_do()]n't have a fur coat!"))
			return
		user.visible_message(span_notice("[user] starts to shave [src] using \the [O]."), span_notice("You start to shave [src] using \the [O]..."))
		if(do_after(user, 50, target = src))
			user.visible_message(span_notice("[user] shaves [src]'s hair using \the [O]."))
			playsound(loc, 'sound/items/welder2.ogg', 20, TRUE)
			shaved = TRUE
			icon_living = "[initial(icon_living)]_shaved"
			icon_dead = "[initial(icon_living)]_shaved_dead"
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
		return
	..()
	update_corgi_fluff()

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
// > some will probably be removed

/mob/living/basic/pet/dog/corgi/proc/place_on_head(obj/item/item_to_add, mob/living/user)
	if(inventory_head)
		if(user)
			to_chat(user, span_warning("You can't put more than one hat on [src]!"))
		return
	if(!item_to_add)
		user.visible_message(span_notice("[user] pets [src]."), span_notice("You rest your hand on [src]'s head for a moment."))
		if(flags_1 & HOLOGRAM_1)
			return
		user.add_mood_event(REF(src), /datum/mood_event/pet_animal, src)
		return

	if(user && !user.temporarilyRemoveItemFromInventory(item_to_add))
		to_chat(user, span_warning("\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!"))
		return

	var/valid = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/head))
		valid = TRUE

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.

	if(valid)
		if(health <= 0)
			to_chat(user, span_notice("There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on [p_them()]."))
		else if(user)
			user.visible_message(span_notice("[user] puts [item_to_add] on [real_name]'s head. [src] looks at [user] and barks once."),
				span_notice("You put [item_to_add] on [real_name]'s head. [src] gives you a peculiar look, then wags [p_their()] tail once and barks."),
				span_hear("You hear a friendly-sounding bark."))
		item_to_add.forceMove(src)
		src.inventory_head = item_to_add
		update_corgi_fluff()
		regenerate_icons()
	else
		to_chat(user, span_warning("You set [item_to_add] on [src]'s head, but it falls off!"))
		item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		dance_rotate(src, set_original_dir=TRUE)

	return valid

/mob/living/basic/pet/dog/corgi/proc/update_corgi_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak_emote = list("barks", "woofs")
	desc = initial(desc)
	set_light(0)

	if(inventory_head?.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply(src)

	if(inventory_back?.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply(src)

/mob/living/basic/pet/dog/corgi/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	..()

	if(inventory_head?.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply_to_speech(speech)

	if(inventory_back?.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply_to_speech(speech)

//IAN! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/ian
	name = "Ian"
	real_name = "Ian" //Intended to hold the name without altering it.
	gender = MALE
	desc = "He's the HoP's beloved corgi."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/age = 0
	var/record_age = 1
	var/memory_saved = FALSE
	var/saved_head //path

/mob/living/basic/pet/dog/corgi/ian/Initialize(mapload)
	. = ..()
	// Ensure Ian exists
	REGISTER_REQUIRED_MAP_ITEM(1, 1)

	//parent call must happen first to ensure IAN
	//is not in nullspace when child puppies spawn
	Read_Memory()
	if(age == 0)
		var/turf/target = get_turf(loc)
		if(target)
			new /mob/living/basic/pet/dog/corgi/puppy/ian(target)
			Write_Memory(FALSE)
			return INITIALIZE_HINT_QDEL
	else if(age == record_age)
		icon_state = "old_corgi"
		icon_living = "old_corgi"
		held_state = "old_corgi"
		icon_dead = "old_corgi_dead"
		desc = "At a ripe old age of [record_age], Ian's not as spry as he used to be, but he'll always be the HoP's beloved corgi." //RIP
		ai_controller?.set_blackboard_key(BB_DOG_IS_SLOW, TRUE)
		is_slow = TRUE
		speed = 2

/mob/living/basic/pet/dog/corgi/ian/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(FALSE)
		memory_saved = TRUE
	..()

/mob/living/basic/pet/dog/corgi/ian/death()
	if(!memory_saved)
		Write_Memory(TRUE)
	..()

/mob/living/basic/pet/dog/corgi/ian/proc/Read_Memory()
	if(fexists("data/npc_saves/Ian.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
		S["age"] >> age
		S["record_age"] >> record_age
		S["saved_head"] >> saved_head
		fdel("data/npc_saves/Ian.sav")
	else
		var/json_file = file("data/npc_saves/Ian.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		age = json["age"]
		record_age = json["record_age"]
		saved_head = json["saved_head"]
	if(isnull(age))
		age = 0
	if(isnull(record_age))
		record_age = 1
	if(saved_head)
		place_on_head(new saved_head)

/mob/living/basic/pet/dog/corgi/ian/Write_Memory(dead, gibbed)
	. = ..()
	if(!.)
		return
	var/json_file = file("data/npc_saves/Ian.json")
	var/list/file_data = list()
	if(!dead)
		file_data["age"] = age + 1
		if((age + 1) > record_age)
			file_data["record_age"] = record_age + 1
		else
			file_data["record_age"] = record_age
		if(inventory_head)
			file_data["saved_head"] = inventory_head.type
		else
			file_data["saved_head"] = null
	else
		file_data["age"] = 0
		file_data["record_age"] = record_age
		file_data["saved_head"] = null
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/basic/pet/dog/corgi/ian/narsie_act()
	playsound(src, 'sound/magic/demon_dies.ogg', 75, TRUE)
	var/mob/living/basic/pet/dog/corgi/narsie/N = new(loc)
	N.setDir(dir)
	investigate_log("has been gibbed by Nar'Sie.", INVESTIGATE_DEATHS)
	gib()

/mob/living/basic/pet/dog/corgi/narsie
	name = "Nars-Ian"
	desc = "Ia! Ia!"
	icon_state = "narsian"
	icon_living = "narsian"
	icon_dead = "narsian_dead"
	faction = list(FACTION_NEUTRAL, FACTION_CULT)
	gold_core_spawnable = NO_SPAWN
	nofur = TRUE
	unique_pet = TRUE
	held_state = "narsian"

/mob/living/basic/pet/dog/corgi/narsie/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	for(var/mob/living/simple_animal/pet/P in range(1, src))
		if(P != src && !istype(P,/mob/living/basic/pet/dog/corgi/narsie))
			visible_message(span_warning("[src] devours [P]!"), \
			"<span class='cult big bold'>DELICIOUS SOULS</span>")
			playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)
			narsie_act()
			P.gib()
	for(var/mob/living/basic/pet/P in range(1, src))
		if(P != src && !istype(P,/mob/living/basic/pet/dog/corgi/narsie))
			visible_message(span_warning("[src] devours [P]!"), \
			"<span class='cult big bold'>DELICIOUS SOULS</span>")
			playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)
			narsie_act()
			P.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
			P.gib()

/mob/living/basic/pet/dog/corgi/narsie/update_corgi_fluff()
	..()
	speak_emote = list("growls", "barks ominously")

/mob/living/basic/pet/dog/corgi/narsie/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("Tari'karat-pasnar!", "IA! IA!", "BRRUUURGHGHRHR"))
	speech.emote_hear = string_list(list("barks echoingly!", "woofs hauntingly!", "yaps in an eldritch manner.", "mutters something unspeakable."))
	speech.emote_see = string_list(list("communes with the unnameable.", "ponders devouring some souls.", "shakes."))

/mob/living/basic/pet/dog/corgi/narsie/narsie_act()
	adjustBruteLoss(-maxHealth)


/mob/living/basic/pet/dog/corgi/regenerate_icons()
	..()
	cut_overlays() //we are redrawing the mob after all
	if(inventory_head)
		var/image/head_icon
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_head.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_head.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_head.color

		if(health <= 0)
			head_icon = DF.get_overlay(dir = EAST)
			head_icon.pixel_y = -8
			head_icon.transform = turn(head_icon.transform, 180)
		else
			head_icon = DF.get_overlay()

		add_overlay(head_icon)

	if(inventory_back)
		var/image/back_icon
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_back.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_back.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_back.color

		if(health <= 0)
			back_icon = DF.get_overlay(dir = EAST)
			back_icon.pixel_y = -11
			back_icon.transform = turn(back_icon.transform, 180)
		else
			back_icon = DF.get_overlay()
		add_overlay(back_icon)

	return



/mob/living/basic/pet/dog/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "They're a corgi puppy!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_icon_state = "puppy"

//puppies cannot wear anything.
/mob/living/basic/pet/dog/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, span_warning("You can't fit this on [src], [p_they()] [p_are()] too small!"))
		return
	..()

//PUPPY IAN! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/puppy/ian
	name = "Ian"
	real_name = "Ian"
	gender = MALE
	desc = "He's the HoP's beloved corgi puppy."


/mob/living/basic/pet/dog/corgi/puppy/void //Tribute to the corgis born in nullspace
	name = "\improper void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back..."
	gender = NEUTER
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	nofur = TRUE
	held_state = "void_puppy"
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 40

/mob/living/basic/pet/dog/corgi/puppy/void/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_AI_BAGATTACK, INNATE_TRAIT)

/mob/living/basic/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 1 //Void puppies can navigate space.

//LISA! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "She's tearing you apart."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	held_state = "lisa"
	var/puppies = 0

//Lisa already has a cute bow!
/mob/living/basic/pet/dog/corgi/lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, span_warning("[src] already has a cute bow!"))
		return
	..()

/mob/living/basic/pet/dog/breaddog //Most of the code originates from Cak
	name = "Kobun"
	desc = "It is a dog made out of bread. 'The universe is definitely half full'."
	icon_state = "breaddog"
	icon_living = "breaddog"
	icon_dead = "breaddog_dead"
	head_icon = 'icons/mob/clothing/head/pets_head.dmi'
	health = 50
	maxHealth = 50
	gender = NEUTER
	damage_coeff = list(BRUTE = 3, BURN = 3, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	butcher_results = list(/obj/item/organ/internal/brain = 1, /obj/item/organ/internal/heart = 1, /obj/item/food/breadslice/plain = 3,  \
	/obj/item/food/meat/slab = 2)
	response_harm_continuous = "takes a bite out of"
	response_harm_simple = "take a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	held_state = "breaddog"
	worn_slot_flags = ITEM_SLOT_HEAD

/mob/living/basic/pet/dog/breaddog/CheckParts(list/parts)
	..()
	var/obj/item/organ/internal/brain/candidate = locate(/obj/item/organ/internal/brain) in contents
	if(!candidate || !candidate.brainmob || !candidate.brainmob.mind)
		return
	candidate.brainmob.mind.transfer_to(src)
	to_chat(src, "[span_boldbig("You are a bread dog!")]<b> You're a harmless dog/bread hybrid that everyone loves. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. You should go around and bring happiness and \
	free bread to the station!	'I’m not alone, and you aren’t either'</b>")
	var/default_name = "Kobun"
	var/new_name = sanitize_name(reject_bad_text(tgui_input_text(src, "You are the [name]. Would you like to change your name to something else?", "Name change", default_name, MAX_NAME_LEN)), cap_after_symbols = FALSE)
	if(new_name)
		to_chat(src, span_notice("Your name is now <b>[new_name]</b>!"))
		name = new_name

/mob/living/basic/pet/dog/breaddog/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(stat)
		return

	if(health < maxHealth)
		adjustBruteLoss(-4 * seconds_per_tick) //Fast life regen

	for(var/mob/living/carbon/humanoid_entities in view(3, src)) //Mood aura which stay as long you do not wear Sanallite as hat or carry(I will try to make it work with hat someday(obviously weaker than normal one))
		humanoid_entities.add_mood_event("kobun", /datum/mood_event/kobun)

/mob/living/basic/pet/dog/breaddog/attack_hand(mob/living/user, list/modifiers)
	..()
	if(user.combat_mode && user.reagents && !stat)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)

/// A dog bone fully heals a dog, and befriends it if it's not your friend.
/obj/item/dog_bone
	name = "jumbo dog bone"
	desc = "A tasty femur full of juicy marrow, the perfect gift for your best friend."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "skeletonmeat"
	custom_materials = list(/datum/material/bone = SHEET_MATERIAL_AMOUNT * 4)
	force = 3
	throwforce = 5
	attack_verb_continuous = list("attacks", "bashes", "batters", "bludgeons", "whacks")
	attack_verb_simple = list("attack", "bash", "batter", "bludgeon", "whack")

/obj/item/dog_bone/pre_attack(atom/target, mob/living/user, params)
	if (!isdog(target) || user.combat_mode)
		return ..()
	var/mob/living/basic/pet/dog/dog_target = target
	if (dog_target.stat != CONSCIOUS)
		return ..()
	dog_target.emote("spin")
	dog_target.fully_heal()
	if (dog_target.befriend(user))
		dog_target.tamed(user)
	new /obj/effect/temp_visual/heart(target.loc)
	qdel(src)
	return TRUE
