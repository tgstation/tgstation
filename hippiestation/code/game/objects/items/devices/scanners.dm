/obj/item/device/slime_scanner/afterattack(atom/target, mob/living/user, flag, params)
	if(flag)
		return
	if(user.stat || user.eye_blind)
		return
	if (!isslime(M))
		to_chat(user, "<span class='warning'>This device can only scan slimes!</span>")
		return
	var/mob/living/simple_animal/slime/T = M
	to_chat(user, "Slime scan results:")
	to_chat(user, "[T.colour] [T.is_adult ? "adult" : "baby"] slime")
	to_chat(user, "Nutrition: [T.nutrition]/[T.get_max_nutrition()]")
	if (T.nutrition < T.get_starve_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is starving!</span>")
	else if (T.nutrition < T.get_hunger_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is hungry</span>")
	to_chat(user, "Electric change strength: [T.powerlevel]")
	to_chat(user, "Health: [round(T.health/T.maxHealth,0.01)*100]")
	if (T.slime_mutation[4] == T.colour)
		to_chat(user, "This slime does not evolve any further.")
	else
		if (T.slime_mutation[3] == T.slime_mutation[4])
			if (T.slime_mutation[2] == T.slime_mutation[1])
				to_chat(user, "Possible mutation: [T.slime_mutation[3]]")
				to_chat(user, "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting")
			else
				to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)")
				to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
		else
			to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]")
			to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
	if (T.cores > 1)
		to_chat(user, "Anomalious slime core amount detected")
	to_chat(user, "Growth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")
