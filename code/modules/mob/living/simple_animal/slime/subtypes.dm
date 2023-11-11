/mob/living/simple_animal/slime/proc/mutation_table(colour)
	var/list/slime_mutation_colors[4]
	switch(colour)
		//Tier 1
		if(SLIME_TYPE_GREY)
			slime_mutation_colors[1] = SLIME_TYPE_ORANGE
			slime_mutation_colors[2] = SLIME_TYPE_METAL
			slime_mutation_colors[3] = SLIME_TYPE_BLUE
			slime_mutation_colors[4] = SLIME_TYPE_PURPLE
		//Tier 2
		if(SLIME_TYPE_PURPLE)
			slime_mutation_colors[1] = SLIME_TYPE_DARK_PURPLE
			slime_mutation_colors[2] = SLIME_TYPE_DARK_BLUE
			slime_mutation_colors[3] = SLIME_TYPE_GREEN
			slime_mutation_colors[4] = SLIME_TYPE_GREEN
		if(SLIME_TYPE_METAL)
			slime_mutation_colors[1] = SLIME_TYPE_SILVER
			slime_mutation_colors[2] = SLIME_TYPE_YELLOW
			slime_mutation_colors[3] = SLIME_TYPE_GOLD
			slime_mutation_colors[4] = SLIME_TYPE_GOLD
		if(SLIME_TYPE_ORANGE)
			slime_mutation_colors[1] = SLIME_TYPE_DARK_PURPLE
			slime_mutation_colors[2] = SLIME_TYPE_YELLOW
			slime_mutation_colors[3] = SLIME_TYPE_RED
			slime_mutation_colors[4] = SLIME_TYPE_RED
		if(SLIME_TYPE_BLUE)
			slime_mutation_colors[1] = SLIME_TYPE_DARK_BLUE
			slime_mutation_colors[2] = SLIME_TYPE_SILVER
			slime_mutation_colors[3] = SLIME_TYPE_PINK
			slime_mutation_colors[4] = SLIME_TYPE_PINK
		//Tier 3
		if(SLIME_TYPE_DARK_BLUE)
			slime_mutation_colors[1] = SLIME_TYPE_PURPLE
			slime_mutation_colors[2] = SLIME_TYPE_BLUE
			slime_mutation_colors[3] = SLIME_TYPE_CERULEAN
			slime_mutation_colors[4] = SLIME_TYPE_CERULEAN
		if(SLIME_TYPE_DARK_PURPLE)
			slime_mutation_colors[1] = SLIME_TYPE_PURPLE
			slime_mutation_colors[2] = SLIME_TYPE_ORANGE
			slime_mutation_colors[3] = SLIME_TYPE_SEPIA
			slime_mutation_colors[4] = SLIME_TYPE_SEPIA
		if(SLIME_TYPE_YELLOW)
			slime_mutation_colors[1] = SLIME_TYPE_METAL
			slime_mutation_colors[2] = SLIME_TYPE_ORANGE
			slime_mutation_colors[3] = SLIME_TYPE_BLUESPACE
			slime_mutation_colors[4] = SLIME_TYPE_BLUESPACE
		if(SLIME_TYPE_SILVER)
			slime_mutation_colors[1] = SLIME_TYPE_METAL
			slime_mutation_colors[2] = SLIME_TYPE_BLUE
			slime_mutation_colors[3] = SLIME_TYPE_PYRITE
			slime_mutation_colors[4] = SLIME_TYPE_PYRITE
		//Tier 4
		if(SLIME_TYPE_PINK)
			slime_mutation_colors[1] = SLIME_TYPE_PINK
			slime_mutation_colors[2] = SLIME_TYPE_PINK
			slime_mutation_colors[3] = SLIME_TYPE_LIGHT_PINK
			slime_mutation_colors[4] = SLIME_TYPE_LIGHT_PINK
		if(SLIME_TYPE_RED)
			slime_mutation_colors[1] = SLIME_TYPE_RED
			slime_mutation_colors[2] = SLIME_TYPE_RED
			slime_mutation_colors[3] = SLIME_TYPE_OIL
			slime_mutation_colors[4] = SLIME_TYPE_OIL
		if(SLIME_TYPE_GOLD)
			slime_mutation_colors[1] = SLIME_TYPE_GOLD
			slime_mutation_colors[2] = SLIME_TYPE_GOLD
			slime_mutation_colors[3] = SLIME_TYPE_ADAMANTINE
			slime_mutation_colors[4] = SLIME_TYPE_ADAMANTINE
		if(SLIME_TYPE_GREEN)
			slime_mutation_colors[1] = SLIME_TYPE_GREEN
			slime_mutation_colors[2] = SLIME_TYPE_GREEN
			slime_mutation_colors[3] = SLIME_TYPE_BLACK
			slime_mutation_colors[4] = SLIME_TYPE_BLACK
		// Tier 5
		else
			slime_mutation_colors[1] = colour
			slime_mutation_colors[2] = colour
			slime_mutation_colors[3] = colour
			slime_mutation_colors[4] = colour
	return(slime_mutation_colors)
