///This component lets you make specific mobs tameable by feeding them
/datum/component/tameable
	///If true, this atom can only be domesticated by one person
	var/unique
	///Starting success chance for taming.
	var/tame_chance
	///Added success chance after every failed tame attempt.
	var/bonus_tame_chance
	///Current chance to tame on interaction
	var/current_tame_chance
	///What the mob eats, typically used for taming or animal husbandry.
	/// if nothing is given, falls back to the BB_BASIC_FOODS blackboard key... as long as the mob handles AI!
	var/list/food_types

/datum/component/tameable/Initialize(food_types, tame_chance, bonus_tame_chance, unique = TRUE)
	if(!isatom(parent)) //yes, you could make a tameable toolbox.
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent

	if(tame_chance)
		src.tame_chance = tame_chance
		src.current_tame_chance = tame_chance
	if(bonus_tame_chance)
		src.bonus_tame_chance = bonus_tame_chance
	if(food_types)
		src.food_types = food_types
	else
		if(!atom_parent.ai_controller || !atom_parent.ai_controller.blackboard_key_exists(BB_BASIC_FOODS))
			CRASH("[parent] tameable component could not get food types from ai_controller!")
		src.food_types = atom_parent.ai_controller.blackboard[BB_BASIC_FOODS]
	src.unique = unique

	RegisterSignal(parent, COMSIG_MOB_ATE, PROC_REF(try_tame))
	RegisterSignal(parent, COMSIG_SIMPLEMOB_SENTIENCEPOTION, PROC_REF(on_tame)) //Instantly succeeds
	RegisterSignal(parent, COMSIG_SIMPLEMOB_TRANSFERPOTION, PROC_REF(on_tame)) //Instantly succeeds

/datum/component/tameable/proc/try_tame(datum/source, obj/item/food, mob/living/feeder)
	SIGNAL_HANDLER
	/// taming is done with hand feeding
	if(!feeder)
		return

	var/inform_tamer = FALSE
	var/modified_tame_chance = current_tame_chance
	if(HAS_TRAIT(feeder, TRAIT_SETTLER))
		modified_tame_chance += 50
		inform_tamer = TRUE
	if(unique || !already_friends(feeder))
		if(prob(modified_tame_chance)) //note: lack of feedback message is deliberate, keep them guessing unless they're an expert!
			on_tame(source, feeder, food, inform_tamer)
		else
			current_tame_chance += bonus_tame_chance

	qdel(food)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Check if the passed mob is already considered one of our friends
/datum/component/tameable/proc/already_friends(mob/living/potential_friend)
	if(!isliving(parent))
		return FALSE // Figure this out when we actually need it
	var/mob/living/living_parent = parent
	return living_parent.faction.Find(REF(potential_friend))

///Ran once taming succeeds
/datum/component/tameable/proc/on_tame(atom/source, mob/living/tamer, obj/item/food, inform_tamer = FALSE)
	SIGNAL_HANDLER
	source.ai_controller?.become_friendly(tamer, food)//Run custom behavior if needed

	if(isliving(tamer) && inform_tamer)
		source.balloon_alert(tamer, "tamed")

	if(HAS_TRAIT(tamer, TRAIT_SETTLER))
		INVOKE_ASYNC(src, PROC_REF(rename_pet), source, tamer)
	if(unique)
		qdel(src)
	else
		current_tame_chance = tame_chance

/datum/component/tameable/proc/rename_pet(mob/living/animal, mob/living/tamer)
	var/chosen_name = sanitize_name(tgui_input_text(tamer, "Choose your pet's name!", "Name pet", animal.name, MAX_NAME_LEN), allow_numbers = TRUE)
	if(QDELETED(animal) || chosen_name == animal.name)
		return
	if(!chosen_name)
		to_chat(tamer, span_warning("Please enter a valid name."))
		rename_pet(animal, tamer)
		return
	animal.fully_replace_character_name(animal.name, chosen_name)
