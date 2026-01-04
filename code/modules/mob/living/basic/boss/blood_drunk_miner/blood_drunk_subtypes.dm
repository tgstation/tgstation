/mob/living/basic/boss/blood_drunk_miner/guidance
	guidance = TRUE

/mob/living/basic/boss/blood_durnk_miner/hunter

/mob/living/basic/boss/blood_drunk_miner/hunter/AttackingTarget(atom/attacked_target)
	. = ..()
	if(. && prob(12))
		INVOKE_ASYNC(dash, TYPE_PROC_REF(/datum/action, Trigger), src, NONE, target)

/mob/living/basic/boss/blood_drunk_miner/doom
	name = "hostile-environment miner"
	desc = "A miner destined to hop across dimensions for all eternity, hunting anomalous creatures."
	speed = 8
	move_to_delay = 8
	ranged_cooldown_time = 0.8 SECONDS

/mob/living/basic/boss/blood_drunk_miner/doom/Initialize(mapload)
	. = ..()
	dash.cooldown_time = 0.8 SECONDS
