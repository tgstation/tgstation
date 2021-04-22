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


	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/try_tame)
	RegisterSignal(parent, COMSIG_SIMPLEMOB_SENTIENCEPOTION, .proc/on_tame) //Instantly succeeds

/datum/component/tameable/proc/try_tame(datum/source, obj/item/food, mob/living/attacker, params)
	SIGNAL_HANDLER
	if(!is_type_in_list(O, food_types))
		return
	if(stat == DEAD)
		to_chat(attacker, "<span class='warning'>[parent] is dead!</span>")
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN //No beating up anymore!

	attacker.visible_message("<span class='notice'>[attacker] hand-feeds [food] to [parent].</span>", "<span class='notice'>You hand-feed [food] to [parent].</span>")
	qdel(food)
	if(tame)
		return
	if (prob(tame_chance)) //note: lack of feedback message is deliberate, keep them guessing!
		on_tame(attacker)
	else
		tame_chance += bonus_tame_chance

///Ran once taming succeeds
/datum/component/tameable/proc/on_tame(mob/living/tamer)
	SIGNAL_HANDLER
	tame = TRUE

	if(after_tame) //Run custom behavior if needed
		after_tame.Invoke(tamer)

	if(ishostile(parent) && isliving(tamer)) //Kinda shit check but this only applies to hostiles atm
		friends = tamer
		faction = tamer.faction.Copy()
