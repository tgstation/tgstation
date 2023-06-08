/mob/living/simple_animal/slime/proc/mutation_table(colour)
	var/list/slime_mutation_colors[4]
	switch(colour)
		//Tier 1
		if("grey")
			slime_mutation_colors[1] = "orange"
			slime_mutation_colors[2] = "metal"
			slime_mutation_colors[3] = "blue"
			slime_mutation_colors[4] = "purple"
		//Tier 2
		if("purple")
			slime_mutation_colors[1] = "dark purple"
			slime_mutation_colors[2] = "dark blue"
			slime_mutation_colors[3] = "green"
			slime_mutation_colors[4] = "green"
		if("metal")
			slime_mutation_colors[1] = "silver"
			slime_mutation_colors[2] = "yellow"
			slime_mutation_colors[3] = "gold"
			slime_mutation_colors[4] = "gold"
		if("orange")
			slime_mutation_colors[1] = "dark purple"
			slime_mutation_colors[2] = "yellow"
			slime_mutation_colors[3] = "red"
			slime_mutation_colors[4] = "red"
		if("blue")
			slime_mutation_colors[1] = "dark blue"
			slime_mutation_colors[2] = "silver"
			slime_mutation_colors[3] = "pink"
			slime_mutation_colors[4] = "pink"
		//Tier 3
		if("dark blue")
			slime_mutation_colors[1] = "purple"
			slime_mutation_colors[2] = "blue"
			slime_mutation_colors[3] = "cerulean"
			slime_mutation_colors[4] = "cerulean"
		if("dark purple")
			slime_mutation_colors[1] = "purple"
			slime_mutation_colors[2] = "orange"
			slime_mutation_colors[3] = "sepia"
			slime_mutation_colors[4] = "sepia"
		if("yellow")
			slime_mutation_colors[1] = "metal"
			slime_mutation_colors[2] = "orange"
			slime_mutation_colors[3] = "bluespace"
			slime_mutation_colors[4] = "bluespace"
		if("silver")
			slime_mutation_colors[1] = "metal"
			slime_mutation_colors[2] = "blue"
			slime_mutation_colors[3] = "pyrite"
			slime_mutation_colors[4] = "pyrite"
		//Tier 4
		if("pink")
			slime_mutation_colors[1] = "pink"
			slime_mutation_colors[2] = "pink"
			slime_mutation_colors[3] = "light pink"
			slime_mutation_colors[4] = "light pink"
		if("red")
			slime_mutation_colors[1] = "red"
			slime_mutation_colors[2] = "red"
			slime_mutation_colors[3] = "oil"
			slime_mutation_colors[4] = "oil"
		if("gold")
			slime_mutation_colors[1] = "gold"
			slime_mutation_colors[2] = "gold"
			slime_mutation_colors[3] = "adamantine"
			slime_mutation_colors[4] = "adamantine"
		if("green")
			slime_mutation_colors[1] = "green"
			slime_mutation_colors[2] = "green"
			slime_mutation_colors[3] = "black"
			slime_mutation_colors[4] = "black"
		// Tier 5
		else
			slime_mutation_colors[1] = colour
			slime_mutation_colors[2] = colour
			slime_mutation_colors[3] = colour
			slime_mutation_colors[4] = colour
	return(slime_mutation_colors)
