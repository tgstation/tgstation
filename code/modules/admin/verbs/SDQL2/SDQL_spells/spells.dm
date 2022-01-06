/obj/effect/proc_holder/spell/aimed/sdql
	name = "Aimed SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	projectile_type = /obj/projectile

/obj/effect/proc_holder/spell/aimed/sdql/Initialize(mapload, new_owner, giver)
	. = ..()
	AddComponent(/datum/component/sdql_executor, giver)
	RegisterSignal(src, COMSIG_PROJECTILE_ON_HIT, .proc/on_projectile_hit)

/obj/effect/proc_holder/spell/aimed/sdql/proc/on_projectile_hit(source, firer, target)
	SIGNAL_HANDLER
	var/datum/component/sdql_executor/executor = GetComponent(/datum/component/sdql_executor)
	if(!executor)
		CRASH("[src]'s SDQL executor component went missing!")
	INVOKE_ASYNC(executor, /datum/component/sdql_executor/proc/execute, list(target), owner.resolve())

/obj/effect/proc_holder/spell/aoe_turf/sdql
	name = "AoE SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."

/obj/effect/proc_holder/spell/aoe_turf/sdql/Initialize(mapload, new_owner, giver)
	. = ..()
	AddComponent(/datum/component/sdql_executor, giver)

/obj/effect/proc_holder/spell/aoe_turf/sdql/cast(list/targets, mob/user)
	var/datum/component/sdql_executor/executor = GetComponent(/datum/component/sdql_executor)
	if(!executor)
		CRASH("[src]'s SDQL executor component went missing!")
	executor.execute(targets, user)

/obj/effect/proc_holder/spell/cone/sdql
	name = "Cone SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/list/targets = list()

/obj/effect/proc_holder/spell/cone/sdql/Initialize(mapload, new_owner, giver)
	. = ..()
	AddComponent(/datum/component/sdql_executor, giver)

/obj/effect/proc_holder/spell/cone/sdql/do_mob_cone_effect(mob/living/target_mob, level)
	targets |= target_mob

/obj/effect/proc_holder/spell/cone/sdql/do_obj_cone_effect(obj/target_obj, level)
	targets |= target_obj

/obj/effect/proc_holder/spell/cone/sdql/do_turf_cone_effect(turf/target_turf, level)
	targets |= target_turf

/obj/effect/proc_holder/spell/cone/sdql/cast(list/targets, mob/user)
	. = ..()
	var/datum/component/sdql_executor/executor = GetComponent(/datum/component/sdql_executor)
	if(!executor)
		CRASH("[src]'s SDQL executor component went missing!")
	executor.execute(targets, user)
	targets = list()

/obj/effect/proc_holder/spell/cone/staggered/sdql
	name = "Staggered Cone SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/list/targets = list()

/obj/effect/proc_holder/spell/cone/staggered/sdql/Initialize(mapload, new_owner, giver)
	. = ..()
	AddComponent(/datum/component/sdql_executor, giver)

/obj/effect/proc_holder/spell/cone/staggered/sdql/do_mob_cone_effect(mob/living/target_mob, level)
	targets |= target_mob

/obj/effect/proc_holder/spell/cone/staggered/sdql/do_obj_cone_effect(obj/target_obj, level)
	targets |= target_obj

/obj/effect/proc_holder/spell/cone/staggered/sdql/do_turf_cone_effect(turf/target_turf, level)
	targets |= target_turf

/obj/effect/proc_holder/spell/cone/staggered/sdql/do_cone_effects(list/target_turf_list, level)
	. = ..()
	var/datum/component/sdql_executor/executor = GetComponent(/datum/component/sdql_executor)
	if(!executor)
		CRASH("[src]'s SDQL executor component went missing!")
	executor.execute(target_turf_list, owner.resolve())
	targets = list()

/obj/effect/proc_holder/spell/pointed/sdql
	name = "Pointed SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."

/obj/effect/proc_holder/spell/pointed/sdql/Initialize(mapload, new_owner, giver)
	. = ..()
	AddComponent(/datum/component/sdql_executor, giver)

/obj/effect/proc_holder/spell/pointed/sdql/cast(list/targets, mob/user)
	var/datum/component/sdql_executor/executor = GetComponent(/datum/component/sdql_executor)
	if(!executor)
		CRASH("[src]'s SDQL executor component went missing!")
	executor.execute(targets, user)

/obj/effect/proc_holder/spell/self/sdql
	name = "Self SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."

/obj/effect/proc_holder/spell/self/sdql/Initialize(mapload, new_owner, giver)
	. = ..()
	AddComponent(/datum/component/sdql_executor, giver)

/obj/effect/proc_holder/spell/self/sdql/cast(list/targets, mob/user)
	var/datum/component/sdql_executor/executor = GetComponent(/datum/component/sdql_executor)
	if(!executor)
		CRASH("[src]'s SDQL executor component went missing!")
	executor.execute(targets, user)

/obj/effect/proc_holder/spell/targeted/sdql
	name = "Targeted SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."

/obj/effect/proc_holder/spell/targeted/sdql/Initialize(mapload, new_owner, giver)
	. = ..()
	AddComponent(/datum/component/sdql_executor, giver)

/obj/effect/proc_holder/spell/targeted/sdql/cast(list/targets, mob/user)
	var/datum/component/sdql_executor/executor = GetComponent(/datum/component/sdql_executor)
	if(!executor)
		CRASH("[src]'s SDQL executor component went missing!")
	executor.execute(targets, user)

/obj/effect/proc_holder/spell/targeted/touch/sdql
	name = "Touch SDQL Spell"
	desc = "If you are reading this outside of the \"Give SDQL Spell\" menu, tell the admin that gave this spell to you to use said menu."
	var/list/hand_var_overrides = list() //The touch attack has its vars changed to the ones put in this list.

/obj/effect/proc_holder/spell/targeted/touch/sdql/Initialize(mapload, new_owner, giver)
	. = ..()
	AddComponent(/datum/component/sdql_executor, giver)

/obj/effect/proc_holder/spell/targeted/touch/sdql/ChargeHand(mob/living/carbon/user)
	if(..())
		for(var/V in hand_var_overrides)
			if(attached_hand.vars[V])
				attached_hand.vv_edit_var(V, hand_var_overrides[V])
		RegisterSignal(attached_hand, COMSIG_ITEM_AFTERATTACK, .proc/on_touch_attack)
		user.update_inv_hands()

/obj/effect/proc_holder/spell/targeted/touch/sdql/proc/on_touch_attack(source, target, user)
	SIGNAL_HANDLER
	var/datum/component/sdql_executor/executor = GetComponent(/datum/component/sdql_executor)
	if(!executor)
		CRASH("[src]'s SDQL executor component went missing!")
	INVOKE_ASYNC(executor, /datum/component/sdql_executor/proc/execute, list(target), user)
