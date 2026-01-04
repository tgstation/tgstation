/// heals slightly on melee hits
/mob/living/basic/boss/blood_drunk_miner/guidance

/mob/living/basic/boss/blood_drunk_miner/guidance/attack_override
	. = ..()
	adjust_health(-2)

/// Better at dash attacking
/mob/living/basic/boss/blood_durnk_miner/hunter

/mob/living/basic/boss/blood_drunk_miner/hunter/attack_override(mob/living/source, atom/target, proximity, modifiers)
	. = ..()
	if(. & COMPONENT_HOSTILE_NO_ATTACK)
		return .

	if(prob(12))
		var/dash_attack = get_ability_from_blackboard(BB_BDM_DASH_ATTACK_ABILITY)
		if(!isnull(dash_attack))
			INVOKE_ASYNC(dash_attack, TYPE_PROC_REF(/datum/action, Trigger), src, NONE, target)

/mob/living/basic/boss/blood_drunk_miner/doom
	name = "hostile-environment miner"
	desc = "A miner destined to hop across dimensions for all eternity, hunting anomalous creatures."
	speed = 8
	ranged_attack_cooldown_duration = 0.8 SECONDS
	ai_controller = /datum/ai_controller/blood_drunk_miner/doom

/mob/living/basic/boss/blood_drunk_miner/doom/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/dash_ability = get_ability_from_blackboard(BB_BDM_DASH_ABILITY)
	if(!isnull(dash_ability))
		dash_ability.cooldown_time = 0.8 SECONDS
