/mob/living/simple_animal/hostile/asteroid/elite/pandora/exploration
	name = "Pyxis"
	desc = "A magic box with similar power and design to the Hierophant. Seems unwilling to close."
	maxHealth = 400
	health = 400
	melee_damage = 10
	attack_action_types = list(/datum/action/innate/elite_attack/singular_shot,
								/datum/action/innate/elite_attack/magic_box,
								/datum/action/innate/elite_attack/pandora_teleport)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/OpenFire()
	if(client)
		switch(chosen_attack)
			if(SINGULAR_SHOT)
				singular_shot(target)
			if(MAGIC_BOX)
				magic_box(target)
			if(PANDORA_TELEPORT)
				pandora_teleport(target)
		return
	var/aiattack = rand(1,3)
	switch(aiattack)
		if(SINGULAR_SHOT)
			singular_shot(target)
		if(MAGIC_BOX)
			magic_box(target)
		if(PANDORA_TELEPORT)
			pandora_teleport(target)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/exploration/Life()
	. = ..()
	if(health >= maxHealth * 0.5)
		cooldown_time = 2.5 SECONDS
		return
	if(health < maxHealth * 0.5 && health > maxHealth * 0.25)
		cooldown_time = 2 SECONDS
		return
	else
		cooldown_time = 1.5 SECONDS
