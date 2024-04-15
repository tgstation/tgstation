/datum/skill/athletics
	name = "Athletics"
	title = "Athlete"
	desc = "Twinkle twinkle little star, hit the gym and lift the bar."
	// The skill value modifier effects the max duration that is possible for /datum/status_effect/exercised; The rands modifier determines block probability and crit probability while boxing against boxers
	modifiers = list(
		SKILL_VALUE_MODIFIER = list(
			1 MINUTES, 
			1.5 MINUTES, 
			2 MINUTES, 
			2.5 MINUTES, 
			3 MINUTES, 
			3.5 MINUTES, 
			5 MINUTES
		), 
		SKILL_RANDS_MODIFIER = list(
			0, 
			5, 
			10, 
			15, 
			20, 
			30, 
			50
		)
	)
	
	skill_item_path = /obj/item/clothing/gloves/boxing/golden
