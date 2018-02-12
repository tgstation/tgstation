/datum/relic_effect/attack
	hogged_signals = list(COMSIG_ITEM_ATTACK,COMSIG_ITEM_ATTACK_OBJ)

/datum/relic_effect/attack/apply_to_component(obj/item/A,datum/component/relic/comp)
	if(COMSIG_ITEM_ATTACK in hogged_signals)
		comp.RegisterSignal(COMSIG_ITEM_ATTACK, CALLBACK(src, .proc/attack_mob, A))
	if(COMSIG_ITEM_ATTACK_OBJ in hogged_signals)
		comp.RegisterSignal(COMSIG_ITEM_ATTACK_OBJ, CALLBACK(src, .proc/attack_obj, A))

/datum/relic_effect/attack/proc/attack_mob(obj/item/A, mob/living/target, mob/living/user)
	return use_power(A,user)

/datum/relic_effect/attack/proc/attack_obj(obj/item/A, obj/target, mob/user)
	return use_power(A,user)

/datum/relic_effect/attack/repair_robot/attack_mob(obj/item/A, mob/living/target, mob/living/user)
	if(user.a_intent != INTENT_HELP || !..())
		return

/datum/relic_effect/attack/activate
	var/datum/relic_effect/activate/internal

/datum/relic_effect/attack/activate/apply()
	internal = pick(subtypesof(/datum/relic_effect/activate))
	internal.free = TRUE

/datum/relic_effect/attack/activate/attack_mob(obj/item/A, mob/living/target, mob/living/user)
	internal.activate(A,target,user)

/datum/relic_effect/attack/activate/attack_obj(obj/item/A, obj/target, mob/living/user)
	internal.activate(A,target,user)