/mob/living/carbon
	/// How many food buffs we have at once
	var/applied_food_buffs = 0
	//Max amount of food buffs
	var/max_food_buffs = 2

/mob/living
	///Is this carbon trying to sprint?
	var/sprint_key_down = FALSE
	var/sprinting = FALSE
	///How many tiles we have continuously moved in the same direction
	var/sustained_moves = 0
