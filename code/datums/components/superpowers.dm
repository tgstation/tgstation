/*
	Gives carbon human mobs speedboosts, and a unique weapon for their fists, as well as stun prevention and push prevention
*/

/datum/component/superpowers
	// the speed boost the human mob should have
	var/speedboost
	// if the human mob should be stunnable or not
	var/stuns
	// if the human mob should be pushable or not
	var/pushable
	// the item type that represents the unique weapon the mob uses to attack with their fists
	var/attack_item_type
	// an item type that is spawned when the mob dies, as well as takes away their super powers
	var/stored_item_type
	// self explanatory, no reason to add this if you have a stored item type
	var/remove_on_death

/datum/component/superpowers/Initialize(speedboost=0, stuns=TRUE, pushable=TRUE, attack_item_type, stored_item_type, remove_on_death=FALSE)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/carbon/human/H = parent

	src.speedboost = speedboost
	src.stuns = stuns
	src.pushable = pushable
	src.attack_item_type = attack_item_type
	src.stored_item_type = stored_item_type
	src.remove_on_death = remove_on_death

	if(!stuns)
		ADD_TRAIT(H, TRAIT_STUNIMMUNE, COMPONENT_SUPERPOWERS_TRAIT)

	if(!pushable)
		ADD_TRAIT(H, TRAIT_PUSHIMMUNE, COMPONENT_SUPERPOWERS_TRAIT)

	if(speedboost)
		H.add_movespeed_modifier(MOVESPEED_ID_SUPERPOWER_COMPONENT, update=TRUE, priority=100, multiplicative_slowdown=-1)

/datum/component/superpowers/RegisterWithParent()
	if(attack_item_type)
		RegisterSignal(parent, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/on_attack_hand)
	if(stored_item_type)
		RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/on_parent_death)

/datum/component/superpowers/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HUMAN_EARLY_UNARMED_ATTACK, COMSIG_MOB_DEATH))

/*
	Interrupts the hand attack and replaces it with the weapon if the user is on harm intent and attacking something that isn't an item
*/
/datum/component/superpowers/proc/on_attack_hand(mob/living/carbon/human/attacker, atom/attacked, proximity)
	if(attacker.a_intent == INTENT_HARM)
		if(isobj(attacked) && !isitem(attacked) || ismob(attacked))
			// generate an item to attack the thing with our parameters and cancel the attack
			var/obj/item/I = new attack_item_type(attacker)
			I.melee_attack_chain(attacker, attacked)
			qdel(I)
			return COMPONENT_NO_ATTACK_HAND

/*
	Removes the superpowers on the parent mobs death and spawns the stored item type
*/
/datum/component/superpowers/proc/on_parent_death(mob/living/carbon/human/H, gibbed)
	if(stored_item_type)
		new stored_item_type(H.loc)
	if(stored_item_type || remove_on_death)
		REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, COMPONENT_SUPERPOWERS_TRAIT)
		REMOVE_TRAIT(H, TRAIT_PUSHIMMUNE, COMPONENT_SUPERPOWERS_TRAIT)
		H.remove_movespeed_modifier(MOVESPEED_ID_SUPERPOWER_COMPONENT, update = TRUE)
		_RemoveFromParent()