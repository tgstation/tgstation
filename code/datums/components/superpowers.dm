/datum/component/superpowers
	var/speedboost
	var/stuns
	var/pushable
	var/attack_item_type // item type is created to attack the enemy with when the user attacks with their hands on harm intent
	var/stored_item_type // stored item type that is created after parent death and removes powers

/datum/component/superpowers/Initialize(speedboost=0, stuns=TRUE, pushable=TRUE, attack_item_type, stored_item_type)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/carbon/human/H = parent

	src.speedboost = speedboost
	src.stuns = stuns
	src.pushable = pushable
	src.attack_item_type = attack_item_type
	src.stored_item_type = stored_item_type

	if(!stuns)
		ADD_TRAIT(H, TRAIT_STUNIMMUNE, COMPONENT_SUPERPOWERS_TRAIT)

	if(!pushable)
		ADD_TRAIT(H, TRAIT_PUSHIMMUNE, COMPONENT_SUPERPOWERS_TRAIT)

	if(speedboost)
		H.add_movespeed_modifier(MOVESPEED_ID_SUPERPOWER_COMPONENT, update=TRUE, priority=100, multiplicative_slowdown=-1)

/datum/component/superpowers/RegisterWithParent()
	if(attack_item_type)
		RegisterSignal(parent, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/on_attack_hand)
	if(stored_item_type)
		RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/on_parent_death)

/datum/component/superpowers/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_MOB_DEATH))

/datum/component/superpowers/proc/on_attack_hand(mob/living/carbon/human/attacker, atom/attacked, proximity)
	if(attacker.a_intent == INTENT_HARM)
		if(isobj(attacked) && !isitem(attacked))
			// generate an item to attack the thing with our parameters and cancel the attack
			var/obj/item/I = new attack_item_type()
			I.melee_attack_chain(attacker, attacked)
			qdel(I)
			return COMPONENT_HUMAN_MELEE_UNARMED_NO_ATTACK

/datum/component/superpowers/proc/on_parent_death(mob/living/carbon/human/H, gibbed)
	if(stored_item_type)
		new stored_item_type(H.loc)
		REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, TRAIT_HULK)
		REMOVE_TRAIT(H, TRAIT_PUSHIMMUNE, TRAIT_HULK)
		H.remove_movespeed_modifier(MOVESPEED_ID_SUPERPOWER_COMPONENT, update = TRUE)
		_RemoveFromParent()