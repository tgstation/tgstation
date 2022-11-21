///This component lets you make specific mobs tameable by feeding them
/datum/component/tameable
	///Are we domesticated?
	var/tame = FALSE
	///What the mob eats, typically used for taming or animal husbandry.
	var/list/food_types
	///Starting success chance for taming.
	var/tame_chance
	///Added success chance after every failed tame attempt.
	var/bonus_tame_chance
	///For effects once soemthing is tamed
	var/datum/callback/after_tame

/datum/component/tameable/Initialize(food_types, tame_chance, bonus_tame_chance, datum/callback/after_tame)
	if(!isatom(parent)) //yes, you could make a tameable toolbox.
		return COMPONENT_INCOMPATIBLE

	if(food_types)
		src.food_types = food_types
	if(tame_chance)
		src.tame_chance = tame_chance
	if(bonus_tame_chance)
		src.bonus_tame_chance = bonus_tame_chance
	if(after_tame)
		src.after_tame = after_tame


	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(try_tame))
	RegisterSignal(parent, list(COMSIG_EXTERNAL_TAME_LIVING_MOB, COMSIG_SIMPLEMOB_SENTIENCEPOTION, COMSIG_SIMPLEMOB_TRANSFERPOTION), PROC_REF(on_tame)) //Instantly succeeds

/datum/component/tameable/proc/try_tame(datum/source, obj/item/food, mob/living/attacker, params)
	SIGNAL_HANDLER
	if(!is_type_in_list(food, food_types))
		return
	if(isliving(source))
		var/mob/living/potentially_dead_horse = source
		if(potentially_dead_horse.stat == DEAD)
			to_chat(attacker, span_warning("[parent] is dead!"))
			return COMPONENT_CANCEL_ATTACK_CHAIN

	attacker.visible_message(span_notice("[attacker] hand-feeds [food] to [parent]."), span_notice("You hand-feed [food] to [parent]."))
	qdel(food)
	if(tame)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if (prob(tame_chance)) //note: lack of feedback message is deliberate, keep them guessing!
		on_tame(attacker)
	else
		tame_chance += bonus_tame_chance
	return COMPONENT_CANCEL_ATTACK_CHAIN

///Ran once taming succeeds
/datum/component/tameable/proc/on_tame(mob/living/tamer)
	SIGNAL_HANDLER
	tame = TRUE

	SEND_SIGNAL(parent, COMSIG_ON_LIVING_TAMED, tamer)
	after_tame?.Invoke(tamer)//Run custom behavior if needed

	if (isliving(parent))
		var/mob/living/living_parent = parent
		if (isliving(tamer))
			living_parent.faction += "[REF(tamer)]"
		if (living_parent.ai_controller)
			var/list/friends = living_parent.ai_controller.blackboard[BB_PET_FRIENDS_LIST]
			if (!friends)
				friends = list()
			friends[WEAKREF(tamer)] = TRUE
			living_parent.ai_controller.blackboard[BB_PET_FRIENDS_LIST] = friends
			living_parent.ai_controller.CancelActions() // In case they are currently actively biting you

	if(ishostile(parent) && isliving(tamer)) //Kinda shit check but this only applies to hostiles atm
		var/mob/living/simple_animal/hostile/evil_but_now_not_evil = parent
		evil_but_now_not_evil.friends = tamer
		evil_but_now_not_evil.faction = tamer.faction.Copy()

	qdel(src)
