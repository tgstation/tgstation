/mob/living/carbon/death(gibbed)
	var/policy = get_policy(POLICY_DEATH)
	if(policy)
		to_chat(src, policy, avoid_highlighting = TRUE)
	return ..()

/mob/living/carbon/revive(full_heal_flags, excess_healing, force_grab_ghost)
	var/old_stat = stat
	. = ..()
	if(old_stat == DEAD)
		var/policy = get_policy(POLICY_REVIVAL)
		if(policy)
			to_chat(src, policy, avoid_highlighting = TRUE)
