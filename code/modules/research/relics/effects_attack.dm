/datum/relic_effect/attack
	hogged_signals = list(COMSIG_ITEM_ATTACK,COMSIG_ITEM_ATTACK_OBJ)

/datum/relic_effect/attack/apply_to_component(obj/item/A,datum/component/relic/comp)
	comp.RegisterSignal(COMSIG_ITEM_ATTACK, CALLBACK(src, .proc/attack_mob, A))
	comp.RegisterSignal(COMSIG_ITEM_ATTACK_OBJ, CALLBACK(src, .proc/attack_obj, A))

/datum/relic_effect/attack/proc/attack_mob(obj/item/A, mob/living/target, mob/living/user)
	return use_power(A,user)

/datum/relic_effect/attack/proc/attack_obj(obj/item/A, obj/target, mob/user)
	return use_power(A,user)

/datum/relic_effect/attack/repair_robot/attack_mob(obj/item/A, mob/living/target, mob/living/user)
